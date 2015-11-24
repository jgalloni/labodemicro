.EQU BAUDRATE=9600
.EQU XTALFREQ=8000000 
.EQU UBRR=(XTALFREQ/(16*BAUDRATE))-1 

;Z puntero al dato ,R16 char a mandar
SENDDATA:
	LPM R16,Z+
	cpi  R16,0
	BREQ ENDSENDDATA

	sts  UDR0,R16
WAITSEND:
	LDS R16,UCSR0A
	sbrs R16,UDRE0 ;espera a que termine de mandar el dato
	rjmp WAITSEND 
	rjmp SENDDATA
ENDSENDDATA:	
	ret

SENDDATAFROMMEM:
	LD R16,X+
	cpi  R16,0
	BREQ ENDSENDDATA2

	sts  UDR0,R16
WAITSEND2:
	LDS R16,UCSR0A
	sbrs R16,UDRE0 ;espera a que termine de mandar el dato
	rjmp WAITSEND2 
	rjmp SENDDATAFROMMEM
ENDSENDDATA2:	
	ret

;Z puntero a donde se guarda el dato. Con 0 se termina el dato,R16 q llega
RECEIVEDATA:
	LDS R16, UCSR0A
	sbrs R16, RXC0 ;espera a que llegue el dato
	rjmp RECEIVEDATA
	in R16,UDRE0
	cpi R16,0
	BREQ ENDRECEIVEDATA
	st X+,R16
ENDRECEIVEDATA:
	ret

Getchr: 
	lds		R17,UCSR0A 
	sbrs	R17,	RXC0
	rjmp		Getchr 
	lds	R18,	UDR0
	ret

	EXT_INT0:
	EXT_INT1:
COMUPC:
	CLI
	ldi r16,0b10000
	out PORTD,r16
	LDI  ZL, LOW(MSJ1<<1)   ;cargo msj
	LDI  ZH, HIGH(MSJ1<<1)
	RCALL SENDDATA
	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)
	RCALL Getchr
	RCALL Putchr
//	LDI  ZL, LOW(indata)   ;cargo el primer dato
//	LDI  ZH, HIGH(indata)
//	LD R16,Z
	cpi R18,49 ;si es uno borra la sd
	BRNE CMPTXDATA
	rcall BORRARSD
	SEI
	reti ;sale interrupcion
CMPTXDATA:
	cpi R18,50 ;si transmito lo q hay en la sd
	BRNE CMPSETHORA
	rcall TXDATA
	SEI
	reti ;sale interrupcion
CMPSETHORA:
	cpi R18,51 ;si es tres, seteo la hora
	BRNE COMUPC ;si mando mal, vuelve a imprimir el msj
	rcall SETHORA
	SEI
	reti ;sale interrupcion

SETHORA:
	LDI  ZL, LOW(MSJ3<<1)   ;cargo msj
	LDI  ZH, HIGH(MSJ3<<1)
	RCALL SENDDATA
	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)

	RCALL Getchr
	st X+,R18
	RCALL Getchr; dia
	st X+,R18

	RCALL Getchr
	
	RCALL Getchr ;mes
	st X+,R18
	RCALL Getchr
	st X+,R18

	RCALL Getchr

	RCALL Getchr ;año
	st X+,R18
	RCALL Getchr
	st X+,R18

	RCALL Getchr

	RCALL Getchr
	st X+,R18
	RCALL Getchr; hora
	st X+,R18

	RCALL Getchr
	
	RCALL Getchr ;minutos
	st X+,R18
	RCALL Getchr
	st X+,R18

	RCALL Getchr

	RCALL Getchr ;segundos
	st X+,R18
	RCALL Getchr
	st X+,R18

	LDI R18,0
	st X+,R18

	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)
	RCALL SENDDATAFROMMEM

	//RCALL RECEIVEDATA
	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)
	RCALL FORMAT_IN_DATE;guardar la fecha
	ret

TXDATA:
;	call READSD ;meter esto en un loop hasta que este vacia la sd
	rcall SENDDATA
	ret	

BORRARSD:
	LDI  ZL, LOW(MSJ2<<1)   ;cargo msj
	LDI  ZH, HIGH(MSJ2<<1)
	RCALL SENDDATA
	ret

Putchr: ; Wait for empty transmit buffer
	LDS		R16,UCSR0A
	sbrs	R16,UDRE0
	rjmp 	Putchr
	sts		UDR0,R18
	WAITPUTCHAR:
	LDS		R16,UCSR0A
	sbrs	R16,UDRE0
	rjmp 	WAITPUTCHAR
	ret ; Put data from (r18)
	

ASCII_TO_BIN:
	LD R16,X+
	SUBI R16,48
	LSL R16
	LSL R16
	LSL R16
	LSL R16
	MOV R17,R16
	LD R16,X+
	SUBI R16,48
	ADD R16,R17
RET

FORMAT_IN_DATE:
	RCALL ASCII_TO_BIN
	STS set_dia,R16
	RCALL ASCII_TO_BIN
	STS set_mes,R16
	RCALL ASCII_TO_BIN
	STS set_anio,R16
	RCALL ASCII_TO_BIN
	STS set_horas,R16
	RCALL ASCII_TO_BIN
	STS set_minutos,R16
	RCALL ASCII_TO_BIN
	STS set_segundos,R16
RET	 