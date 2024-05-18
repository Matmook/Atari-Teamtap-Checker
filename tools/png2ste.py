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

    if len(argv) != 2:
        print("invalid arguments!")
        sys.exit()

    ref_image = argv[0]
    name = argv[1]

    ims = Image.open( ref_image )
    if ims.mode != "P":
        print("Indexed palette image only!")
        sys.exit()

    full_width, full_height = ims.size

    if name == "background":        
        ims = ims.crop((0,61,full_width,full_height))
        full_height = full_height - 61
    # ims.show()
    
    width = full_width
    height = full_height

    # create STE color palette
    palette = []
    color_list = ims.getcolors()
    full_palette = ims.getpalette()       
    for count,id in color_list:
        r = full_palette[(id*3)+0]
        g = full_palette[(id*3)+1]
        b = full_palette[(id*3)+2]            
        c = get_ste_pal(r,g,b)
        if not c in palette:
            palette.append(c)

    # output buffer
    pixmap = bytearray((width*height)//2)
    for y in range(0,height):
        offset_l = y * width // 2       # in bytes
        for x in range(0,width,16):
            offset_w = x//2          # in nibbles
            offset_r = offset_l + offset_w

            bp16 = [0,0,0,0]

            read_pixels = True
            if name == "background":
                if x <=64 and y <= 41:
                    read_pixels = False
            if read_pixels:
                for bit_num in range(0,16):
                    color_index = ims.getpixel((x+bit_num,y))               
                    bp16 = set_bitplans(bp16, color_index, bit_num)                

            pixmap[offset_r+0] = (bp16[0]>>8) & 0xFF
            pixmap[offset_r+1] = (bp16[0]>>0) & 0xFF
            pixmap[offset_r+2] = (bp16[1]>>8) & 0xFF
            pixmap[offset_r+3] = (bp16[1]>>0) & 0xFF
            pixmap[offset_r+4] = (bp16[2]>>8) & 0xFF
            pixmap[offset_r+5] = (bp16[2]>>0) & 0xFF
            pixmap[offset_r+6] = (bp16[3]>>8) & 0xFF
            pixmap[offset_r+7] = (bp16[3]>>0) & 0xFF

    # assembly code/data generation
    text = ""
    text = text + "\t.long\n"
    text = text + f"pal_{name}:\n"
    text = text + "\t.dc.w\t"
    for color in palette:
        text = text + "$"+format( color & 0xFFFF, "04X")+","
    text = text[:-1]+"\n\n"

    cpt = 0
    text = text + "\t.long\n"
    text = text + f"bitmap_{name}:\n"
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
