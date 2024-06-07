	; Carregar dados
	loadn r1, #255 ; indica nada lido
	loadn r2, #0   ; posicao do cursor
	loadn r3, #33  ; caractere de escape

LerTecla:
	inchar r0      ; tentar ler um caractere
	cmp r0, r1     ; testar se foi possivel
	jeq LerTecla   ; se nao foi, tente de novo
	cmp r0, r3     ; testar se eh caractere de escape
	jeq End        ; se for encerre
	outchar r0, r2 ; senao imprima na posicao atual
	inc r2         ; incremente a posicao
	jmp LerTecla   ; leia outro caractere

End:
	halt