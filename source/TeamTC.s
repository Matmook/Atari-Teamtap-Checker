
;
; TeamTap Checker
; Matthieu Barreteau (Matmook)
; May 2024

    jsr     save_context

    ; #############################
    ; show debug
.dump_again:

    ; TeamTap A detection
    move.w  #$FFFA,$ffff9202.w
    move.w  $ffff9200.w,d0
    btst    #0,d0
    bne.s   .not_team_tap_A

    lea     TeamTapA_string,a3
    bsr     print_message    

.not_team_tap_A:

    ; TeamTap B detection
    move.w  #$FFAF,$ffff9202.w
    move.w  $ffff9200.w,d0
    btst    #2,d0
    bne.s   .not_team_tap_B

    lea     TeamTapB_string,a3
    bsr     print_message    

.not_team_tap_B:

    moveq	#4-1,d0
	lea		gKbdJagPadMasksA,a5

    .rept 4
    .rept 4
    ; write mask
    move.w  #$FFFF,d0
    move.b	(a5)+,d0
    move.w  d0,$ffff9202.w

    ; read Pause, Fire 0 or Fire 1 or Fire 2
    move.w  $ffff9200.w,d0
    moveq.l #(4-1),d1
    lea     hex_string,a0
    jsr     core_to_hex_string
	lea     hex_string,a3
    bsr     print_message
    lea     space_string,a3
    bsr     print_message
    
    ; read U,D,L,R or *741 or 0852 or #963
    move.w  $ffff9202.w,d0
    moveq.l #(4-1),d1
    lea     hex_string,a0
    jsr     core_to_hex_string
	lea     hex_string,a3
    bsr     print_message
    lea     space_string,a3
    bsr     print_message

    .endr
    lea     msg_crlf,a3
    bsr     print_message
	
    .endr

    lea     msg_crlf,a3
    bsr     print_message

    bra.s   .wait_dump_key

    jsr     IKBD_PowerpadHandler

    lea     msg_table,a5
.loop_dump:
    move.l  (a5)+,a0
    cmpa.l  #0,a0
    beq.s   .wait_dump_key
    jsr     show_debug
    bra.s   .loop_dump
    
.wait_dump_key:
    jsr     wait_vbl
    jsr     get_key_press
    
    cmp.b   #' ',d0
    beq     .dump_again
    
    cmp.b   #'q',d0
    beq     .exit

    cmp.b   #'s',d0
    beq.s   .start_normal

    bra.s   .wait_dump_key
    ; #############################
.start_normal:
    move.w  #2, -(a7)               ; get physbase
    trap    #14                     ; call XBIOS
    addq.l  #2, a7                  ; clean up stack
    move.l  d0, physbase            ; save it

    move.l  physbase, a0            ; a0 points to screen

    ; clears the screen to colour 0, background
    move.l  #(8000-1), d1           ; size of screen memory
.clrscr:
    clr.l  (a0)+                    ; all 0 means colour 0 :)
    dbf    d1, .clrscr      
        
    ; load palette
    movem.l palette, d0-d7          ; put picture palette in d0-d7
    movem.l d0-d7, $ff8240          ; move palette from d0-d7

    ; load bitmap
    move.l  physbase, a0            ; a0 points to screen    
    move.l  #bitmap, a1             ; a1 points to picture
    move.l  #(8000-1), d0           ; 8000 longwords to a screen
.ldscr:
    move.l  (a1)+, (a0)+            ; move one longword to screen
    dbf     d0, .ldscr

.loop:    
    jsr     wait_vbl
    ; move.w  #$FFF,$ff8240

    move.l  physbase, a1            ; a0 points to screen  

    move.w  #$FFFE,$FF9202
    move.w  $FF9202,d6    
    not.w   d6

    ; up test
    move.l  a1, a0
    adda.l  #160*(155+7)+(16/2),a0

    btst    #8,d6
    beq.s   .up
    jsr     up_on
    bra.s   .endup
.up:
    jsr     up_off
.endup:

    ; down test
    move.l  a1, a0
    adda.l  #160*(155+14)+(16/2),a0

    btst    #9,d6
    beq.s   .down
    jsr     down_on
    bra.s   .enddown
.down:
    jsr     down_off
.enddown:

    ; left test
    move.l  a1, a0
    adda.l  #160*(155+10)+(16/2),a0

    btst    #10,d6
    beq.s   .left
    jsr     left_on
    bra.s   .endleft
.left:
    jsr     left_off
.endleft:

    ; right test
    move.l  a1, a0
    adda.l  #160*(155+10)+(16/2),a0

    btst    #11,d6
    beq.s   .right
    jsr     right_on
    bra.s   .endright
