
; TeamTap management
; at first I have started to ggrab some public source code
; but I had to do my own version to understand.. :D

TEAMTAP_WRITE_MASK_ADDR     .equ    $ffff9202
TEAMTAP_READ_MASK_ADDR1     .equ    $ffff9200

TEAMTAP_READ_MASK_ADDR1_LSB .equ    TEAMTAP_READ_MASK_ADDR1+1
TEAMTAP_READ_MASK_ADDR2     .equ    $ffff9202
TEAMTAP_READ_MASK_ADDR2_LSB .equ    TEAMTAP_READ_MASK_ADDR2+1

; TeamTap A standalone detection
; EQ if present
TeamTapA_detect:
    move.w  #$FFFA,TEAMTAP_WRITE_MASK_ADDR.w
    move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d0
    btst    #0,d0
    rts

; TeamTap B standalone detection
; EQ if present
TeamTapB_detect:
    move.w  #$FFAF,TEAMTAP_WRITE_MASK_ADDR.w
    move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d0
    btst    #2,d0
    rts    

; TeamTap detection function
; d0.b0 => TeamTap A
; d0.b1 => TeamTap B
TeamTap_detect:
    move.l  d1,-(sp)

	; clean result
    moveq.l #0,d0

    ; TeamTap A detection
    move.w  #$FFFA,TEAMTAP_WRITE_MASK_ADDR.w
    move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d0
	not.b	d0		; change it to positive logic
    andi.b  #1,d0   ; bit 0 only!

    ; TeamTap B detection
    move.w  #$FFAF,TEAMTAP_WRITE_MASK_ADDR.w
    move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d1
	not.b	d1		; change it to positive logic
    ror.b   #1,d1   ; move bit 2 in position 1
    andi.b  #2,d1   ; bit 1 only!
    or.b    d1,d0   ; result

    move.l  (sp)+,d1
    rts

; Read all pads entries (RAW)
JapPadsRead:
	movem.l	d0-d3/a0-a1,-(sp)

	; A matrix
	lea		TeamTapA_masks,a0
	lea		JapPadsAState,a1	
	moveq.l	#(4-1),d3

	move.b  TeamTapDetectionFlag,d0
	btst    #TEAMTAP_A_DETECTED_BIT,d0
    bne.s	.read_a_next_port
	moveq.l	#0,d3

.read_a_next_port:
	moveq.l	#0,d2

	moveq.l	#(4-1),d1
.read_a:
	; write mask
	st  	d0
	move.b	(a0)+,d0
	move.w  d0,TEAMTAP_WRITE_MASK_ADDR.w

	; read Pause, Fire 0 or Fire 1 or Fire 2
	move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d0
	not.b	d0
	and.b	#$3,d0
	lsl.l	#2,d2
	or.b	d0,d2

	; read U,D,L,R or *741 or 0852 or #963
	move.b  TEAMTAP_READ_MASK_ADDR2.w,d0
	not.b	d0
	and.b	#$F,d0
	lsl.l	#4,d2
	or.b	d0,d2

	dbra	d1,.read_a

	; save pad bits
	move.l	(a1),d0		; get old state
	move.l	d2,(a1)+	; save new state

	; save edges
	eor.l	d2,d0
	; and.l	d2,d0
	move.l	d0,(a1)+
	
	dbra	d3,.read_a_next_port

	; B matrix
	lea		TeamTapB_masks,a0
	lea		JapPadsBState,a1	
	moveq.l	#(4-1),d3

	move.b  TeamTapDetectionFlag,d0
	btst    #TEAMTAP_B_DETECTED_BIT,d0
    bne.s	.read_b_next_port
	moveq.l	#0,d3

.read_b_next_port:
	moveq.l	#0,d2

	moveq.l	#(4-1),d1
.read_b:
	; write mask
	st  	d0
	move.b	(a0)+,d0
	move.w  d0,TEAMTAP_WRITE_MASK_ADDR.w

	; read Pause, Fire 0 or Fire 1 or Fire 2
	move.b  TEAMTAP_READ_MASK_ADDR1_LSB.w,d0
	lsr.b	#2,d0		; same place as A matrix
	not.b	d0
	and.b	#$3,d0
	lsl.l	#2,d2
	or.b	d0,d2

	; read U,D,L,R or *741 or 0852 or #963
	move.b  TEAMTAP_READ_MASK_ADDR2.w,d0
	lsr.b	#4,d0		; same place as A matrix
	not.b	d0
	and.b	#$F,d0
	lsl.l	#4,d2
	or.b	d0,d2

	dbra	d1,.read_b

	; save pad bits
	move.l	(a1),d0		; get old state
	move.l	d2,(a1)+	; save new state

	; save edges
	eor.l	d2,d0
	; and.l	d2,d0
	move.l	d0,(a1)+

	dbra	d3,.read_b_next_port

	movem.l	(sp)+,d0-d3/a0-a1
    rts

	.data
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

	.bss
TEAMTAP_A_DETECTED_BIT  .equ    0
TEAMTAP_B_DETECTED_BIT  .equ    1
TeamTapDetectionFlag:   .ds.b   1

; ____ ____ APRL DUB_ 147* C_25 80O_ 369#
JAGPAD_MASK_RLDU	.equ	$003C0000
JAGPAD_MASK_PO		.equ	$00400020
JAGPAD_MASK_ABC		.equ	$00820800
JAGPAD_MASK_NUMPAD  .equ	$0000F3CF
JAGPAD_MASK_123		.equ	$00008208
JAGPAD_MASK_ALL		.equ	$00FEFBEF

; 1st long for current, 2nd for edge, ...
JapPadsAState:		.ds.l	(4*2)
JapPadsBState:		.ds.l	(4*2)
	
	.text

; EOF	