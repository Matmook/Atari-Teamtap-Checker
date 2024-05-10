
;
; TeamTap Checker
; Matthieu Barreteau (Matmook)
; May 2024

    jsr     save_context

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
    move.w  #$FFF,$ff8240

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

    move.w  palette,$ff8240

    jsr     get_key_press
    tst.b   d0
    beq.w   .loop

    move.w  #$FFFE,$FF9202
    moveq.l #0,d6
    move.w  $FF9202,d6    
    not.w   d6
    move.l  d6,pad_mask_FFFE

    jsr     restore_context

    lea     hex_string,a0
    move.l  d6,d0
    ; move.l  #$DEADCAFE,d0
    moveq.l #(8-1),d1 
    jsr     core_to_hex_string
    lea     hex_string,a3
    jsr     print_message

    jsr     wait_key_press

    ; move.w  pad1,d0
    ; illegal

    
    jsr     exit_application


    .include "pixmap_mask.s"

; ***************************
; text functions
; ***************************
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
	movem.l	d0-d3, -(sp)

	add.l	d1, a0				; go to last char position

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

	movem.l	(sp)+, d0-d3
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

msg_startup:    
    .dc.b	"TeamTap Checker",13,10,13,10    
	.dc.b	"Press a key to exit",0

msg_test1:
    .dc.b	"Test 1",13,10,0

msg_test2:
    .dc.b	"Test 2",13,10,0

hex_string:
    .dc.b	"00000000",13,10,0    

    .bss
    .long
physbase:       .ds.l    1

pad_mask_FFFE:          .ds.l    1

previous_screen:        .ds.l    1
previous_stack:         .ds.l    1
previous_resolution:    .ds.w    1
previous_palette:       .ds.l    8

; 033f0f3f


    .end
; EOF