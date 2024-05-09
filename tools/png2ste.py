"""
    png to ST
    by Matmook (matthieu@barreteau.org)
"""
import os
import sys
from PIL import Image
  
# main function  
def main(argv):

    ref_image = "source\\background.png"
    # ref_image = "source\\jagpad_mini_16.png"
    ims = Image.open( ref_image )
    width, height = ims.size

    palette = []
    
    for y in range(0,height):
        for x in range(0,width):
            r,g,b,_ = ims.getpixel((x,y))
            c = r<<16 |g<<8 | b        
            if not c in palette:
                palette.append(c)

    pixmap = bytearray((width*height)//2)

    for y in range(0,height):
        offset_l = y * width // 2       # in bytes
        for x in range(0,width,16):
            offset_w = x//2          # in nibbles
            offset_r = offset_l + offset_w

            aa = bb = cc = dd = 0

            for xx in range(0,16):
                r,g,b,_ = ims.getpixel((x+xx,y))
                c = r<<16 |g<<8 | b                
                color_index = palette.index(c)
                
                if color_index & 0x01:
                    aa = aa | (1 << (15-xx))
                if color_index & 0x02:
                    bb = bb | (1 << (15-xx))
                if color_index & 0x04:
                    cc = cc | (1 << (15-xx))
                if color_index & 0x08:
                    dd = dd | (1 << (15-xx))
            
            # print(offset_r)
            # print( format( aa & 0xFFFF, "04X")+format( bb & 0xFFFF, "04X")+format( cc & 0xFFFF, "04X")+format( dd & 0xFFFF, "04X") )
            pixmap[offset_r+0] = (aa>>8) & 0xFF
            pixmap[offset_r+1] = (aa>>0) & 0xFF
            pixmap[offset_r+2] = (bb>>8) & 0xFF
            pixmap[offset_r+3] = (bb>>0) & 0xFF
            pixmap[offset_r+4] = (cc>>8) & 0xFF
            pixmap[offset_r+5] = (cc>>0) & 0xFF
            pixmap[offset_r+6] = (dd>>8) & 0xFF
            pixmap[offset_r+7] = (dd>>0) & 0xFF
        # sys.exit()
            # print(x,y, offset_l, offset_w)

    text = ""
    text = text + "\t.long\n"
    text = text + "palette:\n"
    text = text + "\t.dc.w\t"
    for color in palette:
        r = (color>>20 & 0xF)
        g = (color>>12 & 0xF)
        b = (color>>4 & 0xF)

        r = ((r>>1)&0x7)|((r&0x1)<<3)
        g = ((g>>1)&0x7)|((g&0x1)<<3)
        b = ((b>>1)&0x7)|((b&0x1)<<3)

        color =  r<<8|g<<4|b
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
