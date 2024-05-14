
;
; TeamTap Checker
; Matthieu Barreteau (Matmook)
; May 2024

    jsr     save_context

    ; get screen buffer address
    move.w  #2, -(a7)               ; get physbase
    trap    #14                     ; call XBIOS
    addq.l  #2, a7                  ; clean up stack
    move.l  d0, physbase            ; save it

    move.l  physbase, a0            ; a0 points to screen

    ; clears the screen to colour 0, background
    jsr     clear_screen 
        
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

    move.b  #$FF,TeamTapDetectionFlag ; initial fake state (force upgrade)
    jsr     TeamTap_detect          ; do a first detection
    move.b  d0,TeamTapDetectionFlag ; save initial state

.teamtap_state_changed:
    move.w  #$FFF,$ff8240           ; make it blink!
    jsr     wait_vbl
    jsr     update_teamtaps

.loop:    
    jsr     wait_vbl
    

    ; check if a teamtap has been added or removed
    ; and update bitmap accordingly
    move.b  TeamTapDetectionFlag,d1 ; get previous value
    jsr     TeamTap_detect          ; detect state again
    move.b  d0,TeamTapDetectionFlag ; save new state
    cmp.b   d0,d1
    bne.s   .teamtap_state_changed

    ; read all pads entries (including edges)
    jsr     JapPadsRead

    ; update pads
    moveq.l #(8-1),d5               ; 8 pads max!
    lea     JapPadsAState,a1
    lea     pad_position_table,a3
.loop_pad_update:
    move.l  (a1)+,d6                ; current pad state
    move.l  (a1)+,d7                ; pad changed bits
    beq.w   .next                   ; no pad change!

    ; something has changed, update pad bitmaps

    ; ## DIRECTION ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_RLDU,d0    ; get pad bits
    beq.s   .no_RLDU_change

    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_RLDU,d0    ; get pad bits

    lea     pad_update_table,a2
.search_pad_update:
    move.l  (a2)+,d1
    bmi.s   .no_RLDU_change          ; end of table, unknow value!

    move.l  (a2)+,d2                ; read value
    cmp.l   d0,d1                   ; match?
    bne.s   .search_pad_update      ; nope

    ; update pad
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1
    add.l   #(160*8),d1
    adda.l  d1,a0
    movea.l d2,a4                   ; get the mask/copy function address
    jsr     (a4)                    ; and run it!
.no_RLDU_change:

    ; ## OPTION and PAUSE ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_PO,d0      ; get pad bits
    beq.s   .no_PO_change

    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_PO,d0      ; get pad bits

    lea     po_update_table,a2
.search_po_update:
    move.l  (a2)+,d1
    bmi.s   .no_PO_change           ; end of table, unknow value!

    move.l  (a2)+,d2                ; read value
    cmp.l   d0,d1                   ; match?
    bne.s   .search_po_update       ; nope

    ; update pad
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1
    add.l   #(160*14)+(16/2),d1
    adda.l  d1,a0
    movea.l d2,a4                   ; get the mask/copy function address
    jsr     (a4)                    ; and run it!
.no_PO_change:

    ; ## ABC ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_ABC,d0     ; get pad bits
    beq.s   .no_ABC_change

    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_ABC,d0     ; get pad bits

    lea     abc_update_table,a2
.search_abc_update:
    move.l  (a2)+,d1
    bmi.s   .no_ABC_change          ; end of table, unknow value!

    move.l  (a2)+,d2                ; read value
    cmp.l   d0,d1                   ; match?
    bne.s   .search_abc_update      ; nope

    ; update abc
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1
    add.l   #(160*8)+(16/2),d1
    adda.l  d1,a0
    movea.l d2,a4                   ; get the mask/copy function address
    jsr     (a4)                    ; and run it!
.no_ABC_change:

    ; ## NUMPAD LINE 1 ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_123,d0     ; get pad bits
    beq.s   .no_123_change

    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_123,d0     ; get pad bits

    lea     num_update_table,a2
.search_num123_update:
    move.l  (a2)+,d1
    bmi.s   .no_123_change          ; end of table, unknow value!

    move.l  (a2)+,d2                ; read value
    cmp.l   d0,d1                   ; match?
    bne.s   .search_num123_update   ; nope

    ; update abc
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1
    add.l   #(160*28)+(16/2),d1
    adda.l  d1,a0
    movea.l d2,a4                   ; get the mask/copy function address
    jsr     (a4)                    ; and run it!
.no_123_change:



.next:
    lea     4(a3),a3
    dbra    d5,.loop_pad_update

    ; adda.l  #((160*(155+28))+(32/2)),a0 ; num left
    ; adda.l  #((160*(155+31))+(32/2)),a0 ; num center
    ; adda.l  #((160*(155+34))+(32/2)),a0 ; num right


    move.w  palette,$ff8240         ; back to default background color!

    jsr     get_key_press
    tst.b   d0
    beq.w   .loop

    ; a key has been pressed!
    cmp.b   #'d',d0
    bne.s   .exit
    jsr     enter_debug_mode
