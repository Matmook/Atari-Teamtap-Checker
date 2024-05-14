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

            if x >=288 and y >= 59:
                pass
            elif x < 32 and (y >= 50 and y <=148):
                pass
            else:
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
        ["c", "d0",     (16,  163,16,7),        [(304,59+0*7)]],
        ["c", "d1",     (16,  163,16,7),        [(304,59+1*7)]],
        ["c", "d2",     (16,  163,16,7),        [(304,59+2*7)]],
        ["c", "d3",     (16,  163,16,7),        [(304,59+3*7)]],
        ["c", "d4",     (16,  163,16,7),        [(304,59+4*7)]],
        ["c", "d5",     (16,  163,16,7),        [(304,59+5*7)]],
        ["c", "d6",     (16,  163,16,7),        [(304,59+6*7)]],
        ["c", "d7",     (16,  163,16,7),        [(304,59+7*7)]],
        ["c", "d8",     (16,  163,16,7),        [(304,59+8*7)]],

        ["u", "abc0",   (0,  138,32,11),       [(0,50+0*11)]],
        ["u", "abc1",   (0,  138,32,11),       [(0,50+1*11)]],
        ["u", "abc2",   (0,  138,32,11),       [(0,50+2*11)]],
        ["u", "abc3",   (0,  138,32,11),       [(0,50+3*11)]],
        ["u", "abc4",   (0,  138,32,11),       [(0,50+4*11)]],
        ["u", "abc5",   (0,  138,32,11),       [(0,50+5*11)]],
        ["u", "abc6",   (0,  138,32,11),       [(0,50+6*11)]],
        ["u", "abc7",   (0,  138,32,11),       [(0,50+7*11)]],

        ["u", "po0",    (304, 122,16,3),        [(304,125)]],
        ["u", "po1",    (304, 122,16,3),        [(304,128)]],
        ["u", "po2",    (304, 122,16,3),        [(304,131)]],
        ["u", "po3",    (304, 122,16,3),        [(304,134)]],
        
        ["c", "n0",     (304, 153,16,1),        [(304,154+0)]],
        ["c", "n1",     (304, 153,16,1),        [(304,154+1)]],
        ["c", "n2",     (304, 153,16,1),        [(304,154+2)]],
        ["c", "n3",     (304, 153,16,1),        [(304,154+3)]],
        ["c", "n4",     (304, 153,16,1),        [(304,154+4)]],
        ["c", "n5",     (304, 153,16,1),        [(304,154+5)]],
        ["c", "n6",     (304, 153,16,1),        [(304,154+6)]],
        ["c", "n7",     (304, 153,16,1),        [(304,154+7)]],

        ["ud", "notap",   (96, 74,16,16),       [(304,137)]],
        ["ud", "notpad",  (64, 120,16,16),      [(304,137)]],
    ]

    for mode,name, comp_source, comp_list in mask_list:
        x,y,w,h = comp_source

        if w != 16 and w != 32:
            print("Width is 16 or 32!!")
            sys.exit()
        n16 = w//16
            
        img_comp_source = ims.crop((x,y,x+w,y+h))        
        
        for acomp in comp_list:
            xcomp,ycomp = acomp
            img_comp_test = ims.crop((xcomp,ycomp,xcomp+w,ycomp+h))
            # img_comp_test.show()
            diff = ImageChops.difference(img_comp_source, img_comp_test)  
            # print(xcomp,ycomp)
            # diff.show()          
                        
            # create masks
            mask_delete = f"{name}_delete:\n"
            mask_update = f"{name}_update:\n"
            copy = f"{name}_copy:\n"

            for y in range(0,h):
                mask = [0,0]
                bp16_off = [[0,0,0,0],[0,0,0,0]]
                bp16_on = [[0,0,0,0],[0,0,0,0]]
                bp16_copy = [[0,0,0,0],[0,0,0,0]]

                for nx in range(0,n16):
                    for x in range(0,16):
                        # copy mask
                        r,g,b,_ = img_comp_test.getpixel((x+(nx*16),y))   
                        c = get_ste_pal(r,g,b)
                        color_index = palette.index(c)                        
                        bp16_copy[nx] = set_bitplans(bp16_copy[nx], color_index, x)

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
                mask_delete = mask_delete+f"\tmovem.l (a0),d0-d{(n16*2)-1}\n"
                mask_update = mask_update+f"\tmovem.l (a0),d0-d{(n16*2)-1}\n"

                for nn in range(0,n16):
                    # create copy
                    filler_copy = format( bp16_copy[nn][0] & 0xFFFF, "04X")+format( bp16_copy[nn][1] & 0xFFFF, "04X")                
                    copy = copy+"\tmove.l\t#$"+filler_copy+",(a0)+\n"
                    filler_copy = format( bp16_copy[nn][2] & 0xFFFF, "04X")+format( bp16_copy[nn][3] & 0xFFFF, "04X")                
                    copy = copy+"\tmove.l\t#$"+filler_copy+",(a0)+\n"

                    # create holes
                    mask_txt = format( mask[nn] & 0xFFFF, "04X")+format( mask[nn] & 0xFFFF, "04X")
                    mask_delete = mask_delete+"\tandi.l\t#$"+mask_txt +   f",d{(nn*2)+0}\n"
                    mask_delete = mask_delete+"\tandi.l\t#$"+mask_txt +   f",d{(nn*2)+1}\n"
                    mask_update = mask_update+"\tandi.l\t#$"+mask_txt +     f",d{(nn*2)+0}\n"
                    mask_update = mask_update+"\tandi.l\t#$"+mask_txt +     f",d{(nn*2)+1}\n"

                    # fill holes
                    filler_off = format( bp16_off[nn][0] & 0xFFFF, "04X")+format( bp16_off[nn][1] & 0xFFFF, "04X")                
                    mask_delete = mask_delete+"\tori.l\t#$"+filler_off+f",d{(nn*2)+0}\n"
                    filler_off = format( bp16_off[nn][2] & 0xFFFF, "04X")+format( bp16_off[nn][3] & 0xFFFF, "04X")                
                    mask_delete = mask_delete+"\tori.l\t#$"+filler_off+f",d{(nn*2)+1}\n"

                    filler_on = format( bp16_on[nn][0] & 0xFFFF, "04X")+format( bp16_on[nn][1] & 0xFFFF, "04X")                
                    mask_update = mask_update+"\tori.l\t#$"+filler_on+f",d{(nn*2)+0}\n"                    
                    filler_on = format( bp16_on[nn][2] & 0xFFFF, "04X")+format( bp16_on[nn][3] & 0xFFFF, "04X")                
                    mask_update = mask_update+"\tori.l\t#$"+filler_on+f",d{(nn*2)+1}\n"

                # update memory
                mask_delete = mask_delete+f"\tmovem.l\td0-d{(n16*2)-1},(a0)\n"
                mask_update = mask_update+f"\tmovem.l\td0-d{(n16*2)-1},(a0)\n"

                if h > 1 and y != (h-1):
                    mask_delete = mask_delete+f"\tlea\t160(a0),a0\n"
                    mask_update = mask_update+"\tlea\t160(a0),a0\n"
                    copy = copy+f"\tlea\t{160-(n16*2*4)}(a0),a0\n"

            mask_delete = mask_delete+"\trts\n"
            mask_update = mask_update+"\trts\n"
            copy = copy+"\trts\n"

            if len(argv):
                if "c" in mode:
                    print(copy)
                if "u" in mode:
                    print(mask_update)
                if "d" in mode:
                    print(mask_delete)
    
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
