; Adaptação do Rogue The Videogame, para a arquitetura do ICMC
jmp main

; Mapa da tela na memória, para facilitar o cálculo das posições
memoryMap: #1200

; Variáveis da sala         
room: var #6                ; 0: position, 1: heigth, 2: width, 3: nrmDoors, 4: nrmEnemies, 5: ptrItem, 

;Doors
Doors: var #4			    ; 0: upperDoor, 1: leftDoor, 2: lowerDoor, 3: rigthDoor

; Sprites da sala
roomSprites: var #4
static roomSprites + #0, #'|'
static roomSprites + #1, #'/'
static roomSprites + #2, #'-'
static roomSprites + #3, #'.'

; Variáveis do player
spritePlayer: var #1  
static spritePlayer + #0, #'@' 
posPlayer: var #1

; Strings da UI
Msn0: string "V O C E   M O R R E U !!!"
Msn1: string "Quer jogar novamente? <s/n>"

; Tabela de valores randomicos... Ainda falta arrumar algumas coisas
IncRand: var #1			; Incremento para circular na Tabela de nr. Randomicos
Rand : var #30			; Tabela de nr. Randomicos entre 0 - 7
static Rand + #0, #0
static Rand + #1, #3
static Rand + #2, #7
static Rand + #3, #1
static Rand + #4, #6
static Rand + #5, #2
static Rand + #6, #7
static Rand + #7, #2
static Rand + #8, #0
static Rand + #9, #5
static Rand + #10, #7
static Rand + #11, #2
static Rand + #12, #0
static Rand + #13, #2
static Rand + #14, #7
static Rand + #15, #5
static Rand + #16, #5
static Rand + #17, #6
static Rand + #18, #7
static Rand + #19, #2
static Rand + #20, #0
static Rand + #20, #7
static Rand + #21, #1
static Rand + #22, #5
static Rand + #23, #6
static Rand + #24, #6
static Rand + #25, #7
static Rand + #26, #0
static Rand + #27, #3
static Rand + #28, #1
static Rand + #29, #1

main:
	; Imprimindo a tela de título
	call RefreshScreen
	loadn r1, #tela0Linha0
	loadn r2, #1536
	call PrintScreen2

	; Esperando o jogador digitar "enter" para inicializar
tittleLoop:
	loadn r3, #255
	inchar r0
	cmp r3, r0
	jeq tittleLoop

    ; Criando a sala do nível atual
    call MapSetUp

gameLoop:
    inchar r0               ; r0 recebe o comando do jogador, garantindo que nada ocorra até o input
    
    ; if r0 == 'q': saí do jogo
    loadn r1, #'q'
    cmp r0, r1
    jeq mainEnd

	; if posPlayer == Door: Generate new Level

    ; Processando as mudanças para o jogador
    call ProcessPlayer

    jmp gameLoop
mainEnd:
    halt


; GenerateRand(): Retorna em r2 o número aleatório
GenerateRand:
	loadn r2, #10
	rts


; ProcessPlayer(): Aplica todas as mudanças no jogador de acordo com os inputs dados 
ProcessPlayer:
    push r1
    push r2
    load r1, posPlayer      ; Posição do player na tela
    load r2, spritePlayer   ; Carregando a posição do player em r2
    load r5, posPlayer      ; Salvando em r5 para pintar de preto

    call MovPlayer
    cmp r1, r5

ProcessPlayerEnd:
    pop r2
    pop r1
    rts



; movePlayer(r1 = posPlayer, r2 = spritePlayer), movimenta o jogador conforme o input
; Também o redesenha na tela, e salva a nova posição 
MovPlayer:
    push r3
    push r4
    push r5
    push r6

    loadn r3, #'w'          ; Andar para cima
    cmp r0, r3
    jeq MovPlayerW

    loadn r3, #'d'          ; Andar para direita
    cmp r0, r3
    jeq MovPlayerD

    loadn r3, #'a'          ; Andar para esquerda
    cmp r0, r3
    jeq MovPlayerA

    loadn r3, #'s'          ; Andar para baixo
    cmp r0, r3
    jeq MovPlayerS

    ; Caso ele não tenha se movido, pulamos as instruções para desenhar
    jmp MovPlayerEnd

