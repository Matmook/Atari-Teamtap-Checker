
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
	; check if we are NOT in HIGH resolution
	move.w  #4,-(sp)
	trap    #14
	addq.l  #2,sp
	cmp.w	#2,d0		; 0 for low, 1,for medium, and 2 for high resolution
	blt.s	.low_or_medium

	; we are in high resolution!
	moveq.l #3,d0
    rts

.low_or_medium:
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

;  Atari Compendium
; Major Minor   Shifter
; 0     0       ST
; 1     0       STe
; 1     8       ST Book
; 1     16      Mega STe
; 2     0       TT030
; 3     0       Falcon030


; Freemint documentation
; Machine type
; The upper WORD describes the computer family, the lower serves for finer distinctions.

; High	Low	Type
; 0x0000	0x0000	Atari ST (260 ST,520 ST,1040 ST,Mega ST,...)
; 0x0000	0x4D34	Medusa T40 without SCSI
; 0x0001	0x0000	Atari STE (1040 STE, ST Book, STylus/STPad)
; 0x0001	0x0010	Mega STE
; 0x0001	0x0100	Sparrow (Falcon pre-production machine)
; 0x0002	0x0000	Atari TT or Hades
; 0x0002	0x4D34	Medusa T40 with SCSI
; 0x0003	0x0000	Atari-Falcon030
; 0x0004	0x0000	Milan
; 0x0005	0x0000	ARAnyM >=v0.8.5beta

; The lower WORD serves for finer distinctions, and is defined only for the STE models at present.
; This can be:
; 0x001 = ST Book or STylus
; 0x002 = ST Book
; 0x003 = STylus
; 0x008 = STE with IDE hardware

; EOF