;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                    I N I C I O                      | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------

; -----------------------------------------------------
; --- RUTINAS PARA COLOCAR LAS PAGINAS DEL CARTUCHO ---
; -----------------------------------------------------
; --- SIEMPRE DEBEN IR EN LA PAGINA 1 DEL CARTUCHO! ---
; -----------------------------------------------------
; --- RUTINAS PRINCIPALES DEL MODULO 32K ---
; GETSLOT:	OBTIENE EL VALOR DEL SLOT QUE LE INDIQUEMOS
; SETPAGES32K:	BIOS-ROM-YY-ZZ	 -> BIOS-ROM-ROM-ZZ (SITUA PAGINA 2)
; --- VARIABLES EN RAM NECESARIAS ---
; NINGUNA
; -----------------------------------------------------
; --- RUTINAS PRINCIPALES DEL MODULO 48K ---
; SETPAGES48K:	BIOS-ROM-YY-ZZ	 -> ROM-ROM-ROM-ZZ (SITUA PAGINAS 2 Y 0, EN ESTE ORDEN)
;               ADEMAS GUARDA LOS SLOTS DEL JUEGO Y LA BIOS POR SI HAY QUE INTERCAMBIAR
; SETGAMEPAGE0:	XX-ROM-YY-ZZ     -> ROM-ROM-YY-ZZ (NO TOCA LA PAGINA 2)
; RESTOREBIOS:  XX-ROM-YY-ZZ     -> BIOS-ROM-YY-ZZ (VUELVE A SITUAR LA BIOS)
; SETPAGE0:	POSICIONA SLOT EN LA PAGINA 0
; --- VARIABLES EN RAM NECESARIAS ---
; SLOTBIOS:	BYTE PARA ALMACENAR EL SLOT DE LA BIOS
; SLOTGAME:	BYTE PARA ALMACENAR EL SLOT DEL JUEGO
; -----------------------------------------------------
	MODULE SETPAGES

DEFINE USAR_SETPAGES48K 1

EXPTBL0 = $FCC1
EXPTBL1 = $FCC2
EXPTBL2 = $FCC3
EXPTBL3 = $FCC4
ENASLT  = $0024

; --- Rutina que construye el valor del SLOT para llamar a ENASLT ---
; --- Entrada: a = SLOT                                           ---
; --- Salida: a = valor para ENASLT                               ---
; --- AUTOR: Konamiman                                            ---
@GETSLOT:
	AND	$03		; Proteccion, nos aseguramos de que el valor esta en 0-3
	LD	C, A		; c = slot de la pagina
	LD	B, 0		; bc = slot de la pagina
	LD	HL, EXPTBL0	; Tabla de slots expandidos
	ADD	HL, BC		; hl -> variable que indica si este slot esta expandido
	LD	A, [HL]		; Tomamos el valor
	AND	$80		; Si el bit mas alto es cero...
	JR	Z, .exit	; ...nos vamos a .exit
	; --- El slot esta expandido ---
	OR	C		; Slot basico en el lugar adecuado
	LD	C, A		; Guardamos el valor en c
[4]	INC	HL		; Incrementamos hl ...cuatro veces
	LD	A, [HL]		; a = valor del registro de subslot del slot donde estamos
	AND	$0C		; Nos quedamos con el valor donde esta nuestro cartucho
.exit:
	OR	C		; Slot extendido/basico en su lugar
	RET			; Volvemos
; --- Posiciona las paginas de un megarom o un 32K ---
@SETPAGES32K:
	LD	A, $C9		; Codigo de RET
	LD	[.nopret], A	; Modificamos la siguiente instruccion si estamos en RAM
.nopret:
	nop			; No hacemos nada si no estamos en RAM
	; --- Si llegamos aqui no estamos en RAM, hay que posicionar la pagina ---
;	CALL	RSLREG		; Leemos el contenido del registro de seleccion de slots
	IN	A, [$A8]	; Leemos el contenido del registro de seleccion de slots
[2]	RRCA			; Rotamos a la derecha...dos veces
	CALL	GETSLOT		; Obtenemos el slot de la pagina 1 ($4000-$BFFF)
	LD	H, $80		; Seleccionamos pagina 2 ($8000-$BFFF)
	JP	ENASLT		; Posicionamos la pagina 2 y volvemos

