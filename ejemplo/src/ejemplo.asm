;-----------------------------------------------------------
; DIRECTIVAS PARA EL ENSAMBLADOR ( SjasmPG )
;-----------------------------------------------------------
;	OUTPUT ejemplo.rom		; Mejor por línea de comandos
	DEFPAGE 0, $0000, $4000 	; ROM 16K
	DEFPAGE 1, $4000, $8000		; ROM 32K
	MAP	   $C000		; RAM 16K
;-----------------------------------------------------------

;-----------------------------------------------------------
; PAGINA 0
;-----------------------------------------------------------
	PAGE	0
	CODE @	$0000
	DW	$0000		; 2 bytes sin cabecera

INCLUDE "lib/depletter.asm"
musica01	INCBIN "snd/SG_boot1.pt3.plet5"
labbaymsx_chr	INCBIN "grf/phantis.chr.plet5"
labbaymsx_clr	INCBIN "grf/phantis.clr.plet5"

fin_de_rom0
;-----------------------------------------------------------

;-----------------------------------------------------------
; PAGINA 1
;-----------------------------------------------------------
	PAGE	1			; Seleccionamos nuestra ROM
	CODE @	$4000
	DB	$41, $42		; Cartucho ROM
	DW	INICIO	 		; Dirección de Inicio
	DW	0, 0, 0, 0, 0, 0	; 12 Bytes para completar	
;-----------------------------------------------------------
; INCLUIR LIBRERIAS PARA EL USUARIO
;-----------------------------------------------------------
INCLUDE "lib/bios.asm"		; BIOS
INCLUDE "lib/setpages.asm"	; ROM 48K
INCLUDE "lib/sonido.asm"

ACTIVA_BIOS
	CALL	RESTOREBIOS
	EI
	RET
	
QUITA_BIOS
	DI
	CALL	SETGAMEPAGE0
	RET
	
ENGANCHA	; Engancha una función a ejecutar por cada interrupción de VDP.
	DI	; Entrada:	LD	HL, FUNCION
	LD 	A, $C3		; ASMCODE_JP
	LD	[TIMI], A
	LD	[TIMI+1], HL
	EI
	RET
	
DESENGANCHA
	DI
	LD 	A, $C9		; ASMCODE_RET
	LD	[TIMI], A
	LD	[TIMI+1], A
	EI
	RET
	
;-----------------------------------------------------------
; DEFINIR CONTANTES PARA EL USUARIO
;-----------------------------------------------------------	
ANCHO	=	40 	; Constante ANCHO=40
ALTO	=	23	; Constante ALTO=23
TEXTO	DB "ADIOS", 0
TEXTO_DES_MUSICA DB "DESCOMPRIMIENDO LA MUSICA", 0

;---------------------------------------------------------
; VARIABLES EN 16K DE RAM A PARTIR DE $C000:
;---------------------------------------------------------
VARIABLE  # 1		; Variable de 1 Byte
VARIABLE2 # 2		; Variable de 2 Bytes.
BUFFER    # 2048	; Un bonito buffer de 256 Bytes

;-----------------------------------------------------------
; ETIQUETAS:			TIEMPO
;	INSTRUCCIONES			COMENTARIOS
;-----------------------------------------------------------
INICIO
	DI
	IM	1		; ACTIVAR EL MODO DE INTERRUPCIÓN 1
	LD	SP,  [HIMEM] 	; [HIMEM] = [$FC4A]
	CALL	SETPAGES48K
	CALL	RESTOREBIOS
	EI

; MOSTRAMOS TEXTO EN PANTALLA:
	LD	A, 40		; A=40
	LD	[LINL40], A	; Definimos 40 como ancho de línea.
	CALL	INITXT		; SCREEN 0 texto de 40 x 24 con 2 colores
	CP	A		; (A-A)==0 -> Z=1
	CALL	CLS 		; Limpia la pantalla machaca AF, BC y DE
	LD	H , 10		; Situamos la Columna X
	LD	L , 10		; y la Fila Y para 
	CALL	POSIT		; fijar el cursor a escribir.
	LD	HL, TEXTO_DES_MUSICA
	CALL	PRINTXT

; DESCOMPRIMIMOS LA MUSICA
	CALL	QUITA_BIOS
	LD	HL, musica01
	LD	DE, BUFFER
	CALL	DEPLETTER
	CALL	ACTIVA_BIOS
	
; INICIAMOS EL SONIDO A 50Hz
	LD	A, SONIDO_50HZ
	CALL	INICIA_SONIDO
	LD	A, 0			; 0 con bucle y 1 sin bucle
	LD	HL, BUFFER		; En página 0 así que hay que quitar la bios
	CALL	REPRODUCE_MUSICA
	LD	HL, ACTUALIZA_SONIDO
	CALL	ENGANCHA

