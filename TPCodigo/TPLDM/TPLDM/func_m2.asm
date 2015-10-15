/*
 * AsmFile1.asm
 *
 *  Created: 15/10/2015 01:14:16 p.m.
 *   Author: mtomas
 */ 

 
subrutina_test_m2:
;retardo
	LDI R18,5
LOOP2:
	DEC R18
	BRNE LOOP2
ret