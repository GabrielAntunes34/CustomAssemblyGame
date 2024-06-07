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

	loadn r5, #10  ; carregar base algebrica
	loadn r6, #'0' ; carregar caractere '0'
	loadn r7, #0   ; carregar valor 0

	mov r2, r0 ; inicializar R2 com o numero a ser impresso
	mov r3, r7 ; inicializar R3 com 0 = numero de digitos - 1
CountLoop:
	div r2, r2, r5   ; deslocar numero para direita
	jz PrepDivLoop   ; se deu zero, contamos todos os digitos
	inc r3           ; senao contar mais um digito
	jmp CountLoop    ; continue dividindo

PrepDivLoop:
	mov r2, r0 ; restaurar numero a ser impresso
	mov r4, r3 ; numero de deslocamentos = numero de digitos restantes - 1 = R3

DivideLoop:
	cmp r4, r7     ; comparar numero de deslocamentos restantes com 0
	jeq PrintDigit ; se for igual, podemos imprimir o digito
	div r2, r2, r5 ; senao deslocamos mais uma vez para a direita
	dec r4         ; descontamos um deslocamento
	jmp DivideLoop ; testamos de novo a condicao de parada

PrintDigit:
	mod r2, r2, r5  ; pegamos apenas o digito relevante
	add r2, r2, r6  ; transformamos no valor ASCII correspondente
	outchar r2, r1  ; imprimimos na posicao contida em R1
	cmp r3, r7      ; comparamos digitos restantes com 0
	jeq Finnish     ; se for igual, imprimimos todo o numero, acabou
	inc r1          ; senao avancamos o cursor
	dec r3          ; descontamos o digito ja impresso
	jmp PrepDivLoop ; redeslocamos ate proximo digito

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