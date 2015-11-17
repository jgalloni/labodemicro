/*
 * AsmFile1.asm
 *
 *  Created: 20/10/2015 09:48:29 a.m.
 *   Author: mtomas
 */ 

DAME_FECHA_HORA:
	;utilizaría el RTC parac obtener y cargar la hora en las variables:
	;dia, mes, anio, horas,minutos.

	;Para leer los datos del RTC  primero debemos escribir en el dispositivo (para setear el Address Pointer del device)
	;Luego se le envia un READ para obtener los DATOS en esa address.

	CALL I2C_INIT				;inicializa el modo TWI
	
	;Master generates Start Condition, status code 0x08 is returned para indicar que la condicion de START se transmitio OK. 
	CALL I2C_START				;transmite la condición de START
	CALL I2C_READ_STATUS		;lee el registro de Status
	CPI R26,0x08				;verifica si se transmitio correctamente el START (0x08 es la respuesta esperada)
	;BRNE ERROR_I2C_READ_STATUS	;If error, jump to error function

	;Master sends slave bus address (SLA en este caso es 0xd1=0b1100 0001), DS1307 returns ACK
	LDI R21,0b11010001			;bus address del SLAVE DS1307(1101000)+R(1) [es la orden de "leer"]
								;A continuacion, escribimos R27 en el I2C Bus
	CALL I2C_SEND				;envia la info por el bus

	;A continuacion se solicita la info al RTC
	;En cada pasada se pediran en el siguiente orden: Segundos, Minutos, Horas, Dia, Mes Anio
	
	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R21,0x7F			;mascara para sacar los 7 LSB de los SEGUNDOS
	STS segundos,R21
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function

	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R27,0x7F			;mascara para sacar los 7 LSB de los MINUTOS
	STS minutos,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function
	
	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R27,0x3F			;mascara para sacar los 6 LSB de la HORA
	STS horas,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function

	CALL DAME_DATO_RTC ;deja el dato en R21
	;ANDI R27,0x03			;mascara para sacar los 3 LSB del numero de dia de la semana
	;STS dia_de_la_semana,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function

	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R27,0x3F			;mascara para sacar los 6 LSB del numero de dia en el mes
	STS dia,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function

	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R27,0x1F			;mascara para sacar los 5 LSB del numero de mes
	STS mes,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function

	CALL DAME_DATO_RTC ;deja el dato en R21
	ANDI R27,0xFF			;mascara para sacar los 8 bits del numero de anio
	STS anio,R27
	;CALL I2C_READ_STATUS		;read status register
	;CPI R26,0x50				;was data transmitted, ack received?
	;BRNE ERROR_I2C_READ_STATUS	;if error, jump to error function
	
	;Master sends Stop condition, no status code returned
	CALL I2C_STOP

	;ERROR_I2C_READ_STATUS:
		;falta escribir que se hace en caso de error
	;nop;
ret

SET_FECHA:
	;configura la fecha en el RTC
	CALL I2C_INIT		;initialize the I2C module
		
	;Master generates Start Condition, status code 0x08 is returned
	CALL I2C_START		;transmit a START condition

	;Master sends slave address (0xd0), slave device returns ACK, status code 0x18
	LDI R21,0b11010000	;SLA(1101000)+W(0)
	CALL I2C_SEND		;transmit R21 to I2C bus
	
	LDI R21,0x07		;set register pointer to 07
	CALL I2C_SEND		;to access the control register
	
	LDI R21,0x00		;set control register = 0, lo cual le dice al ds1307 donde va a empezar a escribir la fecha.
	CALL I2C_SEND		;transmit R21 to I2C bus
	CALL I2C_STOP		;transmit Stop condition

	call I2C_DELAY

	;Master sends one or more data bytes, slave device returns ACK, status code 0x28
	CALL I2C_START		;transmit a START condition
	LDI R21,0b11010000	;SLA(1101000)+W(0)
	CALL I2C_SEND		;transmit R21 to I2C bus
	LDI R21,0x04		;set register pointer to 04
	CALL I2C_SEND		;to access the control register
	LDS R21,set_dia		;set dia. Usar notacion BCD
	CALL I2C_SEND		;to access the control register
	LDS R21,set_mes		;set mes. Usar notacion BCD
	CALL I2C_SEND		;to access the control register
	LDS R21,set_anio	;set anio. Usar notacion BCD
	CALL I2C_SEND		;transmit R21 to I2C bus

	;Master generates Stop Condition, no status code returned
	CALL I2C_STOP		;transmit Stop condition
ret

