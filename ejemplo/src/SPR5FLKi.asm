; ==============================================================================
;   SPR5FLKi.asm
;   sprite flicker
;   by mvac7/303bcn 2017 
;   Assemble with Sjasm Z80 v0.42c from XL2S Entertainment 
;                 http://xl2s.eu.pn/sjasm.html
; ==============================================================================


;  output SPR5FLKi.ROM ; Mejor por línea de comandos
	DEFPAGE 1, 4000h, 4000h   ;16k

VDPVRAM   EQU   $98 ;VRAM Data (Read/Write)
VDPSTATUS EQU   $99 ;VDP Status Registers


;system vars -------------------------------------------------------------------
MSXVER EQU $002D

HTIMI  EQU $FD9F  ;Interrupt handler

FORCLR EQU $F3E9 ;Foreground colour
BAKCLR EQU $F3EA ;Background colour
BDRCLR EQU $F3EB ;Border colour
CLIKSW EQU $F3DB ;0 disabled / 1 enabled
RG1SAV EQU $F3E0 ;VDP REG 1
EXTVDP EQU $FFE7 ;


;BIOS (info by MSX Assembly Page) ----------------------------------------------
;http://map.grauw.nl/resources/msxbios.php
DISSCR EQU $0041 ;inhibits the screen display
ENASCR EQU $0044 ;displays the screen
WRTVDP EQU $0047 ;write data in the VDP-register
RDVRM  EQU $004A ;Reads the content of VRAM
WRTVRM EQU $004D ;Writes data in VRAM
SETRD  EQU $0050 ;Enable VDP to read
SETWRT EQU $0053 ;Enable VDP to write
FILVRM EQU $0056 ;fill VRAM with value
LDIRMV EQU $0059 ;Block transfer to memory from VRAM
LDIRVM EQU $005C ;Block transfer to VRAM from memory
CHGMOD EQU $005F ;Switches to given screenmode
CHGCLR EQU $0062 ;Changes the screencolors
CLRSPR EQU $0069 ;Initialises all sprites
INITXT EQU $006C ;Switches to SCREEN 0 (text screen with 40 * 24 characters)
INIT32 EQU $006F ;Switches to SCREEN 1 (text screen with 32*24 characters)
INIGRP EQU $0072 ;Switches to SCREEN 2 (high resolution screen with 256*192 pixels)
INIMLT EQU $0075 ;Switches to SCREEN 3 (multi-color screen 64*48 pixels)
SETTXT EQU $0078 ;Switches to VDP in SCREEN 0 mode
SETT32 EQU $007B ;Switches VDP in SCREEN mode 1
SETGRP EQU $007E ;Switches VDP to SCREEN 2 mode
SETMLT EQU $0081 ;Switches VDP to SCREEN 3 mode
CALPAT EQU $0084 ;Returns the address of the sprite pattern table
CALATR EQU $0087 ;Returns the address of the sprite attribute table
GSPSIZ EQU $008A ;Returns current sprite size
GRPPRT EQU $008D ;Displays a character on the graphic screen

GICINI EQU $0090 ;Initialises PSG and sets initial value for the PLAY statement
WRTPSG EQU $0093 ;Writes data to PSG-register
RDPSG  EQU $0096 ;Reads value from PSG-register

; more BIOS functions
CHKRAM EQU $0000 ;Tests RAM and sets RAM slot for the system
ENASLT EQU $0024 ;Switches indicated slot at indicated page on perpetual
CHGET  EQU $009F ;One character input
POSIT  EQU $00C6
GTSTCK EQU $00D5 ;Returns the joystick status
GTTRIG EQU $00D8 ;Returns current trigger status
SNSMAT EQU $0141 ;Returns the value of the specified line from the keyboard matrix
KILBUF EQU $0156 ;Clear keyboard buffer
; ------------------------------------------------------------------------------





;constants ---------------------------------------------------------------------
;screen 1
BASE5  EQU $1800 ;name table
BASE6  EQU $2000 ;color table
BASE7  EQU $0000 ;character pattern table

;screen 2
BASE10 EQU $1800 ;name table
BASE11 EQU $2000 ;color table
BASE12 EQU $0000 ;character pattern table
BASE13 EQU $1B00 ;sprite attribute table
BASE14 EQU $3800 ;sprite pattern table


