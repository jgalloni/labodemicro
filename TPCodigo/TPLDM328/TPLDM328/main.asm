.INCLUDE "M328DEF.INC"				; Incluye definición archivos 

.EQU LIM_MAX_TABLA_TEMPERATURAS=200	;Max tamaño esperable en tabla en RAM
.EQU TAMANIO_TABLA_TEMPERATURA=20	;bytes
.EQU TAMANIO_TEXTO_TEMPERATURA=1	;bytes
.EQU BARRA='/'
.EQU DOS_PUNTOS=':'
.EQU COMA=','
.EQU PCOMA=';'
.EQU LONG_LOG=0x0F;	;es lo que va a medir cada linea del LOG

.DSEG
.org 0x160

;Variables necesarias
	temperatura: .byte TAMANIO_TEXTO_TEMPERATURA	;almacena el dato del medidor de temperatura
	dia: .byte 1
	mes: .byte 1
	anio: .byte 1
	horas: .byte 1
	minutos: .byte 1
	tabla_temperaturas: .byte TAMANIO_TABLA_TEMPERATURA 
	ocupacion_tabla_temp_ram: .byte 1	;sirve para registrar qué tan llena está la ram con datos de tmeperatura
	indata: .byte 5

.CSEG 
.ORG 0x00
RJMP PROGRAMA   


.ORG 0x30
/*aqui se incluyen los bloques de codigo que implementemos por separado*/
.include "func_test_m1.asm"		;Archivo Test, se puede borrar
.include "func_test_m2.asm"		;Archivo Test, se puede borrar

.include "time.asm"				;Rutinas para obtener fecha y hora
.include "rwd_en_ram.asm"		;Rutinas para escribir, leer y borrar datos de la ram
.include "copy_ram_to_sd.asm"	;Rutinas para copiar datos de la RAM a la SD
.include "temperatura.asm"		;Rutinas para leer la medicion del sensor de temperatura

.include "tx.asm"			;Rutinas transmitir datos a la pc
.include "setup.asm"		;Rutinas configurar el micro

/***********************************************************************/					
									           
PROGRAMA:

	CALL SETUP
	CALL COMUPC
	RCALL BORRAR_TABLA_FECHA_HORA_TEMP_EN_RAM ;inicializa la tabla

	INICIO_LOOP_SENSADO:

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
			;Dormir por N tiempo

		RJMP INICIO_LOOP_SENSADO

	END: RJMP END 

	.ORG 0x500  ;cambiar pos  ;msj para la pc                    
MSJ1: .DB "1 para borrar SD,2 para transferir datos,3 para setear hora",0
MSJ2: .DB "SD borrada ",0
MSJ3: .DB "Ingrese HH:MM:SS ",0