MovPlayerDrawn:
    loadn r6, #0
    outchar r6, r5          ; Pintando a posição anterior de preto
    outchar r2, r1          ; Pintando o personagem na nova posição
    store posPlayer, r1     ; Salvando a nova posição

MovPlayerEnd:
    pop r6
    pop r5
    pop r4
    pop r3
    rts

MovPlayerW:
    loadn r4, #40
    sub r1, r1, r4          ; posPlayer -= 40 (sobe);
    jmp MovPlayerDrawn

MovPlayerD:
    inc r1                  ; posPlayer++;
    jmp MovPlayerDrawn

MovPlayerA:
    dec r1                  ; posPlayer--;
    jmp MovPlayerDrawn

MovPlayerS:
    loadn r4, #40
    add r1, r1, r4          ; porPlayer += 40;             
    jmp MovPlayerDrawn


; MapSetUp(r1 = posPlayer), cria um novo nível
MapSetUp:
	push r0				    ; r0 = position
	push r2					; r2 = heigth
	push r3					; r3 = width
	push r4					; r4 = nrmDoors
	push r5					; r5 = item
	push r6					; Auxiliar para r2			
	push r1					; Ponteiro para room

    call RefreshScreen
    call CreateRoom
	;call SetPlayerinRoom
	;call SetEnemies
    call DrawnRoom

	pop r1
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r0
    rts



; RefreshScreen(), reseta a tela, pintando tudo de preto
RefreshScreen:
    push r1
    push r2
    push r3

    loadn r1, #0            ; r1 recebe o início da tela
    loadn r2, #1200         ; r2 recebe o fim da tala
    loadn r3, #0            ; r3 mantem o valor para pintar a tela de preto

RefreshScreenLoop:
    outchar r3, r1          ; Resetando a posição atual da tela
    inc r1
    cmp r1, r2
    jne RefreshScreenLoop   ; Itera enqunato não chegar ao fim da tela

    pop r3
    pop r2
    pop r1
    rts



; CreateRoom(r1 = posPlayer);
; Slva na memória a sala gerada aleatoriamente, atualizando a posição inicial do player
; Reseta Doors, Enemies e item
; Retorna em r0 a posição inicial e outros valores da sala para os outros regs
CreateRoom:

	; Nova posição
	loadn r1, #room
	call GenerateRand		; r2 recebe um aleatório
	mov r0, r2				; r6 guardará temporariamente a altura
	storei r1, r2

	; Nova altura
	inc r1
	call GenerateRand
	mov r6, r2
	storei r1, r2

	; Nova largura
	inc r1
	call GenerateRand
	mov r3, r2
	storei r1, r2 

	; Gerando novas portas
	inc r1
	call CreateNewDoors		; Retorna nrmdoors em r4
	storei r1, r4

	; Falta gerar novos itens...

	mov r2, r6				; Restaurando a altura em r2
	rts



; CreateNewDoors(); Retorna em r4
; Gera as portas para a nova sala
CreateNewDoors:
	push r1
	push r2
	push r3
	push r4

	; Gerando o número de portas aleatório entre 1 e 3
	loadn r3, #3
	call GenerateRand
	mod r1, r2, r3			; r1 = r2 % 3
	inc r1					; Garante que r1 estará entre 1 e 3

	; Instanciando as novas portas
	loadn r4, #Doors			; r4 armazena o endereço do vetor das portas
	loadn r5, #0			; Contador do loop

