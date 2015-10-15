.INCLUDE "M8DEF.INC"                                  ; Incluye definición archivos 

; .EQU TEMP=4

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
PROGRAMA:
    LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16

