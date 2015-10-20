/*
 * AsmFile1.asm
 *
 *  Created: 20/10/2015 09:48:29 a.m.
 *   Author: mtomas
 */ 

DAME_FECHA_HORA:
;utilizaría el RTC parac obtener y cargar la hora y la fecha en las variables:
; - fecha
; - hora
;Utiliza R18
    ldi r18,20		;Suponemos que la fecha es "20/10/15"
    sts dia, r18	
    ldi r18,10		;Suponemos que la fecha es "20/10/15"
    sts mes, r18	
    ldi r18,15		;Suponemos que la fecha es "20/10/15"
    sts anio, r18	


	ldi r18,13		;suponemos que la hora es "13:15"
	sts horas, r18
	ldi r18,15		;suponemos que la hora es "13:15"
	sts minutos, r18

ret

SET_FECHA_HORA:
;configura la fecha y la hora en el RTC del uC
ret

