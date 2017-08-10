;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                    I N I C I O                      | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------

;-----------------------------------------------------------
;                           I N D E X
;-----------------------------------------------------------
; Functions:					Line:
; 	RSTs					34
;	I/O initialisation			167
;	VDP access				185
;	PSG					396
;	Keyboard, CRT, printer input-output	428
;	Game I/O access				551
;	Cassette input-output routine		582
;	Miscellaneous				653
; Constants:					758
; 	MSX I/O Ports				762
; 	VRAM addresses				909
; Variables:					1001
; 	System Variables located in Main ROM	1005
; 	System Variables located in RAM		1034
;	System work area			1062
;       Hook area				1331
;	Program for expansion BIOS calls	1343
;	Register Area for new VDP(9938)		1349
;	MAIN-ROM slot address			1368
;	slot selection register			1377
;-----------------------------------------------------------

;-----------------------------------------------------------
;                          RSTs
;-----------------------------------------------------------

;-----------------------------------------------------------
CHKRAM	= $0000
; Function:	tests RAM and sets RAM slot for the system
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
SYNCHR	= $0008
; Funtcion:	tests whether the character of [HL] is the specified
;		character. If not, it generates SYNTAX ERROR, otherwise it
;		goes to CHRGTR (0010H).
; Input:	set the character to be tested in [HL] and the character to
;		be compared next to RST instruction which calls this routine
;		(inline parameter).
;
;		Example:	LD	HL,LETTER
;				RST	08H
;				DB	"A"
;					 .
;					 .
;					 .
;			LETTER: DB	"B"
;
; Output:	HL is increased by one and A receives [HL]. When the tested
;		character is numerical, the CY flag is set; the end of the
;		statement (00H or 3AH) causes the Z flag to be set.
; Registers:	AF, HL
;-----------------------------------------------------------
RDSLT	= $000C
; Function:	selects the slot corresponding to the value of A and reads
;		one byte from the memory of the slot. When this routine is
;		called, the interrupt is inhibited and remains inhibited
;		even after execution ends.
; Input:	A for the slot number.
;
;		 F000EEPP
;		 -   ----
;		 |   ||++-------------- Basic slot number (0 to 3)
;		 |   ++---------------- Expansion slot number (0 to 3)
;		 +--------------------- "1" when using expansion slot
;
;		HL for the address of memory to be read
; Output:	the value of memory which has been read in A
; Registers:	AF, BC, DE
;-----------------------------------------------------------
CHRGTR	= $0010
; Function:	gets a character (or a token) from BASIC text
; Input:	[HL] for the character to be read
; Output:	HL is incremented by one and A receives [HL]. When the
;		character is numerical, the CY flag is set; the end of the
;		statement causes the Z flag to be set.
; Registers:	AF, HL
;-----------------------------------------------------------
WRSLT	= $0014
; Function:	selects the slot corresponding to the value of A and writes
;		one byte to the memory of the slot. When this routine is
;		called, interrupts are inhibited and remain so even after
;		execution ends.
; Input:	specifies a slot with A (same as RDSLT)
; Output:	none
; Registers:	AF, BC, D
;-----------------------------------------------------------
OUTDO	= $0018
; Funtion:	sends the value to current device
; Input:	A for the value to be sent
;		   sends output to the printer when PTRFLG (F416H) is other
;		    than 0
;		   sends output to the file specified by PTRFIL (F864H) when
;		    PTRFIL is other than 0
; Output:	none
; Registers:	none
;-----------------------------------------------------------
CALSLT	= $001C
;  Function:	calls the routine in another slot (inter-slot call)
;  Input:	specify the slot in the 8 high order buts of the IY register
;		(same as RDSLT). IX is for the address to be called.
;  Output:	depends on the calling routine
;  Registers:	depends on the calling routine
;-----------------------------------------------------------
DCOMPR	= $0020
;  Function:	compares the contents of HL and DE
;  Input:	HL, DE
;  Output:	sets the Z flag for HL = DE, CY flag for HL < DE
;  Registers:	AF
;-----------------------------------------------------------
ENASLT	= $0024
; Function:	selects the slot corresponding to the value of A and enables
;		the slot to be used. When this routine is called, interrupts
;		are inhibited and remain so even after execution ends.
; Input:	specify the slot by A (same as RDSLT)
;		specify the page to switch the slot by 2 high order bits of HL
; Output:	none
; Registers:	all
;-----------------------------------------------------------
GETYPR	= $0028
; Function:	returns the type of DAC (decimal accumulator)
; Input:	none
; Output:	S, Z, P/V flags are changed depending on the type of DAC:
;		integer type			single precision real type
;		   C = 1				C = 1
;		   S = 1 *				S = 0
;		   Z = 0				Z = 0;
;		   P/V = 1				P/V = 0 *
;		string type			double precision real type
;		   C = 1				C = 0 *
;		   S = 0				S = 0
;		   Z = 1 *				Z = 0
;		   P/V = 1				P/V = 1
;		Types can be recognised by the flag marked by "*".
; Registers:	AF
;-----------------------------------------------------------
CALLF	= $0030
; Function:	calls the routine in another slot. The following is the
;		calling sequence:
;			RST	30H
;			DB	n	;n is the slot number (same as RDSLT)
;			DW	nn	;nn is the called address
;
; Input:	In the method described above
; Output:	depends on the calling routine
; Registers:	AF, and other registers depending on the calling routine
;-----------------------------------------------------------
KEYINT	= $0038
; Function:	executes the timer interrupt process routine
; Input:	none
; Output:	none
; Register:	none
;-----------------------------------------------------------

;-----------------------------------------------------------
;                   I/O initialisation
;-----------------------------------------------------------

;-----------------------------------------------------------
INITIO	= $003B
; Function:	initialises the device
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
INIFNK	= $003E
; Function:	initialises the contents of function keys
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------

;-----------------------------------------------------------
;                        VDP access
;-----------------------------------------------------------