; --- Posiciona las paginas de un cartucho de 48K ---
IFDEF USAR_SETPAGES48K
SLOTBIOS # 1	; BYTE PARA ALMACENAR EL SLOT DE LA BIOS
SLOTGAME # 1	; BYTE PARA ALMACENAR EL SLOT DEL JUEGO
@SETPAGES48K:	
	CALL	SETPAGES32K	; Colocamos la pagina 2 del cartucho
; --- Guardamos el slot de la BIOS por si tenemos que restaurarla ---
	LD	A, [EXPTBL0]	; Valor del slot de la BIOS
	LD	[SLOTBIOS], A	; Grabamos el slot de la BIOS para recuperarlo si hace falta
; --- Guardamos el slot del juego por si hay que restaurarlo ---
	IN	A, [$A8]	; Leemos el contenido del registro de seleccion de slots
[2]	RRCA			; Rotamos a la derecha...dos veces
	CALL	GETSLOT		; Obtenemos el slot de la pagina 1 ($4000-$7FFF) y volvemos
	LD	[SLOTGAME], A	; Grabamos el slot del juego para recuperarlo si hace falta
; --- RUTINA QUE POSICIONA LA PAGINA 0 DEL JUEGO ---
; ---     ANTES HAY QUE LLAMAR A SETPAGES48K     ---
@SETGAMEPAGE0:	
	LD	A, [SLOTGAME]	; Leemos el slot del juego
	JP	SETPAGE0	; Situamos la pagina 0 del juego y volvemos
; --- RUTINA QUE VUELVE A SITUAR LA BIOS ---
; --- ANTES HAY QUE LLAMAR A SETPAGES48K ---
@RESTOREBIOS:	
	LD	A, [SLOTBIOS]	; Leemos el slot de la BIOS
; --- RUTINA QUE POSICIONA SLOT EN LA PAGINA 0 ---
; --- AUTOR: Ramones                           ---
; --- ENTRADA: a = slot con formato FxxxSSPP   ---
SETPAGE0:	
	DI			; Desactivamos las interrupciones
	LD	B, A		; Guardamos el slot
	IN	A, [$A8]	; Leemos el registro principal de slots
	AND	$FC		; Nos quedamos con los valores de las tres paginas superiores
	LD	D, A		; D = Valor del slot primario
	LD	A, B		; Recuperamos el slot
	AND	$03		; Nos fijamos en el slot primario
	OR	D		; Colocamos los bits de las paginas superiores
	LD	D, A		; Guardamos en D el valor final para el slot primario
	; Comprobamos si esta expandido
	LD	A, B		; Recuperamos el slot
	BIT	7, A		; Miramos el bit de expansion
	JR	Z, .setprimary	; ...y saltamos si no esta expandido
	; Si llegamos aqui el slot esta expandido
	AND	$03		; Nos quedamos con el slot primario
[2]	RRCA			; Rotamos ciclicamente a la derecha una...y dos veces
	LD	C, A		; Guardamos el valor en c
	LD	A, D		; Recuperamos el valor final para el slot primario
	AND	$3F		; Nos quedamos con las paginas 0, 1 y 2
	OR	C		; Colocamos los bits para la pagina 3
	LD	C, A		; C:=valor del slot primario incluso en pagina 3
	LD	A, B		; Recuperamos otra vez el slot
	AND	$0C		; Nos quedamos con el valor del subslot
[2]	RRCA			; Rotamos ciclicamente a la derecha una...y dos veces
	LD	B, A		; B:= Slot expandido en pagina 3
	LD	A, c		; valor del slot primario incluyendo pagina 3
	OUT	[$A8], A	; Slots : Primario, xx, xx, Primario
	LD	A,[$FFFF]	; Leemos registro de seleccion de subslots
	CPL			; Complementamos (recordemos que siempre hay que complementarlo)
	AND	$FC		; Nos quedamos con las paginas superiores
	OR	b		; Colocamos el valor del slot expandido en pagina 0
	LD	[$FFFF], A	; Seleccionamos el slot expandido
.setprimary:			; --- Colocamos el slot primario ---
	LD	A, D		; Valor final del slot primario
	OUT	[$A8], A	; Slots: Seleccionado, xx, xx, Ram
	RET			; Volvemos
ENDIF

	ENDMODULE SETPAGES

;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                      F I N                          | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------
