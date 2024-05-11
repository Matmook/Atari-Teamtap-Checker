
; TeamTap A

TEAMTAP_WRITE_MASK_ADDR     .equ    $ffff9202
TEAMTAP_READ_MASK_ADDR1     .equ    $ffff9200
TEAMTAP_READ_MASK_ADDR2     .equ    $ffff9202

; mask 1, 2, 3 and 4
TeamTapA_masks:	
	dc.b	$fe,$fd,$fb,$f7 ; port A pad 1, also default pad 1
	dc.b	$f0,$f1,$f2,$f3 ; port A pad 2
	dc.b	$f4,$f5,$f6,$f8 ; port A pad 3
	dc.b	$f9,$fa,$fc,$ff ; port A pad 4
; detected if bit 0 or group 2 pad 4 is cleared

TeamTapB_masks:	
	dc.b	$ef,$df,$bf,$7f ; port B pad 1, also default pad 2
	dc.b	$0f,$1f,$2f,$3f ; port B pad 2
	dc.b	$4f,$5f,$6f,$8f ; port B pad 3
	dc.b	$9f,$af,$cf,$ff ; port B pad 4
; detected if bit 2 or group 2 pad 4 is cleared    

TeamTapA_detect:
    move.w  #$FFFA,TEAMTAP_WRITE_MASK_ADDR.w
    move.w  TEAMTAP_READ_MASK_ADDR1.w,d0
    btst    #0,d0
    rts

TeamTapB_detect:
    move.w  #$FFAF,TEAMTAP_WRITE_MASK_ADDR.w
    move.w  TEAMTAP_READ_MASK_ADDR1.w,d0
    btst    #2,d0
    rts    

JapPadRead:



    rts

*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_PowerpadHandler()
* ACTION   : reads both powerpads
* COMMENTS : this routine should be called immediately after VBL
*            or called on VBL routine
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_PowerpadHandler:
	movem.l	a0-a2/d0-d3,-(a7)			; save registers

.check0:
	moveq	#1,d0
	and.b	TeamTapActiveBits,d0
	beq.s	.noTeamTap0

	moveq	#4-1,d0
	lea		gKbdJagPadMasksA,a0
	lea		TeamTapDirs,a1
	lea		TeamTapKeys,a2
.loop0:		
	bsr		IKBD_ReadPadMatrixA
	addq.l	#4,a0
	addq.l	#1,a1
	addq.l	#2,a2
	dbra	d0,.loop0

	bra.s	.check1
	
.noTeamTap0:

	lea		gKbdJagPadMasksA,a0
	lea		Pad0Dir,a1
	lea		Pad0Key,a2
	bsr		IKBD_ReadPadMatrixA

.check1:
	moveq	#2,d0
	and.b	TeamTapActiveBits,d0
	beq.s	.noTeamTap1

	moveq	#4-1,d0
	lea		gKbdJagPadMasksB,a0
	lea		TeamTapDirs+4,a1
	lea		TeamTapKeys+8,a2
.loop1:
	bsr		IKBD_ReadPadMatrixB
	addq.l	#4,a0
	addq.l	#1,a1
	addq.l	#2,a2
	dbra	d0,.loop1

	bra.s	.done


.noTeamTap1:

	lea		gKbdJagPadMasksB,a0
	lea		Pad1Dir,a1
	lea		Pad1Key,a2
	bsr		IKBD_ReadPadMatrixB

.done:

	movem.l	(a7)+,a0-a2/d0-d3			; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_ReadPowerpadA()
* ACTION   : reads jaguar PowerPad A
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPowerpadA:
	movem.l	d0-d3/a0-a1,-(a7)	; save registers

	lea		$ffff9200.w,a0		; extended port address (read only)
	lea		2(a0),a1			; extended port address (read/write)
	moveq	#0,d2				; clear d2 - it will contain key information
	move.w	#$fffe,(a1)			; write mask
	move.w	(a1),d0				; read directional data
	move.w	(a0),d3				; read fire_a/pause data
	not.w	d0					; invert bits (0->1)
	move.w	d0,d1				; save directional data
	lsr.w	#8,d1				; shift into low bits (0-3)
	and.w	#%1111,d1			; mask off unwanted data
	lsr.w	#1,d3				; check bit 0 (pause data)
	bcs.s	.no_pause			; if set, pause is not pressed
	bset	#13,d2				; pause is pressed so set pause bit
.no_pause:
	lsr.w	#1,d3				; check bit 1 (fire a data)
	bcs.s	.no_firea			; if set, fire is not pressed
	bset	#7,d1				; fire_a is pressed, so set fire_a bit
.no_firea:
	move.w	#$fffd,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check fire_b
	bne.s	.no_fireb			; if set, fire_b is not pressed
	bset	#6,d1				; fire_b is pressed, set relevant bit