.exit:
    jsr     restore_context  
    jsr     exit_application
    ; GO BACK TO THE SYSTEM!


    ; 9 positions
pad_update_table:
    dc.l    $00000000,d0_copy
    dc.l    $00040000,d1_copy
    dc.l    $00240000,d2_copy
    dc.l    $00200000,d3_copy
    dc.l    $00280000,d4_copy
    dc.l    $00080000,d5_copy
    dc.l    $00180000,d6_copy
    dc.l    $00100000,d7_copy
    dc.l    $00140000,d8_copy
    dc.l    $FFFFFFFF

    ; 8 positions
abc_update_table:
    dc.l    $00000000,abc0_update
    dc.l    $00800000,abc1_update
    dc.l    $00020000,abc2_update
    dc.l    $00820000,abc3_update
    dc.l    $00000800,abc4_update
    dc.l    $00800800,abc5_update
    dc.l    $00020800,abc6_update
    dc.l    $00820800,abc7_update
    dc.l    $FFFFFFFF    

    ; 8 positions
num_update_table:
    dc.l    $00000000,n0_copy
    dc.l    $00800000,n1_copy
    dc.l    $00020000,n2_copy
    dc.l    $00820000,n3_copy
    dc.l    $00000800,n4_copy
    dc.l    $00800800,n5_copy
    dc.l    $00020800,n6_copy
    dc.l    $00820800,n7_copy
    dc.l    $FFFFFFFF    

    ; 4 positions
po_update_table:
    dc.l    $00000000,po0_update
    dc.l    $00000020,po1_update
    dc.l    $00400000,po2_update
    dc.l    $00400020,po3_update
    dc.l    $FFFFFFFF

    ; 8 pads
pad_position_table:
    dc.l    (16/2)+(160*155)
    dc.l    (48/2)+(160*109)
    dc.l    (80/2)+(160*155)
    dc.l    (112/2)+(160*109)
    dc.l    (144/2)+(160*155)
    dc.l    (176/2)+(160*109)
    dc.l    (208/2)+(160*155)
    dc.l    (240/2)+(160*109)



; update TeamTaps picture
update_teamtaps:
    movem.l d0-d5/a0-a3,-(sp)
    move.l  physbase, a1            ; a0 points to screen 

    ; TeamTap A
    lea     notap_update,a2
    lea     notpad_update,a3
    move.b  TeamTapDetectionFlag,d5
    btst    #TEAMTAP_A_DETECTED_BIT,d5
    beq.s   .update_team_tap_A

    ; there is a teamtap
    lea     notap_delete,a2
    lea     notpad_delete,a3
.update_team_tap_A:
    move.l  a1, a0
    adda.l  #((160*75)+(96/2)),a0
    jsr     (a2)

    move.l  a1, a0
    adda.l  #((160*120)+(64/2)),a0
    jsr     (a3)

    move.l  a1, a0
    adda.l  #((160*120)+(128/2)),a0
    jsr     (a3)

    move.l  a1, a0
    adda.l  #((160*166)+(96/2)),a0
    jsr     (a3)

    ; TeamTap B
    lea     notap_update,a2
    lea     notpad_update,a3
    btst    #TEAMTAP_B_DETECTED_BIT,d5
    beq.s   .update_team_tap_B

    ; there is a teamtap
    lea     notap_delete,a2
    lea     notpad_delete,a3
.update_team_tap_B:
    move.l  a1, a0
    adda.l  #((160*75)+((96+128)/2)),a0
    jsr     (a2)
   
    move.l  a1, a0
    adda.l  #((160*120)+((64+128)/2)),a0
    jsr     (a3)

    move.l  a1, a0
    adda.l  #((160*120)+((128+128)/2)),a0
    jsr     (a3)

    move.l  a1, a0
    adda.l  #((160*166)+((96+128)/2)),a0
    jsr     (a3)

    movem.l (sp)+,d0-d5/a0-a3
    rts

; ***************************
; external functions
; ***************************
    .include "debug.s"
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

    lea     string_crlf,a3
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
clear_screen:
    movem.l d0/a0,-(sp)

    ; clears the screen to colour 0, background
    move.l  physbase, a0            ; a0 points to screen
    move.l  #(8000-1), d0           ; size of screen memory
.clrscr:
    clr.l  (a0)+                    ; all 0 means colour 0 :)
    dbf    d0, .clrscr 

    movem.l (sp)+,d0/a0
    rts

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
    .include "pixmap.s"             ; we need some bitmaps!

    .bss
    .long
physbase:               .ds.l    1
    .long
hex_string:             .ds.b    8

; context backup
    .long
previous_screen:        .ds.l    1
previous_stack:         .ds.l    1
previous_palette:       .ds.l    8
previous_resolution:    .ds.w    1

    .end
; EOF