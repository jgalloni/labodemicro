
;El programa envia informacino mediante SPI
;Se utiliza R16 para enviar informacio


.INCLUDE "M328DEF.INC"



.EQU RegistroDelQueCopiarLosDatos = R16

.ORG 0x00
JMP PROGRAMA   ;test de grabado

;dejo los comentarios que estan en el datasheet para saber de donde
;saque los datos

;MOSI y MISO son dos pines del puerto B, por lo que hay que
;ver que se va a usar en el momento de la interrupcion

PROGRAMA:
	JMP SPI_MasterInit 

	LDI R16,'H'
	JMP SPI_MasterTransmit

	LDI R16,'O'
	JMP SPI_MasterTransmit

	LDI R16,'L'
	JMP SPI_MasterTransmit

	LDI R16,'A'
	JMP SPI_MasterTransmit

FIN_DEL_PROGRAMA:
	RJMP FIN_DEL_PROGRAMA

SPI_MasterInit:
	; Set MOSI and SCK output, all others input
	; (1<<DD_MOSI)|(1<<DD_SCK) esta sentencia lque hace es realizar
	; el corrimiento de los bits al que se va a copiar
	; DD_MOSI = PB3 es el registro del que estamos copiando los datos
	; DDR_SPI = DDRB
	; DD_MISO = PB4
	; DD_SCK = PB5

	LDI R17,(1<<PB4)|(1<<PB5)
	OUT DDRB,R17
	; Enable SPI, Master, set clock rate fck/16
	LDI R17,(1<<SPE)|(1<<MSTR)|(1<<SPR0)
	OUT SPCR,r17
	RET

SPI_MasterTransmit:
	; Start transmission of data (r16)
	OUT SPDR,R16
	Wait_Transmit:
	; Wait for transmission complete
	IN R16, SPSR
	SBRS R16, SPIF
	RJMP Wait_Transmit
	RET

Wait_Transmit:
	; Wait for transmission complete
	IN r16, SPSR
	SBRS r16, SPIF
	RJMP Wait_Transmit
	RET

