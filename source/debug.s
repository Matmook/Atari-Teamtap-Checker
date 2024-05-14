; #############################
; show debug

    .text
enter_debug_mode:    

    jsr     clear_screen 

    ; TeamTap detection and read (initial read)
    jsr     TeamTap_detect
    move.b  d0,TeamTapDetectionFlag
    jsr     JapPadsRead

.debug_mode_loop:

    lea     string_bits,a3
    bsr     print_message

    ; TeamTap A?
    moveq.l #(1-1),d6
    lea     string_TeamTapA,a3
    bsr     print_message 

    move.b  TeamTapDetectionFlag,d0
    btst    #TEAMTAP_A_DETECTED_BIT,d0
    beq.s   .not_team_tap_A

    ; detected!
    lea     string_detected,a3
    bsr     print_message    
    moveq.l #(4-1),d6

.not_team_tap_A:
    lea     string_crlf,a3
    bsr     print_message   

	lea		JapPadsAState,a5    
    jsr     dump_regs

    ; TeamTap B?
    moveq.l #(1-1),d6
    lea     string_TeamTapB,a3
    bsr     print_message 

    move.b  TeamTapDetectionFlag,d0
    btst    #TEAMTAP_B_DETECTED_BIT,d0
    beq.s   .not_team_tap_B

    ; detected!
    lea     string_detected,a3
    bsr     print_message    
    moveq.l #(4-1),d6

.not_team_tap_B:
    lea     string_crlf,a3
    bsr     print_message   

	lea		JapPadsBState,a5    
    jsr     dump_regs
   
.wait_dump_key:
    jsr     wait_vbl

    ; TeamTap detection and read
    jsr     TeamTap_detect
    move.b  d0,TeamTapDetectionFlag
    jsr     JapPadsRead

    ; check if something has changed
    lea		JapPadsAState,a5
    moveq.l #(8-1),d1
.look_for_changes:
    adda    #4,a5               ; bypass current state
    move.l  (a5)+,d2
    tst.l   d2                  ; something new?
    bne.w   .debug_mode_loop        
    dbra    d1,.look_for_changes

    jsr     get_key_press
    cmp.b   #' ',d0
    beq.s   .done

    bra.s   .wait_dump_key
.done:    
    rts

dump_regs:

.print_reg:
    ; convert long to hex string
    move.l  (a5)+,d0
    moveq.l #(8-1),d1
    lea     hex_string,a0
    jsr     core_to_hex_string

    lea     hex_string,a3
    bsr     print_message

    lea     string_space,a3
    bsr     print_message 

    ; convert long to hex string
    move.l  (a5)+,d0
    moveq.l #(8-1),d1
    lea     hex_string,a0
    jsr     core_to_hex_string

    lea     hex_string,a3
    bsr     print_message

    lea     string_crlf,a3
    bsr     print_message 

    dbra    d6, .print_reg

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

string_bits:
    .dc.b   "____ ____ APRL DUB_ 147* C_25 80O_ 369#",13,10,0

    .text

; EOF