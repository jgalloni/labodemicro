/*
 * temperatura.asm
 *
 *  Created: 20/10/2015 10:26:21 a.m.
 *   Author: mtomas
 */ 


 INICIALIZAR_PUERTO_TEMPERATURA:
 ;setea el puerto X como entrada para la lectura de temperaturas
 ;usa R17
	LDI R17,0x00	;Load 0b00000000 in R17
	OUT DDRB,R16	;Configure PortB as an Input port
 ret

 DAME_TEMPERATURA:
; Lee el valor de la tension ingresada por el puerto conectado al sensor
; Convierte el valor leido a grados celsius
; Guarda la temperatura medida en la variable "temperatura"
; Usa R17
	IN R17,PINB		;Toma dato de Port B
	;hacer cuenta para convertir Volts en grados Celsius y darle el formato correcto
	STS temperatura,R17;
 ret