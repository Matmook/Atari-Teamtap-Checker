
; based on https://st-news.com/issues/st-news-volume-4-issue-3/education/raving-rasters
rasters_enable:
    move.l  a0,-(sp)
    move.w  #$2700,sr               ; Shut down all interrupts
    
    move.l  $68,old_68k_hbl_isr     ; current HBL vector
    move.l  #new_68k_hbl_isr,$68    ; new VBL vector

    move.l  $70,old_vbl_isr+2      ; current VBL vector to be called by the new one
    move.l  #new_vbl_isr,$70        ; new VBL vector

    ; current Times settings
    lea     old_timers,a0
    move.b  $fffffa07,(a0)+         ; Timer B enable
    move.b  $fffffa09,(a0)+         ; Timer C enable
    move.b  $fffffa0f,(a0)+         ; Timer B in-service
    move.b  $fffffa11,(a0)+         ; Timer C in-service
    move.b  $fffffa1b,(a0)+         ; Timer B control

    and.b   #$df,$fffa09            ; disable Timer C
    and.b   #$fe,$fffa07            ; disable Timer B

    move.l  $120,old_timerb_isr     ; MFP's Timer B current vector
    move.l  #new_timerb_isr,$120    ; MFP's Timer B new vector

    or.b    #1,$fffffa07            ; enable Timer B
    or.b    #1,$fffffa13            ; set Timber B mask

    move.w  #$2300,sr                ; Turn all interrupts back on (well, the ones we need anyway)

    move.b #$12,$fffffc02           ; Turn off mouse reporting (for stability)

    move.l  (sp)+,a0
    rts

rasters_disable:
    move.l  a0,-(sp)
    move.w  #$2700,sr               ; Shut down all interrupts

    lea     old_timers,a0
    move.b  (a0)+,$fffffa07         ; restore all registers
    move.b  (a0)+,$fffffa09
    move.b  (a0)+,$fffffa0f
    move.b  (a0)+,$fffffa11
    move.b  (a0)+,$fffffa1b

    move.l  old_timerb_isr,$120     ; restore MFP's Timer B old vector
    move.l  old_vbl_isr+2,$70       ; restore old VBL vector
    move.l  old_68k_hbl_isr,$68     ; restore old 68K HBL vector
    
    move.w  #$2300,sr               ; Turn all interrupts back on (well, the ones we need anyway)

    move.b #$8,$fffffc02            ; Restore mouse reporting

    move.l  (sp)+,a0
    rts

    ; TimerB isr
    .long
new_timerb_isr:
    clr.b   $fffffa1b.w             ; timer stop
    movem.l  d0-d7,-(sp)            ; save context

;     move.b  (a0),d0         ; get value of Timer B
; .wait:       
;     cmp.b   (a0),d0         ; wait one scanline
;     beq.s   .wait

    movem.l pal_background, d0-d7   ; put picture palette in d0-d7
    movem.l d0-d7, $ff8240          ; move palette from d0-d7

    movem.l  (sp)+,d0-d7            ; restore context

    bclr 	#0,$fffffa0f.w 	        ; acknowledge interrupt Timer B    
    rte

    ; VBL isr
    .long
new_vbl_isr:    
    clr.b   $fffffa1b               ; disable Timer B
    move.b  #13,$fffffa21           ; set Timber B offset   (change at line 13!)
    move.b  #8,$fffffa1b            ; enable Timer B

    movem.l  d0-d7,-(sp)            ; save context

    movem.l pal_matmook,d0-d7       ; put picture palette in d0-d7
    movem.l d0-d7, $ff8240          ; move palette from d0-d7

    movem.l  (sp)+,d0-d7            ; restore context
old_vbl_isr:
    jmp	    $0.l                    ; execute System's VBL (it will return for us)
    nop

    ; 68K HBL isr
    .long
new_68k_hbl_isr:
    rte

    .bss

    .long
old_timerb_isr:     .ds.l   1
old_68k_hbl_isr:    .ds.l   1
old_timers:         .ds.b   5
hbl_counter:        .ds.b   1

    .text
; EOF    