;-----------------------------------------------------------
DISSCR	= $0041
; Function:	inhibits the screen display
; Input:	none
; Output:	none
; Registers:	AF, BC
;-----------------------------------------------------------
ENASCR	= $0044
; Function:	displays the screen
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
WRTVDP	= $0047
; Function:	writes data in the VDP register
; Input:	C for the register number, B for data; the register number
;		is 0 to 23 and 32 to 46
; Output:	none
; Registers:	AF, BC
;-----------------------------------------------------------
RDVRM	= $004A
; Function:	reads the contents of VRAM. This is for TMS9918, so only the
;		14 low order bits of the VRAM address are valid. To use all
;		bits, call NRDVRM.
; Input:	HL for VRAM address to be read
; Output:	A for the value which was read
; Registers:	AF
;-----------------------------------------------------------
WRTVRM	= $004D
;Function:	writes data in VRAM. This is for TMS9918, so only the 14 low
;		order bits of the VRAM address are valid. To use all bits,
;		call NWRVRM.
; Input:	HL for VRAM address, A for data
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
SETRD	= $0050
; Function:	sets VRAM address to VDP and enables it to be read. This is
;		used to read data from the sequential VRAM area by using the
;		address auto-increment function of VDP. This enables faster
;		readout than using RDVRM in a loop. This is for TMS9918, so
;		only the 14 low order bits of VRAM address are valid. To use
;		all bits, call NSETRD.
; Input:	HL for VRAM address
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
SETWRT	= $0053
; Function:	sets VRAM address to VDP and enables it to be written. The
;		purpose is the same as SETRD. This is for TMS9918, so only
;		the 14 low order bits of VRAM address are valid. To use all
;		bits, call NSETRD.
; Input:	HL for VRAM address
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
FILVRM	= $0056
; Function:	fills the specified VRAM area with the same data. This is for
;		TMS9918, so only the 14 low order bits of the VRAM address
;		are valid. To use all bits, see BIGFIL.
; Input:	HL for VRAM address to begin writing, BC for the length of
;		the area to be written, A for data.
; Output:	none
; Registers:	AF, BC
;-----------------------------------------------------------
LDIRMV	= $0059
; Function:	block transfer from VRAM to memory
; Input:	HL for source address (VRAM), DE for destination address
;		(memory), BC for the length. All bits of the VRAM address
;		are valid.
; Output:	none
; Registers:	all
;-----------------------------------------------------------
LDIRVM	= $005C
; Function:	block transfer from memory to VRAM
; Input:	HL for source address (memory), DE for destination address
;		(VRAM), BC for the length. All bits of the VRAM address are
;		valid.
; Output:	none
; Registers:	all
;-----------------------------------------------------------
CHGMOD	= $005F
; Function:	changes the screen mode. The palette is not initialised. To
;		initialise it, see CHGMDP in SUB-ROM.
; Input:	A for the screen mode (0 to 8)
; Output:	none
; Registers:	all
;-----------------------------------------------------------
CHGCLR	= $0062
; Function:	changes the screen colour
; Input:	A for the mode
;		   FORCLR (F3E9H) for foreground color
;		   BAKCLR (F3EAH) for background color
;		   BDRCLR (F3EBH) for border colour
; Output:	none
; Registers:	all
;-----------------------------------------------------------
NMI	= $0066
; Function:	executes NMI (Non-Maskable Interrupt) handling routine
; Input:	none
; Output:	none
; Registers:	none
;-----------------------------------------------------------
CLRSPR	= $0069
; Function:	initialises all sprites. The sprite pattern is cleared to
;		null, the sprite number to the sprite plane number, the
;		sprite colour to the foregtound colour. The vertical location
;		of the sprite is set to 209 (mode 0 to 3) or 217
;		(mode 4 to 8).
; Input:	SCRMOD (FCAFH) for the screen mode
; Output:	none
; Registers:	all
;-----------------------------------------------------------
INITXT	= $006C
; Function:	initialises the screen to TEXT1 mode (40 x 24). In this
;		routine, the palette is not initialised. To initialise the
;		palette, call INIPLT in SUB-ROM after this call.
; Input:	TXTNAM (F3B3H) for the pattern name table
;		TXTCGP (F3B7H) for the pattern generator table
;		LINL40 (F3AEH) for the length of one line
; Output:	none
; Registers:	all
;-----------------------------------------------------------
INIT32	= $006F
; Function:	initialises the screen to GRAPHIC1 mode (32x24). In this
;		routine, the palette is not initialised.
; Input:	T32NAM (F3BDH) for the pattern name table
;		T32COL (F3BFH) for the colour table
;		T32CGP (F3C1H) for the pattern generator table
;		T32ATR (F3C3H) for the sprite attribute table
;		T32PAT (F3C5H) for the sprite generator table
; Output:	none
; Registers:	all
;-----------------------------------------------------------
INIGRP	= $0072
; Function:	initialises the screen to the high-resolution graphics mode.
;		In this routine, the palette is not initialised.
; Input:	GRPNAM (F3C7H) for the pattern name table
;		GRPCOL (F3C9H) for the colour table
;		GRPCGP (F3CBH) for the pattern generator table
;		GRPATR (F3CDH) for the sprite attribute table
;		GRPPAT (F3CFH) for the sprite generator table
; Output:	none
; Registers:	all
;-----------------------------------------------------------
INIMLT	= $0075
; Function:	initialises the screen to MULTI colour mode. In this routine,
;		the palette is not initialised.
; Input:	MLTNAM (F3D1H) for the pattern name table
;		MLTCOL (F3D3H) for the colour table
;		MLTCGP (F3D5H) for the pattern generator table
;		MLTATR (F3D7H) for the sprite attribute table
;		MLTPAT (F3D9H) for the sprite generator table
; Output:	none
; Registers:	all
;-----------------------------------------------------------
SETTXT	= $0078
; Function:	set only VDP in TEXT1 mode (40x24)
; Input:	same as INITXT
; Output:	none
; Registers:	all
;-----------------------------------------------------------
SETT32	= $007B
; Function:	set only VDP in GRAPHIC1 mode (32x24)
; Input:	same as INIT32
; Output:	none
; Registers:	all
;-----------------------------------------------------------
SETGRP	= $007E
; Function:	set only VDP in GRAPHIC2 mode
; Input:	same as INIGRP
; Output:	none
; Registers:	all
;-----------------------------------------------------------
SETMLT	= $0081
; Function:	set only VDP in MULTI colour mode
; Input:	same as INIMLT
; Output:	none
; Registers:	all
;-----------------------------------------------------------
CALPAT	= $0084
; Funtion:	returns the address of the sprite generator table
; Input:	A for the sprite number
; Output:	HL for the address
; Registers:	AF, DE, HL
;-----------------------------------------------------------
CALATR	= $0087
; Function:	returns the address of the sprite attribute table
; Input:	A for the sprite number
; Output:	HL for the address
; Registers:	AF, DE, HL
;-----------------------------------------------------------
GSPSIZ	= $008A
; Function:	returns the current sprite size
; Input:	none
; Output:	A for the sprite size (in bytes). Only when the size is
;		16 x 16, the CY flag is set; otherwise the CY flag is reset.
; Registers:	AF
;-----------------------------------------------------------
GRPPRT	= $008D
; Function:	displays a character on the graphic screen
; Input:	A for the character code. When the screen mode is 0 to 8,
;		set the logical operation code in LOGOPR (FB02H).
; Output:	none
; Registers:	none
;-----------------------------------------------------------

;-----------------------------------------------------------
;                     PSG
;-----------------------------------------------------------

;-----------------------------------------------------------
GICINI	= $0090
; Function:	initialises PSG and sets the initial value for the PLAY
;		statement
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
WRTPSG	= $0093
; Function:	writes data in the PSG register
; Input:	A for PSG register number, E for data
; Output:	none
; Registers:	none
;-----------------------------------------------------------
RDPSG	= $0096
; Function:	reads the PSG register value
; Input:	A for PSG register number
; Output:	A for the value which was read
; Registers:	none
;-----------------------------------------------------------
STRTMS	= $0099
; Function:	tests whether the PLAY statement is being executed as a
;		background task. If not, begins to execute the PLAY statement
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------

;-----------------------------------------------------------
;           Keyboard, CRT, printer input-output
;-----------------------------------------------------------

