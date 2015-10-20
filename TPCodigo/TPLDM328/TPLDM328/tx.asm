.EQU BAUDRATE 9600
.EQU XTALFREQ 
.EQU UBRR (XTALFREQ/(16*BAUDRATE))-1 

;X puntero al dato ,R16 char a mandar
SENDDATA:
	LPM R16,X+
	cpi  R16,0
	BREQ ENDSENDDATA
	out UDR0,R16
WAITSEND:
	in R16,UCSRnA
	sbis R16,UDREn ;espera a que termine de mandar el dato
	rjmp WAITSEND 
	rjmp SENDDATA
ENDSENDDATA:	
	ret

;X puntero a donde se guarda el dato. Con 0 se termina el dato,R16 q llega
RECEIVEDATA:
	in R16, UCSRnA
	sbrs R16, UDREn 
	rjmp RECEIVEDATA
	in R16,UDREn
	cpi R16,0
	BREQ ENDRECEIVEDATA
	st +X,R16
ENDRECEIVEDATA:
	ret

COMUPC:
	LDI  XL, LOW(MSJ1<<1)   ;cargo msj
	LDI  XH, HIGH(MSJ1<<1)
	RCALL SENDDATA
	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)
	RCALL RECEIVEDATA
	LDI  XL, LOW(indata)   ;cargo el primer dato
	LDI  XH, HIGH(indata)
	LD R16,X
	cpi R16,1 ;si es uno borra la sd
	BRNE CMPTXDATA
	rcall BORRARSD
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
	LDI  XL, LOW(indata)   ;cargo la posicion donde llega el dato
	LDI  XH, HIGH(indata)
	RCALL RECEIVEDATA
	;guardar la hora donde corresponde
	ret

TXDATA:
	call READSD ;meter esto en un loop hasta que este vacia la sd
	rcall SENDDATA
	ret	


.ORG 0x500  ;cambiar pos  ;msj para la pc                    
MSJ1: .DB "1 para borrar SD,2 para transferir datos,3 para setear hora",0
MSJ2: .DB "SD borrada",0
MSJ1: .DB "Ingrese HH:MM:SS",0
