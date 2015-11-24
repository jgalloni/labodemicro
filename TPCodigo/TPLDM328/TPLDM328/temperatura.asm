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
; Usa R16, R17, R18
	
	;Activamos el ADC
	;LDI R17,0b11000111 ;enable, start conversion y set prescaler
						;el prescaler quedo en 111 (128) para que 20Mhz/128 caiga 
						;dentro del rango de 50khz a 200khz)
	;STS ADCSRA,R17

	;Toma dato de temperatura del ADC
	;Para eso miramos que el ADC haya terminado de procesar la informacion verificando el estatus del flag 4 de ADCSRA.
	ldS R17, ADCSRA    
	ori R17, (1<<ADSC)
	sts ADCSRA, R17

	CAPTURA_TEMPERATURA:
		LDS R17,ADCSRA
		SBRC R17,ADSC			;saltea la siguiente instruccion si el bit 4 del registro esta en 1
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

	;LDI R18,205
	;FMUL R17,R18
	CLC 
	ROR R17
	;El resultado del producto está en R1:R0, pero utilizo solo R0 porque las temperaturas son bajas
//	MOV R16,R18
//	call Putchr
	;A continuacion se realiza la conversion de la temperatura en R16, de numero binario a BCD
	CALL BIN_TO_BCD

	STS temperatura,R16
 ret


BIN_TO_BCD: 
	;En R16 viene  el dato a convertir
	;Se usan los registros R17 y R18
	;En nuestro caso tendremos temperaturas menores a 100 grados celsius, 
	;con lo cual vamos a convertir numeros menores a 100.

	LDI R17,0 ;decenas

	BIN_MAYOR_A_DIEZ:
		CPI R16,10 ;si es mayor a diez, aumentar contador de decenas y restar 10 al numero binario
		BRLO BIN_MAYOR_A_UNO
		subi R16,10
		inc R17
		RJMP BIN_MAYOR_A_DIEZ

	BIN_MAYOR_A_UNO:
	;En este punto, en R17 esta la cantidad de decenas y en R16 la cantidad de unidades.
	;Finalmente, se unen ambas partes en un solo valor BCD 
	ADD R16,R17
ret