;-----------------------------------------------------------
CHSNS	= $009C
; Function:	tests the status of the keyboard buffer
; Input:	none
; Output:	the Z flag is set when the buffer is empty, otherwise the
;		Z flag is reset
; Registers:	AF
;-----------------------------------------------------------
CHGET	= $009F
; Function:	one character input (waiting)
; Input:	none
; Output:	A for the code of the input character
; Registers:	AF
;-----------------------------------------------------------
CHPUT	= $00A2
; Function:	displays the character
; Input:	A for the character code to be displayed
; Output:	none
; Registers:	none
;-----------------------------------------------------------
LPTOUT	= $00A5
; Function:	sends one character to the printer
; Input:	A for the character code to be sent
; Output:	if failed, the CY flag is set
; Registers:	F
;-----------------------------------------------------------
LPTSTT	= $00A8
; Function:	tests the printer status
; Input:	none
; Output:	when A is 255 and the Z flag is reset, the printer is READY.
;		when A is 0 and the Z flag is set, the printer is NOT READY.
; Registers:	AF
;-----------------------------------------------------------
CNVCHR	= $00AB
; Function:	test for the graphic header and transforms the code
; Input:	A for the character code
; Output:	the CY flag is reset to not the graphic header
;		the CY flag and the Z flag are set to the transformed code
;		is set in A
;		the CY flag is set and the CY flag is reset to the
;		untransformed code is set in A
;  Registers:	AF
;-----------------------------------------------------------
PINLIN	= $00AE
; Function:	stores in the specified buffer the character codes input
;		until the return key or STOP key is pressed.
; Input:	none
; Output:	HL for the starting address of the buffer minus 1, the CY
;		flag is set only when it ends with the STOP key.
; Registers:	all
;-----------------------------------------------------------
INLIN	= $00B1
; Function:	same as PINLIN except that AUTFLG (F6AAH) is set
; Input:	none
; Output:	HL for the starting address of the buffer minus 1, the CY
;		flag is set only when it ends with the STOP key.
; Registers:	all
;-----------------------------------------------------------
QINLIN	= $00B4
; Function:	executes INLIN with displaying "?" and one space
; Input:	none
; Output:	HL for the starting address of the buffer minus 1, the CY
;		flag is set only when it ends with the STOP key.
; Registers:	all
;-----------------------------------------------------------
BREAKX	= $00B7
; Function:	tests Ctrl-STOP key. In this routine, interrupts are
;		inhibited.
; Input:	none
; Output:	the CY flag is set when pressed
; Registers:	AF
;-----------------------------------------------------------
ISCNTC	= $00BA
CKCNTC	= $00BD
;-----------------------------------------------------------
BEEP	= $00C0
; Function:	generates BEEP
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
CLS	= $00C3
; Function:	clears the screen
; Input:	set zero flag
; Output:	none
; Registers:	AF, BC, DE
;-----------------------------------------------------------
POSIT	= $00C6
; Function:	moves the cursor
; Input:	H for the X-coordinate of the cursor, L for the Y-coordinate
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
FNKSB	= $00C9
; Function:	tests whether the function key display is active (FNKFLG).
;		If so, displays them, otherwise erases them.
; Input:	FNKFLG (FBCEH)
; Output:	none
; Registers:	all
;-----------------------------------------------------------
ERAFNK	= $00CC
; Function:	erases the function key display
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
DSPFNK	= $00CF
; Function:	displays the function keys
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------
TOTEXT	= $00D2
; Function:	forces the screen to be in the text mode
; Input:	none
; Output:	none
; Registers:	all
;-----------------------------------------------------------

;-----------------------------------------------------------
;                     Game I/O access
;-----------------------------------------------------------

;-----------------------------------------------------------
GTSTCK	= $00D5
; Function:	returns the joystick status
; Input:	A for the joystick number to be tested
; Output:	A for the joystick direction
; Registers:	all
;-----------------------------------------------------------
GTTRIG	= $00D8
; Function:	returns the trigger button status
; Input:	A for the trigger button number to be tested
; Output:	When A is 0, the trigger button is not being pressed.
;		When A is FFH, the trigger button is being pressed.
; Registers:	AF
;-----------------------------------------------------------
GTPAD	= $00DB
; Function:	returns the touch pad status
; Input:	A for the touch pad number to be tested
; Output:	A for the value
; Registers:	all
;-----------------------------------------------------------
GTPDL	= $00DE
; Function:	returns the paddle value
; Input:	A for the paddle number
; Output:	A for the value
; Registers:	all
;-----------------------------------------------------------

;-----------------------------------------------------------
;               Cassette input-output routine
;-----------------------------------------------------------

;-----------------------------------------------------------
TAPION	= $00E1
; Function:	reads the header block after turning the cassette motor ON.
; Input:	none
; Output:	if failed, the CY flag is set
; Registers:	all
;-----------------------------------------------------------
TAPIN	= $00E4
; Function:	reads data from the tape
; Input:	none
; Output:	A for data. If failed, the CY flag is set.
; Registers:	all
;-----------------------------------------------------------
TAPIOF	= $00E7
; Function:	stops reading the tape
; Input:	none
; Output:	none
; Registers:	none
;-----------------------------------------------------------
TAPOON	= $00EA
; Function:	writes the header block after turning the cassette motor ON
; Input:	A = 0, short header; A <> 0, long header
; Output:	if failed, the CY flag is set
; Registers:	all
;-----------------------------------------------------------
TAPOUT	= $00ED
; Function:	writes data on the tape
; Input:	A for data
; Output:	if failed, the CY flag is set
; Registers:	all
;-----------------------------------------------------------
TAPOOF	= $00F0
; Function:	stops writing to the tape
; Input:	A for data
; Output:	if failed, the CY flag is set
; Registers:	all
;-----------------------------------------------------------
STMOTR	= $00F3
; Function:	sets the cassette motor action
; Input:	A = 0		->	stop
;		A = 1		->	start
;		A = 0FFH	->	reverse the current action
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
LFTQ	= $00F6
PUTQ	= $00F9
RIGHTC	= $00FC
LEFTC	= $00FF
UPC	= $0102
TUPC	= $0105
DOWNC	= $0108
TDOWNC	= $010B
SCALXY	= $010E
MAPXY	= $0111
FETCHC	= $0114
STOREC	= $0117
SETATR	= $011A
READC	= $011D
SETC	= $0120
NSETCX	= $0123
GTASPC	= $0126
PNTINI	= $0129
SCANR	= $012C
SCANL	= $012F
;-----------------------------------------------------------

;-----------------------------------------------------------
;                     Miscellaneous
;-----------------------------------------------------------

;-----------------------------------------------------------
CHGCAP	= $0132
; Function:	alternates the CAP lamp status
; Input:	A = 0		->	lamp off
;		A <>0		->	lamp on
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
CHGSND	= $0135
; Function:	alternates the 1-bit sound port status
; Input:	A = 0		->	OFF
;		A <>0		->	ON
; Output:	none
; Registers:	AF
;-----------------------------------------------------------
RSLREG	= $0138
; Function:	reads the contents of current output to the basic slot
;		register
; Input:	none
; Output:	A for the value which was read
; Registers:	A
;-----------------------------------------------------------
WSLREG	= $013B
; Function:	writes to the primary slot register
; Input:	A for the value to be written
; Output:	none
; Registers:	none
;-----------------------------------------------------------
RDVDP	= $013E
; Function:	reads VDP status register
; Input:	none
; Output:	A for the value which was read
; Registers:	A
;-----------------------------------------------------------
SNSMAT	= $0141
; Function:	reads the value of the specified line from the keyboard
;		matrix
; Input:	A for the specified line
; Output:	A for data (the bit corresponding to the pressed key will
;		be 0)
; Registers:	AF, C
;-----------------------------------------------------------
PHYDIO	= $0144
; Function:	Physical input/output for disk devices
; Input:	A for the drive number (0 = A:, 1 = B:,...)
;		B for the number of sector to be read from or written to
;		C for the media ID
;		DE for the first sector number to be read rom or written to
;		HL for the startinga address of the RAM buffer to be
;		   read from or written to specified sectors
;		CY set for sector writing; reset for sector reading
; Output:	CY set if failed
;		B for the number of sectors actually read or written
;		A for the error code (only if CY set):
;			0 = Write protected
;			2 = Not ready
;			4 = Data error
;			6 = Seek error
;			8 = Record not found
;		       10 = Write error
;		       12 = Bad parameter
;		       14 = Out of memory
;		       16 = Other error
;  Registers:	all
;-----------------------------------------------------------
FORMAT	= $0147
;-----------------------------------------------------------
ISFLIO	= $014A
; Function:	tests whether the device is active
; Input:	none
; Output:	A = 0		->	active
;		A <>0		->	inactive
; Registers:	AF
;-----------------------------------------------------------
OUTDLP	= $014D
; Function:	printer output.Different from LPTOUT in the following points:
;		     1. TAB is expanded to spaces
;		     2. For non-MSX printers, hiragana is transformed to
;			katakana and graphic characters are transformed to
;			1-byte characters.
;		     3. If failed, device I/O error occurs.
; Input:	A for data
; Output:	none
; Registers:	F
;-----------------------------------------------------------
GETVCP	= $0150
GETVC2	= $0153
;-----------------------------------------------------------
KILBUF	= $0156
; Function:	clears the keyboard buffer
; Input:	none
; Output:	none
; Registers:	HL
;-----------------------------------------------------------
CALBAS	= $0159
; Function:	executes inter-slot call to the routine in BASIC interpreter
; Input:	IX for the calling address
; Output:	depends on the called routine
; Registers:	depends on the called routine
;-----------------------------------------------------------

