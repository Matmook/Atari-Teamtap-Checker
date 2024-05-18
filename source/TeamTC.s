
;
; TeamTap Checker
; Matthieu Barreteau (Matmook of Jagware)
; May 2024

    OFFSET_Y    .equ    20

    jsr     save_context

    lea     string_greetings,a3
    jsr     print_message

    jsr     detect_ste    

    ; we may be in HIGH-RES?
    lea     string_wrong_res,a3
    cmp.b   #3,d0
    beq.s   .go_to_debug_mode

    ; we may be on a Falcon?
    lea     string_falcon,a3
    cmp.b   #2,d0
    beq.s   .go_to_debug_mode

    ; we may not be on an STE?
    lea     string_wrong_machine,a3
    cmp.b   #1,d0
    beq.s   .this_is_an_ste

.go_to_debug_mode:
    ; that's not a compliant machine    
    jsr     print_message
    jsr     enter_debug_mode
    bra.w   .get_out
    ; GO BACK TO THE SYSTEM! 

.this_is_an_ste:
    lea     string_press_a_key,a3
    jsr     print_message
    jsr     wait_key_press
    jsr     switch_to_low_res

    jsr     rasters_enable

    ; get screen buffer address
    move.w  #2, -(sp)               ; get physbase
    trap    #14                     ; call XBIOS
    addq.l  #2, sp                  ; clean up stack
    move.l  d0, physbase            ; save it

    move.l  physbase, a0            ; a0 points to screen

    ; clears the screen to colour 0, background
    jsr     clear_screen 

    ; load bitmap
    move.l  physbase, a0            ; a0 points to screen
    adda.l  #(160*OFFSET_Y),a0
    move.l  #bitmap_background, a1  ; a1 points to picture
    move.l  #(5560-1), d0
.ldscr:
    move.l  (a1)+, (a0)+            ; move one longword to screen
    dbf     d0, .ldscr

    ; show matmook logo
    move.l  physbase, a0            ; a0 points to screen    
    move.l  #bitmap_matmook, a1     ; a1 points to picture
    move.l  #(480-1), d0            ; 480 longwords to a screen
.ldmatmook:
    move.l  (a1)+, (a0)+            ; move one longword to screen
    dbra    d0, .ldmatmook

    ; load bitjagware
    move.l  physbase, a0            ; a0 points to screen
    adda.l  #(160*(200-32)),a0
    move.l  #bitmap_jagware, a1     ; a1 points to picture
    move.l  #(((160*32)/4)-1), d0
.ldjagware:
    move.l  (a1)+, (a0)+            ; move one longword to screen
    dbf     d0, .ldjagware

    move.b  #$FF,TeamTapDetectionFlag ; initial fake state (force upgrade)
    jsr     TeamTap_detect          ; do a first detection
    move.b  d0,TeamTapDetectionFlag ; save initial state

    move.w  pal_background, pal_color_0_backup
.teamtap_state_changed:
    ; make it blink!
    move.w  #$FFF,pal_background
    jsr     wait_vbl
    jsr     update_teamtaps

    ; restore middle background color!
    move.w  pal_color_0_backup,pal_background

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

    ; update bitmap
    lea     pad_update_table,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*8),d1             ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_RLDU_change:

    ; ## OPTION and PAUSE ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_PO,d0      ; get pad bits
    beq.s   .no_PO_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_PO,d0      ; get pad bits

    ; update bitmap
    lea     po_update_table,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*14)+(16/2),d1     ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_PO_change:

    ; ## ABC ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_ABC,d0     ; get pad bits
    beq.s   .no_ABC_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_ABC,d0     ; get pad bits

    ; update bitmap
    lea     abc_update_table,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*7)+(16/2),d1      ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_ABC_change:

    ; ## NUMPAD LINE 1 ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_123,d0     ; get pad bits
    beq.s   .no_123_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_123,d0     ; get pad bits

    ; update bitmap
    lea     num_update_table_123,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*28)+(16/2),d1     ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_123_change:

    ; ## NUMPAD LINE 2 ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_456,d0     ; get pad bits
    beq.s   .no_456_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_456,d0     ; get pad bits

    ; update bitmap
    lea     num_update_table_456,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*31)+(16/2),d1     ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_456_change:

    ; ## NUMPAD LINE 3 ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_789,d0     ; get pad bits
    beq.s   .no_789_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_789,d0     ; get pad bits

    ; update bitmap
    lea     num_update_table_789,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*34)+(16/2),d1     ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_789_change:

    ; ## NUMPAD LINE 4 ##
    move.l  d7,d0                   ; copy flags
    and.l   #JAGPAD_MASK_X0X,d0     ; get pad bits
    beq.s   .no_x0x_change
    move.l  d6,d0                   ; copy flags
    and.l   #JAGPAD_MASK_X0X,d0     ; get pad bits

    ; update bitmap
    lea     num_update_table_x0x,a2    
    move.l  physbase, a0            ; a0 points to screen  
    move.l  (a3),d1                 ; get pad base offset on screen
    add.l   #(160*37)+(16/2),d1     ; add pad relative offset
    adda.l  d1,a0                   ; where to start to draw
    jsr     pad_update_part
