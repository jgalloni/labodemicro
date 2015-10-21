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
; Usa R17
	IN R17,PINB		;Toma dato de Port B
	;hacer cuenta para convertir Volts en grados Celsius y darle el formato correcto
	STS temperatura,R17;
 ret