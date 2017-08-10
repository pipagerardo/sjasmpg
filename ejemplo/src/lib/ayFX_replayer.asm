;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                    I N I C I O                      | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------
	MODULE AYFX_REPLAYER
	
; --- ayFX REPLAYER v1.31 ---
; --- v1.31	Fixed bug on previous version, only PSG channel C worked
; --- v1.3	Fixed volume and Relative volume versions on the same file, conditional compilation
; ---		Support for dynamic or fixed channel allocation
; --- v1.2f/r	ayFX bank support
; --- v1.11f/r	If a frame volume is zero then no AYREGS update
; --- v1.1f/r	Fixed volume for all ayFX streams
; --- v1.1	Explicit priority (as suggested by AR)
; --- v1.0f	Bug fixed (error when using noise)
; --- v1.0	Initial release

; --- DEFINE AYFXRELATIVE AS 0 FOR FIXED VOLUME VERSION ---
; --- DEFINE AYFXRELATIVE AS 1 FOR RELATIVE VOLUME VERSION ---
AYFXRELATIVE=0

ayFX_MODE:	#	1	; ayFX mode = 1 to switching channel routine
ayFX_BANK:	#	2	; Current ayFX Bank
@ayFX_PRIORITY:	#	1	; Current ayFX stream priotity
ayFX_POINTER:	#	2	; Pointer to the current ayFX stream
ayFX_TONE:	#	2	; Current tone of the ayFX stream
ayFX_NOISE:	#	1	; Current noise of the ayFX stream
ayFX_VOLUME:	#	1	; Current volume of the ayFX stream
ayFX_CHANNEL:	#	1	; PSG channel to play the ayFX stream

	IF ( AYFXRELATIVE == 1 )
ayFX_VT:	#	2	; ayFX relative volume table pointer
	ENDIF

; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
; PT3_AYREGS:	#	14	; Ram copy of PSG registers
; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---

; ---          ayFX replayer setup          ---
; --- INPUT: HL -> pointer to the ayFX bank ---
@ayFX_SETUP:
	ld	[ayFX_BANK],hl		; Current ayFX bank
	xor	a			; a:=0
	ld	[ayFX_MODE],a		; Initial mode: fixed channel
	inc	a			; Starting channel (=1)
	ld	[ayFX_CHANNEL],a	; Updated
; --- End of an ayFX stream ---
ayFX_END:
	ld	a,255			; Lowest ayFX priority
	ld	[ayFX_PRIORITY],a	; Priority saved (not playing ayFX stream)
	ret				; Return
; ---     INIT A NEW ayFX STREAM     ---
; --- INPUT: A -> sound to be played ---
; ---        C -> sound priority     ---
@ayFX_INIT:	
	push	bc			; Store bc in stack
	push	de			; Store de in stack
	push	hl			; Store hl in stack
; --- Check if the index is in the bank ---
	ld	b,a			; b:=a (new ayFX stream index)
	ld	hl,[ayFX_BANK]		; Current ayFX BANK
	ld	a,[hl]			; Number of samples in the bank
	or	a			; If zero (means 256 samples)...
	jr	z,.CHECK_PRI		; ...goto .CHECK_PRI
; The bank has less than 256 samples
	ld	a,b			; a:=b (new ayFX stream index)
	cp	[hl]			; If new index is not in the bank...
	ld	a,2			; a:=2 (error 2: Sample not in the bank)
	jr	nc,.INIT_END		; ...we can't init it
; --- Check if the new priority is lower than the current one ---
; ---   Remember: 0 = highest priority, 15 = lowest priority  ---
.CHECK_PRI:	
	ld	a,b			; a:=b (new ayFX stream index)
	ld	a,[ayFX_PRIORITY]	; a:=Current ayFX stream priority
	cp	c			; If new ayFX stream priority is lower than current one...
	ld	a,1			; a:=1 (error 1: A sample with higher priority is being played)
	jr	c,.INIT_END		; ...we don't start the new ayFX stream
; --- Set new priority ---
	ld	a,c			; a:=New priority
	and	$0F			; We mask the priority
	ld	[ayFX_PRIORITY],a	; new ayFX stream priority saved in RAM
