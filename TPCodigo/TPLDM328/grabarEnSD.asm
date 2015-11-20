;RUTINA PARA COPIAR LA INFORMACION DE LA MEMORIA RAM EN LA SD MEDIANTE
;EL PROTOCOLO SERIE

;Esta rutina utiliza el registro X para copiar la informacion de la posicion de 
;memoria asignada a la SD
.EQU PUNTERO_DEL_REGISTRO_DONDE_ESTA_LA_INFORMACION = X

;Para setear los BaudRate hay una tabla que corresponde a la frecuencia
;del cristal que se esta utilizando.
; BaudRate = 9600 con un cristal de 8Mhz => BAUDRATE = 51 (decimal)

.INCLUDE "M32DEF.INC"

.EQU BAUDRATE = 51

;CANTIDAD_DE_REGISTROS_A_LEER representa la cantidad total de registros que tienen
;que copiarse a la SD
.EQU CANTIDAD_DE_REGISTROS_A_LEER = 56

.ORG 0
	JMP PROGRAMA

.ORG 300
PROGRAMA:

	;Inicializacion de StackPointer (se carga la direccion de 
	;la ultima posicion de memoria de la RAM)
	R16,HIGH(RAMEND)
	OUT SPH,R16
	LDI R16,LOW(RAMEND)
	OUT SPL,R16
		
	;Habilitacion de bit en el registro UCSRB para
	;transmitir informacion mediante Tx (MOSI)
	;UCSRB: USART Control and Status Register B
	LDI R16,(1<<RXEN0)
	STS UCSR0B,R16  


	;Configuracion del BaudRate = 9600 para un cristal de 8Mhz
	LDI R16,BAUDRATE
	OUT UBRRL,R16	
	
	;Se envia informacion de 8-bit => (1<<UCSZ1)
	;Sin bit de paridad => (1<<UCSZ0)
	LDI R16,(1<<UCSZ1)|(1<<UCSZ0)
	OUT UCSRC,R16

;Aca empieza la parte para enviar la informacion a la SD(transmitir)
	
	;A partir de aca empiezo a aponer lo que me parece va
	;Para enviar informacion a mediante Protocolo Serie se pone la informacion en el registro UDR


LDI R30, CANTIDAD_DE_REGISTROS_A_LEER
COPIAR_A_SD:
	SBIS UCSRA,UDRE	;verifica si esta vacio UDR. 
	RJMP REPETIR

	LDI R16, PUNTERO_DEL_REGISTRO_DONDE_ESTA_LA_INFORMACION+	
	OUT UDR,R16

	DEC R30
	BRNQ COPIAR_A_SD
	
FIN:
	RJMP FIN