.right:
    jsr     right_off
.endright:

    move.l  a1, a0
    adda.l  #((160*(155+14))+(32/2)),a0
    jsr     pause_on

    move.l  a1, a0
    adda.l  #((160*(155+14))+(32/2)),a0
    jsr     option_on

    move.l  a1, a0
    adda.l  #((160*(155+28))+(32/2)),a0
    jsr     numl_on

    move.l  a1, a0
    adda.l  #((160*(155+31))+(32/2)),a0
    jsr     numm_on

    move.l  a1, a0
    adda.l  #((160*(155+34))+(32/2)),a0
    jsr     numr_on

    move.l  a1, a0
    adda.l  #((160*(155+7))+(32/2)),a0
    jsr     buta_on

    move.l  a1, a0
    adda.l  #((160*(155+10))+(32/2)),a0
    jsr     butb_on

    move.l  a1, a0
    adda.l  #((160*(155+13))+(32/2)),a0
    jsr     butc_on

    ; move.w  palette,$ff8240

    jsr     get_key_press
    tst.b   d0
    beq.w   .loop

.exit:
    jsr     restore_context  
    jsr     exit_application

    .include "pads.s"
    .include "pixmap_mask.s"

; ***************************
; text functions
; ***************************

show_debug:
    move.l  a0,-(sp)

    move.l  a0,a6           ; save base address

    ; print label
    lea     5(a6),a3
    bsr.s   print_message

    ; get number of
    moveq.l #0,d1
    moveq.l #0,d0
    move.l  0(a6),a0        ; variable address
    move.b  4(a6),d1        ; number of chars to print
    
    cmp.b   #2,d1
    bne.s   .not_a_byte
    move.b  (a0),d0 
    bra.s   .go_conv
.not_a_byte:

    cmp.b   #4,d1
    bne.s   .not_a_word
    move.w  (a0),d0
    bra.s   .go_conv
.not_a_word:
    move.l  (a0),d0         ; a long

.go_conv:
    subq.l  #1,d1        
    lea     hex_string,a0
    jsr     core_to_hex_string

    lea     hex_string,a3
    bsr.s   print_message

    lea     msg_crlf,a3
    bsr.s   print_message

    move.l  (sp)+,a0
    rts

print_message:
    move.l d0,-(sp)
	moveq.l #0,d0
.next:    
	move.b	(a3)+,d0
	beq.s	.done
	move.w	d0,-(sp)		; Character to print
	move.w	#2,-(sp)		; Print to console
	move.w	#3,-(sp)		; Bconout function
	trap	#13			    ; BIOS call
	addq.l	#6,sp
	bra.s	.next
.done:	
    move.l (sp)+,d0
    rts

; a0: destination string
; d0: input number
; d1: number of character
core_to_hex_string:
	movem.l	d0-d3/a0, -(sp)
    
	add.l	d1, a0				; go to last char position
    move.b  #0,1(a0)            ; ends string

.next_nibble:
	move.l	#'0', d3			; prepare result, this is '0'
	move.l	d0, d2				; get 2 chars
	and.l	#$F, d2				; keep one nibble
	cmp.b	#9, d2				; more than 9
	ble.s	.number
	move.l	#'7', d3			; prepare result, this is '7'
.number:
	add.l	d2, d3
	move.b	d3, (a0)
	subq.l	#1, a0	
	lsr.l	#4, d0
	subq.b	#1, d1
	bpl.s	.next_nibble

	movem.l	(sp)+, d0-d3/a0
	rts    

; ***************************
; keyboard functions
; ***************************
get_key_press:
    move.w  #$ff,-(sp)
    move.w  #6,-(sp)
    trap    #1
    lea     4(sp),sp
    rts

wait_key_press:
    ; wait for a key
    move.w	#2,-(sp)		; Read from console
	move.w	#2,-(sp)		; Bconin function
	trap	#13			    ; BIOS call
	addq.l	#4,sp
    rts


; ***************************
; system functions
; ***************************
wait_vbl:
    move.w  #37, -(a7)               ; wait VBL
    trap    #14
    addq.l  #2, a7
    rts

