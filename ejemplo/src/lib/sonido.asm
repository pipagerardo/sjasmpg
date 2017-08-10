;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                    I N I C I O                      | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------

SONIDO_50HZ	=	$80	; Intenta usar 50Hz CF = 0
SONIDO_60HZ	=	$00	; Intenta usar 60Hz CF = 0

	MODULE SONIDO

INCLUDE	"ayFX_replayer.asm"
INCLUDE	"PT3_replayer.asm"

; SONIDO_BIOS=1	; Se usan las funciones de la BIOS
;SONIDO_BIOS=0	; No se usa la BIOS para nada.

; AÑADIDO PARA SOPORTE 50 Y 60 HZ
PT3_HERCIOS	#	1	; 50Hz = $80 <-> 60Hz = $00
PT3_60_50:	#	1
PT3_AYREGS_BAK:	#	14

;-----------------------------------------------------------
@INICIA_SONIDO:
; Entrada:	A	La frecuencia SONIDO_50HZ | SONIDO_60HZ
; Salida:	--
;-----------------------------------------------------------
	LD 	[PT3_HERCIOS], A	; ASOPORTE 50 Y 60 HZ
;	CALL	PARA_MUSICA
;	CALL	PARA_SONIDO
	CALL	QUITA_SONIDO
	XOR	A			; A = 0;
	LD 	[PT3_60_50], A
	LD 	A, [PT3_HERCIOS]	; ASOPORTE 50 Y 60 HZ
	AND 	$80
	RET NZ
	LD	A, 6
	LD	[PT3_60_50], A		; FIN SOPORTE 50 Y 60 Hz	
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
@QUITA_SONIDO:
	DI
	CALL	PARA_MUSICA
	CALL	PARA_SONIDO
	CALL	LIMPIA_SONIDO
	EI
	CALL 	GICINI			; initialize PSG (GICINI = $0090)
	HALT
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
LIMPIA_SONIDO:
; Borra los buffer de sonido y actualiza los registros  PSG 
; para que no se escuche pitidos
; Requisitos:	Desactivar las interrupciones.
;-----------------------------------------------------------
	LD	HL, 0
	LD	[PT3_AYREGS+0], HL
	LD	[PT3_AYREGS+2], HL
	LD	[PT3_AYREGS+4], HL
	LD	[PT3_AYREGS+6], HL
	LD	[PT3_AYREGS+8], HL
	LD	[PT3_AYREGS+10], HL
	LD	[PT3_AYREGS+12], HL
	LD	HL, PT3_AYREGS
	LD	DE, PT3_AYREGS_BAK
	LD	BC, 14
	LDIR
	CALL	PT3_ROUT
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
@ACTUALIZA_SONIDO:
; Requisitos:	Desactivar las interrupciones.
;-----------------------------------------------------------
	CALL	PT3_ROUT	; Write values on PSG registers
;	CALL	PT3_PLAY	; Calculates PSG values for next frame
	CALL	PT3_PLAYMUSIC	; Mejora PT3_PLAY dando soporte a 60Hz
	CALL	ayFX_PLAY	; Fx
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
@REPRODUCE_MUSICA:
; Entradas:	A	0 con bucle y 1 sin bucle
;		HL	Módulo PT3
;-----------------------------------------------------------
	LD	[PT3_SETUP], A
	CALL	PT3_INIT	; Inits PT3 player
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
@PARA_MUSICA:
;-----------------------------------------------------------
	LD	A, 1		 ; A=0 con bucle; A=1 sin bucle
	LD	[PT3_SETUP], A
	LD	HL, EMPTYSAMORN
	CALL	PT3_INIT
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
@REPRODUCE_SONIDO:
;-----------------------------------------------------------
; Entrada:	HL	Modulo AFB
;		C	Prioridad [0~15]
; Salida:	--
; Registros:	AF
;-----------------------------------------------------------
	CALL	ayFX_SETUP
	LD	A, 0		; Num. sample [0~255]
	CALL	ayFX_INIT
	RET
;-----------------------------------------------------------	

;-----------------------------------------------------------
@PARA_SONIDO:
;-----------------------------------------------------------
	LD	A, 255			; Lowest ayFX priority
	LD	[ayFX_PRIORITY], A	; Priority saved (not playing ayFX stream)
	RET
;-----------------------------------------------------------

;-----------------------------------------------------------
PT3_PLAYMUSIC:
; AÑADIDO PARA SOPORTE 50 Y 60 HZ
;-----------------------------------------------------------
	LD	A, [PT3_HERCIOS]
	AND	128
	JP NZ,	PT3_PLAY
	LD 	A, [PT3_60_50]
	DEC 	A
	LD 	[PT3_60_50], A
	JP Z,	.RESTORECOPY
	CALL 	PT3_PLAY
	LD 	HL, PT3_AYREGS
	LD 	DE, PT3_AYREGS_BAK
	LD 	BC, 14
	LDIR
	RET
.RESTORECOPY:
	LD 	A, 6
	LD	[PT3_60_50], A
	LD	HL, PT3_AYREGS_BAK
	LD	DE, PT3_AYREGS
	LD	BC, 14
	LDIR
	RET
;-----------------------------------------------------------

	ENDMODULE SONIDO
;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                      F I N                          | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------

