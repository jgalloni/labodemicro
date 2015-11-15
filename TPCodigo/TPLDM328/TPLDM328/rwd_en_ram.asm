/*
 * datos_en_ram.asm
 *
 *  Created: 20/10/2015 09:49:00 a.m.
 *   Author: mtomas
 */ 


ESCRIBIR_FECHA_HORA_TEMP_EN_RAM:
;recibe el parametro de la fecha 
;lo escribe en la posicion de ram que se le indique en formato DD/MM/AAAA
;Al final de la fecha, coloca una coma
	LDS R16,dia           
    ST   X+,R16

	LDS R16,mes           
    ST   X+,R16	               

	LDS R16,anio           
    ST   X+,R16

;recibe el parametro de la hora
; lo escribe en la posicion de la ram que se le indique en formato HH:MM
; Al final de la hora, coloca una coma
	
	LDS R16,horas           
    ST   X+,R16

	LDS R16,minutos
	ST	X+,R16

;Recibe el parametro de la temperatura
;lo escribe en la posicion de la ram que se le indique, usando 5 caracteres::
; +02.8
; -10.4
	LDS R16,temperatura           
    ST   X+,R16

; Se escribe un "punto y coma" para indicar el fin de linea

	LDS R16,ocupacion_tabla_temp_ram	;actualizamos el valor de Ocupacion_tabla_temperaturas_en_ram
	LDI R17,LONG_LOG
	ADD R16,R17					;para ello lo que hacemos es sumar el nuevo largo de los datos copiados
	STS ocupacion_tabla_temp_ram,R16

ret

BORRAR_TABLA_FECHA_HORA_TEMP_EN_RAM:
;llenar tabla con ceros y volver puntero al inicio
;Usa R17 y R18

	LDI R17,TAMANIO_TABLA_TEMPERATURA ;Contador
	LDI XL,LOW(tabla_temperaturas)
	LDI XH,HIGH(tabla_temperaturas)
	LDI R18,0x00

LOOP_BTFHTER:
	ST X+,R18
	DEC R17
	BRNE LOOP_BTFHTER

	LDI XL,LOW(tabla_temperaturas)
	LDI XH,HIGH(tabla_temperaturas)

	LDI R17,0
	STS ocupacion_tabla_temp_ram,R17 ;marcamos como "0" el nivel de ocupación de la tabla
ret

GET_TABLA_EN_RAM:
;entregaria un punturo al inicio de la tabla, y la longitud de la misma
ret