; Flicker Sprites --------------------------------------------------------------
SPRFLK_INIT   EQU  6 ;<--- sprite first layer where the inversion is applied
SPRFLK_END    EQU 12 ;<--- last layer of the range of sprites +1
SPRLENGTH     EQU 32 ;total sprites 
; ------------------------------------------------------------------------------




;variables and buffers (RAM) ---------------------------------------------------
SPR0YSIN  EQU $E000       ;(1B) Y value for sprite0
SPR1YSIN  EQU SPR0YSIN+1  ;(1B) Y value for sprite1
SPR2YSIN  EQU SPR1YSIN+1  ;(1B) Y value for sprite2

; for sprite flicker
SPR_FIELD EQU SPR2YSIN+1  ;(1B) VBLANK Frame control
OAMBUF    EQU SPR_FIELD+1 ;(32*4=128B) OAM copy
OAM2BUF   EQU OAMBUF+128  ;(32*4=128B) OAM modified for copy to VRAM(inversion)
; ------------------------------------------------------------------------------




;ROM HEADER ####################################################################

	page 1

	code                        

	db  $41
	db  $42
	dw  INIT
	dw  $0000
	dw  $0000
	dw  $0000
	dw  $0000
	dw  $0000
	dw  $0000
 

INIT:
	di
	ld   SP,[$fc4a] ; Stack at the top of memory.
	ei
; ##############################################################################  	


;init vars
	xor  A  ;put a 0
	ld   [CLIKSW],A    ;keys click off
	ld   [SPR_FIELD],A
	ld   [SPR0YSIN],A  
  
	ld   A,100
	ld   [SPR1YSIN],A
  
	//ld   A,128
	//ld   [SPR2YSIN],A
    
  
;color 15,4,4 
	LD	HL,FORCLR
	LD	[HL],15
	INC	HL
	LD	[HL],4
	INC	HL	
	LD	[HL],4
	call CHGCLR 
  
;screen1
	ld   A,1
	call CHGMOD
	
;set sprite mode (16x16 nozoom)
	ld   DE,$0100
	call SETUPSPRITES
  
  
;copy sprite patterns from memory to VRAM  
	ld   HL,SPRITE_DATA
	ld   DE,BASE14  
	ld   BC,32*7  ;32*num patterns
	call LDIRVM  
  
;copy tile pattern(8) from memory to VRAM 
	ld   HL,TILE8
	ld   DE,BASE7 +(8*8)  
	ld   BC,8
	call LDIRVM
  
;write tile color in VRAM 
	ld   HL,BASE6+1
	ld   A,$9E
	call WRTVRM
  
;write 8 tile in two lines of the screen
;imprime el tile 8 en dos lineas de la pantalla
	ld   A,8
	ld   HL,BASE5+(2*32)
	ld   BC,64  
	call FILVRM

;copy the sprite attributes(OAM) to OAMBUF buffer 
	ld   HL,SPRITE_ATTRS
	ld   DE,OAMBUF  
	ld   BC,4*SPRLENGTH
	LDIR

;install interrupt hook
	ld   A,$C3
	ld   [HTIMI],A
	ld   HL,HOOK
	ld   [HTIMI+1],HL
  
MAINLOOP:
	HALT  ;wait to VBLANK
  
  ;move sprites
	ld   IX,OAMBUF   ;buffer principal (OAM)
  
	ld   HL,SPR0YSIN
	call GETA_YPOS  
	ld   [IX],A      ;Y from 0 sprite layer
  
	ld   HL,SPR1YSIN
	call GETA_YPOS  
	ld   [IX+36],A   ;Y from 9 sprite layer
	//ld   [IX+44],A   ;Y from 11 sprite layer
  
	CALL SPRflicker  ;Call the Sprite Fliker routine.
  

	JR  MAINLOOP 	;Hasta el infinito y más alla!  ;)
			;To infinity and beyond!

;Provides a screen coordinate value from an index value (A)
;proporciona un valor de coordenada de pantalla apartir de un valor de indice (A)
GETA_YPOS:
	ld   A,[HL]
	inc  [HL]
  
	ld   HL,SINEDATA
	ld   D,0
	ld   E,A
	add  HL,DE
	ld   A,[HL]
	ret

