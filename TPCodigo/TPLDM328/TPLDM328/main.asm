.INCLUDE "M328DEF.INC"				; Incluye definición archivos 

.EQU LIM_MAX_TABLA_TEMPERATURAS=512	;Max tamaño esperable en tabla en RAM
.EQU TAMANIO_TABLA_TEMPERATURA=100	;bytes
.EQU TAMANIO_TEXTO_TEMPERATURA=1	;bytes
.EQU BARRA='/'
.EQU DOS_PUNTOS=':'
.EQU COMA=','
.EQU PCOMA=';'

.DSEG
.org 0x160

;Variables necesarias
	temperatura: .byte TAMANIO_TEXTO_TEMPERATURA
	dia: .byte 1
	mes: .byte 1
	anio: .byte 1
	horas: .byte 1
	minutos: .byte 1
	tabla_temperaturas: .byte TAMANIO_TABLA_TEMPERATURA 

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

/***********************************************************************/					
									           
PROGRAMA:
    LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16
	
	RCALL subrutina_test_m		;Rutinas para test, se puede borrar
	RCALL subrutina_test_m2		;rutinas para test, se puede borrar
	
	END: RJMP END 