;---------------------------------------------------------
; CONSTANTS
;---------------------------------------------------------

;---------------------------------------------------------
; MSX I/O Ports
;---------------------------------------------------------

;---------------------------------------------------------
; 00H to 3FH	user defined
;---------------------------------------------------------
; 40H to 7FH	reserved
;---------------------------------------------------------
; 80H to 87H	for RS-232C
;      80H	8251 data
;      81H	8251 status/command
;      82H	status read/interrupt mask
;      83H	unused
;      84H	8253
;      85H	8253
;      86H	8253
;      87H	8253
;---------------------------------------------------------
; 88H to 8BH	VDP (9938) I/O port for MSX1 adaptor
;		This is V9938 I/O for MSX1. To access VDP directly,
;		examine 06H and 07H of MAIN-ROM to confirm the port
;		address
;---------------------------------------------------------
; 8CH to 8DH	for the modem
;---------------------------------------------------------
; 8EH to 8FH	reserved
;---------------------------------------------------------
; 90H to 91H	printer port
;      90H	bit 0: strobe output (write)
;		bit 1: status input (read)
;      91H	data to be printed
;---------------------------------------------------------
; 92H to 97H	reserved
;---------------------------------------------------------
; VDP / Video Display Processor / TMS9918A / v9938 / v9958
VDP_DATA	=	$98	; PORT [$88] | [$98] VRAM read/write
VDP_CMD		=	$99	; PORT [$89] | [$99] VDP registers read/write
VDP_PAL		= 	$9A 	; Palette registers write
VDP_IND		= 	$9B 	; Indirect register write
;---------------------------------------------------------
; 9CH to 9FH	reserved
;---------------------------------------------------------
; PSG / AY-3-8910 (Programmable Sound Generator)
ioPSG0	=	$A0	; (write) Register write port
ioPSG1	=	$A1	; (write) Value write port
ioPSG2	=	$A2	; (read) Value read port
;---------------------------------------------------------
; PPI / Programmable Peripheral Interface / 8255
ioPPI_A	=	$A8	; PPI-register A / Primary slot select register.
ioPPI_B	=	$A9 	; (read) PPI-register B  /  Keyboard matrix row input register.
ioPPI_C	=	$AA	; PPI-register C / Keyboard and cassette interface.
ioPPI_D	=	$AB 	; (write) /	Command register.
;---------------------------------------------------------
; A4H to A7H	reserved
;---------------------------------------------------------
; A8H to ABH	parallel port (8255)
;      A8H	port A
;      A9H	port B
;      AAH	port C
;      ABH	mode set
;---------------------------------------------------------
; ACH to AFH	MSX engine (one chip MSX I/O)
;---------------------------------------------------------
; B0H to B3H	expansion memory (SONY specification) (8255)
;      A8H	port A, address (A0 to A7)
;      A9H	port B, address (A8 to A10, A13 to A15), control R/"
;      AAH	port C, address (A11 to A12), data (D0 - D7)
;      ABH	mode set
;---------------------------------------------------------
; B4H to B5H	CLOCK-IC (RP-5C01)
;      B4H	address latch
;      B5H	data
;---------------------------------------------------------
; B6H to B7H	reserved
;---------------------------------------------------------
; B8H to BBH	lightpen control (SANYO specification)
;      B8H	read/write
;      B9H	read/write
;      BAH	read/write
;      BBH	write only
;---------------------------------------------------------
; BCH to BFH	VHD control (JVC) (8255)
;      BCH	port A
;      BDH	port B
;      BEH	port C
;---------------------------------------------------------
; C0H to C1H	MSX-Audio
;---------------------------------------------------------
; C2H to C7H	reserved
;---------------------------------------------------------
; C8H to CFH	MSX interface
;---------------------------------------------------------
; D0H to D7H	floppy disk controller (FDC)
;		The floppy disk controller can be interrupted by an
;		external signal. Interrupt is possible only when the
;		FDC is accessed. Thus, the system can treat different
;		FDC interfaces.
;---------------------------------------------------------
; D8 to D9H	kanji ROM (TOSHIBA specification)
;     D8H	b5-b0		lower address (write only)
;     D9H	b5-b0		upper address (write)
;		b7-b0		data (read)
;---------------------------------------------------------
; DAH to DBH	for future kanji expansion
;---------------------------------------------------------
; DCH to F4H	reserved
;---------------------------------------------------------
; F5H		system control (write only)
;		setting bit to 1 enables available I/O devices
;	b0	kanji ROM
;	b1	reserved for kanji
;	b2	MSX-AUDIO
;	b3	superimpose
;	b4	MSX interface
;	b5	RS-232C
;	b6	lightpen
;	b7	CLOCK-IC (only on MSX2)
;		Bits to void the conflict between internal I/O
;		devices or those connected by cartridge. The bits
;		can disable the internal devices. When BIOS is initialised,
;		internal devices are valid if no external devices are
;		connected. Applications may not write to or read from here.
;---------------------------------------------------------
; F8H		colour bus I/O
;---------------------------------------------------------
; F7H		A/V control
;	b0	audio R 		mixing ON (write)
;	b1	audio L 		mixing OFF (write)
;	b2	select video input	21p RGB (write)
;	b3	detect video input	no input (read)
;	b4	AV control		TV (write)
;	b5	Ym control		TV (write)
;	b6	inverse of bit 4 of VDP register 9 (write)
; 	b7	inverse of bit 5 of VDP register 9 (write)
;---------------------------------------------------------
; F8H to FBH	reserved
;---------------------------------------------------------
; FCH to FFH	memory mapper
;---------------------------------------------------------

;---------------------------------------------------------
; VRAM addresses  SCREEN 2 / GRAPHIC 2
;---------------------------------------------------------
CHRTBL 	=	$0000   ; Pattern table
NAMTBL 	=	$1800   ; Name table
CLRTBL 	=	$2000   ; Colour table
SPRTBL  = 	$3800   ; Sprite pattern table
SPRATR	=	$1b00   ; Sprite attributtes
CHRTBL0	=	CHRTBL
CHRTBL1	=	CHRTBL+2048
CHRTBL2	=	CHRTBL+4096
CLRTBL0	=	CLRTBL
CLRTBL1	=	CLRTBL+2048
CLRTBL2	=	CLRTBL+4096
;---------------------------------------------------------

