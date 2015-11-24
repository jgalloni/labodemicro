.INCLUDE "M328DEF.INC"				; Incluye definición archivos 

.EQU LIM_MAX_TABLA_TEMPERATURAS=60	;Max tamaño esperable en tabla en RAM
.EQU TAMANIO_TABLA_TEMPERATURA=255	;bytes para llenar con lineas tipo DDMMAAHHMMTTTTT, 
.EQU TAMANIO_TEXTO_TEMPERATURA=1	;bytes
;.EQU BARRA='/'
;.EQU DOS_PUNTOS=':'
;.EQU COMA=','
;.EQU PCOMA=';'
.EQU LONG_LOG=0x10;	;es el largo que tendra cada liea que se escriba con la T + Fecha en formato "DDMMAAHHMMSTT.T,"

.DSEG
.org 0x160

;Variables necesarias
	temperatura: .byte TAMANIO_TEXTO_TEMPERATURA	;almacena el dato del medidor de temperatura
	dia: .byte 1
	mes: .byte 1
	anio: .byte 1
	horas: .byte 1
	minutos: .byte 1
	segundos: .byte 1
	set_dia: .byte 1
	set_mes: .byte 1
	set_anio: .byte 1
	set_horas: .byte 1
	set_minutos: .byte 1
	set_segundos: .byte 1
	tabla_temperaturas: .byte TAMANIO_TABLA_TEMPERATURA
	tabla_temperaturas_1: .byte TAMANIO_TABLA_TEMPERATURA
	tabla_temperaturas_2: .byte TAMANIO_TABLA_TEMPERATURA	 
	ocupacion_tabla_temp_ram: .byte 1	;sirve para registrar qué tan llena está la ram con datos de tmeperatura+ fecha
	indata: .byte 5

.CSEG 
.ORG 0x00
RJMP PROGRAMA

.ORG INT1addr
JMP WAKEUP

.ORG INT0addr
JMP COMUPC   


.ORG 0x30
/*aqui se incluyen los bloques de codigo que implementemos por separado*/
.include "func_test_m1.asm"		;Archivo Test, se puede borrar
.include "func_test_m2.asm"		;Archivo Test, se puede borrar

.include "time.asm"				;Rutinas para obtener fecha y hora
.include "rwd_en_ram.asm"		;Rutinas para escribir, leer y borrar datos de la ram
.include "copy_ram_to_sd.asm"	;Rutinas para copiar datos de la RAM a la SD
.include "copy_sd_to_ram.asm" 	;Rutina para copiar de la SD a la RAM
.include "temperatura.asm"		;Rutinas para leer la medicion del sensor de temperatura

.include "tx.asm"			;Rutinas transmitir datos a la pc
.include "setup.asm"		;Rutinas configurar el micro

/***********************************************************************/					
									           
PROGRAMA:

	CALL SETUP
;	CALL COMUPC
	RCALL BORRAR_TABLA_FECHA_HORA_TEMP_EN_RAM ;inicializa la tabla

	INICIO_LOOP_SENSADO:
		CLI
		;leer temperatura T
		RCALL DAME_TEMPERATURA
		;Leer fecha y hora
		RCALL DAME_FECHA_HORA
		
		;almacenar en memoria ram: fecha+hora+temperatura
		RCALL ESCRIBIR_FECHA_HORA_TEMP_EN_RAM

		;si la tabla de temperaturas tiene más de 512 bytes, copiar tabla en SD y luego limpiar RAM
		LDS R17,ocupacion_tabla_temp_ram
		CPI R17,LIM_MAX_TABLA_TEMPERATURAS
		BRMI A_DORMIR
		;Copiar RAM to SD
		RCALL BORRAR_TABLA_FECHA_HORA_TEMP_EN_RAM

		A_DORMIR:
			SEI
			;Dormir por N tiempo
			sleep

		RJMP INICIO_LOOP_SENSADO

	END: RJMP END 


	WAKEUP: RETI

	.ORG 0x500  ;cambiar pos  ;msj para la pc                    
MSJ1: .DB "1 para borrar SD,2 para transferir datos,3 para setear hora ",'\n',0
MSJ2: .DB "SD borrada",'\n',0
MSJ3: .DB "Ingrese DD/MM/AA HH:MM:SS ",'\n',0