;captain -->
HOOK:
	DI
  
	push HL
	push DE
	push BC
  
	ld   HL,OAM2BUF  
	ld   DE,BASE13  
	ld   BC,4*SPRLENGTH
	call LDIRVM            ;vuelca el segundo buffer a la tabla OAM de la VRAM 
  
	pop  BC
	pop  DE
	pop  HL
  
	EI
	ret  
 


; ------------------------------------------------------------------------------
; Sprite Flicker (inversion)

; * Needs a buffer (OAMBUF), with values of sprite attributes (OAM), where 
;   sprites changes are written.
; * Needs a second buffer (OAM2BUF), where the changes are made to generate the 
;   sprite fliker. This buffer is the one that dump to the OAM of the VRAM.
; * Needs a byte (SPR_FIELD) to control the flicker frame.

; * Necesita de un buffer principal (OAMBUF) con los valores de los atributos de sprite (OAM)
;   donde se escribe los cambios de los sprites 
; * Necesita un segundo búfer (OAM2BUF), donde se realizan los cambios para 
;   generar el parpadeo de los sprites. Este buffer es el que se vuelca al OAM 
;   de la VRAM.
; * Necesita de un byte (SPR_FIELD) para controlar el frame del parpadeo.
SPRflicker:
 
	ld   A,[SPR_FIELD]
	inc  A
	CP   2
	jr   Z,PUT_A0
  
	ld   [SPR_FIELD],A  ;1
  
  ;copy to second buffer (OAM2BUF) 
	ld   HL,OAMBUF
	ld   DE,OAM2BUF  
	ld   BC,4*SPRLENGTH
	LDIR
  
	ret
  

;Reverses the position of the Sprite attributes.
;Invierte la posicion de los atributos de Sprite.
PUT_A0:
	xor  A
	ld   [SPR_FIELD],A  ;0

	ld   HL,OAMBUF  + (4*SPRFLK_INIT)
	ld   DE,OAM2BUF + (4*SPRFLK_END) - 4
  
	ld   B,SPRFLK_END - SPRFLK_INIT
  
NEXTSPR:
	push  BC
	push  DE
    
	ld   BC,4
	ldir
  
	pop  DE
  
	dec  DE
	dec  DE
	dec  DE
	dec  DE
  
	pop  BC
	djnz NEXTSPR

	ret
; ------------------------------------------------------------------------------
  



  

; Set size and zoom mode of the sprites
; D size -> 0=8x8, 1=16x16
; E zoom -> 1=x2
SETUPSPRITES:
 
  ;in A,(VDPSTATUS)
  
	ld B,0
  
	ld A,D
	cp 1
	jr NZ,STSP1
	set 1,b ; --- if 16x16 sprites => set bit 1

STSP1:
	ld A,E
	cp 1
	jr NZ,STSP2
	set 0,b ; --- if zoom sprites => set bit 0

STSP2:
	ld HL,RG1SAV ; --- read vdp(1) from mem
	ld A,[HL]
	and $fc
	or B
  
	ld  B,A
	ld  C,$01
	call  WRTVDP
  
	ret

;SPRITE ATRIBUTE DATAS #########################################################
;Y,X,PATTERN,COLOR  (PATTERN*4 in 16x16 mode)
SPRITE_ATTRS:
  db 50,60,0,2   ; pepinillo
    
  db 15,0,124,0
  db 15,0,124,0
  db 15,0,124,0
  db 15,0,124,0
  
  db 50,80,4,11
  db 50,100,8,3
  db 50,120,16,8
  
  db 42,140,12,14
  db 50,160,20,15
  db 58,180,12,12             
  db 50,200,24,10
  
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
  db 192,0,124,0
;END SPRITE ATRIBUTE DATAS #####################################################


