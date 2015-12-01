/*
 * datos_en_ram.asm
 *
 *  Created: 20/10/2015 09:49:00 a.m.
 *   Author: mtomas
 */ 



ESCRIBIR_FECHA_HORA_TEMP_EN_RAM:
	;recibe el parametro de la fecha y lo escribe en la posicion de ram que se le indique en formato DDMMAAHHMM
	;Lueogo de la fecha coloca una "coma" para indicar el fin de linea

	LDI XL,LOW(tabla_temperaturas)
	LDI XH,HIGH(tabla_temperaturas)
	LDS R16,ocupacion_tabla_temp_ram

loopasd:
	LDI R17,16
ultimalinea:
	ADIW XH:XL,1
	cpi
	dec r17
	BRNE ultimalinea
	dec r16
	BRNE loopasd ;va a la ultima posciion de la tabla

	LDS R16,dia ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

	LDS R16,mes  ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

	LDS R16,anio ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

	; A continuacion se escribe el parametro de la hora
	; Lo escribe en la posicion de la ram que se le indique en formato HHMM	
	
	LDS R16,horas ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

	LDS R16,minutos ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

    LDS R16,segundo ;Se guarda en R16 un DATO de dos digito sen formato BCD
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16

	;Se escribe el parametro de la temperatura
	;REVISAR como se escribe la temperatura
	LDS R16,temperatura
	CALL Bin2ToBcd
	MOV R17,R16 
	ROR R17
	ROR R17
	ROR R17
	ROR R17
	ANDI R17,0x0F ;En R17 esta el primer digito del DATO
	ORI R17,0x30 ;En R17 esta el primer digito del DATO
	ANDI R16,0x0F ;En R16 esta el segundo digito del DATO
	ORI R16,0x30 ;En R17 esta el primer digito del DATO
	ST X+,R17            
    ST X+,R16           

	;Por ultimo coloca un caracter "coma" para indicar el fin de linea
	LDI R16,','
	ST X+,R16
	LDI R16,'\n'
	ST X+,R16

	LDS R16,ocupacion_tabla_temp_ram	;actualizamos el valor de Ocupacion_tabla_temperaturas_en_ram
	inc R16								;para ello lo que hacemos es sumar el nuevo largo de los datos copiados
	STS ocupacion_tabla_temp_ram,R16
ret

BORRAR_TABLA_FECHA_HORA_TEMP_EN_RAM:	
;	;llenar tabla con ceros y volver puntero al inicio
	;Usa R17 y R18

;	LDI R17,TAMANIO_TABLA_TEMPERATURA ;Contador
;	LDI XL,LOW(tabla_temperaturas)
;	LDI XH,HIGH(tabla_temperaturas)
;	LDI R18,0x00 ;Valor para rellenar los campos de la tabla

;	LOOP_BTFHTER:
;		ST X+,R18
;		DEC R17
;		BRNE LOOP_BTFHTER
;		LDI XL,LOW(tabla_temperaturas)
;		LDI XH,HIGH(tabla_temperaturas)

;		LDI R17,0
;		STS ocupacion_tabla_temp_ram,R17 ;marcamos como "0" el nivel de ocupación de la tabla
LDI R16,0
STS ocupacion_tabla_temp_ram,R16

ret

GET_TABLA_EN_RAM:
	;Carga en el puntero Y inicio de la tabla donde se guardan las fechas y la temperatura
	LDI YL,LOW(tabla_temperaturas)
	LDI YH,HIGH(tabla_temperaturas)
ret

RELLENAR_TABLA_CON_CEROS_EN_RAM:
	;llenar el final de la tabla con ceros
	;Usa R17 y R18 y el puntero X

	LDI R18,0x00 ;Valor para rellenar los campos de la tabla
	LDS R17,ocupacion_tabla_temp_ram
	LDI R16,TAMANIO_TABLA_TEMPERATURA

	LOOP_BTCCER:
		ST X+,R18
		INC R17
		CP R17,R16
		BRLO LOOP_BTCCER

		STS ocupacion_tabla_temp_ram,R17 ;actualizamos el nivel de ocupación de la tabla
ret


Bin2ToBcd:
 	mov r17,r16
 	ldi r18,0
 looptobcd:
	cpi r17,10
	BRLO endbin2tobcd
	SUBI r17,10
	inc r18
	rjmp looptobcd
endbin2tobcd:
	swap r18
	andi r17,0x0F
	ori r17,r18
ret
