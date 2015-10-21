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
	sbrs R16,TXC0 ;espera a que termine de mandar el dato
	rjmp WAITSEND 
	rjmp SENDDATA
ENDSENDDATA:	
	ret

;Z puntero a donde se guarda el dato. Con 0 se termina el dato,R16 q llega
RECEIVEDATA:
	LDS R16, UCSR0A
	sbrs R16, RXC0 ;espera a que llegue el dato
	rjmp RECEIVEDATA
	in R16,UDRE0
	cpi R16,0
	BREQ ENDRECEIVEDATA
	st Z+,R16
ENDRECEIVEDATA:
	ret

COMUPC:
	LDI  ZL, LOW(MSJ1<<1)   ;cargo msj
	LDI  ZH, HIGH(MSJ1<<1)
	RCALL SENDDATA
	LDI  ZL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  ZH, HIGH(indata)
	RCALL RECEIVEDATA
	LDI  ZL, LOW(indata)   ;cargo el primer dato
	LDI  ZH, HIGH(indata)
	LD R16,Z
	cpi R16,1 ;si es uno borra la sd
	BRNE CMPTXDATA
;	rcall BORRARSD
	ret ;sale
CMPTXDATA:
	cpi R16,2 ;si transmito lo q hay en la sd
	BRNE CMPSETHORA
	rcall TXDATA
	ret ;sale
CMPSETHORA:
	cpi R16,3 ;si es tres, seteo la hora
	BRNE COMUPC ;si mando mal, vuelve a imprimir el msj
	rcall SETHORA
	ret ;sale

SETHORA:
	LDI  ZL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  ZH, HIGH(indata)
	RCALL RECEIVEDATA
	;guardar la hora donde corresponde
	ret

TXDATA:
;	call READSD ;meter esto en un loop hasta que este vacia la sd
	rcall SENDDATA
	ret	


