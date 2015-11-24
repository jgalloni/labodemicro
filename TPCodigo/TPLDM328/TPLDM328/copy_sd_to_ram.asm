/*
 * copy_sd_to_ram.asm
 *
 * 
 */ 

COPY_FROM_SD:
	; Set MOSI and SCK output, all others input
	; (1<<DD_MOSI)|(1<<DD_SCK) esta sentencia lque hace es realizar
	; el corrimiento de los bits al que se va a copiar
	; DD_MOSI = PB3 es el registro del que estamos copiando los datos
	; DDR_SPI = DDRB
	; DD_MISO = PB4
	; DD_SCK = PB5

SPI_SlaveInit:
	; Set MISO output, all others input
	ldi r17,(1<<PB4)
	out DDRB,r17
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
