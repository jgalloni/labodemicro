SETUP:
	;setea el PORTC.0 como entrada para la lectura de temperaturas
 	;usa R17
	;LDI R17,0x00	;Load 0b00000000 in R17
	;OUT DDRC,R16	;Configure PortC as an Input port
	;CBI DDRC,0 ;configura PORTC.0 como Input port

	;Configuración del ADC
	LDI R17,(1<<REFS0)
	STS ADMUX,R17
	ldi R17, (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	sts ADCSRA, R17
	;Para elegir la referencia:
	;CBI ADMUX,7
	;CBI ADMUX,6
	;Para ajustar a izquierda
	;SBI ADMUX,5
	;Para definir que vamos a usar el ADC0 para tomar la temperatura
	;CBI ADMUX,3 
	;CBI ADMUX,2
	;CBI ADMUX,1
	;CBI ADMUX,0

	;configuro el puerto serie
	ldi R16,HIGH(UBRR)
	sts  UBRR0H,R16
	ldi R16,LOW(UBRR)
	sts  UBRR0L,R16 ;seteo los baudios
	ldi R16,(1<<RXEN0)|(1<<TXEN0)
	sts  UCSR0B,R16  ;rx,tx habilitado
	ldi R16, (1<<USBS0)|(1<<UCSZ00)|(1<<UCSZ01)
	sts  UCSR0C,R16 ;8bits, 1 de stop sin pariedad
	
	ldi R16,0
	;configuro el stack

	LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16

	;configuro las interrupciones externas

	LDI R16,0b1100;
	OUT PORTD,R16

	LDI R16,0b1010  ;la interrupcion es por flanco ascendente
	STS EICRA,R16

	LDI R16,0b11; habilito las interrupciones en las patas 4 y 5
	OUT  EIMSK,R16

	ldi R16, 0b11
	OUT EIFR, R16 


;	ldi r16,0
	;configuro isp para el rtc
	;LDI R16,1
	;STS TWSR,R16


	;activar interrupciones
	SEI
 ret