;---------------------------------------------------------
;                    VRAM MAP
;---------------------------------------------------------
; SCREEN 0 (WIDTH 40) / TEXT 1
; 0000H - 03BFH	-->	Pattern name table
; 0400H - 042FH	-->	Palette table
; 0800H - 0FFFH	-->	Pattern generator table
;---------------------------------------------------------
; SCREEN 0 (WIDTH 80) / TEXT 2
; 0000H - 077FH	-->	Pattern name table
; 0800H - 08EFH	-->	Blink table (24 lines mode)
; 	  090DH			    (26.5 lines mode)
; 0F00H - 0F2FH	-->	Palette table
; 1000H - 17FFH	-->	Pattern generator table
;---------------------------------------------------------
; SCREEN 1 / GRAPHIC 1
; 0000H - 07FFH	-->	Pattern generator table
; 1800H - 1AFFH	-->	Pattern name table
; 1B00H - 1B7FH	-->	Sprite attribute table
; 2000H - 201FH	-->	Colour table
; 2020H - 204FH	-->	Palette table
; 3800H - 3FFFH	-->	Sprite generator table
;---------------------------------------------------------
; SCREEN 2 / GRAPHIC 2
; 0000H - 07FFH	-->	Pattern generator table 1
; 0800H - 0FFFH	-->	Pattern generator table 2
; 1000H - 17FFH	-->	Pattern generator table 3
; 1800H - 18FFH	-->	Pattern name table 1
; 1900H - 19FFH	-->	Pattern name table 2
; 1A00H - 1AFFH	-->	Pattern name table 3
; 1B00H - 1B7FH	-->	Sprite attribute table
; 1B80H - 1BAFH	-->	Palette table
; 2000H - 27FFH	-->	Colour table 1
; 2800H - 2FFFH	-->	Colour table 2
; 3000H - 37FFH	-->	Colour table 3
; 3800H - 3FFFH	-->	Sprite generator table
;---------------------------------------------------------
; SCREEN 3 / MULTI COLOUR
; 0000H - 07FFH	-->	Pattern generator table
; 0800H - 0AFFH	-->	Pattern name table
; 1B00H - 1B7FH	-->	Sprite attribute table
; 2020H - 204FH	-->	Palette table
; 3800H - 3FFFH	-->	Sprite generator table
;---------------------------------------------------------
; SCREEN 4 / GRAPHIC 3
; 0000H - 07FFH	-->	Pattern generator table 1
; 0800H - 0FFFH	-->	Pattern generator table 2
; 1000H - 17FFH	-->	Pattern generator table 3
; 1800H - 18FFH	-->	Pattern name table 1
; 1900H - 19FFH	-->	Pattern name table 2
; 1A00H - 1AFFH	-->	Pattern name table 3
; 1B80H - 1BAFH	-->	Palette table
; 1C00H - 1DFFH	-->	Sprite colour table
; 1E00H - 1E7FH	-->	Sprite attribute table
; 2000H - 27FFH	-->	Colour table 1
; 2800H - 2FFFH	-->	Colour table 2
; 3000H - 37FFH	-->	Colour table 3
; 3800H - 3FFFH	-->	Sprite generator table
;---------------------------------------------------------
; SCREEN 5, 6 / GRAPHIC 4, 5
; 0000H - 5FFFH	-->	Pattern name table (192 lines)
; 	  69FFH				   (212 lines)
; 7400H - 75FFH	-->	Sprite colour table
; 7600H - 767FH	-->	Sprite attribute table
; 7680H - 76AFH	-->	Palette table
; 7A00H - 7FFFH	-->	Sprite generator table
;---------------------------------------------------------
; SCREEN 7, 8 / GRAPHIC 6, 7
; 0000H - BFFFH	-->	Pattern name table (192 lines)
; 	  D3FFH				   (212 lines)
; F000H - F7FFH	-->	Sprite generator table
; F800H - F9FFH	-->	Sprite colour table
; FA00H - FA7FH	-->	Sprite attribute table
; FA80H - FAAFH	-->	Palette table
;---------------------------------------------------------

;---------------------------------------------------------
;                     Variables
;---------------------------------------------------------

;---------------------------------------------------------
; System Variables located in Main ROM
;---------------------------------------------------------
CGTABL	=	$0004	; (2) Base address of the MSX character set in ROM
VDPDR	=	$0006  	; (1) Base port address for VDP data read
VDPDW	=	$0007	; (1) Base port address for VDP data write
BASV0	=	$002b	; (1) Basic ROM version
			;	7 6 5 4 3 2 1 0
			;	| | | | +-+-+-+-- Character set
			;	| | | |           0 = Japanese, 1 = International, 2=Korean
			;	| +-+-+---------- Date format
			;	|                 0 = Y-M-D, 1 = M-D-Y, 2 = D-M-Y
			;	+---------------- Default interrupt frEQUency
			;	                  0 = 60Hz, 1 = 50Hz
BASV1	=	$002c	; (1) Basic ROM version
			;	7 6 5 4 3 2 1 0
			;	| | | | +-+-+-+-- Keyboard type
			;	| | | |           0 = Japanese, 1 = International
			;	| | | |           2 = French (AZERTY), 3 = UK, 4 = German (DIN)
			;	+-+-+-+---------- Basic version
			;	                  0 = Japanese, 1 = International
BASV2	=	$002d	; (1) MSX version number
			;	0 = MSX 1
			;	1 = MSX 2
			;	2 = MSX 2+
			;	3 = MSX turbo R
MSXMIDI	=	$002e	; (1) Bit 0: if 1 then MSX-MIDI is present internally (MSX turbo R only)
;VOID00	=  	$002f	; (1) Reserved

;---------------------------------------------------------
;        MSX System Variables located in RAM
;---------------------------------------------------------
;                       Work area
;	FFFF	---------------------------
;		| slot selection register |
;	FFFC	|-------------------------|
;		|	  reserved	  |
;	FFF8	|-------------------------|
;	FFF7	|  MAIN-ROM slot address  |
;		|-------------------------|
;		|  register reservation   |
;		|      area for new	  |
;	FFE7	|	VDP (9938)	  |
;		|-------------------------|
;		|	program for	  |
;	FFCA	|  expansion BIOS calls   |
;		|-------------------------|
;		|			  |
;		|	hook area	  |
;	FD9A	|			  |
;		|-------------------------|
;		|			  |
;		|    system work area	  |
;	F380	|			  |
;		---------------------------
;---------------------------------------------------------

