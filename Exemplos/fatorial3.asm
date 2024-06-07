; Fatorial Nao recursivo
; Obs: Se o resultado for maior que 999, vai imprimir ????

jmp main

; Declaracao e Inicializacao de variaveis estaticas

; ----------x--------------x-----------
; Inicio do codigo

main:
	loadn r0, #8    ; Escolha o numero para o calculo do fatorial

	call Fatorial   ; Calcula o Fatorial de um numero (colocado em r0)
	                ; e retorna o valor em r1

	mov r0, r1      ; Passa o resultado (r1) para r0 para ser imprimido
	loadn r1, #578  ; Posicao da tela onde o valor sera' imprimido
	call Printnr    ; Imprime um numero menor que 1000 com todas as casas:
	                ; Parametros: r0 - numero; r1 - posicao na tela

	halt            ; Interrompe a execucao

; Final do codigo


; ----------x--------------x-----------
; inicio das Subrotinas

;........
Fatorial:	; Calcula o Fatorial de um numero (colocado em r0)
            ; e retorna o valor em r1

	push r0
	push r2

	loadn r1, #1 ; Contera' o resultado
	loadn r2, #1 ; Para referencia

FatorialLoop:
	mul r1, r1, r0   ; Multiplica e acumula em r1
	dec r0           ; decrementa o numero
	cmp r0, r2       ; compara com 1 para parar
	jgr FatorialLoop ; se maior que 1, goto loop

	pop r2
	pop r0	
	rts		; Fim da subrotina: Retorna o valor do fatorial em r1

;.......
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