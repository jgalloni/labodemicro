	.cseg
hi:		.db	"SD card test",0,0
hi2:	.db	"Init successful",0
hi3:	.db	"Halfway",0
err1:	.db	"timeout 1",0
err2:	.db	"timeout 2",0
err3:	.db	"too many cmd1",0
cmd0:	.db	0x40,0x00,0x00,0x00,0x00,0x95	; SD card cmd 0
cmd1:	.db	0x41,0x00,0x00,0x00,0x00,0xff	; SD card cmd 1
cmd9:	.db	0x49,0x00,0x00,0x00,0x00,0xff	; SD card cmd 9
cmdx:   .db 0x50, 0x00,0x00,0x02,0x00, 0xFF,


SD_INITIALIZE:
	ldi	ZL,low(hi<<1)		; greetings, earthling
	ldi	ZH,high(hi<<1)
	CALL SENDDATA
	rcall	SPI_Init		; do SPI initialization
	ldi	ZL,low(hi2<<1)		; greetings again
	ldi	ZH,high(hi2<<1)
	CALL SENDDATA

	RET

get_csd1:
	cbi	portb,portb1		; select ~CS
	ldi	zh,high(cmd9<<1)	; send cmd9
	ldi	zl,low(cmd9<<1)

	ldi	r16,10			; give them 10 tries
okw2:	ser	r20			; wait for response
	rcall	SPI_comm
	dec	r16
	breq	timeout1a
	cpi	r20,0xff
	breq	okw2
	tst	r20
	brne	timeout1a

	ldi	r16,10			; give them 10 tries
okw3:	ser	r20			; wait for response
	rcall	SPI_comm
	dec	r16
	breq	timeout1a
	cpi	r20,0xff
	breq	okw3

	cpi	r20,0xfe		; block start token
	brne	timeout1a

	ldi	yl,low(TAMANIO_TABLA_TEMPERATURA)		; read the CSD data
	ldi	yh,high(TAMANIO_TABLA_TEMPERATURA)
	ldi	r16,18			; 16 bytes & 16 bit CRC

okw4:	ser	r20
	rcall	SPI_comm
	st	y+,r20
	dec	r16
	brne	okw4

	sbi	portb,portb1		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks
;	rcall	send_16
;	rcall	sendCRLF
;	rjmp	loop
	ret

timeout2a:
	ldi	ZL,low(err2<<1)		; greetings again
	ldi	ZH,high(err2<<1)
	CALL SENDDATA
	ret
timeout1a:
	ldi	ZL,low(err1<<1)		; greetings again
	ldi	ZH,high(err1<<1)
	CALL SENDDATA
	ret

; ------------------------------------------------------
;	SPI_init - initializa SPI 
;
;	  PB1 - SPI clock (pin 5 of SD, SCK)
;	  PB2 - Data in (pin 2 of SD, SPI MOSI)
;	  PB3 - Data out (pin 7 of SD, SPI MISO)
;	  PB4 - Chip Sel (pin 1 of SD, SPI ~SS) 
;
;	inicializacion (may or may not be correct)
;	  wait > 1 ms
;	  send 10 0xFF with CS high
;	  send CMD0 (hex: 40 00 00 00 00 95) with CS low
;	  wait for 0x01
;	  repeatedly send CMD1 (hex: 41 00 00 00 00 01)
;	  wait for 0x00

SPI_init:
	push	r16
	push	r17
	push	r20
	push	zh
	push	zl

	sbi	ddrb,portb2		; PB1 is an output to SD card (~CS)
	sbi	portb,portb2

	sbi	ddrb,portb1		; PB1 is an output to SD card (~CS)
	sbi	portb,portb1		; active low, so set high
	sbi	ddrb,portb0		; dataflash chip select
	sbi	portb,portb0		; kill the dataflash

	sbi	ddrb,portb5		; B5 is an output (SCK)
	sbi	ddrb,portb3		; B3 is an output (MOSI)
	cbi	ddrb,portb4		; B4 is an input (MISO)
	sbi	portb,portb4		; pullup?

	ldi	r16,11			; kill a millisecond or so
	clr	r20
