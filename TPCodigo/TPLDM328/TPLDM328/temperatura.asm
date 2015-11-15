/*
 * temperatura.asm
 *
 *  Created: 20/10/2015 10:26:21 a.m.
 *   Author: mtomas
 */ 

 DAME_TEMPERATURA:
; Lee el valor de la tension ingresada por el puerto conectado al sensor
; Convierte el valor leido a grados celsius
; Guarda la temperatura medida en la variable "temperatura"
; Usa r17 y r18
	
	;Activamos el ADC
	LDI R17,0b11000111 ;enable, start conversion y set prescaler
						;el prescaler quedo en 111 (128) para que 20Mhz/128 caiga 
						;dentro del rango de 50khz a 200khz)
	STS ADCSRA,R17

	;Toma dato de temperatura del ADC
	;Para eso miramos que el ADC haya terminado de procesar la informacion verificando el estatus del flag 4 de ADCSRA.
	CAPTURA_TEMPERATURA:
		LDS R17,ADCSRA
		SBRS R17,4			;saltea la siguiente instruccion si el bit 4 del registro esta en 1
		RJMP CAPTURA_TEMPERATURA

	;Si se llega a este punto, es porque el ADC ya termino la conversion a digital

	LDS R17,ADCL
	LDS R18,ADCH
	;Notar que no usaremos el ADCH pues no vamos a tener temperaturas tan altas
	
	;Notar que la resolucion del ADC es de 10 bits y como alimentamos con 5V 
	;entonces cada paso del ADC equivale a 5mV (pues 5V/1024 es aprox 5mV)

	;La salida del LM35 varía linealmente con la temperatura (10 mV x °C)
	;Por lo tanto tendremos una resolucion de medio grado

	;La salida del ADC puede pasarse a Volts haciendo: Vin*(1024) / Vref
	;donde Vin es la tension que entro por la pata del adc (lo que envio el LM35)
	;y donde Vref es 5V 
	;La conversión a °C entonces seria:
	;°C = [Vin*(1024)]/[5v] = Vin *  205

	LDI R18,205
	FMUL R17,R18
	;El resultado del producto está en R1:R0, pero utilizo solo R0 porque las temperaturas son bajas
	STS temperatura,R0
 ret