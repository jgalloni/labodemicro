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
	
	ldi R16,0
	;configuro el stack

	LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16

	;configuro las interrupciones externas

	LDI R16,0b10011; ptd3 y 4 como entrada
	OUT DDRD,R16
	
	LDI R16,5 ;la interrupcion es por cambio de nivel
	sts EICRA,R16

	LDI R16,0b11; habilito las interrupciones en las patas 4 y 5
	OUT EIMSK,R16

;	ldi r16,0
	;configuro isp para el rtc

	;LDI R16,1
	;STS TWSR,R16

	SEI

 ret