splp:	dec	r20
	brne	splp
	dec	r16
	brne	splp

;	enable SPI, master, mode 0
	ldi	r16,(1<<spe)|(1<<mstr)|(0<<cpha)|(0<<cpol)
	out	spcr,r16

;	---------------------- send 74 clock pulses to start it off

	ldi	r16,10			; send 80 clock pulses
	sbi	portb,portb1		; write 1 to ~CS to deselect SD card

splp1:	ser	r20			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	dec	r16			; counting...
	brne	splp1			; and repeat

;	--------------------- send CMD0 to get into SPI mode

	cbi	portb,portb1		; select ~CS
	ldi	zh,high(cmd0<<1)	; send cmd0
	ldi	zl,low(cmd0<<1)
	rcall	send_fcmd

	ldi	r16,10			; give them 10 tries
okw:	ser	r20			; wait for 0x01 (idle)
	rcall	SPI_comm
	dec	r16
	breq	timeout1
	cpi	r20,1
	brne	okw

	sbi	portb,portb1		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks

;	---------------------- send CMD1 to wait for end of idle

	ldi	yl,0xff
	ldi	yh,0x0f
cc1:	cbi	portb,portb1		; select SD card
	ldi	zh,high(cmd1<<1)
	ldi	zl,low(cmd1<<1)
	rcall	send_fcmd		; send cmd1

	ldi	r17,10			; 10 shots at responding
cc2:	ser	r20
	rcall	SPI_comm
	dec	r17
	breq	timeout2
	cpi	r20,0xff
	breq	cc2

cc3:

	ldi	zh,high(cmdx<<1)
	ldi	zl,low(cmdx<<1)
	rcall	send_fcmd	

	tst	r20
	breq	okk
	sbiw	yh:yl,1
	breq	timeout3
	sbi	portb,portb1
	ser	r20
	rcall	SPI_comm
	rjmp	cc1

okk:	sbi	portb,portb1		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks

	pop	zl
	pop	zh
	pop	r20
	pop	r17
	pop	r16
	ret

timeout3:
	ldi	zl,low(err3<<1)		; timeout 3
	ldi	zh,high(err3<<1)
	rjmp	here1
timeout1:
	ldi	zl,low(err1<<1)		; timeout 1
	ldi	zh,high(err1<<1)
	rjmp	here1
timeout2:
	ldi	zl,low(err2<<1)		; timeout 2
	ldi	zh,high(err2<<1) 
here1:	sbi	portb,portb1		; deselect SD card
	CALL SENDDATA
here:	reti

; ------------------------------------------------------
;	send_fcmd - send flash command
;
;	Z - points to 6 byte flash command (not preserved)

send_fcmd:
	push	r20
	push	r18

	ldi	r18,6		; command frames are 6 bytes
slw:	lpm	r20,z+		; send them out
	rcall	SPI_comm
	dec	r18		; repeat until done
	brne	slw

	pop	r18
	pop	r20
	ret

; ------------------------------------------------------
;	SPI_comm - exchange a byte with the SPI
;
;	send a byte (command or otherwise) and receive one, too
;
;	parameters: R20 - byte to send
;
;	returns: R20 - byte received

SPI_comm:
	push	r16

	out	spdr,r20	; going out
sp_wt:	in	r16,spsr	; watch spif flag
	sbrs	r16,spif	; 0 means busy
	rjmp	sp_wt

	in	r20,spdr	; grab the incoming byte

	pop	r16
	ret

; -----------------------------------------------------------
; byte_2_hex - convert byte to hexadecimal string
;
;	parameters:
;	  r0 - byte to convert
;	  z - address of destination for string
;
;	returns:
;	  z points at terminating null, r0 preserved
;
;	note: caller must be sure destination has space for
;	  3 bytes (2 hex digits plus null)