CreateNewDoorsLoop:
	call GenerateRand
	mod r2, r2, r3		    ; Gerando o valor que indica o que terá na porta (de 1 a 3)
	inc r2
	storei r4, r2		    ; Guardando em Doors
	inc r4					; Doors++
	inc r5					; Contador++
	cmp r1, r5
	jle CreateNewDoorsLoop	; jel = jump equal or lesses (<=)

	; Resetando as portas remanescentes (para 0), caso o número gerado seja menor que 4
	loadn r2, #0
	cmp r5, r3
	jel CreateNewDoorsReset	; jle = jump lesser (<)


CreateNewDoorsEnd:
	mov r4, r1				; Salvando nrmDoors no retorno

	pop r4
	pop r3
	pop r2
	pop r1
	rts

CreateNewDoorsReset:
	storei r4, r2
	inc r4
	inc r5					; contador++
	cmp r5, r3
	jel CreateNewDoorsReset ; Itera enquanto contador < 3
	jmp CreateNewDoorsEnd

; DrawRoom(r0 = pos, r2 =  heigth, r3 = width)
DrawnRoom:
	push r1					; Auxiliar para r0
	push r4					; endereço base de roomSprites
	push r5					; recebe o valor do sprite
	push r6					; contador
	push r7					; Auxiliar para as cores

	; Calculando a ultima posição de impressão e guardando em r2
	inc r2					; Altura +1 (para garantir que não acabará antes da última linha)
	loadn r4, #40
	mul r4, r2, r4
	add r2, r4, r0			; r2 = (h + 1) *40 + pos


	; Imprimindo o teto da sala
	loadn r4, #roomSprites
	loadn r7, #2
	add r5, r4, r7 
	loadi r5, r5			; r5 recebe `-`
	loadn r7, #256			
	add r5, r5, r7			; Setando a cor

	mov r1, r0				; r1 será usada para incrementar em largura
	loadn r6, #0			; Inicializando o contador
	inc r3					; width não considera as paredes. Por isso incrementamos temporariamente
DrawnRoomTop:
	outchar r5, r1
	inc r1
	inc r6					; contador++;
	cmp r6, r3
	jel DrawnRoomTop		; Itera enquanto r6 <= (width + 1)

	; Imprimindo tudo internamente
	dec r3					; Como a impressão das paredes difere, podemos usar apenas width
	loadn r1, #40
	add r1, r1, r0			; r1 recebe a posição da próxima linha

DrawRoomLoop1:
	loadn r6, #0			; Resetando o contador
	add r5, r4, r6			; Printando a parede esquerda da nova linha
	loadi r5, r5
	loadn r7, #256
	add r5, r5, r7			; Setando a cor
	outchar r5, r1
	inc r1

	loadn r7, #3
	add r5, r4, r7			; Carregando . para printar width vezes
	loadi r5, r5
	loadn r7, #768
	add r5, r5, r7
DrawRoomLoop2:
	outchar r5, r1
	inc r1
	inc r6
	cmp r6, r3
	jne DrawRoomLoop2		; Itera enquanto contador < width

	loadn r7, #0
	add r5, r4, r7			; Printando a parede direita da nova linha
	loadi r5, r5
	loadn r7, #256
	add r5, r5, r7			; Setando a cor
	outchar r5, r1

	sub r1, r1, r3			; Voltando r1 para o começo da linha
	loadn r7, #39
	add r1, r1, r7			; r1 vai para a posição inicial da próxima linha
	cmp r1, r2
	jne DrawRoomLoop1		; Itera enquanto r1 < r2 (altura máxima)

	; Imprimindo a base da sala
	loadn r7, #2
	add r5, r4, r7 
	loadi r5, r5			; r5 recebe `-`
	loadn r7, #256			
	add r5, r5, r7			; Setando a cor

	loadn r6, #0			; Inicializando o contador
	inc r3					; width não considera as paredes. Por isso incrementamos temporariamente
DrawnRoomBottom:
	outchar r5, r1
	inc r1
	inc r6					; contador++;
	cmp r6, r3
	jel DrawnRoomBottom		; Itera enquanto r6 <= (width + 1)


	pop r7
	pop r6
	pop r5
	pop r4
	pop r1
	rts

