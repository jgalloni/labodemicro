
subrutina_test_m:
;retardo
	LDI R18,5
LOOP:
	DEC R18
	BRNE LOOP
ret