.no_x0x_change:

.next:
    lea     4(a3),a3
    dbra    d5,.loop_pad_update


    ; back to default background color!
    ; move.w  pal_background,$ff8240

    jsr     get_key_press
    tst.b   d0
    beq.w   .loop

    ; a key has been pressed!
    cmp.b   #'d',d0
    bne.s   .exit

    jsr     clear_screen 
    jsr     rasters_disable
    jsr     restore_resolution
    jsr     enter_debug_mode
    bra.s   .get_out

.exit:
    jsr     rasters_disable
    jsr     restore_resolution
.get_out:    
    jsr     restore_context  
    jsr     exit_application
    ; GO BACK TO THE SYSTEM!


; d0: current bits
; a0: where to start to draw
; a2: action table
pad_update_part:

.search_update:
    move.l  (a2)+,d1                ; read compare mask entry
    bmi.s   .no_change              ; end of table, unknow value!

    move.l  (a2)+,a4                ; get the mask/copy function address

    cmp.l   d0,d1                   ; match?
    bne.s   .search_update          ; nope, check next
    
    jsr     (a4)                    ; and run it!
.no_change:
    rts

; update TeamTaps picture
update_teamtaps:
    movem.l d0-d5/a0-a4,-(sp)
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

    ; teamtap
    move.l  a1, a0
    adda.l  #((160*(OFFSET_Y+13))+(96/2)),a0
    jsr     (a2)

    ; all other teamtap ports (but the first)
    lea     pad_position_table+4,a4
    rept 3
    move.l  a1, a0
    adda.l  (a4)+,a0
    adda.l  #((160*11)+(16/2)),a0
    jsr     (a3)
    endr

    ; TeamTap B
    lea     notap_update,a2
    lea     notpad_update,a3
    btst    #TEAMTAP_B_DETECTED_BIT,d5
    beq.s   .update_team_tap_B

    ; there is a teamtap
    lea     notap_delete,a2
    lea     notpad_delete,a3
.update_team_tap_B:

    ; teamtap
    move.l  a1, a0
    adda.l  #((160*(OFFSET_Y+13))+((112+128)/2)),a0
    jsr     (a2)
   
   ; all other teamtap ports (but the first)
    lea     4(a4),a4
    rept 3
    move.l  a1, a0
    adda.l  (a4)+,a0
    adda.l  #((160*11)+(16/2)),a0
    jsr     (a3)
    endr

    movem.l (sp)+,d0-d5/a0-a4
    rts

; ***************************
; external functions
; ***************************
    .include "debug.s"
    .include "pads.s"
    .include "generated/gfx_masks.s"
    .include "hardware_detect.s"
    .include "rasters.s"

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
    move.w  #37, -(sp)               ; wait VBL
    trap    #14
    addq.l  #2, sp
    rts

save_context:
    clr.l   -(sp)                  ; clear stack
    move.w  #32, -(sp)             ; prepare for super mode
    trap    #1                     ; call gemdos
    addq.l  #6, sp                 ; clear up stack
    move.l  d0, previous_stack          ; backup old stack pointer
    rts

switch_to_low_res:
    ; save the old palette; previous_palette
    move.l  #previous_palette, a0         ; put backup address in a0
    movem.l $ffff8240, d0-d7         ; all palettes in d0-d7
    movem.l d0-d7, (a0)              ; move data into previous_palette

    ; saves the old screen adress
    move.w  #2, -(sp)                ; get physbase
    trap    #14
    addq.l  #2, sp
    move.l  d0, previous_screen           ; save old screen address

    ; save the old resolution into previous_resolution
    move.w  #4, -(sp)               ; get resolution
    trap    #14
    addq.l  #2, sp
    move.w  d0, previous_resolution ; save resolution

    ; change resolution to low (0)    
    move.w  #0, -(sp)               ; low resolution
    move.l  #-1, -(sp)              ; keep physbase
    move.l  #-1, -(sp)              ; keep logbase
    move.w  #5, -(sp)               ; change screen
    trap    #14
    add.l   #12, sp
    rts

restore_resolution:
    ;restores the old resolution and screen adress
    move.w  previous_resolution, d0 ; res in d0
    move.w  d0, -(sp)               ; push resolution
    move.l  previous_screen, d0     ; screen in d0
    move.l  d0, -(sp)               ; push physbase
    move.l  d0, -(sp)               ; push logbase
    move.w  #5, -(sp)               ; change screen
    trap    #14
    add.l   #12, sp

    ; restores the old palette
    move.l  #previous_palette, a0   ; palette pointer in a0
    movem.l (a0), d0-d7             ; move palette data
    movem.l d0-d7, $ffff8240        ; smack palette in
    rts

restore_context:
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
string_falcon:
    .dc.b   "Falcon detected, switching to text mode!",13,10,0

    .long
string_wrong_res:
    .dc.b   "Wrong monitor, switching to text mode!",13,10,0

    .long
string_wrong_machine:
    .dc.b   "Sorry, no Extended Joypad ports!",13,10,0

    .long
string_greetings:
    .dc.b   "Extended Joypad ports Tester by Matmook",13,10
    .dc.b   "Matthieu Barreteau - May 2024",13,10,13,10,0

    .long
string_press_a_key:
    .dc.b   "press a key when ready...",13,10,0

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
num_update_table_123:
    dc.l    $00000000,n0_copy
    dc.l    $00000008,n1_copy
    dc.l    $00000200,n2_copy
    dc.l    $00000208,n3_copy
    dc.l    $00008000,n4_copy
    dc.l    $00008008,n5_copy
    dc.l    $00008200,n6_copy
    dc.l    $00008208,n7_copy
    dc.l    $FFFFFFFF    

    ; 8 positions
num_update_table_456:
    dc.l    $00000000,n0_copy
    dc.l    $00000004,n1_copy
    dc.l    $00000100,n2_copy
    dc.l    $00000104,n3_copy
    dc.l    $00004000,n4_copy
    dc.l    $00004004,n5_copy
    dc.l    $00004100,n6_copy
    dc.l    $00004104,n7_copy
    dc.l    $FFFFFFFF    

    ; 8 positions
num_update_table_789:
    dc.l    $00000000,n0_copy
    dc.l    $00000002,n1_copy
    dc.l    $00000080,n2_copy
    dc.l    $00000082,n3_copy
    dc.l    $00002000,n4_copy
    dc.l    $00002002,n5_copy
    dc.l    $00002080,n6_copy
    dc.l    $00002082,n7_copy
    dc.l    $FFFFFFFF    

    ; 8 positions
num_update_table_x0x:
    dc.l    $00000000,n0_copy
    dc.l    $00000001,n1_copy
    dc.l    $00000040,n2_copy
    dc.l    $00000041,n3_copy
    dc.l    $00001000,n4_copy
    dc.l    $00001001,n5_copy
    dc.l    $00001040,n6_copy
    dc.l    $00001041,n7_copy
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
    dc.l    (16/2) +(160*(OFFSET_Y+94))
    dc.l    (48/2) +(160*(OFFSET_Y+48))
    dc.l    (80/2) +(160*(OFFSET_Y+94))
    dc.l    (112/2)+(160*(OFFSET_Y+48))
    dc.l    (160/2)+(160*(OFFSET_Y+94))
    dc.l    (192/2)+(160*(OFFSET_Y+48))
    dc.l    (224/2)+(160*(OFFSET_Y+94))
    dc.l    (256/2)+(160*(OFFSET_Y+48))

    ; we need some bitmaps!
    .include "generated/gfx_background.s" 
    .include "generated/gfx_matmook.s"
    .include "generated/gfx_jagware.s"

    .bss
    .long
physbase:               .ds.l    1
    .long
hex_string:             .ds.b    8
pal_color_0_backup:     .ds.w    1

; context backup
    .long
previous_screen:        .ds.l    1
previous_stack:         .ds.l    1
previous_palette:       .ds.l    8
previous_resolution:    .ds.w    1

    .end
; EOF