;********************************************************
;               IMPRIME TELA
;********************************************************	
PrintScreen: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	
   PrintScreen_Loop:
		call PrintString
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne PrintScreen_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


;********************************************************
;                     IMPRIME STRING 
;********************************************************
PrintString:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   PrintString_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq PrintString_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp PrintString_Loop
	
   PrintString_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts


;********************************************************
;                  IMPRIME TELA 2
;********************************************************	
PrintScreen2: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	loadn R6, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   PrintScreen2_Loop:
		call PrintString2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne PrintScreen2_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
				

;********************************************************
;          IMPRIME STRING 2
;********************************************************
	
PrintString2:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

   PrintString2_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq PrintString2_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq PrintString2_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
   		storei r6, r4
   PrintString2_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		inc r6
		jmp PrintString2_Loop
	
   PrintString2_Sai:	
	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

tela0Linha0  : string "                                        "
tela0Linha1  : string "                                        "
tela0Linha2  : string "                                        "
tela0Linha3  : string "                                        "
tela0Linha4  : string "   _________.__                         "
tela0Linha5  : string "  /   _____/|__| _____ _____    _____   "
tela0Linha6  : string "  \\_____  \\ |  |/     \\\\__  \\  /  ___/  "
tela0Linha7  : string "  /        \\|  |  / \\  \\/ __ \\_\\___ \\   "
tela0Linha8  : string " /_______  /|__|__|_|  (____  /____  >  "
tela0Linha9  : string "         \\/          \\/     \\/     \\/   "
tela0Linha10 : string "  __________                            "
tela0Linha11 : string " \\______   \\ ____   ____  __ __   ____  "
tela0Linha12 : string "  |       _//  _ \\ / ___\\|  |  \\_/ __ \\ "
tela0Linha13 : string "  |    |   (  <_> ) /_/  >  |  /\\  ___/ "
tela0Linha14 : string "  |____|_  /\\____/\\___  /|____/  \\___  >"
tela0Linha15 : string "         \\/      /_____/             \\/ "
tela0Linha16 : string "                                        "
tela0Linha17 : string "                                        "
tela0Linha18 : string "                                        "
tela0Linha19 : string "                                        "
tela0Linha20 : string "                                        "
tela0Linha21 : string "                                        "
tela0Linha22 : string "         type any key to play           "
tela0Linha23 : string "                                        "
tela0Linha24 : string "                                        "
tela0Linha25 : string "                                        "
tela0Linha26 : string "                                        "
tela0Linha27 : string "                                        "
tela0Linha28 : string "                                        "
tela0Linha29 : string "                                        "


; Declara e preenche tela linha por linha (40 caracteres):
tela1Linha0  : string "                                        "
tela1Linha1  : string "                                        "
tela1Linha2  : string "                                        "
tela1Linha3  : string "                                        "
tela1Linha4  : string "                                        "
tela1Linha5  : string "                                        "
tela1Linha6  : string "                                        "
tela1Linha7  : string "                                        "
tela1Linha8  : string "                                        "
tela1Linha9  : string "                                        "
tela1Linha10 : string "                                        "
tela1Linha11 : string "                                        "
tela1Linha12 : string "                                        "
tela1Linha13 : string "                                        "
tela1Linha14 : string "                                        "
tela1Linha15 : string "                                        "
tela1Linha16 : string "                                        "
tela1Linha17 : string "                                        "
tela1Linha18 : string "                                        "
tela1Linha19 : string "                                        "
tela1Linha20 : string "                                        "
tela1Linha21 : string "                                        "
tela1Linha22 : string "                                        "
tela1Linha23 : string "                                        "
tela1Linha24 : string "                                        "
tela1Linha25 : string "                                        "
tela1Linha26 : string "                                        "
tela1Linha27 : string "                                        "
tela1Linha28 : string "                                        "
tela1Linha29 : string "                                        "