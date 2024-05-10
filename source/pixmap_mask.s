up_off:
	movem.l (a0),d0-d1
	andi.l	#$FFEFFFEF,d0
	andi.l	#$FFEFFFEF,d1
	ori.l	#$00000010,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFC7FFC7,d0
	andi.l	#$FFC7FFC7,d1
	ori.l	#$00000038,d0
	ori.l	#$00080000,d1
	movem.l d0-d1,(a0)
	rts

up_on:
	movem.l (a0),d0-d1
	andi.l	#$FFEFFFEF,d0
	andi.l	#$FFEFFFEF,d1
	ori.l	#$00100010,d0
	ori.l	#$00100000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFC7FFC7,d0
	andi.l	#$FFC7FFC7,d1
	ori.l	#$00380038,d0
	ori.l	#$00380000,d1
	movem.l d0-d1,(a0)
	rts

down_off:
	movem.l (a0),d0-d1
	andi.l	#$FFC7FFC7,d0
	andi.l	#$FFC7FFC7,d1
	ori.l	#$00000038,d0
	ori.l	#$00080000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFEFFFEF,d0
	andi.l	#$FFEFFFEF,d1
	ori.l	#$00000010,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	rts

down_on:
	movem.l (a0),d0-d1
	andi.l	#$FFC7FFC7,d0
	andi.l	#$FFC7FFC7,d1
	ori.l	#$00380038,d0
	ori.l	#$00380000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFEFFFEF,d0
	andi.l	#$FFEFFFEF,d1
	ori.l	#$00100010,d0
	ori.l	#$00100000,d1
	movem.l d0-d1,(a0)
	rts

right_off:
	movem.l (a0),d0-d1
	andi.l	#$FFFDFFFD,d0
	andi.l	#$FFFDFFFD,d1
	ori.l	#$00000002,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFFCFFFC,d0
	andi.l	#$FFFCFFFC,d1
	ori.l	#$00000003,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFFDFFFD,d0
	andi.l	#$FFFDFFFD,d1
	ori.l	#$00000002,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	rts

right_on:
	movem.l (a0),d0-d1
	andi.l	#$FFFDFFFD,d0
	andi.l	#$FFFDFFFD,d1
	ori.l	#$00020002,d0
	ori.l	#$00020000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFFCFFFC,d0
	andi.l	#$FFFCFFFC,d1
	ori.l	#$00030003,d0
	ori.l	#$00030000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FFFDFFFD,d0
	andi.l	#$FFFDFFFD,d1
	ori.l	#$00020002,d0
	ori.l	#$00020000,d1
	movem.l d0-d1,(a0)
	rts

left_off:
	movem.l (a0),d0-d1
	andi.l	#$FF7FFF7F,d0
	andi.l	#$FF7FFF7F,d1
	ori.l	#$00000080,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FE7FFE7F,d0
	andi.l	#$FE7FFE7F,d1
	ori.l	#$00000180,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF7FFF7F,d0
	andi.l	#$FF7FFF7F,d1
	ori.l	#$00000080,d0
	ori.l	#$00000000,d1
	movem.l d0-d1,(a0)
	rts

left_on:
	movem.l (a0),d0-d1
	andi.l	#$FF7FFF7F,d0
	andi.l	#$FF7FFF7F,d1
	ori.l	#$00800080,d0
	ori.l	#$00800000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FE7FFE7F,d0
	andi.l	#$FE7FFE7F,d1
	ori.l	#$01800180,d0
	ori.l	#$01800000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF7FFF7F,d0
	andi.l	#$FF7FFF7F,d1
	ori.l	#$00800080,d0
	ori.l	#$00800000,d1
	movem.l d0-d1,(a0)
	rts

pause_off:
	movem.l (a0),d0-d1
	andi.l	#$F3FFF3FF,d0
	andi.l	#$F3FFF3FF,d1
	ori.l	#$0C000000,d0
	ori.l	#$0C000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$E7FFE7FF,d0
	andi.l	#$E7FFE7FF,d1
	ori.l	#$18000000,d0
	ori.l	#$18000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$CFFFCFFF,d0
	andi.l	#$CFFFCFFF,d1
	ori.l	#$10002000,d0
	ori.l	#$30000000,d1
	movem.l d0-d1,(a0)
	rts

