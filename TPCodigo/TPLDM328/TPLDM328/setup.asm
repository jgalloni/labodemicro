SETUP:
	;setea el puerto X como entrada para la lectura de temperaturas
 	;usa R17
	LDI R17,0x00	;Load 0b00000000 in R17
	OUT DDRB,R16	;Configure PortB as an Input port

	;configuro el puerto serie
	ldi R16,HIGH(UBRR)
	out UBRR0H,R16
	ldi R16,LOW(UBRR)
	out UBRR0L,R16 ;seteo los baudios
	ldi R16,0b00011000
	out UCSR0B,R16  ;rx,tx habilitado
	ldi R16,0x86
	out UCSR0C,R16 ;8bits, 1 de stop sin pariedad
	
 ret