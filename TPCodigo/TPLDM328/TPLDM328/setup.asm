SETUP:
	;setea el puerto X como entrada para la lectura de temperaturas
 	;usa R17
	LDI R17,0x00	;Load 0b00000000 in R17
	OUT DDRB,R16	;Configure PortB as an Input port

	;configuro el puerto serie
	ldi R16,HIGH(UBRR)
	sts  UBRR0H,R16
	ldi R16,LOW(UBRR)
	sts  UBRR0L,R16 ;seteo los baudios
	ldi R16,0x18
	sts  UCSR0B,R16  ;rx,tx habilitado
	ldi R16,0x86
	sts  UCSR0C,R16 ;8bits, 1 de stop sin pariedad
	
	;configuro el stack

	LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16

 ret