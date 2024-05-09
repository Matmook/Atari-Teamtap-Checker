
;
; TeamTap Checker
; Matthieu Barreteau (Matmook)
; May 2024

    lea     msg_startup,a3
    jsr     print_message
    jsr     wait_key_press

    ; exit TOS application
	clr.w	-(sp)			; Pterm0 function
	trap	#1			    ; GEMDOS call


wait_key_press:
    ; wait for a key
    move.w	#2,-(sp)		; Read from console
	move.w	#2,-(sp)		; Bconin function
	trap	#13			    ; BIOS call
	addq.l	#4,sp
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

    .data
msg_startup:    
    .dc.b	"TeamTap Checker",13,10,13,10    
	.dc.b	"Press a key to exit",0

    .end
; EOF