pause_on:
	movem.l (a0),d0-d1
	andi.l	#$F3FFF3FF,d0
	andi.l	#$F3FFF3FF,d1
	ori.l	#$0C000C00,d0
	ori.l	#$0C000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$E7FFE7FF,d0
	andi.l	#$E7FFE7FF,d1
	ori.l	#$18001800,d0
	ori.l	#$18000000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$CFFFCFFF,d0
	andi.l	#$CFFFCFFF,d1
	ori.l	#$30003000,d0
	ori.l	#$30000000,d1
	movem.l d0-d1,(a0)
	rts

option_off:
	movem.l (a0),d0-d1
	andi.l	#$FFCFFFCF,d0
	andi.l	#$FFCFFFCF,d1
	ori.l	#$00300000,d0
	ori.l	#$00300000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF9FFF9F,d0
	andi.l	#$FF9FFF9F,d1
	ori.l	#$00600000,d0
	ori.l	#$00600000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF3FFF3F,d0
	andi.l	#$FF3FFF3F,d1
	ori.l	#$00400080,d0
	ori.l	#$00C00000,d1
	movem.l d0-d1,(a0)
	rts

option_on:
	movem.l (a0),d0-d1
	andi.l	#$FFCFFFCF,d0
	andi.l	#$FFCFFFCF,d1
	ori.l	#$00300030,d0
	ori.l	#$00300000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF9FFF9F,d0
	andi.l	#$FF9FFF9F,d1
	ori.l	#$00600060,d0
	ori.l	#$00600000,d1
	movem.l d0-d1,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d1
	andi.l	#$FF3FFF3F,d0
	andi.l	#$FF3FFF3F,d1
	ori.l	#$00C000C0,d0
	ori.l	#$00C00000,d1
	movem.l d0-d1,(a0)
	rts

numl_off:
	movem.l (a0),d0-d1
	andi.l	#$87FF87FF,d0
	andi.l	#$87FF87FF,d1
	ori.l	#$00000000,d0
	ori.l	#$78000000,d1
	movem.l d0-d1,(a0)
	rts

numl_on:
	movem.l (a0),d0-d1
	andi.l	#$87FF87FF,d0
	andi.l	#$87FF87FF,d1
	ori.l	#$78007800,d0
	ori.l	#$78000000,d1
	movem.l d0-d1,(a0)
	rts

numm_off:
	movem.l (a0),d0-d1
	andi.l	#$FC3FFC3F,d0
	andi.l	#$FC3FFC3F,d1
	ori.l	#$00000000,d0
	ori.l	#$03C00000,d1
	movem.l d0-d1,(a0)
	rts

numm_on:
	movem.l (a0),d0-d1
	andi.l	#$FC3FFC3F,d0
	andi.l	#$FC3FFC3F,d1
	ori.l	#$03C003C0,d0
	ori.l	#$03C00000,d1
	movem.l d0-d1,(a0)
	rts

numr_off:
	movem.l (a0),d0-d1
	andi.l	#$FFE1FFE1,d0
	andi.l	#$FFE1FFE1,d1
	ori.l	#$00000000,d0
	ori.l	#$001E0000,d1
	movem.l d0-d1,(a0)
	rts

numr_on:
	movem.l (a0),d0-d1
	andi.l	#$FFE1FFE1,d0
	andi.l	#$FFE1FFE1,d1
	ori.l	#$001E001E,d0
	ori.l	#$001E0000,d1
	movem.l d0-d1,(a0)
	rts

buta_off:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FFBFFFBF,d2
	andi.l	#$FFBFFFBF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00400000,d2
	ori.l	#$00000040,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FF1FFF1F,d2
	andi.l	#$FF1FFF1F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00800060,d2
	ori.l	#$000000E0,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FE0FFE0F,d2
	andi.l	#$FE0FFE0F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$011000F0,d2
	ori.l	#$000001F0,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FF1FFF1F,d2
	andi.l	#$FF1FFF1F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$002000E0,d2
	ori.l	#$000000E0,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FFBFFFBF,d2
	andi.l	#$FFBFFFBF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00400040,d2
	ori.l	#$00000040,d3
	movem.l d0-d3,(a0)
	rts

buta_on:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FFBFFFBF,d2
	andi.l	#$FFBFFFBF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00400040,d2
	ori.l	#$00400000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FF1FFF1F,d2
	andi.l	#$FF1FFF1F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00E000E0,d2
	ori.l	#$00E00000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FE0FFE0F,d2
	andi.l	#$FE0FFE0F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$01F001F0,d2
	ori.l	#$01F00000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FF1FFF1F,d2
	andi.l	#$FF1FFF1F,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00E000E0,d2
	ori.l	#$00E00000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FFBFFFBF,d2
	andi.l	#$FFBFFFBF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$00400040,d2
	ori.l	#$00400000,d3
	movem.l d0-d3,(a0)
	rts