;---------------------------------------------------------
;                      System work area
;---------------------------------------------------------
RDPRIM	=	$f380	; (5) Routine that reads from a primary slot
WRPRIM	=	$f385	; (7) Routine that writes to a primary slot
CLPRIM	=	$f38c	; (14) Routine that calls a routine in a primary slot
USRTAB	=	$f39a	; (2) Address to call with Basic USR
USRTAB0	=	$f39a	; (2) Address to call with Basic USR0
USRTAB1	=	$f39c	; (2) Address to call with Basic USR1
USRTAB2	=	$f39e	; (2) Address to call with Basic USR2
USRTAB3	=	$f3a0	; (2) Address to call with Basic USR3
USRTAB4	=	$f3a2	; (2) Address to call with Basic USR4
USRTAB5	=	$f3a4	; (2) Address to call with Basic USR5
USRTAB6	=	$f3a6	; (2) Address to call with Basic USR6
USRTAB7	=	$f3a8	; (2) Address to call with Basic USR7
USRTAB8	=	$f3aa	; (2) Address to call with Basic USR8
USRTAB9	=	$f3ac	; (2) Address to call with Basic USR9
LINL40	=	$f3ae	; (1) Width for SCREEN 0 (default 37)
LINL32	=	$f3af	; (1) Width for SCREEN 1 (default 29)
LINLEN	=	$f3b0	; (1) Width for the current text mode
CRTCNT	=	$f3b1	; (1) Number of lines on screen
CLMLST	=	$f3b2	; (1) Column space. It’s uncertain what this address actually stores
TXTNAM	=	$f3b3	; (2) BASE(0) - SCREEN 0 name table
TXTCOL	=	$f3b5	; (2) BASE(1) - SCREEN 0 color table
TXTCGP	=	$f3b7	; (2) BASE(2) - SCREEN 0 character pattern table
TXTATR	=	$f3b9	; (2) BASE(3) - SCREEN 0 Sprite Attribute Table
TXTPAT	=	$f3bb	; (2) BASE(4) - SCREEN 0 Sprite Pattern Table
T32NAM	=	$f3bd	; (2) BASE(5) - SCREEN 1 name table
T32COL	=	$f3bf	; (2) BASE(6) - SCREEN 1 color table
T32CGP	=	$f3c1	; (2) BASE(7) - SCREEN 1 character pattern table
T32ATR	=	$f3c3	; (2) BASE(8) - SCREEN 1 sprite attribute table
T32PAT	=	$f3c5	; (2) BASE(9) - SCREEN 1 sprite pattern table
GRPNAM	=	$f3c7	; (2) BASE(10) - SCREEN 2 name table
GRPCOL	=	$f3c9	; (2) BASE(11) - SCREEN 2 color table
GRPCGP	=	$f3cb	; (2) BASE(12) - SCREEN 2 character pattern table
GRPATR	=	$f3cd	; (2) BASE(13) - SCREEN 2 sprite attribute table
GRPPAT	=	$f3cf	; (2) BASE(14) - SCREEN 2 sprite pattern table
MLTNAM	=	$f3d1	; (2) BASE(15) - SCREEN 3 name table
MLTCOL	=	$f3d3	; (2) BASE(16) - SCREEN 3 color table
MLTCGP	=	$f3d5	; (2) BASE(17) - SCREEN 3 character pattern table
MLTATR	=	$f3d7	; (2) BASE(18) - SCREEN 3 sprite attribute table
MLTPAT	=	$f3d9	; (2) BASE(19) - SCREEN 3 sprite pattern table
CLIKSW	=	$f3db	; (1) Keyboard click sound
			;	=0 when key press click disabled
			;	=1 when key press click enabled
			;	SCREEN ,,n will write to this address
CSRY	=	$f3dc	; (1) Current row-position of the cursor
CSRX	=	$f3dd	; (1) Current column-position of the cursor
CNSDFG	=	$f3de	; (1) Key function show
			;	=0 when function keys are not displayed
			;	=1 when function keys are displayed