SET_HORA:
	;configura la hora en el RTC
	;Vamos a setear el clokc a las 16:58:55 usando el modo de 24 hs.
	
	CALL I2C_INIT	;inicializa el modulo I2c

	CALL I2C_START		;transmite condición de START
	LDI R21,0b11010000	;SLA(1101000) + W(0)
	CALL I2C_SEND		;transmit R21 to I2C bus
	LDI R21,0x07		;set Register Pointer to 07
	CALL I2C_SEND		;to access the Control Register
	LDI R21,0x00		;set control register = 0
	CALL I2C_SEND		;transmit R21 to I2C bus
	CALL I2C_STOP		;Transmit a STOP condition

	CALL I2C_DELAY

	CALL I2C_START		;transmit a START condition
	LDI R21,0b11010000	;SLA(1101000)+W(0)
	CALL I2C_SEND		;transmit R21 to I2C bus
	LDI R21,0x00		;set register pointer to 0
	CALL I2C_SEND		;Transmit R21 to I2c Bus
	LDS R21,set_segundos;set seconds to 0x55=55 BCD
	CALL I2C_SEND		;Transmit R21 too I2C Bus
	LDS R21,set_minutos	;Set minutes to 0x58=58 BCD
	CALL I2C_SEND		;transmit R21 to I2C bus
	LDS R21,set_horas	;hour = 16 (en modo de 24 hs)
	CALL I2C_SEND		;transmit R21 to I2C bus
	CALL I2C_STOP		;transmit a STOP condition
ret

I2C_INIT:
	;Es la inicializacion 
	;The TWI clock speed is usually 100kHz or 400kHz. Tomaremos 100kHz. 
	;It is set by writting the proper prescaler and clock rate values to:
	; - TWSR (los bits 0 y 1 son el prescaler)
	; - TWBR(TWI Bit Rate Register). 
	; La formula para verificar si el clock speed es adecuado, es: 
	; SCL Frecuency = CPU_CLOCK_frec / (16+2*TWBR*(4^prescaler))
	LDI R21,0			
	STS TWSR,R21		;set prescaler bits to zero
	LDI R21,0x32		;move 0x32 into r21
	STS TWBR,R21		;SCL freq is 100k for micro de 8Mhz
	LDI R21,(1<<TWEN)	;move 0x04 into r21
	STS TWCR,R21		;enable the TWI
ret

I2C_START:
	;Se genera la condicion de START
	;To generate a start, load TWCR with 0xA4 (0b10100100, esos 3 unos corresponden a TWINT, TWSTA y TWEN), y luego wait.
	LDI R21,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	STS TWCR,R21		;transmit a START condition, es decir el 0x10100100.
LOOP_I2C_START:			
	LDS R21,TWCR		;read control registre into R21 para ver si todo esta ok
	SBRS R21,TWINT		;Skip next line if bit TWINT in register R21 is SET (mask the interrupt flag)
	RJMP LOOP_I2C_START	;jump to Loop if TWINT es 1
RET

I2C_SEND:
	STS TWDR,R21					;put the address of the slave into TWDR: mvoe SLA+W into TWDR
	LDI R21,(1<<TWINT)|(1<<TWEN)	;Instruccion para Send Data
	STS TWCR,R21					;configure TWCR to send TWDR (put the SEND command in TWCR)
LOOP_I2C_SEND:						;monitoring the interrupt flag bit (TWINT) to be set
	LDS R21,TWCR		;read control register (Se monitorea el control register)
	SBRS R21,TWINT		;mask the interrupt flag (skip next line if TWINT is 1)
	RJMP LOOP_I2C_SEND	;jump to W2 if TWINT is 1
RET


I2C_STOP:
	LDI R21,(1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
	STS  TWCR,R21		;Transmit STOP condition
LOOP_I2C_STOP:	
	LDS R21,TWCR		;Read control register into R21
	SBRS R21,TWSTO		;Mask the interrupt flag
	RJMP LOOP_I2C_STOP	;jump to w3 if TWINT is 1
RET

I2C_DELAY:
	LDI	R22,0xff	
LOOP_I2C_DELAY:	
	DEC R22		
	NOP
	BRNE LOOP_I2C_DELAY
RET

I2C_READ_STATUS:
	LDS R26,TWSR				;Read status register into r21
	ANDI R26,0xf8				;mask the prescaler bits
RET

DAME_DATO_RTC:
	LDI R21,(1<<TWINT)|(1<<TWEN)|(1<<TWEA)	;recibir un byte de  DATOS y retornar ACK 
	STS TWCR,R21
	LOOP_I2C_READ:
		LDS R21,TWCR		;read control registre into r21
		SBRS R21,TWINT		;skip next line if TWINT is 1
		RJMP LOOP_I2C_READ
	LDS R21,TWDR			;Se lee el dato (segundos) que nos envio el slave y se lo guarda en r21
RET