; Sprite Patterns Data
SPRITE_DATA:
  ; 0-PEPINO
  db $0F,$1F,$3D,$3F,$7B,$7C,$BF,$BF
  db $9F,$EF,$6F,$1F,$0F,$05,$05,$1D
  db $C0,$E0,$60,$C0,$40,$80,$80,$84
  db $86,$DE,$C0,$C0,$80,$00,$00,$C0
  ; 1-ONION
  db $05,$07,$1A,$2E,$6F,$5B,$5C,$5B
  db $5F,$58,$6F,$2D,$16,$02,$02,$06
  db $40,$C0,$B8,$D4,$D4,$6A,$EA,$6A
  db $EA,$6A,$D4,$D4,$F8,$40,$40,$60
  ; 2-PEAR
  db $03,$07,$4F,$CF,$4D,$4F,$2C,$1E
  db $3F,$3F,$3F,$3F,$1F,$02,$02,$06
  db $C0,$E2,$E6,$E2,$A2,$F4,$38,$7C
  db $FE,$FE,$FE,$FC,$F8,$40,$40,$60
  ; 3-mushroom
  db $05,$1E,$3F,$6F,$57,$6E,$3F,$00
  db $07,$05,$07,$04,$06,$03,$02,$06
  db $60,$F8,$F4,$EA,$76,$BE,$7C,$00
  db $E0,$60,$E0,$20,$60,$C0,$40,$60
  ; 4-TOMATO
  db $05,$07,$1F,$3F,$7F,$7F,$7F,$7D
  db $7F,$7F,$78,$3F,$1F,$04,$04,$0C
  db $40,$C0,$F0,$F8,$FC,$FC,$FC,$7C
  db $FC,$FC,$3C,$F8,$F0,$40,$40,$60
  ; 5-Orange
  db $07,$1F,$3F,$3F,$7F,$71,$7F,$7F
  db $7F,$7E,$3E,$3F,$1F,$07,$02,$06
  db $E0,$F8,$FC,$FC,$FE,$8E,$FE,$FE
  db $FE,$7E,$7C,$FC,$F8,$E0,$40,$60
  ; 6-LEMON
  db $00,$07,$1F,$3F,$7F,$71,$FF,$FF
  db $7B,$7C,$3F,$1F,$07,$02,$02,$06
  db $00,$E0,$F8,$FC,$FE,$8E,$FF,$FF
  db $DE,$3E,$FC,$F8,$E0,$40,$40,$60

; tile 8 pattern
TILE8:
  db $FE,$FE,$FE,$00,$EF,$EF,$EF,$00

; Sine
; Length= 256
SINEDATA:
  db $32,$33,$34,$36,$37,$38,$39,$3B,$3C,$3D,$3E,$3F,$41,$42,$43,$44
  db $45,$46,$47,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55
  db $55,$56,$57,$58,$59,$5A,$5A,$5B,$5C,$5C,$5D,$5E,$5E,$5F,$5F,$60
  db $60,$61,$61,$62,$62,$62,$63,$63,$63,$63,$63,$64,$64,$64,$64,$64
  db $64,$64,$64,$64,$64,$64,$63,$63,$63,$63,$62,$62,$62,$61,$61,$61
  db $60,$60,$5F,$5E,$5E,$5D,$5D,$5C,$5B,$5B,$5A,$59,$58,$58,$57,$56
  db $55,$54,$53,$52,$51,$50,$4F,$4E,$4D,$4C,$4B,$4A,$49,$48,$47,$46
  db $45,$43,$42,$41,$40,$3F,$3E,$3C,$3B,$3A,$39,$38,$36,$35,$34,$33
  db $31,$30,$2F,$2E,$2C,$2B,$2A,$29,$28,$26,$25,$24,$23,$22,$21,$1F
  db $1E,$1D,$1C,$1B,$1A,$19,$18,$17,$16,$15,$14,$13,$12,$11,$10,$0F
  db $0E,$0D,$0C,$0C,$0B,$0A,$09,$09,$08,$07,$07,$06,$06,$05,$04,$04
  db $03,$03,$03,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$03,$03,$04
  db $04,$05,$05,$06,$06,$07,$08,$08,$09,$0A,$0A,$0B,$0C,$0D,$0E,$0F
  db $0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1D,$1E,$1F
  db $20,$21,$22,$23,$25,$26,$27,$28,$29,$2B,$2C,$2D,$2E,$30,$31,$32

	end