.no_fireb:
	lsr.w	#8,d0				; shift key data into bits 0-3
	and.w	#%1111,d0			; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$fffb,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check for fire_c
	bne.s	.no_firec			; if set, fire_c is not pressed
	bset	#5,d1				; fire_c is pressed, set relevant bit
.no_firec:
	lsr.w	#4,d0				; shift key data into bits 4-7
	and.w	#%11110000,d0		; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$fff7,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check for option
	bne.s	.no_option 			; if set, option is not pressed
	bset	#12,d2				; set option bit
.no_option:
	and.w	#%111100000000,d0	; mask off unwanted bits
	or.w	d0,d2				; store key data

	move.b	d1,Pad0Dir		; save directional+fire data in variable
	move.w	d2,Pad0Key		; save key data in variable

	movem.l	(a7)+,d0-d3/a0-a1	; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_ReadPowerpadB()
* ACTION   : reads jaguar PowerPad B
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPowerpadB:
	movem.l	d0-d3/a0-a1,-(a7)	; save registers

	lea		$ffff9200.w,a0		; extended port address (read only)
	lea		2(a0),a1			; extended port address (read/write)
	moveq	#0,d2				; clear d2 - it will contain key information
	move.w	#$ffef,(a1)			; write mask
	move.w	(a1),d0				; read directional data
	move.w	(a0),d3				; read fire_a/pause data
	not.w	d0					; invert bits (0->1)
	move.w	d0,d1				; save directional data
	lsr.w	#8,d1				; shift directional data down
	lsr.w	#4,d1				; shift into low bits (0-3)
	and.w	#%1111,d1			; mask off unwanted data
	btst	#2,d3				; check bit 2 (pause data)
	bne.s	.no_pause			; if set, pause is not pressed
	bset	#13,d2				; pause is pressed so set pause bit
.no_pause:
	btst	#3,d3				; check bit 3 (fire a data)
	bne.s	.no_firea			; if set, fire is not pressed
	bset	#7,d1				; fire_a is pressed, so set fire_a bit
.no_firea:
	move.w	#$ffdf,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check fire_b
	bne.s	.no_fireb			; if set, fire_b is not pressed
	bset	#6,d1				; fire_b is pressed, set relevant bit
.no_fireb:	
	lsr.w	#8,d0
	lsr.w	#4,d0				; shift key data into bits 0-3
	and.w	#%1111,d0			; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$ffbf,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check for fire_c
	bne.s	.no_firec			; if set, fire_c is not pressed
	bset	#5,d1				; fire_c is pressed, set relevant bit
.no_firec:		
	lsr.w	#8,d0				; shift key data into bits 4-7
	and.w	#%11110000,d0		; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$ff7f,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check for option
	bne.s	.no_option 			; if set, option is not pressed
	bset	#12,d2				; set option bit
.no_option:
	lsr.w	#4,d0				; shift key data into bits 8-11
	and.w	#%111100000000,d0	; mask off unwanted bits
	or.w	d0,d2				; store key data

	move.b	d1,Pad1Dir		; save directional+fire data in variable
	move.w	d2,Pad1Key		; save key data in variable

	movem.l	(a7)+,d0-d3/a0-a1	; restore registers
	rts


;-----------------------------------------------
; 9203 : W : E
; 9201 : R :                .[1:FIREA].[0:PAUSE]
; 9203 : R : [3: U ].[2: D ].[1:L    ].[0:R    ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:FIREB].[0:     ]
; 9203 : R : [3: 1 ].[2: 4 ].[1: 7   ].[0: *   ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:FIREC].[0:     ]
; 9203 : R : [3: 2 ].[2: 5 ].[1: 8   ].[0: 0   ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:OPT  ].[0:     ]
; 9203 : R : [3: 3 ].[2: 6 ].[1: 9   ].[0: #   ]
;-----------------------------------------------


; a0->table
; a1->dirs
; a2->keys	

*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_ReadPadMatrixA
* ACTION   : reads teamtap a
* CREATION : 11.11.01 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPadMatrixA:
	movem.l	d0-d2/a0,-(a7)

	move.b	(a0)+,$ffff9203.w			; select ( [fireA.pause].[rldu] )
	bsr		.pause						; lets wait a while
	moveq	#0,d1						; clear key
	move.b	$ffff9201.w,d2				; [fireA.pause]
	move.b	$ffff9202.w,d0				; read directional data [rldu]
	not.b	d0							; invrt
	and.b	#%1111,d0					; mask out unwanted bits
	move.b	(a0)+,$ffff9203.w			; select ( [fireB.-].[147*] )
	btst	#0,d2						; check bit 0 [pause]
	bne.s	.no_pause					; if set, pause is not pressed
	bset	#13,d1						; pause is pressed so set pause bit
.no_pause:
	btst	#1,d2						; check bit 1 (fire a data)
	bne.s	.no_firea					; if set, fire is not pressed
	bset	#7,d0						; fire_a is pressed, so set fire_a bit
.no_firea:

	move.b	$ffff9201.w,d2				; read fire b
	btst	#1,d2						; check fire b
	bne.s	.nofireb					; zero=not pressed
	bset	#6,d0						; set fire b
.nofireb:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [fireC.-].[2580] )
	not.b	d2							; invert bits
	and.b	#%1111,d2					; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read fire c
	btst	#1,d2						; is firec pressed?
	bne.s	.nofirec					; zero=not pressed
	bset	#5,d0						; set fire c