butb_off:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FBFFFBFF,d2
	andi.l	#$FBFFFBFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$04000000,d2
	ori.l	#$00000400,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$F1FFF1FF,d2
	andi.l	#$F1FFF1FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$08000600,d2
	ori.l	#$00000E00,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$E0FFE0FF,d2
	andi.l	#$E0FFE0FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$11000F00,d2
	ori.l	#$00001F00,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$F1FFF1FF,d2
	andi.l	#$F1FFF1FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$02000E00,d2
	ori.l	#$00000E00,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FBFFFBFF,d2
	andi.l	#$FBFFFBFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$04000400,d2
	ori.l	#$00000400,d3
	movem.l d0-d3,(a0)
	rts

butb_on:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FBFFFBFF,d2
	andi.l	#$FBFFFBFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$04000400,d2
	ori.l	#$04000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$F1FFF1FF,d2
	andi.l	#$F1FFF1FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$0E000E00,d2
	ori.l	#$0E000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$E0FFE0FF,d2
	andi.l	#$E0FFE0FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$1F001F00,d2
	ori.l	#$1F000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$F1FFF1FF,d2
	andi.l	#$F1FFF1FF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$0E000E00,d2
	ori.l	#$0E000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$FBFFFBFF,d2
	andi.l	#$FBFFFBFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$04000400,d2
	ori.l	#$04000000,d3
	movem.l d0-d3,(a0)
	rts

butc_off:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$BFFFBFFF,d2
	andi.l	#$BFFFBFFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$40000000,d2
	ori.l	#$00004000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$1FFF1FFF,d2
	andi.l	#$1FFF1FFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$80006000,d2
	ori.l	#$0000E000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFEFFFE,d0
	andi.l	#$FFFEFFFE,d1
	andi.l	#$0FFF0FFF,d2
	andi.l	#$0FFF0FFF,d3
	ori.l	#$00010000,d0
	ori.l	#$00000001,d1
	ori.l	#$1000F000,d2
	ori.l	#$0000F000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFCFFFC,d0
	andi.l	#$FFFCFFFC,d1
	andi.l	#$1FFF1FFF,d2
	andi.l	#$1FFF1FFF,d3
	ori.l	#$00020001,d0
	ori.l	#$00000003,d1
	ori.l	#$2000E000,d2
	ori.l	#$0000E000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFEFFFE,d0
	andi.l	#$FFFEFFFE,d1
	andi.l	#$3FFF3FFF,d2
	andi.l	#$3FFF3FFF,d3
	ori.l	#$00000001,d0
	ori.l	#$00000001,d1
	ori.l	#$C000C000,d2
	ori.l	#$0000C000,d3
	movem.l d0-d3,(a0)
	rts

butc_on:
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$BFFFBFFF,d2
	andi.l	#$BFFFBFFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$40004000,d2
	ori.l	#$40000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFFFFFF,d0
	andi.l	#$FFFFFFFF,d1
	andi.l	#$1FFF1FFF,d2
	andi.l	#$1FFF1FFF,d3
	ori.l	#$00000000,d0
	ori.l	#$00000000,d1
	ori.l	#$E000E000,d2
	ori.l	#$E0000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFEFFFE,d0
	andi.l	#$FFFEFFFE,d1
	andi.l	#$0FFF0FFF,d2
	andi.l	#$0FFF0FFF,d3
	ori.l	#$00010001,d0
	ori.l	#$00010000,d1
	ori.l	#$F000F000,d2
	ori.l	#$F0000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFCFFFC,d0
	andi.l	#$FFFCFFFC,d1
	andi.l	#$1FFF1FFF,d2
	andi.l	#$1FFF1FFF,d3
	ori.l	#$00030003,d0
	ori.l	#$00030000,d1
	ori.l	#$E000E000,d2
	ori.l	#$E0000000,d3
	movem.l d0-d3,(a0)
	lea 160(a0),a0
	movem.l (a0),d0-d3
	andi.l	#$FFFEFFFE,d0
	andi.l	#$FFFEFFFE,d1
	andi.l	#$3FFF3FFF,d2
	andi.l	#$3FFF3FFF,d3
	ori.l	#$00010001,d0
	ori.l	#$00010000,d1
	ori.l	#$C000C000,d2
	ori.l	#$C0000000,d3
	movem.l d0-d3,(a0)
	rts


; EOF