save_context:
    clr.l   -(sp)                  ; clear stack
    move.w  #32, -(sp)             ; prepare for super mode
    trap    #1                     ; call gemdos
    addq.l  #6, sp                 ; clear up stack
    move.l  d0, previous_stack          ; backup old stack pointer

    ; save the old palette; previous_palette
    move.l  #previous_palette, a0         ; put backup address in a0
    movem.l $ffff8240, d0-d7         ; all palettes in d0-d7
    movem.l d0-d7, (a0)              ; move data into previous_palette

    ; saves the old screen adress
    move.w  #2, -(a7)                ; get physbase
    trap    #14
    addq.l  #2, a7
    move.l  d0, previous_screen           ; save old screen address

    ; save the old resolution into previous_resolution
    move.w  #4, -(a7)               ; get resolution
    trap    #14
    addq.l  #2, a7
    move.w  d0, previous_resolution ; save resolution

    ; change resolution to low (0)    
    move.w  #0, -(a7)               ; low resolution
    move.l  #-1, -(a7)              ; keep physbase
    move.l  #-1, -(a7)              ; keep logbase
    move.w  #5, -(a7)               ; change screen
    trap    #14
    add.l   #12, a7
    rts

restore_context:
    ;restores the old resolution and screen adress
    move.w  previous_resolution, d0 ; res in d0
    move.w  d0, -(a7)               ; push resolution
    move.l  previous_screen, d0     ; screen in d0
    move.l  d0, -(a7)               ; push physbase
    move.l  d0, -(a7)               ; push logbase
    move.w  #5, -(a7)               ; change screen
    trap    #14
    add.l   #12, a7

    ; restores the old palette
    move.l  #previous_palette, a0   ; palette pointer in a0
    movem.l (a0), d0-d7             ; move palette data
    movem.l d0-d7, $ffff8240        ; smack palette in

    ; set user mode again
    move.l  previous_stack, -(sp)   ; restore old stack pointer
    move.w  #32, -(sp)              ; back to user mode
    trap    #1                      ; call gemdos
    addq.l  #6, sp                  ; clear stack
    rts

exit_application:
	clr.w	-(sp)			        ; Pterm0 function
	trap	#1			            ; GEMDOS call

    .data
    .long

    .include "pixmap.s"

    .long
msg_TeamTapActiveFlag:
    .dc.l   TeamTapActiveFlag
    .dc.b   2,"TeamTapActiveFlag:",0

    .long
msg_TeamTapActiveBits:
    .dc.l   TeamTapActiveBits
    .dc.b   2,"TeamTapActiveBits:",0

    .long
msg_Pad0Dir:
    .dc.l   Pad0Dir
    .dc.b   2,"Pad0Dir:",0

    .long
msg_Pad1Dir:
    .dc.l   Pad1Dir
    .dc.b   2,"Pad1Dir:",0

    .long
msg_Pad0Key:
    .dc.l   Pad0Key
    .dc.b   4,"Pad0Key:",0

    .long
msg_Pad1Key:
    .dc.l   Pad1Key
    .dc.b   4,"Pad1Key:",0

    .long
msg_TeamTapDirs_p1:
    .dc.l   TeamTapDirs
    .dc.b   8,"TeamTapDirs:",0

    .long
msg_TeamTapDirs_p2:
    .dc.l   TeamTapDirs+4
    .dc.b   8,"TeamTapDirs:",0    

    .long
msg_TeamTapKeys_p1:
    .dc.l   TeamTapKeys
    .dc.b   8,"TeamTapKeys:",0  

    .long
msg_TeamTapKeys_p2:
    .dc.l   TeamTapKeys+4
    .dc.b   8,"TeamTapKeys:",0  

    .long
msg_TeamTapKeys_p3:
    .dc.l   TeamTapKeys+8
    .dc.b   8,"TeamTapKeys:",0  

    .long
msg_TeamTapKeys_p4:
    .dc.l   TeamTapKeys+12
    .dc.b   8,"TeamTapKeys:",0          

    .long
msg_table:
    .dc.l   msg_TeamTapActiveFlag
    .dc.l   msg_TeamTapActiveBits
    .dc.l   msg_Pad0Dir
    .dc.l   msg_Pad1Dir
    .dc.l   msg_Pad0Key
    .dc.l   msg_Pad1Key
    .dc.l   msg_TeamTapDirs_p1
    .dc.l   msg_TeamTapDirs_p2
    .dc.l   msg_TeamTapKeys_p1
    .dc.l   msg_TeamTapKeys_p2
    .dc.l   msg_TeamTapKeys_p3
    .dc.l   msg_TeamTapKeys_p4
    .dc.l   0

    .long
msg_crlf:
    .dc.b	13,10,0

    .long
space_string:    
    .dc.b	' ',0

    .long
TeamTapA_string:
    .dc.b   "TeamTap A!",13,10,0  

    .long
TeamTapB_string:
    .dc.b   "TeamTap B!",13,10,0      

    .bss
    .long
physbase:       .ds.l    1

hex_string:             .ds.b    8

previous_screen:        .ds.l    1
previous_stack:         .ds.l    1
previous_resolution:    .ds.w    1
previous_palette:       .ds.l    8

; 033f0f3f


    .end
; EOF