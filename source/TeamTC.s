
;
; TeamTap Checker
; Matthieu Barreteau (Matmook)
; May 2024

    jsr     save_context

    move.w  #2, -(a7)                ; get physbase
    trap    #14                      ; call XBIOS
    addq.l  #2, a7                   ; clean up stack
    move.l  d0, physbase             ; save it

    move.w  #$700, $ffff8240       ; red background color

    move.l  physbase, a0                   ; a0 points to screen

    ; clears the screen to colour 0, background
    move.l  #(8000-1), d1            ; size of screen memory
.clrscr:
    clr.l  (a0)+                     ; all 0 means colour 0 :)
    dbf    d1, .clrscr      
        
    ; load palette
    movem.l palette, d0-d7         ; put picture palette in d0-d7
    movem.l d0-d7, $ff8240           ; move palette from d0-d7

    ; load bitmap
    move.l  physbase, a0             ; a0 points to screen    
    move.l  #bitmap, a1          ; a1 points to picture
    move.l  #(8000-1), d0            ; 8000 longwords to a screen
.ldscr:
    move.l  (a1)+, (a0)+             ; move one longword to screen
    dbf     d0, .ldscr

    bra.s   .bypass

    lea     msg_startup,a3
    jsr     print_message

    clr.l   pad1

.loop:    
    move.w  #$FFFE,$FF9202
    move.w  $FF9200,d0
    and.w   #$F,d0
    not.w   d0

    lea     msg_test1,a3
    btst    #1,d0
    beq.s   .plop
    lea     msg_test2,a3    
.plop:
    jsr     print_message

    jsr     get_key_press
    tst.b   d0
    beq.s   .loop

.bypass:
    jsr     wait_key_press
   

    move.w  #$777, $ffff8240       ; white background color
    ; move.w  pad1,d0
    ; illegal

    jsr     restore_context
    jsr     exit_application


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

    .bss
    .long
physbase:       .ds.l    1

pad1:           .ds.l    1

previous_screen:        .ds.l    1
previous_stack:         .ds.l    1
previous_resolution:    .ds.w    1
previous_palette:       .ds.l    8

    .end
; EOF