.nofirec:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [opt.-].[369#] )
	not.b	d2							; invert bits
	and.b	#%1111,d2					; mask out unwanted bits
	lsl.w	#4,d2						; shift into bits 4-7
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read opt
	btst	#1,d2						; is option pressed?
	bne.s	.noopt						; not zero=not pressed
	bset	#12,d1						; mark option bit
.noopt:
	move.b	$ffff9202.w,d2				; read keys
	not.b	d2							; invert bits
	and.w	#%1111,d2					; mask out unwanted bits
	lsl.w	#8,d2						; shift into bits 8-11
	or.w	d2,d1						; combine keys

	move.b	d0,(a1)						; store directions+fire
	move.w	d1,(a2)						; store keys

	movem.l	(a7)+,d0-d2/a0
.pause:
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_ReadPadMatrixB
* ACTION   : reads teamtap b
* CREATION : 11.11.01 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPadMatrixB:
	movem.l	d0-d2/a0,-(a7)

	move.b	(a0)+,$ffff9203.w			; select ( [fireA.pause].[rldu] )
	bsr		.pause						; lets wait a while
	moveq	#0,d1						; clear key
	move.b	$ffff9201.w,d2				; [fireA.pause]
	move.b	$ffff9202.w,d0				; read directional data [rldu]
	not.b	d0							; invert
	lsr.w	#4,d0						; shift into bits 3-0
	and.b	#%1111,d0					; mask out unwanted bits
	move.b	(a0)+,$ffff9203.w			; select ( [fireB.-].[147*] )
	btst	#2,d2						; check bit 0 [pause]
	bne.s	.no_pause					; if set, pause is not pressed
	bset	#13,d1						; pause is pressed so set pause bit
.no_pause:
	btst	#3,d2						; check bit 1 (fire a data)
	bne.s	.no_firea					; if set, fire is not pressed
	bset	#7,d0						; fire_a is pressed, so set fire_a bit
.no_firea:

	move.b	$ffff9201.w,d2				; read fire b
	btst	#3,d2						; check fire b
	bne.s	.nofireb					; zero=not pressed
	bset	#6,d0						; set fire b
.nofireb:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [fireC.-].[2580] )
	not.b	d2							; invert bits
	lsr.w	#4,d2
	and.b	#%1111,d2					; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read fire c
	btst	#3,d2						; is firec pressed?
	bne.s	.nofirec					; zero=not pressed
	bset	#5,d0						; set fire c
.nofirec:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [opt.-].[369#] )
	not.b	d2							; invert bits
	and.b	#%11110000,d2				; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read opt
	btst	#3,d2						; is option pressed?
	bne.s	.noopt						; not zero=not pressed
	bset	#12,d1						; mark option bit
.noopt:
	move.b	$ffff9202.w,d2				; read keys
	not.b	d2							; invert bits
	and.w	#%11110000,d2				; mask out unwanted bits
	lsl.w	#4,d2						; shift into bits 8-11
	or.w	d2,d1						; combine keys

	move.b	d0,(a1)						; store directions+fire
	move.w	d1,(a2)						; store keys

	movem.l	(a7)+,d0-d2/a0
.pause:
	rts


teamtaptab:     DC.B $EE,$DD,$BB,$77  ;first 4 bytes are the same for non-teamtap controller
                DC.B $00,$11,$22,$33
                DC.B $44,$55,$66,$88
                DC.B $99,$AA,$CC,$FF
noteamtap:


**************************************************************************************
	DATA
**************************************************************************************    
gKbdJagPadMasksA:	
	dc.b	$fe,$fd,$fb,$f7
	dc.b	$f0,$f1,$f2,$f3
	dc.b	$f4,$f5,$f6,$f8
	dc.b	$f9,$fa,$fc,$ff

gKbdJagPadMasksB:	
	dc.b	$ef,$df,$bf,$7f
	dc.b	$0f,$1f,$2f,$3f
	dc.b	$4f,$5f,$6f,$8f
	dc.b	$9f,$af,$cf,$ff

    .long:
TeamTapActiveFlag:  .ds.b   1
TeamTapActiveBits:  .ds.b   1
Pad0Dir:            .ds.b   1
Pad1Dir:            .ds.b   1
Pad0Key:            .ds.w   1
Pad1Key:            .ds.w   1
TeamTapDirs:        .ds.b   8
TeamTapKeys:        .ds.w   8

; EOF	