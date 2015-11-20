.INCLUDE "M328DEF.INC"

.EQU RegistroDelQueCopiarLosDatos = R16

.ORG 0x00
JMP SPI_MasterInit   ;test de grabado

;dejo los comentarios que estan en el datasheet para saber de donde
;saque los datos

;MOSI y MISO son dos pines del puerto B, por lo que hay que
;ver que se va a usar en el momento de la interrupcion

;MOSI es la salida y donde se va a poner el bit de informacion

SPI_MasterInit:
	; Set MOSI and SCK output, all others input
	; (1<<DD_MOSI)|(1<<DD_SCK) esta sentencia lque hace es realizar
	; el corrimiento de los bits al que se va a copiar
	; DD_MOSI es el registro del que estamos copiando los datos

	ldi r17,(1<<DD_MOSI)|(1<<DD_SCK)
	out DDR_SPI,r17
	; Enable SPI, Master, set clock rate fck/16
	ldi r17,(1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out SPCR,r17
ret

SPI_MasterTransmit:
	; Start transmission of data (r16)
	out SPDR,r16
	Wait_Transmit:
	; Wait for transmission complete
	in r16, SPSR
	sbrs r16, SPIF
	rjmp Wait_Transmit
ret

SPI_SlaveInit:
	; Set MISO output, all others input
	ldi r17,(1<<DD_MISO)	;aca copio en la en el bit
	out DDR_SPI,r17
	; Enable SPI
	ldi r17,(1<<SPE)
	out SPCR,r17
ret
	
SPI_SlaveReceive:
	; Wait for reception complete
	in r16, SPSR
	sbrs r16, SPIF
	rjmp SPI_SlaveReceive
	; Read received data and return
	in r16,SPDR
ret
