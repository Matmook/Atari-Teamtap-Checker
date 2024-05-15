
detect_ste:
	move.l  $5a0.w,d0               ; _p_cookies: This is a pointer to the system Cookie Jar.
	beq.s   .no_p_cookie
	movea.l d0,a0                   ; get Cookie Jar address
.check_again:
	move.l  (a0)+,d0
	beq.s   .no_cookies             ; there are no cookies at all
	cmp.l   #'_MCH',d0              ; there is something, but is that a machine entry?
	beq.s   .cookie_found           ; yep, read Cookie
	addq.w  #4,a0                   ; nope, bypass this entry's value
	bra.s   .check_again            ; and try again
.cookie_found:
	move.w	(a0)+,d0                ; read cookie's MSW
	cmp.w	#$3,d0                  ; Falcon ?
	beq.s	.falcon
	cmp.w	#$1,d0                  ; STE ?
	bne.s	.tt30
	move.w	(a0),d0                 ; read cookie's LSW and check if that's a Mega STE
	bne.s	.megaste
    
    ; This is an STE and this is the machine we were expecting!
    moveq.l #1,d0
    rts

.falcon:
    moveq.l #2,d0
    rts

.megaste:
.tt30:
.no_cookies:
.no_p_cookie:    
    moveq.l #0,d0
    rts

; Major Minor   Shifter
; 0     0       ST
; 1     0       STe
; 1     8       ST Book
; 1     16      Mega STe
; 2     0       TT030
; 3     0       Falcon030

; EOF