; --- Volume adjust using PT3 volume table ---
	IF ( AYFXRELATIVE == 1 )
	ld	c,a			; c:=New priority (fixed)
	ld	a,15			; a:=15
	sub	c			; a:=15-New priority = relative volume
	jr	z,.INIT_NOSOUND	; If priority is 15 -> no sound output (volume is zero)
	add	a,a			; a:=a*2
	add	a,a			; a:=a*4
	add	a,a			; a:=a*8
	add	a,a			; a:=a*16
	ld	e,a			; e:=a
	ld	d,0			; de:=a
	ld	hl, PT3_VT_			; hl:=PT3 volume table
	add	hl,de			; hl is a pointer to the relative volume table
	ld	[ayFX_VT],hl		; Save pointer
	ENDIF
; --- Calculate the pointer to the new ayFX stream ---
	ld	de,[ayFX_BANK]		; de:=Current ayFX bank
	inc	de			; de points to the increments table of the bank
	ld	l,b			; l:=b (new ayFX stream index)
	ld	h,0			; hl:=b (new ayFX stream index)
	add	hl,hl			; hl:=hl*2
	add	hl,de			; hl:=hl+de (hl points to the correct increment)
	ld	e,[hl]			; e:=lower byte of the increment
	inc	hl			; hl points to the higher byte of the correct increment
	ld	d,[hl]			; de:=increment
	add	hl,de			; hl:=hl+de (hl points to the new ayFX stream)
	ld	[ayFX_POINTER],hl	; Pointer saved in RAM
	xor	a			; a:=0 (no errors)
.INIT_END:
	pop	hl			; Retrieve hl from stack
	pop	de			; Retrieve de from stack
	pop	bc			; Retrieve bc from stack
	ret				; Return

; --- Init a sample with relative volume zero -> no sound output ---
	IF ( AYFXRELATIVE == 1 )
.INIT_NOSOUND:
	ld	a,255			; Lowest ayFX priority
	ld	[ayFX_PRIORITY],a	; Priority saved (not playing ayFX stream)
	jr	.INIT_END		; Jumps to .INIT_END
	ENDIF

; --- PLAY A FRAME OF AN ayFX STREAM ---
@ayFX_PLAY:	
	ld	a,[ayFX_PRIORITY]	; a:=Current ayFX stream priority
	or	a			; If priority has bit 7 on...
	ret	m			; ...return
; --- Calculate next ayFX channel (if needed) ---
	ld	a,[ayFX_MODE]		; ayFX mode
	and	1			; If bit0=0 (fixed channel)...
	jr	z,.TAKECB		; ...skip channel changing
	ld	hl,ayFX_CHANNEL		; Old ayFX playing channel
	dec	[hl]			; New ayFX playing channel
	jr	nz,.TAKECB		; If not zero jump to .TAKECB
	ld	[hl],3			; If zero -> set channel 3
; --- Extract control byte from stream ---
.TAKECB:	
	ld	hl,[ayFX_POINTER]	; Pointer to the current ayFX stream
	ld	c,[hl]			; c:=Control byte
	inc	hl			; Increment pointer
; --- Check if there's new tone on stream ---
	bit	5,c			; If bit 5 c is off...
	jr	z,.CHECK_NN		; ...jump to .CHECK_NN (no new tone)
; --- Extract new tone from stream ---
	ld	e,[hl]			; e:=lower byte of new tone
	inc	hl			; Increment pointer
	ld	d,[hl]			; d:=higher byte of new tone
	inc	hl			; Increment pointer
	ld	[ayFX_TONE],de		; ayFX tone updated
; --- Check if there's new noise on stream ---
.CHECK_NN:	
	bit	6,c			; if bit 6 c is off...
	jr	z,.SETPOINTER		; ...jump to .SETPOINTER (no new noise)
; --- Extract new noise from stream ---
	ld	a,[hl]			; a:=New noise
	inc	hl			; Increment pointer
	cp	$20			; If it's an illegal value of noise (used to mark end of stream)...
;	jr	z, ayFX_END		; ...jump to ayFX_END
	jp	z, ayFX_END		; ...jump to ayFX_END
	ld	[ayFX_NOISE],a		; ayFX noise updated
; --- Update ayFX pointer ---
.SETPOINTER:	
	ld	[ayFX_POINTER],hl	; Update ayFX stream pointer
; --- Extract volume ---
	ld	a,c			; a:=Control byte
	and	$0F			; lower nibble