RG0SAV	=	$f3df	; (1) Content of VDP(0) register (R#0)
RG1SAV	=	$f3e0	; (1) Content of VDP(1) register (R#1)
RG2SAV	=	$f3e1	; (1) Content of VDP(2) register (R#2)
RG3SAV	=	$f3e2	; (1) Content of VDP(3) register (R#3)
RG4SAV	=	$f3e3	; (1) Content of VDP(4) register (R#4)
RG5SAV	=	$f3e4	; (1) Content of VDP(5) register (R#5)
RG6SAV	=	$f3e5	; (1) Content of VDP(6) register (R#6)
RG7SAV	=	$f3e6	; (1) Content of VDP(7) register (R#7)
STATFL	=	$f3e7	; (1) Content of VDP(8) status register (S#0)
TRGFLG	=	$f3e8	; (1) Information about trigger buttons and space bar state
			;	7 6 5 4 3 2 1 0
			;	| | | |       +-- Space bar, trig(0) (0 = pressed)
			;	| | | +---------- Stick 1, Trigger 1 (0 = pressed)
			;	| | +------------ Stick 1, Trigger 2 (0 = pressed)
			;	| +-------------- Stick 2, Trigger 1 (0 = pressed)
			;	+---------------- Stick 2, Trigger 2 (0 = pressed)
FORCLR	=	$f3e9	; (1) Foreground color
BAKCLR	=	$f3ea	; (1) Background color
BDRCLR	=	$f3eb	; (1) Border color
MAXUPD	=	$f3ec	; (3) Jump instruction used by Basic LINE command. The routines used are: RIGHTC, LEFTC, UPC and DOWNC
MINUPD	=	$f3ef	; (3) Jump instruction used by Basic LINE command. The routines used are: RIGHTC, LEFTC, UPC and DOWNC
ATRBYT	=	$f3f2	; (1) Attribute byte (for graphical routines it’s used to read the color)
QUEUES	=	$f3f3	; (2) Address of the queue table
FRCNEW	=	$f3f5	; (1) CLOAD flag
			;	=0 when CLOAD
			;	=255 when CLOAD?
SCNCNT	=	$f3f6	; (1) Key scan timing
			;	When it’s zero, the key scan routine will scan for pressed keys so
			;	characters can be written to the keyboard buffer
REPCNT	=	$f3f7	; (1) This is the key repeat delay counter
			;	When it reaches zero, the key will repeat
PUTPNT	=	$f3f8	; (2) Address in the keyboard buffer where a character will be written
GETPNT	=	$f3fa	; (2) Address in the keyboard buffer where the next character is read
CS120	=	$f3fc	; (5) Cassette I/O parameters to use for 1200 baud ; DB LOW01,HIGH01,LOW11,HIGH11,HEDLEN*2/256
CS240	=	$f401	; (5) Cassette I/O parameters to use for 2400 baud ; DB LOW02,HIGH02,LOW12,HIGH22,HEDLEN*2/256
LOW	=	$f406	; (2) Signal delay when writing a 0 to tape ; DB LOW01,HIGH01   (Width of LOW & HIGH wich represents bit 0)
HIGH	=	$f408	; (2) Signal delay when writing a 1 to tape ; DB LOW11,HIGH11   (Width of LOW & HIGH wich represents bit 1)
HEADER	=	$f40a	; (1) Delay of tape header (sync.) block    ; DB HEDLEN*2/256    (Header bit for the short header)
ASPCT1	=	$f40b	; (2) Horizontal / Vertical aspect for CIRCLE command (256/aspect ratio for BASIC Circle command)
ASPCT2	=	$f40d	; (2) Horizontal / Vertical aspect for CIRCLE command (256/aspect ratio for BASIC Circle command)
ENDPRG	=	$f40f	; (5) Pointer for the RESUME NEXT command (DB ":" Dummy program end for RESUME NEXT st.)
ERRFLG	=	$f414	; (1) Basic Error code
LPTPOS	=	$f415	; (1) Position of the printer head
			;	Is read by Basic function LPOS and used by LPRINT Basic command
PRTFLG	=	$f416	; (1) Printer output flag is read by OUTDO
			;	=0 to print to screen
			;	=1 to print to printer
NTMSXP	=	$f417	; (1) Printer type is read by OUTDO. SCREEN ,,,n writes to this address
			;	=0 for MSX printer
			;	=1 for non-MSX printer
RAWPRT	=	$f418	; (1) Raw printer output is read by OUTDO
			;	=0 to convert tabs and unknown characters to spaces and remove graphical headers
			;	=1 to send data just like it gets it
VLZADR	=	$f419	; (2) Address of data that is temporarilly replaced by ‘O’ when Basic function VAL("") is running (ADDRESS OF CHARACTER REPLACED BY VAL)
VLZDAT	=	$f41b	; (1) Original value that was in the address pointed to with VLZADR (CHARACTER REPLACED WITH 0 BY VAL)
CURLIN	=	$f41c	; (2) Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
KBFMIN	=	$f41e	; (1) Same as  ENDPRG, used if direct statement error occures
KBUF	=	$F41F	; () Crunch buffer;translated into intermediate language from BUF
BUFMIN	=	$F55D	; used by INPUT routine
BUF	=	$F55E 	; Buffer to store characters typed( in ASCII code)
;SX	=	$F562 	; VDP R# 32, Source X Low
;SX	=	$F563 	; VDP R# 33, Source X High
;SY	=	$F564	; VDP R# 34, Source Y Low
;SY	=	$F565	; VDP R# 35, Source Y High
;DX	=	$F566 	; VDP R# 36, Dest. X Low
;DX	=	$F567	; VDP R# 37, Dest. X High
;DY	=	$F568	; VDP R# 38, Dest. Y Low
;DY	=	$F569	; VDP R# 39, Dest. Y High
;NX	=	$F56A	; VDP R# 40, Nr of dots X Low
;NX	=	$F56B	; VDP R# 41, Nr of dots X High
;NY	=	$F56C	; VDP R# 42, Nr of dots Y Low
;NY	=	$F56D	; VDP R# 43, Nr of dots Y High
;CDUMMY	=	$F56E	; VDP R# 44, Color register
;ARG	=	$F56F	; VDP R# 45, Argument register
;L_OP	=	$F570	; VDP R# 46, Command  register
VDPCMD_SX	=	$F562 	; VDP R# 32, Source X Low
VDPCMD_SX_1	=	$F563 	; VDP R# 33, Source X High
VDPCMD_SY	=	$F564	; VDP R# 34, Source Y Low
VDPCMD_SY_1	=	$F565	; VDP R# 35, Source Y High
VDPCMD_DX	=	$F566 	; VDP R# 36, Dest. X Low
VDPCMD_DX_1	=	$F567	; VDP R# 37, Dest. X High
VDPCMD_DY	=	$F568	; VDP R# 38, Dest. Y Low
VDPCMD_DY_1	=	$F569	; VDP R# 39, Dest. Y High
VDPCMD_NX	=	$F56A	; VDP R# 40, Nr of dots X Low
VDPCMD_NX_1	=	$F56B	; VDP R# 41, Nr of dots X High
VDPCMD_NY	=	$F56C	; VDP R# 42, Nr of dots Y Low
VDPCMD_NY_1	=	$F56D	; VDP R# 43, Nr of dots Y High
VDPCMD_CDUMMY	=	$F56E	; VDP R# 44, Color register
VDPCMD_ARG	=	$F56F	; VDP R# 45, Argument register
VDPCMD_L_OP	=	$F570	; VDP R# 46, Command  register
; The above Bit-blitten addresses are used by the COPY command in Basic.
; The VDP is allso able to communicate with the DISKROM to 
; save or load images from or to VRAM.
; A 2Byte filename pointer is expected in SX for Loading and DX for Writing operation.
; i.e. FNAAM: DEFB 34,"d:filename.ext",34,0 
; L_OP has 10 different operators:
;	0 -  PSET       1 -  AND
;	2 -  OR         3 -  XOR
;	4 -  PRESET     8 -  TPSET
;	9 -  TAND       10 - TOR
;	11 - TXOR       12 - TPRESET								
;SLTID	=	$f91f	; (1) Character set SlotID
;CADDR	=	$f920	; (2) Character set address
EXBRSA	=	$faf8	; (1) Slot address of the SUBROM (EXtended Bios-Rom Slot Address)
DRVINF	=	$fb21	; (1) Nr. of drives connected to disk interface
DRVINF1D =	$fb21	; (1) Nr. of drives connected to disk interface 1
DRVINF1S =	$fb22	; (1) Slot address of disk interface 1
DRVINF2D =	$fb23	; (1) Nr. of drives connected to disk interface 2
DRVINF2S =	$fb24	; (1) Slot address of disk interface 2
DRVINF3D =	$fb25	; (1) Nr. of drives connected to disk interface 3
DRVINF3S =	$fb26	; (1) Slot address of disk interface 3
DRVINF4D =	$fb27	; (1) Nr. of drives connected to disk interface 4
DRVINF4S =	$fb28	; (1) Slot address of disk interface 4
; MUSIC (BASIC)
PRSCNT	=	$FB35	; Used by PLAY command in BASIC 
SAVSP	=	$FB36	; Used by PLAY command in BASIC 
VOICEN	=	$FB38	; Used by PLAY command in BASIC 
SAVVOL	=	$FB39	; Used by PLAY command in BASIC 
MCLLEN	=	$FB3B	; Used by PLAY command in BASIC 
MCLPTR	=	$FB3C	; Used by PLAY command in BASIC 
QUEUEN	=	$FB3E  
MUSICF	=	$FB3F  
PLYCNT	=	$FB40  
VCBA	=	$FB41  
VCBB	=	$FB66  
VCBC	=	$FB8B  
ENSTOP	=	$FBB0	; <>0 if warm start enabled (CTRL+SHIFT+GRPH+KANA/CODE for warm start) 
BASROM	=	$FBB1	; <>0 if basic is in rom (CTRL+STOP disabled) 
LINTTB	=	$FBB2	; line terminator table (<>0 if line terminates) 
FSTPOS	=	$FBCA	; first position for inlin 
CODSAV	=	$FBCC	; code save area for cursor 
FNKSWI	=	$FBCD	; indicate which func key is displayed 
FNKFLG	=	$FBCE	; fkey which have subroutine 
ONGSBF	=	$FBD8	; global event flag 
CLIKFL	=	$FBD9	
OLDKEY	=	$FBDA  
NEWKEY	=	$FBE5 
; - Example of European Keyboard Layout 
; FBE5 0 => 7     | 6     | 5     | 4     | 3     | 2     | 1     | 0 
; FBE6 1 => ;     | ]     | [     | \     | =     | -     | 9     | 8 
; FBE7 2 => B     | A     | ACCENT| /     | .     | ,     | `     | ' 
; FBE8 3 => J     | I     | H     | G     | F     | E     | D     | C 
; FBE9 4 => R     | Q     | P     | O     | N     | M     | L     | K 
; FBEA 5 => Z     | Y     | X     | W     | V     | U     | T     | S 
; FBEB 6 => F3    | F2    | F1    | CODE  | CAPS  | GRPH  | CTRL  | SHIFT 
; FBEC 7 => RET   | SEL   | BS    | STOP  | TAB   | ESC   | F5    | F4 
; FBED 8 => RIGHT | DOWN  | UP    | LEFT  | DEL   | INS   | HOME  | SPACE 
; FBEE 9 => 4 3 2 1 0 / + * 
; FBEF 10 => . , - 9 8 7 6 5 
KEYBUF	=	$FBF0	; key code buffer 
BUFEND	=	$FC18	; end of key buffer 
LINWRK	=	$FC18  
PATWRK	=	$FC40	; Pattern Buffer 
BOTTOM	=	$fc48	; (2) Bottom of EQUiped RAM
HIMEM	=	$fc4a	; (2) High free RAM address available (init stack with)
TRPTBL	=	$FC4C  
RTYCNT	=	$FC9A  
INTFLG	=	$FC9B	; This flag is set if STOP or CTRL + STOP is pressed
			; 0 = Not Pressed
			; 3 = CTRL +STOP Pressed
			; 4 = STOP Pressed
PADY	=	$FC9C	; (1) Y-coordinate of a connected Graphics Tablet (PAD) 
PADX	=	$FC9D	; (1) X-coordinate of a connected Graphics Tablet (PAD) 
JIFFY	=	$FC9E	; (1) Contains value of the software clock, each interrupt of the VDP it is increased by 1. 
			; The contents can be read or changed by the 'TIME' function or 'TIME' statement.
INTVAL	=	$FCA0	; (2) Contains length of the interval when the ON INTERVAL routine was established. 
INTCNT	=	$FCA2	; (2) ON INTERVAL counter (counts backwards) 
LOWLIM	=	$FCA4	; (2) Used by the Cassette system (minimal length of startbit) 
WINWID	=	$FCA5	; (1) Used by the Cassette system (store the difference between a low-and high-cycle) 
GRPHED	=	$FCA6	; (1) flag for graph. char 
ESCCNT	=	$FCA7	; (1) escape sEQUence counter 
INSFLG	=	$FCA8	; (1) insert mode flag 
CSRSW	=	$FCA9	; (1) cursor display switch 
CSTYLE	=	$FCAA	; (1) cursor style i.e. Used if INS Key is used ( 00# = Full Cursor / FF# = Halve Cursor ) 
CAPST	=	$FCAB	; (1) capital status ( 00# = Off / FF# = On ) 
KANAST	=	$FCAC	; (1) russian key status (Dead Keys)
			; 0 = No Dead Keys
			; 1 = Dead Key > Accent Grave
			; 2 = SHIFT + Dead Key > Accent Egu
			; 3 = CODE + Dead Key > Accent Circumflex
			; 4 = SHIFT + CODE + Dead Key > Trema
KANAMD	=	$FCAD  
FLBMEM	=	$FCAE	; (1) 0 if loading basic programm 
SCRMOD	=	$FCAF	; (1) screen mode 
OLDSCR	=	$FCB0	; (1) old screen mode 
CASPRV	=	$FCB1  
BRDATR	=	$FCB2	; (1) border color for paint 
GXPOS	=	$FCB3	; (1) X-position 
GYPOS	=	$FCB5	; (1) Y-position 
GRPACX	=	$FCB7  
GRPACY	=	$FCB9  
DRWFLG	=	$FCBB	; (1) Used by the DRAW statement (DrawFlag)
			; Bit 7 = Draw Line 0 = No / 1 = Yes ( ,N )
			; Bit 6 = Move Cursor 0 = Yes / 1 = Yes ( ,B )
			; Bit 5 - 0 Unused
DRWSCL	=	$FCBC	; (1) Used by the DRAW statement (DrawScaling) 
DRWANG	=	$FCBD	; (1) Used by the DRAW statement (DrawAngle)
			; 0 = 0°  rotation
			; 1 = 90° rotation
			; 2 = 180° rotation
			; 3 = 270° Rotation
RUNBNF	=	$FCBE	; (1) Run Binary File After loading ( Bload"File.Bin",R ) 0 = Don't Run / 1 = Run 
SAVENT	=	$FCBF	; (2) start address for BSAVE / BLOAD operations
EXPTBL	=	$fcc1	; (1) Slot 0: #80 = expanded, 0 = not expanded. Also slot address of the main BIOS-ROM.
EXPTBL0	=	$fcc1	; (1) Slot 0: #80 = expanded, 0 = not expanded. Also slot address of the main BIOS-ROM.
EXPTBL1	=	$fcc2	; (1) Slot 1: #80 = expanded, 0 = not expanded.
EXPTBL2	=	$fcc3	; (1) Slot 2: #80 = expanded, 0 = not expanded.
EXPTBL3	=	$fcc4	; (1) Slot 3: #80 = expanded, 0 = not expanded.
SLTTBL	=	$fcc5	; (1) Mirror of slot 0 secondary slot selection register.
SLTTBL0	=	$fcc5	; (1) Mirror of slot 0 secondary slot selection register.
SLTTBL1	=	$fcc6	; (1) Mirror of slot 1 secondary slot selection register.
SLTTBL2 =	$fcc7	; (1) Mirror of slot 2 secondary slot selection register.
SLTTBL3	=	$fcc8	; (1) Mirror of slot 3 secondary slot selection register.
SLTATR	=	$fcc9	; (1) Slot attributes found during start process
			; bit 7 = Basic programm 0 = No / 1 = Yes
			; bit 6 = Device Extention  0 = No / 1 = Yes
			; bit 5 = Statement Extention  0 = No / 1 = Yes
			; bit 4 - 0 = Unused
;---------------------------------------------------------
;                        Hook area
;---------------------------------------------------------
SLTWRK	=	$FD09	; (free word = FD09H + 32*basic slot + 8*expansion slot + 2*page)
PROCNM	=	$FD89	; name of expanded statement
DEVICE	=	$FD99	; (1) device ID for cartrige 0-3
KEYI 	=	$FD9A
;  meaning:	beginning of MSXIO interrupt handling
;  purpose:	adds the interrupt operation such as RS-232C
TIMI	=	$FD9F
;  meaning:	MSXIO timer interrupt handling
;  purpose:	adds the timer interrupt handling
;---------------------------------------------------------
;              Program for expansion BIOS calls
;---------------------------------------------------------
FCALL	=	$FFCA	; hook used by expanded BIOS
DISINT	=	$FFCF	; used by DOS
ENAINT	=	$FFD4	; used by DOS
;---------------------------------------------------------
;      Register reservation area for neW VDP (9938)	
;---------------------------------------------------------
RG08SAV	=	$ffe7	; (1) Content of VDP(09) register (R#08)
RG09SAV	=	$ffe8	; (1) Content of VDP(10) register (R#09)
RG10SAV	=	$ffe9	; (1) Content of VDP(11) register (R#10)
RG11SAV	=	$ffea	; (1) Content of VDP(12) register (R#11)
RG12SAV	=	$ffeb	; (1) Content of VDP(13) register (R#12)
RG13SAV	=	$ffec	; (1) Content of VDP(14) register (R#13)
RG14SAV	=	$ffed	; (1) Content of VDP(15) register (R#14)
RG15SAV	=	$ffee	; (1) Content of VDP(16) register (R#15)
RG16SAV	=	$ffef	; (1) Content of VDP(17) register (R#16)
RG17SAV	=	$fff0	; (1) Content of VDP(18) register (R#17)
RG18SAV	=	$fff1	; (1) Content of VDP(19) register (R#18)
RG19SAV	=	$fff2	; (1) Content of VDP(20) register (R#19)
RG20SAV	=	$fff3	; (1) Content of VDP(21) register (R#20)
RG21SAV	=	$fff4	; (1) Content of VDP(22) register (R#21)
RG22SAV	=	$fff5	; (1) Content of VDP(23) register (R#22)
RG23SAV	=	$fff6	; (1) Content of VDP(24) register (R#23)
;---------------------------------------------------------
;	           MAIN-ROM slot address
;---------------------------------------------------------
ROMSLT	  =	$fff7	; (1) Slotadress of Main-ROM
;reserved =	$fff8	; (2) Reserved
;RG25SAV  =	$fffa	; (1) Content of VDP(26) register (R#25) MSX2+
;RG26SAV  =	$fffb	; (1) Content of VDP(27) register (R#26) MSX2+
;RG27SAV  =	$fffc	; (1) Content of VDP(28) register (R#27) MSX2+
;TMPSTK	  =	$fffd	; (2) Temporary stack pointer storage
;---------------------------------------------------------
;                    Slot selection register
;---------------------------------------------------------
SLTSL	=	$ffff	; (1) Secondary slot select register (Reading returns INVERTED! previous written value)
SLTALL	=	$ffff	; (1) (all slots) Secondary slot select register. Reading returns the inverted previously written value.
;---------------------------------------------------------

;-----------------------------------------------------------
;| ------------------------------------------------------- |
;| |                      F I N                          | |
;| ------------------------------------------------------- |
;-----------------------------------------------------------

