jmp main
; Declaracao e Inicializacao de variaveis estaticas

; ----------x--------------x-----------
main:
	loadn r0, #9999
	loadn r1, #10
	call Printnr

	halt

; Final do codigo


; ----------x--------------x-----------
; inicio das Subrotinas

Printnr:	; Imprime um numero com todas as casas:
            ; Parametros: r0 - numero a ser impresso; r1 - posicao na tela
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7

	loadn r3, #10  ; carregar base algebrica
	loadn r4, #'0' ; carregar caractere '0'
	loadn r5, #0   ; carregar valor 0

StackDigits:
	mod r2, r0, r3  ; pega o ultimo digito
	add r2, r2, r4  ; transforma em ASCII
	push r2         ; empilha o caractere
	inc r5          ; incrementa contagem de digitos
	div r0, r0, r3  ; elimina ultimo digito
	jz PrintStack   ; se nao sobrou nada
	jmp StackDigits ; senao repete ate acabar os digitos

PrintStack:
	pop r0         ; pega o primeiro digito (topo)
	outchar r0, r1 ; imprime na posicao guardada em R1
	inc r1         ; avanca cursor
	dec r5         ; desconta digito impresso
	jz Finnish     ; se nao houver mais digitos
	jmp PrintStack ; senao imprime o proximo

Finnish:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts