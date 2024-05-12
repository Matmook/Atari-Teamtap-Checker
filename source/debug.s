; #############################
; show debug

    .text
enter_debug_mode:
    ; clears the screen to colour 0, background
    move.l  physbase, a0            ; a0 points to screen
    move.l  #(8000-1), d1           ; size of screen memory
.clrscr:
    clr.l  (a0)+                    ; all 0 means colour 0 :)
    dbf    d1, .clrscr 

.debug_mode_loop:

    ; TeamTap detection and read
    jsr     TeamTap_detect
    move.b  d0,TeamTapDetectionFlag
    jsr     JapPadsRead

    ; TeamTap A?
    lea     string_TeamTapA,a3
    bsr     print_message 

    move.b  TeamTapDetectionFlag,d0
    btst    #TEAMTAP_A_DETECTED_BIT,d0
    beq.s   .not_team_tap_A

    ; detected!
    lea     string_detected,a3
    bsr     print_message    

.not_team_tap_A:
    lea     string_crlf,a3
    bsr     print_message   

	lea		JapPadsARawBuffer,a5    
    jsr     dump_regs

    ; TeamTap B?
    lea     string_TeamTapB,a3
    bsr     print_message 

    move.b  TeamTapDetectionFlag,d0
    btst    #TEAMTAP_B_DETECTED_BIT,d0
    beq.s   .not_team_tap_B

    ; detected!
    lea     string_detected,a3
    bsr     print_message    

.not_team_tap_B:
    lea     string_crlf,a3
    bsr     print_message   

	lea		JapPadsBRawBuffer,a5    
    jsr     dump_regs
   
.wait_dump_key:
    jsr     wait_vbl
    jsr     get_key_press
    
    cmp.b   #' ',d0
    beq.w   .debug_mode_loop

    tst.b   d0
    beq.s   .wait_dump_key
    
    rts

dump_regs:
    .rept 4
        .rept 4
            ; read Pause, Fire 0 or Fire 1 or Fire 2
            move.w  (a5)+,d0
            moveq.l #(4-1),d1
            lea     hex_string,a0
            jsr     core_to_hex_string
            lea     hex_string,a3
            bsr     print_message
            lea     string_space,a3
            bsr     print_message
            
            ; read U,D,L,R or *741 or 0852 or #963
            move.w  (a5)+,d0
            moveq.l #(4-1),d1
            lea     hex_string,a0
            jsr     core_to_hex_string
            lea     hex_string,a3
            bsr     print_message
            lea     string_space,a3
            bsr     print_message

        .endr
        lea     string_crlf,a3
        bsr     print_message
	
    .endr

    lea     string_crlf,a3
    bsr     print_message 

    rts   

    .data

    .long
string_crlf:
    .dc.b	13,10,0

    .long
string_space:
    .dc.b	' ',0

    .long
string_TeamTapA:
    .dc.b   "TeamTap A ",0

    .long
string_TeamTapB:
    .dc.b   "TeamTap B ",0    

string_detected:
    .dc.b   " (detected)",0

    .text

; EOF