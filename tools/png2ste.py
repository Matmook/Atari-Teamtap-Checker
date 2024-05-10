"""
    png to ST
    by Matmook (matthieu@barreteau.org)
"""
import os
import sys
from PIL import Image, ImageChops

def get_ste_pal(r,g,b):
    color = r<<16 |g<<8 | b
    r = (color>>20 & 0xF)
    g = (color>>12 & 0xF)
    b = (color>>4 & 0xF)

    r = ((r>>1)&0x7)|((r&0x1)<<3)
    g = ((g>>1)&0x7)|((g&0x1)<<3)
    b = ((b>>1)&0x7)|((b&0x1)<<3)

    color =  r<<8|g<<4|b
    return color

def set_bitplans( bitplans,color_index, bit):
    if color_index & 0x01:
        bitplans[0] = bitplans[0] | (1 << (15-bit))
    if color_index & 0x02:
        bitplans[1] = bitplans[1] | (1 << (15-bit))
    if color_index & 0x04:
        bitplans[2] = bitplans[2] | (1 << (15-bit))
    if color_index & 0x08:
        bitplans[3] = bitplans[3] | (1 << (15-bit))

    return bitplans
    
# main function  
def main(argv):

    ref_image = "source\\background.png"
    # ref_image = "source\\jagpad_mini_16.png"
    ims = Image.open( ref_image )
    full_width, full_height = ims.size

    width = 48
    height = 40
    width = full_width
    height = full_height

    palette = []
    
    for y in range(0,height):
        for x in range(0,width):
            r,g,b,_ = ims.getpixel((x,y))
            c = get_ste_pal(r,g,b)
            if not c in palette:
                palette.append(c)

    pixmap = bytearray((width*height)//2)

    for y in range(0,height):
        offset_l = y * width // 2       # in bytes
        for x in range(0,width,16):
            offset_w = x//2          # in nibbles
            offset_r = offset_l + offset_w

            bp16 = [0,0,0,0]

            for bit_num in range(0,16):
                r,g,b,_ = ims.getpixel((x+bit_num,y))
                c = get_ste_pal(r,g,b)
                color_index = palette.index(c)
                
                bp16 = set_bitplans(bp16, color_index, bit_num)                

            pixmap[offset_r+0] = (bp16[0]>>8) & 0xFF
            pixmap[offset_r+1] = (bp16[0]>>0) & 0xFF
            pixmap[offset_r+2] = (bp16[1]>>8) & 0xFF
            pixmap[offset_r+3] = (bp16[1]>>0) & 0xFF
            pixmap[offset_r+4] = (bp16[2]>>8) & 0xFF
            pixmap[offset_r+5] = (bp16[2]>>0) & 0xFF
            pixmap[offset_r+6] = (bp16[3]>>8) & 0xFF
            pixmap[offset_r+7] = (bp16[3]>>0) & 0xFF

    mask_list = [
        ["up",      (0,7,16,2),[(0,46)]],
        ["down",    (0,14,16,2),[(0,48)]],
        ["right",   (0,10,16,3),[(0,43)]],
        ["left",    (0,10,16,3),[(0,40)]],
        ["pause",   (16,14,16,3),[(0,50)]],
        ["option",  (16,14,16,3),[(0,53)]],
        ["numl",    (16,28,16,1),[(0,71)]],
        ["numm",    (16,28,16,1),[(0,72)]],
        ["numr",    (16,28,16,1),[(0,73)]],
        ["buta",    (16,7,32,5),[(0,56)]],
        ["butb",    (16,10,32,5),[(0,61)]],
        ["butc",    (16,13,32,5),[(0,66)]],
    ]

    for name, comp_source, comp_list in mask_list:
        x,y,w,h = comp_source

        if w != 16 and w != 32:
            print("Width is 16 or 32!!")
            sys.exit()
        n16 = w//16
            
        img_comp_source = ims.crop((x,y,x+w,y+h))        
        
        for acomp in comp_list:
            x,y = acomp
            img_comp_test = ims.crop((x,y,x+w,y+h))

            diff = ImageChops.difference(img_comp_source, img_comp_test)            
                        
            # create masks
            mask_off = f"{name}_off:\n"
            mask_on = f"{name}_on:\n"

            for y in range(0,h):
                mask = [0,0]
                bp16_off = [[0,0,0,0],[0,0,0,0]]
                bp16_on = [[0,0,0,0],[0,0,0,0]]

                for nx in range(0,n16):
                    for x in range(0,16):
                        # cleaning mask
                        r,g,b,_ = diff.getpixel((x+(nx*16),y))                   
                        filled = r+g+b
                        
                        mask[nx] = mask[nx] << 1
                        if not filled:
                            mask[nx] |= 1
                        else:
                            # unset mask                        
                            r,g,b,_ = img_comp_source.getpixel((x+(nx*16),y))   
                            c = get_ste_pal(r,g,b)
                            color_index = palette.index(c)                        
                            bp16_off[nx] = set_bitplans(bp16_off[nx], color_index, x)

                            # set mask                        
                            r,g,b,_ = img_comp_test.getpixel((x+(nx*16),y))   
                            c = get_ste_pal(r,g,b)
                            color_index = palette.index(c)                        
                            bp16_on[nx] = set_bitplans(bp16_on[nx], color_index, x) 

                # load memory
                mask_off = mask_off+f"\tmovem.l (a0),d0-d{(n16*2)-1}\n"
                mask_on = mask_on+f"\tmovem.l (a0),d0-d{(n16*2)-1}\n"

                for nn in range(0,n16):
                    # create holes
                    mask_txt = format( mask[nn] & 0xFFFF, "04X")+format( mask[nn] & 0xFFFF, "04X")
                    mask_off = mask_off+"\tandi.l\t#$"+mask_txt +   f",d{(nn*2)+0}\n"
                    mask_off = mask_off+"\tandi.l\t#$"+mask_txt +   f",d{(nn*2)+1}\n"
                    mask_on = mask_on+"\tandi.l\t#$"+mask_txt +     f",d{(nn*2)+0}\n"
                    mask_on = mask_on+"\tandi.l\t#$"+mask_txt +     f",d{(nn*2)+1}\n"

                for nn in range(0,n16):
                    # fill holes
                    filler_off = format( bp16_off[nn][0] & 0xFFFF, "04X")+format( bp16_off[nn][1] & 0xFFFF, "04X")                
                    mask_off = mask_off+"\tori.l\t#$"+filler_off+f",d{(nn*2)+0}\n"
                    filler_off = format( bp16_off[nn][2] & 0xFFFF, "04X")+format( bp16_off[nn][3] & 0xFFFF, "04X")                
                    mask_off = mask_off+"\tori.l\t#$"+filler_off+f",d{(nn*2)+1}\n"

                    filler_on = format( bp16_on[nn][0] & 0xFFFF, "04X")+format( bp16_on[nn][1] & 0xFFFF, "04X")                
                    mask_on = mask_on+"\tori.l\t#$"+filler_on+f",d{(nn*2)+0}\n"
                    filler_on = format( bp16_on[nn][2] & 0xFFFF, "04X")+format( bp16_on[nn][3] & 0xFFFF, "04X")                
                    mask_on = mask_on+"\tori.l\t#$"+filler_on+f",d{(nn*2)+1}\n"

                # update memory
                mask_off = mask_off+f"\tmovem.l d0-d{(n16*2)-1},(a0)\n"
                mask_on = mask_on+f"\tmovem.l d0-d{(n16*2)-1},(a0)\n"

                if h > 1 and y != (h-1):
                    mask_off = mask_off+f"\tlea 160(a0),a0\n"
                    mask_on = mask_on+"\tlea 160(a0),a0\n"
            mask_off = mask_off+"\trts\n"
            mask_on = mask_on+"\trts\n"

            if len(argv):
                print(mask_off)
                print(mask_on)                
    
    if len(argv):
        print("\n; EOF")
        sys.exit()

    # assembly code/data generation
    text = ""
    text = text + "\t.long\n"
    text = text + "palette:\n"
    text = text + "\t.dc.w\t"
    for color in palette:
        text = text + "$"+format( color & 0xFFFF, "04X")+","
    text = text[:-1]+"\n\n"

    cpt = 0
    text = text + "\t.long\nbitmap:\n"
    for abyte in pixmap:
        if cpt == 0:
            text = text + "\t.dc.b\t"
            
        text = text + "$"+format( abyte & 0xFF, "02X")+","

        cpt = cpt + 1
        if cpt == (width//2):
            text = text[:-1]+"\n"
            cpt = 0

    if cpt != 0:
        text = text[:-1]+"\n"

    print(text)

# entry point
current_script = os.path.basename(__file__)
if __name__ == "__main__":
    main(sys.argv[1:])