; --- Fix the volume using PT3 Volume Table ---
	IF ( AYFXRELATIVE == 1 )
	ld	hl,[ayFX_VT]		; hl:=Pointer to relative volume table
	ld	e,a			; e:=a (ayFX volume)
	ld	d,0			; d:=0
	add	hl,de			; hl:=hl+de (hl points to the relative volume of this frame
	ld	a,[hl]			; a:=ayFX relative volume
	or	a			; If relative volume is zero...
	ENDIF
	ld	[ayFX_VOLUME],a		; ayFX volume updated
	ret	z			; ...return (don't copy ayFX values in to AYREGS)
; -------------------------------------
; --- COPY ayFX VALUES IN TO AYREGS ---
; -------------------------------------
; --- Set noise channel ---
	bit	7,c			; If noise is off...
	jr	nz,.SETMASKS		; ...jump to .SETMASKS
	ld	a,[ayFX_NOISE]		; ayFX noise value
	ld	[PT3_AYREGS+6],a	; copied in to AYREGS (noise channel)
; --- Set mixer masks ---
.SETMASKS:
	ld	a,c			; a:=Control byte
	and	$90			; Only bits 7 and 4 (noise and tone mask for psg reg 7)
	cp	$90			; If no noise and no tone...
	ret	z			; ...return (don't copy ayFX values in to AYREGS)
; --- Copy ayFX values in to ARYREGS ---
	rrca				; Rotate a to the right (1 TIME)
	rrca				; Rotate a to the right (2 TIMES) (OR mask)
;	ld	d, $DB			; d:=Mask for psg mixer (AND mask)
	ld	d, 0DBH		; d:=Mask for psg mixer (AND mask)
; --- Dump to correct channel ---
	ld	hl,ayFX_CHANNEL		; Next ayFX playing channel
	ld	b,[hl]			; Channel counter
; --- Check if playing channel was 1 ---
.CHK1:
	djnz	.CHK2			; Decrement and jump if channel was not 1
; --- Play ayFX stream on channel C ---
.PLAY_C:	
	call	.SETMIXER		; Set PSG mixer value (returning a=ayFX volume and hl=ayFX tone)
	ld	[PT3_AYREGS+10],a	; Volume copied in to AYREGS (channel C volume)
	bit	2,c			; If tone is off...
	ret	nz			; ...return
	ld	[PT3_AYREGS+4],hl	; copied in to AYREGS (channel C tone)
	ret				; Return
; --- Check if playing channel was 2 ---
.CHK2:
	rrc	d			; Rotate right AND mask
	rrca				; Rotate right OR mask
	djnz	.CHK3			; Decrement and jump if channel was not 2
.PLAY_B:	; --- Play ayFX stream on channel B ---
	call	.SETMIXER		; Set PSG mixer value (returning a=ayFX volume and hl=ayFX tone)
	ld	[PT3_AYREGS+9],a	; Volume copied in to AYREGS (channel B volume)
	bit	1,c			; If tone is off...
	ret	nz			; ...return
	ld	[PT3_AYREGS+2],hl	; copied in to AYREGS (channel B tone)
	ret				; Return
; --- Check if playing channel was 3 ---
.CHK3:
	rrc	d			; Rotate right AND mask
	rrca				; Rotate right OR mask
; --- Play ayFX stream on channel A ---
.PLAY_A:
	call	.SETMIXER		; Set PSG mixer value (returning a=ayFX volume and hl=ayFX tone)
	ld	[PT3_AYREGS+8],a	; Volume copied in to AYREGS (channel A volume)
	bit	0,c			; If tone is off...
	ret	nz			; ...return
	ld	[PT3_AYREGS+0],hl	; copied in to AYREGS (channel A tone)
	ret				; Return
; --- Set PSG mixer value ---
.SETMIXER:	
	ld	c,a			; c:=OR mask
	ld	a,[PT3_AYREGS+7]	; a:=PSG mixer value
	and	d			; AND mask
	or	c			; OR mask
	ld	[PT3_AYREGS+7],a	; PSG mixer value updated
	ld	a,[ayFX_VOLUME]		; a:=ayFX volume value
	ld	hl,[ayFX_TONE]		; ayFX tone value
	ret				; Return
	
	IF ( AYFXRELATIVE == 1 )
; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
; PT3_VT_:	.INCBIN	"VT.BIN"
; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
	ENDIF

	ENDMODULE AYFX_REPLAYER
;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                      F I N                          | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------
