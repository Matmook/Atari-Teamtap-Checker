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

    ref_image = "source\\gfx\\background.png"
    ims = Image.open( ref_image )
    if ims.mode != "P":
        print("Indexed palette image only!")
        sys.exit()

    mask_list = [
        ["c", "d0",     (16,  163,16,7),        [(48,0*7)]],
        ["c", "d1",     (16,  163,16,7),        [(48,1*7)]],
        ["c", "d2",     (16,  163,16,7),        [(48,2*7)]],
        ["c", "d3",     (16,  163,16,7),        [(48,3*7)]],
        ["c", "d4",     (16,  163,16,7),        [(48,4*7)]],
        ["c", "d5",     (16,  163,16,7),        [(48,5*7)]],
        ["c", "d6",     (16,  163,16,7),        [(48,6*7)]],
        ["c", "d7",     (16,  163,16,7),        [(48,7*7)]],
        ["c", "d8",     (16,  163,16,7),        [(48,8*7)]],

        ["u", "abc0",   (0,  88,32,11),        [(0,0*11)]],
        ["u", "abc1",   (0,  88,32,11),        [(0,1*11)]],
        ["u", "abc2",   (0,  88,32,11),        [(0,2*11)]],
        ["u", "abc3",   (0,  88,32,11),        [(0,3*11)]],
        ["u", "abc4",   (0,  88,32,11),        [(0,4*11)]],
        ["u", "abc5",   (0,  88,32,11),        [(0,5*11)]],
        ["u", "abc6",   (0,  88,32,11),        [(0,6*11)]],
        ["u", "abc7",   (0,  88,32,11),        [(0,7*11)]],

        ["u", "po0",    (48, 63,16,3),         [(48,66)]],
        ["u", "po1",    (48, 63,16,3),         [(48,69)]],
        ["u", "po2",    (48, 63,16,3),         [(48,72)]],
        ["u", "po3",    (48, 63,16,3),         [(48,75)]],
        
        ["c", "n0",     (48, 94,16,1),        [(48,95+0)]],
        ["c", "n1",     (48, 94,16,1),        [(48,95+1)]],
        ["c", "n2",     (48, 94,16,1),        [(48,95+2)]],
        ["c", "n3",     (48, 94,16,1),        [(48,95+3)]],
        ["c", "n4",     (48, 94,16,1),        [(48,95+4)]],
        ["c", "n5",     (48, 94,16,1),        [(48,95+5)]],
        ["c", "n6",     (48, 94,16,1),        [(48,95+6)]],
        ["c", "n7",     (48, 94,16,1),        [(48,95+7)]],

        ["ud", "notap",   (96, 74,16,16),       [(48,78)]],
        ["ud", "notpad",  (64, 120,16,16),      [(48,78)]],
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
            
            # create mask (ImageChops.difference does not work on indexed pictures)
            diff = img_comp_source.copy()  # easy way to create the same picture type
            for y in range(0,h):
                for x in range(0,w):
                    col1 = img_comp_test.getpixel((x,y))
                    col2 = img_comp_source.getpixel((x,y))
                    if col1 == col2:
                        diff.putpixel((x,y),1)
                    else:
                        diff.putpixel((x,y),0)

            # if name.startswith("abc0"):                
            #     diff.show()                 
                        
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
                        color_index = img_comp_test.getpixel((x+(nx*16),y))   
                        bp16_copy[nx] = set_bitplans(bp16_copy[nx], color_index, x)

                        # cleaning mask
                        mask[nx] = mask[nx] << 1
                        is_masked = diff.getpixel((x+(nx*16),y))                        
                        if is_masked == 1:
                            mask[nx] = mask[nx] | 1
                        else:
                            # unset mask                        
                            color_index = img_comp_source.getpixel((x+(nx*16),y))   
                            bp16_off[nx] = set_bitplans(bp16_off[nx], color_index, x)

                            # set mask                        
                            color_index = img_comp_test.getpixel((x+(nx*16),y))   
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

            if "c" in mode:
                print(copy)
            if "u" in mode:
                print(mask_update)
            if "d" in mode:
                print(mask_delete)
    
    print("\n; EOF")
    sys.exit()

# entry point
current_script = os.path.basename(__file__)
if __name__ == "__main__":
    main(sys.argv[1:])
