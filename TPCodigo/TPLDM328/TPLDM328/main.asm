.INCLUDE "M328DEF.INC"                                  ; Incluye definición archivos 

.DSEG
.org 0x160

;Variables necesarias
	temperatura: .byte 1
    horas: .byte 1
    minutos: .byte 1
	dia: .byte 1
	mes: .byte 1
	anio: .byte 1		

.CSEG 
.ORG 0x00
RJMP PROGRAMA   


.ORG 0x30
/*aqui se incluyen los bloques de codigo que implementemos por separado*/
.include "func_m1.asm"
.include "func_m2.asm"
/***********************************************************************/					
									           
PROGRAMA:
    LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16
	
	RCALL subrutina_test_m

	RCALL subrutina_test_m2
	
	END: RJMP END 