byte_2_hex:
	push	r17
	push	r16

	mov	r17,r0		; our byte to convert
	rcall	hnib2hex	; convert high nibble
	mov	r17,r0		; original again
	swap	r17		; exchange nibbles
	rcall	hnib2hex	; convert high nibble
	clr	r17
	st	Z,r17		; add null at end

	pop	r16
	pop	r17
	ret

hnib2hex:			; helper routine - conv hi nibble
	swap	r17
	andi	r17,0x0f	; keep 4 bits
	cpi	r17,10
	brcs	digs		; branch if 0 to 9
	ldi	r16,'A' - 10	; constant to convert 10 --> 'A'
	rjmp	hout

digs:	ldi	r16,'0'		; constant to convert 0 --> '0'
hout:	add	r17,r16		; add constant to our number
	st	Z+,r17		; and store into output string
	ret

SPI_SEND_BLOCK:
	;;manda el comando
	cbi	portb,portb1	
	LDI R20,0x58
	call SPI_comm

	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm

	LDI R20,0xFF
	call SPI_comm
	mov r18,r20
	call putchr

	LDI R20,0xFF
	call SPI_comm

	LDI R20,0xFF
	call SPI_comm

	LDI R20,0xFE
	call SPI_comm

waitsdwrite:	
	LDI R20,0xff			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	cpi R20,0
	brne	waitsdwrite

	;;;;manda los datos
	ldi	xh,high(TAMANIO_TABLA_TEMPERATURA)	; send cmd0
	ldi	xl,low(TAMANIO_TABLA_TEMPERATURA)
SENDBYTESD:
	LD R20,X+
	;mov r18,r20
	;call putchr
	cpi  R20,0
	BREQ ENDSENDBLOCK
	call SPI_comm
	rjmp SENDBYTESD

ENDSENDBLOCK:
	LDI R20,0xFF
	call SPI_comm

	LDI R20,0xFF
	call SPI_comm

	LDI R20,0xFE
	call SPI_comm

waitspisend:
	LDI R20,0xFF
	call SPI_comm
	cpi r20,0xff
	breq waitspisend

	Sbi	portb,portb1

ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPI_READ_BLOCK:
	;;manda el comando
	cbi	portb,portb1
	LDI R20,0x51
	call SPI_comm

	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm
	LDI R20,0x00
	call SPI_comm

	LDI R20,0xFF
	call SPI_comm

	LDI R20,0xFF
	call SPI_comm
	;;;;espera respuesta
waitsdread:	
	LDI R20,0xff			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	cpi R20,0
	brne	waitsdread

waitsdread1:	
	LDI R20,0xff			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	cpi R20,0xfe
	brne	waitsdread1



	;lee y guarda en la tabla
	ldi	xh,high(TAMANIO_TABLA_TEMPERATURA)	; send cmd0
	ldi	xl,low(TAMANIO_TABLA_TEMPERATURA)
	ldi r16,0xff ;
waitsdread4:	
	LDI R20,0xff			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	st x+,R20
	dec	r16			; counting...
	brne	waitsdread4

	ldi r19,0xff ;
waitsdread5:	
	LDI R20,0xff			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	st x+,R20
	mov r18,r20
	call putchr
	dec	r19			; counting...
	brne	waitsdread5

	;ldi r16,0 ;cambiar por offset
waitsdread6:	
	;LDI R20,0xff			; send 1's
	;rcall	SPI_comm		; clock 8 times each pass
	;dec	r16			; counting...
	;brne	waitsdread6

	LDI R20,0xFF
	call SPI_comm
	LDI R20,0xFF
	call SPI_comm

	lds R20,0
	st x+,R20

	ldi	xh,high(TAMANIO_TABLA_TEMPERATURA)	; send cmd0
	ldi	xl,low(TAMANIO_TABLA_TEMPERATURA)
	call SENDDATAFROMMEM
	Sbi	portb,portb1
ret