; IMPRIMIMOS CARACTERES POR TODA LA PANTALLA
	LD	D, 'A'		; D='A'
.BUCLE				; Etiqueta local
	CALL	IMPRIME		; Imprimir la pantalla
	INC	D		; ++D;
	LD	A, 'Z'+1	; A='Z'+1
	LD	[VARIABLE], A
	LD	A, [VARIABLE]
	CP	D		; (A-D)
	JP	NZ, .BUCLE	; if(A!=0) goto .BUCLE;

; QUITAMOS LA MUSICA:
	CALL	DESENGANCHA	; Primero desenganchar la funcion
	CALL	QUITA_SONIDO	; Limpiar el sonido que quede.
	
; MOSTRAMOS UNA IMAGEN EN PANTALLA
	CALL	INIGRP
	CALL	QUITA_BIOS
	LD	HL, labbaymsx_chr
	LD	DE, CHRTBL
	CALL	DEPLETTER_VRAM
	LD	HL, labbaymsx_clr
	LD	DE, CLRTBL
	CALL	DEPLETTER_VRAM
	CALL	ACTIVA_BIOS
	
; ESPERAMOS 5 SEGUNDOS:
[250]	HALT

; MOSTRAMOS MENSAGE DE ADIOS:
	CALL	INITXT		; SCREEN 0 texto de 40 x 24 con 2 colores
	CP	A		; (A-A)==0 -> Z=1
	CALL	CLS 		; Limpia la pantalla machaca AF, BC y DE
	LD	H , 15		; Situamos la Columna X
	LD	L , 10		; y la Fila Y para 
	CALL	POSIT		; fijar el cursor a escribir.
	LD	HL, TEXTO
	CALL	PRINTXT

; FINAL
FINAL
	HALT
	JP	FINAL
	
;---------------------------------------------------------
IMPRIME
; RUTINA QUE IMPRIME EL TEXTO EN PANTALLA
; ENTRADAS: 	D
; MODIFICA:		AF, BC, y  HL
;---------------------------------------------------------
	LD	H , 1		; H=1;		Situamos la Columna X
	LD	L , 1		; L=1;		y la Fila Y para 
	CALL	POSIT		; fijar el cursor a escribir.
	LD	A, D		; A=D;		El carácter a imprimir.
	LD	B, ANCHO	; B=ANCHO;
	LD	C, ALTO		; C=ALTO;
.BUCLE
	CALL	CHPUT		; Escribimos el carácter contenido en A.
	DJNZ	.BUCLE		; --B; if(B!=0) goto .BUCLE;
	LD	B, ANCHO	; B=ANCHO;
	DEC	C		; --C;		Decrementamos ALTO.
	JP	NZ, .BUCLE	; if(C!=0) goto .BUCLE;
	RET			; FIN

; ----------------------------------------------------------
PRINTXT
; Imprime una cadena de texto terminada en cero.
; Entrada:	HL
; Salida:	--
; Registros:	AF y HL
; Ejemplo:
;	LD	H, posX
;	LD	L, posY
;	CALL	POSIT
;	LD	HL, BUFFER
;	CALL	PRINTXT
; ----------------------------------------------------------
.BUCLE
	LD	A, [HL]		; Cogemos el primer carácter.
	OR	A		; CP A, 0
	RET	Z		; Si cero return
	CALL	CHPUT		; escribimos el caracter
	INC	HL 		; ++HL
	JR	.BUCLE		; Si no fin goto @@BUCLE
; ----------------------------------------------------------



;---------------------------------------------------------
; FIN DEL PROGRAMA:
;---------------------------------------------------------
	PRINTSTRDEC "Memoria ROM0 (16K) consumida = ", fin_de_rom0 - $0000
	PRINTSTRDEC "Memoria ROM0 (16K) libre     = ", $4000 - ( fin_de_rom0 - $0000 )
	
fin_de_rom1
	PRINTSTRDEC "Memoria ROM1 (32K) consumida = ", fin_de_rom1 - $4000
	PRINTSTRDEC "Memoria ROM1 (32K) libre     = ", $8000 - ( fin_de_rom1 - $4000 )
	
fin_de_ram # 0
	PRINTSTRDEC "Memoria RAM  (16K) consumida = ", fin_de_ram - $C000
	PRINTSTRDEC "Memoria RAM  (16K) libre     = ", $4000 - ( fin_de_ram - $C000 )
	
	ENDMAP		; FIN DEL MAPA DE MEMORIA
	END		; FIN DE PROGRAMA
;---------------------------------------------------------
