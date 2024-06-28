; Adaptação do Rogue The Videogame, para a arquitetura do ICMC
jmp main

memoryMap: var #1200 		; Mapa da tela na memória, para facilitar o cálculo das posições
room: var #6                ; room: 0: position, 1: height, 2: width, 3: nmrDoors, 4: nrmEnemies, 5: ptrItem, 
Doors: var #4			    ; Doors: 0: upperDoor, 1: leftDoor, 2: lowerDoor, 3: rigthDoor
							; Código pro item: 0: x, 1: m, 2: d, 3: v
; Sprites da sala
roomSprites: var #4
static roomSprites + #0, #'|'
static roomSprites + #1, #'/'
static roomSprites + #2, #'-'
static roomSprites + #3, #'.'

healthPotion: var #2
static healthPotion + #0, #'x'
static healthPotion + #1, #15

CoinPotion: var #2
static CoinPotion + #0, #'m'
static CoinPotion + #1, #100

DamagePotion: var #2
static DamagePotion + #0, #'d'
static DamagePotion + #1, #10

MaxHealthPotion: var #2
static MaxHealthPotion + #0, #'v'
static MaxHealthPotion + #1, #15

player: var #5				; player: 0: posPlayer, 1: life, 2: maxLife, 3: coins, 4: damage
spritePlayer: var #1  
static spritePlayer + #0, #'@'

enemies: var #9			; Enemies: 0: LifeEnemy1, 1: PosEnemy1, 2: damageEnemy1, 3: lifeEnemy2, .., 6: LifeEnemy3, ..
spriteEnemy: var #1
static spriteEnemy + #0, #'&'



; Strings da UI
UI0: string "HP : \0"
UI2: string "ATK: \0"
UI1: string "$$ : \0"


; Tabela de valores randômicos... Ainda falta arrumar algumas coisas
IncRand: var #1			; Incremento para circular na Tabela de nr. Randomicos
Rand : var #61			; Tabela de nr. Randomicos entre 0 - 7
static Rand + #0, #7
static Rand + #1, #6
static Rand + #2, #24
static Rand + #3, #16
static Rand + #4, #9
static Rand + #5, #11
static Rand + #6, #5
static Rand + #7, #22
static Rand + #8, #23
static Rand + #9, #12
static Rand + #10, #13
static Rand + #11, #21
static Rand + #12, #19
static Rand + #13, #25
static Rand + #14, #20
static Rand + #15, #5
static Rand + #16, #14
static Rand + #17, #17
static Rand + #18, #15
static Rand + #19, #18
static Rand + #20, #8
static Rand + #21, #15
static Rand + #22, #8
static Rand + #23, #16
static Rand + #24, #13
static Rand + #25, #18
static Rand + #26, #25
static Rand + #27, #11
static Rand + #28, #23
static Rand + #29, #7
static Rand + #30, #6
static Rand + #31, #14
static Rand + #32, #19
static Rand + #33, #10
static Rand + #34, #20
static Rand + #35, #17
static Rand + #36, #9
static Rand + #37, #24
static Rand + #38, #22
static Rand + #39, #12
static Rand + #40, #21
static Rand + #41, #10
static Rand + #42, #6
static Rand + #43, #9
static Rand + #44, #7
static Rand + #45, #13
static Rand + #46, #12
static Rand + #47, #14
static Rand + #48, #24
static Rand + #49, #15
static Rand + #50, #22
static Rand + #51, #19
static Rand + #52, #20
static Rand + #53, #8
static Rand + #54, #16
static Rand + #55, #11
static Rand + #56, #23
static Rand + #57, #17
static Rand + #58, #10
static Rand + #59, #21
static Rand + #60, #18

main:
	; Imprimindo a tela de título
	call RefreshScreen
	loadn r1, #tela0Linha0
	loadn r2, #1536
	call PrintScreen2

	; Esperando o jogador digitar algo para iniciar
	loadn r4, #0			; r4 receberá a seed para incrand
mainTittleLoop:
	inc r4
	loadn r3, #255
	inchar r0
	cmp r3, r0
	jeq mainTittleLoop

    ; Criando a sala do nível atual
	loadn r5, #IncRand
	storei r5, r4			; salvando em incRand a seed

mainRestart:
	; Gerando o item do level primeiro level
	call GenerateRand
	loadn r5, #4
	mod r2, r2, r5
	call PlayerSetUp

mainNewLevel:
	; Setando o mapa
    call MapSetUp
	call UISetUp
	call SpawnItem

mainGameLoop:
	; Esperando o turno do jogador
    inchar r0               ; r0 recebe o comando do jogador
	loadn r1, #255
	cmp r0, r1
	jeq mainGameLoop

	; caso o jogador saia do jogo
    loadn r1, #'q'
    cmp r0, r1
    jeq mainDeathSecren

    ; Processando os turnos do jogador e dos inimigos
    call ProcessPlayer
	;call ProcessEnemy

	; Caso o jogador, tenha morrido:
	loadn r0, #player
	inc r0
	loadi r0, r0			; r0 recebe a vida do jogador
	loadn r1, #0			; r1 recebe zero para a comparação
	cmp r0, r1
	jeq mainDeathSecren

	; Caso não tenha mais inimigos na sala --> Colocar isso em processEnemies??
	;loadn r0, #room
	;loadn r2, #4
	;add r0, r0, r2
	;loadi r0, r0			; r0 recebe nmrEnemies
	;cmp r0, r1
	;jne mainProcessDoor
	;call SpawnItem			; se nmrEnemies == 0

	; Caso o jogador tenhe chegado a uma porta
	call IsItADoor			; Retornando em r1 se há portas e, se sim, setando
	loadn r3, #1			; o item em r2
	cmp r1, r3
	jeq mainNewLevel

    jmp mainGameLoop

mainEnd:
	call RefreshScreen
    halt

mainDeathSecren:
	call RefreshScreen
	loadn r1, #tela1Linha0
	call PrintScreen

	loadn r1, #'y'
	loadn r2, #'n'
	loadn r3, #255
mainDeathScreenLoop:
	inchar r0				; Esperando uma ação do usuário 
	cmp r0, r3
	jeq mainDeathScreenLoop ; Espere caso ele não clique em nada
	cmp r0, r2
	jeq main				; Se n, volte a tela  de título
	cmp r0, r1
	jeq mainRestart			; se y, recomece
	jmp mainDeathScreenLoop	; se qualquer outra coisa, espere

; GenerateRand(): Retorna em r2 o número aleatório
GenerateRand:
	push r0
	push r1
	push r3
	push r4

    ; Tratando o seed para gerar o número aleatório
    load r1, IncRand        ; Carregando a seed / aleatório atual
	load r4, player
    loadn r3, #60
    inc r1
	add r1, r1, r4
    mod r1, r1, r3          ; Aleatório gerado

    ; Salvando em IncRand
    loadn r0, #IncRand
    storei r0, r1

    ; Usando o aleatório em r1 para pegar um valor da tabela
	loadn r0, #Rand			; declara ponteiro para tabela rand na memória
							; é para IncRand estar entre 0 e 29

	add r0, r0, r1			; soma incremento ao ponteiro rand
	loadi r2, r0			; r2 = numero aleatorio entre 5 e 25

	pop r4
	pop r3
	pop r1
	pop r0
	rts



; UISetUp(): Inicializa a UI com as informações do jogador
UISetUp:
	push r0					; Posição da tela
	push r1					; String convertida para a tela
	push r2					; cor da mensagem
	push r3					; Ponteiro para variáveis do jogador

	loadn r2, #1536			; cor branca
	loadn r3, #player		; Carregando a vida do jogador
	inc r3

	; Imprimindo vida atual
	loadn r1, #UI0
	loadn r0, #0
	call PrintString
	loadn r0, #5
	loadi r1, r3			; r1 recebe life
	call PrintNumber
	
	; Imprimindo / e vida total
	loadn r0, #10
	loadn r1, #'/'
	outchar r1, r0
	inc r0
	inc r3
	loadi r1, r3			; r1 recebe maxLife
	call PrintNumber

	; Impriminido dinheiro do personagem
	loadn r0, #40
	loadn r1, #UI1
	call PrintString
	loadn r0, #45
	inc r3
	loadi r1, r3			; r1 recebe damage
	call PrintNumber

	; Imprimindo dano do personagem
	loadn r0, #80
	loadn r1, #UI2
	call PrintString
	loadn r0, #85
	inc r3
	loadi r1, r3
	call PrintNumber


	pop r3
	pop r2
	pop r1
	pop r0
	rts



;PlayerSetUp()
; Inicializa as variáveis do jogador quando começamos o jogo
PlayerSetUp:
	push r0
	push r1

	loadn r0, #player

	; Vida inicial: 50
	inc r0
	loadn r1, #50
	storei r0, r1
	inc r0
	storei r0, r1

	; Dinheiro inicial: 0
	inc r0
	loadn r1, #0
	storei r0, r1

	; Dano inicial 25
	inc r0
	loadn r1, #25
	storei r0, r1

	pop r1
	pop r0
	rts



; ProcessPlayer(): Aplica todas as mudanças no jogador de acordo com os inputs dados 
ProcessPlayer:
    push r1
    push r2
    load r1, player      	; Posição do player na tela
    load r2, spritePlayer   ; Carregando a posição do player em r2
    load r5, player      	; Salvando em r5 para pintar de preto

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
	push r7

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
    loadn r6, #'.'			; Carregando e pintando '.'
	loadn r7, #768
	add r6, r6, r7
    outchar r6, r5          ; Pintando a posição anterior de preto
    outchar r2, r1          ; Pintando o personagem na nova posição
    store player, r1     ; Salvando a nova posição

MovPlayerEnd:
	pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    rts

MovPlayerW:
	; Calculando a nova posição em r3
	mov r3, r1 
    loadn r4, #40
    sub r3, r3, r4          ; posPlayer -= 40 (sobe);
	call HandleWallColision
    jmp MovPlayerDrawn

MovPlayerD:
	mov r3, r1
    inc r3                  ; posPlayer++;
	call HandleWallColision
    jmp MovPlayerDrawn

MovPlayerA:
	mov r3, r1
    dec r3                  ; posPlayer--;
	call HandleWallColision
    jmp MovPlayerDrawn

MovPlayerS:
	mov r3, r1
    loadn r4, #40
    add r3, r3, r4          ; porPlayer += 40;
	call HandleWallColision             
    jmp MovPlayerDrawn

;HandleWallColision(r1 = velhaPosição, r3 = novaPosição)
; Verifica se, em um movimento, não houveram colisões, retornando em r1 o resultado
HandleWallColision:
	push r0
	push r2
	push r4
	push r5

	loadn r0, #'-'			; Carregando '-' em r0 para comparar com o mapa
	loadn r2, #memoryMap	
	add r2, r2, r3
	loadi r2, r2			; r2 recebe o que há no mapa na posição r3
	cmp r2, r0
	jeq HandleWallColisionEnd ; se novaPosição == '-', não mudaremos a posição antiga (r1)
	mov r1, r3				; senão, r1 = novaPosição (r3)

	; Com a posição atualizada, verificamos se há item
	loadn r0, #'x'
	cmp r2, r0
	jeq Grabhealthpotion

	loadn r0, #'m'
	cmp r2, r0
	jeq Grabcoinpotion

	loadn r0, #'d'
	cmp r2, r0
	jeq Grabdamagepotion

	loadn r0, #'v'
	cmp r2, r0
	jeq Grabmaxhealthpotion

HandleWallColisionEnd:
	; Verificando se um item foi obtido
	loadn r0, #1
	cmp r2, r0			; Resetando, se r0 == 1
	jne HandleWallColisionExit

	; Tirando item do mapa da memória e da tela
	loadn r4, #memoryMap
	add r4, r4, r1
	loadn r5, #0
	storei r4, r5		; colocando '' para onde havia o item
	
	call OpenDoors
	call UISetUp

HandleWallColisionExit:
	pop r5
	pop r4
	pop r2
	pop r0
	rts 

Grabhealthpotion:
	push r1
	push r3
	push r4
	push r5

	loadn r1, #player
	inc r1				; r1 recebe o endereço de life
	loadi r3, r1 		; r3 recebe o valor nesse endereço                 
	
	loadn r2, #2
	add r5, r1, r2		; passando enderenço de maxLife
	loadi r5, r1		; r5 recebe o valor de maxLife

	loadn r4, #healthPotion
	inc r4
	loadi r4, r4		; r4 recebe o valor da healthPotion
	add r3, r4, r3		; r3 = r3 + r4 (valor somado: health temporario)

	cmp r3, r5			; caso r3 seja menor que r5(maxLife), pular
	jel skipHealthToMaxHealth
	mov r3, r5

skipHealthToMaxHealth:	
	storei r1, r3

	loadn r2, #1		; Indicará que as portas deverão abrir

	pop r5
	pop r4
	pop r3
	pop r1
	jmp HandleWallColisionEnd


Grabcoinpotion:
	push r1
	push r3
	push r4

	loadn r1, #player
	loadn r2, #3     
	add r1, r1, r2			; r1 recebe o endereço de coin
	loadi r3, r1            ; r3 recebe o valor nesse endereço
	loadn r4, #CoinPotion
	inc r4
	loadi r4, r4			; r5 recebe o valor de CoinPotion
	add r3, r4, r3			; r3 = r3 + r5			
	storei r1, r3

	loadn r2, #1		; Indicará que as portas deverão abrir

	pop r4
	pop r3
	pop r1
	jmp HandleWallColisionEnd

Grabdamagepotion:
	push r1
	push r3
	push r4

	loadn r1, #player
	loadn r2, #4     
	add r1, r1, r2			; r1 recebe o endereço de damage
	loadi r3, r1            ; r3 recebe o valor nesse endereço
	loadn r4, #DamagePotion
	inc r4
	loadi r4, r4
	add r3, r4, r3
	storei r1, r3

	loadn r2, #1		; Indicará que as portas deverão abrir

	pop r4
	pop r3
	pop r1
	jmp HandleWallColisionEnd

Grabmaxhealthpotion:
	push r1
	push r3
	push r4

	loadn r1, #player
	loadn r2, #2     
	add r1, r1, r2			; r1 recebe o endereço de maxHealth
	loadi r3, r1            ; r3 recebe o valor nesse endereçø
	loadn r4, #MaxHealthPotion
	inc r4
	loadi r4, r4
	add r3, r4, r3
	storei r1, r3

	loadn r2, #1		; Indicará que as portas deverão abrir

	pop r4
	pop r3
	pop r1
	jmp HandleWallColisionEnd


; Gera os inimigos de um novo mapa a partir de nmrEnemies
SetEnemies:
	push r0					; Auxiliar para valores imediatos / contador
	push r1					; Indice para o inimigo 
	push r2					; Número de inimigos gerado
	push r3					; Endereço de nmrEnemies / auxiliar para r1

	; Guardando em r3 o endereço de nmrEnemies
	loadn r0, #4
	loadn r3, #room
	add r3, r3, r0

	; Gerando uma quantidade de inimigos (1 a 3)
	loadn r0, #3
	call GenerateRand
	mod r2, r2, r0
	inc r2					; Número de inimigos gerado

	; Loop para setar cada inimigo
	loadn r1, #0			; r1 recebe a posição do primeiro inimigo
	loadn r0, #0			; r0 é o contador
	loadn r3, #3			; será usado para incrementar r1
	
SetEnemiesLoop:
	call EnemiesSetUp
	inc r0					; contador++
	add r1, r1, r3			; r1 recebe o novo índice
	cmp r0, r2
	jle SetEnemiesLoop		; Itera enquanto contador < nrmEnemies

	pop r3
	pop r2
	pop r1
	pop r0
	rts

; EnemiesSetUp(r1 = indice)
; r1 indice do inimigo (0: superior direito, 1: inferior direito, 2: inferior esquerdo)
EnemiesSetUp:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r3, #enemies   ; Posição de memória do primeiro índice do inimigo
	; Inicializa vida dos inimigos 
	loadn r5, #0	; Auxiliar que terá valor igual a 3
	add r5, r5, r1	
	add r5, r3, r5  ; vai pegar a posição de memória da vida
	call GenerateRand	; Vai salvar um valor aleatório em r2
	loadn r4, #50		; Valor auxiliar que é igual a 50
	mod r2, r2, r4			; Vai efetivamente ter o valor da vida
	storei r5, r2		; Vai armazenar o valor da vida na posição de r5
	; Inicializa Dano dos inimigos
	loadn r5, #2
	add r5, r5, r1
	add r5, r3, r5		; Vai pegar a posição de memória do Dano
	loadn r2, #10		; Dano será igual a 10
	storei r5, r2

	; Inicializa posição inicial dos inimigos
	loadn r4, #room   ; Endereço de memória da posição inicial da sala
	loadn r5, #0      
	cmp r0, r5
	jeq EnemiesSetUpIsZero
	loadn r5, #1
	cmp r0, r5 
	jeq EnemiesSetUpIsOne
	loadn r5, #2
	cmp r0, r5 
	jeq EnemiesSetUpIsTwo

EnemiesSetUpEnd:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts	
	
EnemiesSetUpIsZero:
	loadi r0, r4   ; Valor da posição inicial da sala
	loadn r6, #2   ; Auxiliar que vai ter o valor 2
	add r3, r4, r6 ; Posição de memória do Width
	loadi r3, r3   ; Valor de Width
	loadn r2, #40  ; Auxiliar que vai ter valor 41
	add r0, r0, r2
	add r0, r0, r3  ; Após tudo, r0 tem valor da posição
	loadn r6, #1
	add r6, r6, r1
	loadn r3, #enemies 
	add r3, r3, r6  ; Pega posição de memória da posição do inimigo
	storei r3, r0

	loadn r7, #'a'
	outchar r7, r0
	jmp EnemiesSetUpEnd
EnemiesSetUpIsOne:
	loadi r0, r4
	loadn r6, #1
	add r3, r4, r6 ; Posição de Memória do Height
	loadi r3, r3   ; Valor do Height
	loadn r2, #40
	mul r3, r3, r2 ; Valor quando pega Height e multiplica por 40
	loadn r6, #2  ; Auxiliar que vai ter valor igual a 2
	add r6, r6, r4 ; Pega posição de memória de Width
	loadi r6, r6 ; Pega valor de Width
	add r3, r3, r6 ; Soma já com o Width (Agora falta somar com a posição inicial)
	add r3, r3, r0 ; Valor final
	loadn r6, #1
	add r6, r6, r1
	loadn r2, #enemies
	add r2, r2, r6 ; Pega a posição de memória do inimigo
	storei r2, r3 ; Salva no endereço de memória de r2 o valor contido em r3

	loadn r7, #'b'
	outchar r7, r3
	jmp EnemiesSetUpEnd

EnemiesSetUpIsTwo:
	loadi r0, r4	; Valor da posição inicial da sala
	inc r0
	loadn r6, #1
	add r3, r4, r6 ; Posição de Memória do Height
	loadi r3, r3   ; Valor do Height
	loadn r2, #40
	mul r3, r3, r2 ; Valor quando pega Height e multiplica por 40
	add r3, r3, r0 ; Valor final
	loadn r6, #1
	add r6, r6, r1
	loadn r2, #enemies
	add r2, r2, r6 ; Pega a posição de memória do inimigo
	storei r2, r3 ; Salva no endereço de memória de r2 o valor contido em r3

	loadn r7, #'c'
	outchar r7, r3
	jmp EnemiesSetUpEnd



ProcessEnemy:
	push r0
	push r1
	push r2
	push r3
	push r4
	
	; Enemies: 0: LifeEnemy1, 1: PosEnemy1, 2: DamageEnemy1, 3: lifeEnemy2, ..,
	loadn r1, #4
	loadn r0, #room			; endereço #room em r0
	add r0, r0, r1			; somar 4 para conseguir a quantidade de inimigos
	loadi r2, r0			; r2 = valor da quantidade de inimigos

	loadn r1, #0			; vai guardar o index do inimigo
	loadn r3, #enemies		; Endereco inimigo
	call MovEnemyLoop

	pop r4	
	pop r3	
	pop r2	
	pop r1
	pop r0
	rts

; MovEnemyLoop(r2 = qtd de inimigos, r3 = endereco inimigo atual)
; Loop por cada inimigo
; Para cada inimigo, ver posição do jogador, e posição dos outros inimigos
MovEnemyLoop:
	loadn r0, #0
	loadi r4, r3			; life enemy
	cmp r0, r4				; comparar lifeEnemy com 0
	jle MovEnemyAlive		; caso seja r4 > 0, entao está vivo

	loadn r0, #3
	add r3, r3, r0			; pular inimigo
	jmp MovEnemyLoop

; inimigo vivo, r3 = endereco do inimigo da vez	
MovEnemyAlive:
	load r0, player			; pegar a posição do jogador
	
	inc r3
	loadi r1, r3			; r1 = pos inimigo

	

	cmp r1, r2
	jeq MovEnemyLoopEnd		; sair do loop depois que passar por todos
	inc r1
	
	jmp MovEnemyLoop

MovEnemyLoopEnd:
	rts

MovEnemy:
    push r3
    push r4
    push r5
    push r6
	push r7

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

MovPlayeDrawn:
    loadn r6, #'.'			; Carregando e pintando '.'
	loadn r7, #768
	add r6, r6, r7
    outchar r6, r5          ; Pintando a posição anterior de preto
    outchar r2, r1          ; Pintando o personagem na nova posição
    store player, r1     ; Salvando a nova posição

MovEnemnd:
	pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    rts

; MapSetUp(r2 = item)
; Faz todos os cálculos para gerar o mapa do novo nível
MapSetUp:
	push r0				    ; r0 = position
	push r2					; r2 = height
	push r3					; r3 = width
	push r4					; r4 = nrmDoors
	push r5					; r5 = item
	push r6					; Auxiliar para r2			
	push r1					; Ponteiro para room

    call RefreshScreen
	call RefreshMemoryMap
	call SetItemInRoom
    call CreateRoom
	call DrawnRoom
	call SetMemoryMap
	call SetPlayerInRoom
	call SetEnemies

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

; RefreshMemoryMap(), reseta o mapa do nível ná memória
RefreshMemoryMap:
	push r1
    push r2
    push r3
	push r4

    loadn r1, #memoryMap    ; r1 recebe o início de memoryMap
    loadn r2, #1200         ; r2 recebe a posição final desse vetor
    loadn r3, #0            ; r3 mantém a string vazia para ressetar a tela
	loadn r4, #0			; contador

RefreshMemoryMapLoop:
    storei r1, r3            ; Resetando a posição atual da tela
    inc r1
	inc r4
    cmp r4, r2
    jne RefreshMemoryMapLoop; Itera enqunato não chegar ao fim da tela

	pop r4
    pop r3
    pop r2
    pop r1
    rts


;SetItemInRoom(r2 = item); Guarda no vetor da sala um item
SetItemInRoom:
	push r1
	push r3

	loadn r1, #room
	loadn r3, #5
	add r1, r1, r3			; r1 recebe o endereço para guardar o item na sala

	storei r1, r2 			; Guardando na sala e retornando
	pop r3
	pop r1
	rts


; CreateRoom(r1 = posPlayer);
; Slva na memória a sala gerada aleatoriamente, atualizando a posição inicial do player
; Reseta Doors, Enemies e item
; Retorna em r0 a posição inicial e outros valores da sala para os outros regs
CreateRoom:

	; Nova posição
	loadn r1, #room
	loadn r0, #166			; Supostamente calculariamos em r0 a pos mais ao meio	
	storei r1, r0

	; Nova altura
	inc r1
	call GenerateRand
	mov r6, r2				; r6 guardará temporariamente a altura
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

	mov r2, r6				; Restaurando a altura em r2
	rts



; CreateNewDoors(); Retorna em r4
; Gera as portas para a nova sala
CreateNewDoors:
	push r1
	push r2
	push r3
	push r5

	; Gerando o número de portas aleatório entre 1 e 3
	loadn r3, #3
	call GenerateRand
	mod r1, r2, r3			; r1 = r2 % 3
	inc r1					; Garante que r1 estará entre 1 e 3

	; Instanciando as novas portas
	inc r3					; r3 recebe 4 para gerar, com mod, os códigos dos itens
	loadn r4, #Doors		; r4 armazena o endereço do vetor das portas
	loadn r5, #0			; Contador do loop

CreateNewDoorsLoop:
	call GenerateRand
	mod r2, r2, r3		    ; Gerando o valor que indica o que terá na porta (de 0 a 3)
	storei r4, r2		    ; Guardando em Doors
	inc r4					; Doors++
	inc r5					; Contador++
	cmp r5, r1
	jel CreateNewDoorsLoop	; jel = jump equal or lesser (<=)

	; Resetando as portas remanescentes (para 10), caso o número gerado seja menor que 4
	dec r3
	loadn r2, #10
	cmp r5, r3
	jel CreateNewDoorsReset	; jle = jump lesser (<)


CreateNewDoorsEnd:
	mov r4, r1				; Salvando nrmDoors no retorno

	pop r5
	pop r3
	pop r2
	pop r1
	rts

CreateNewDoorsReset:
	storei r4, r2
	inc r4
	inc r5					; contador++
	cmp r5, r3
	jle CreateNewDoorsReset ; Itera enquanto contador < 3
	jmp CreateNewDoorsEnd



SetMemoryMap:
	push r1					; Auxiliar para r0, tendo a posição correta
	push r2
	push r4					; recebe o valor base de memoryMap
	push r6					; contador
	push r7					; Auxiliar para os sprites
	
	; Imprimindo o teto da sala
	loadn r4, #memoryMap
	loadn r7, #'-'

	mov r1, r0				; r1 será usada para incrementar em largura
	add r1, r1, r4			; r1 recebe o endereço exato a ser preenchido
	loadn r6, #0			; Inicializando o contador
	inc r3					; width não considera as paredes. Por isso incrementamos temporariamente
SetMemoryMapTop:
	storei r1, r7
	inc r1
	inc r6					; contador++;
	cmp r6, r3
	jel SetMemoryMapTop		; Itera enquanto r6 <= (width + 1)

	; salvando tudo internamente
	loadn r1, #40
	add r1, r1, r0			; r1 recebe a posição da próxima linha
	add r1, r1, r4			; r1 recebe o endereço exato a ser preenchido
	loadn r6, #1			; Resetando o contador para multiplicar o número de linhas
SetMemoryMapLoop:
	storei r1, r7
	add r1, r1, r3			; r1 = r1 + (width + 1)
	storei r1, r7

	inc r6					; Calculando a posição da próxima linha
	loadn r1, #40
	mul r1, r1, r6
	add r1, r1, r0
	add r1, r1, r4
	cmp r6, r2
	jel SetMemoryMapLoop

	; Imprimindo a base da sala
	loadn r6, #0			; Inicializando o contador
SetMemoryMapBottom:
	storei r1, r7
	inc r1
	inc r6					; contador++;
	cmp r6, r3
	jel SetMemoryMapBottom ; Itera enquanto r6 <= (width + 1)

	dec r3
	pop r7
	pop r6
	pop r4
	pop r2
	pop r1
	rts



; DrawRoom(r0 = pos, r2 =  height, r3 = width)
DrawnRoom:
	push r1					; Auxiliar para r0
	push r2					; Será usado para calcular a altura máxima
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

	dec r3					; Voltando r3 ao valor original

	pop r7
	pop r6
	pop r5
	pop r4
	pop r2
	pop r1
	rts


; SetPlayerInRoom(r0 = posRoom)
; Recalcula a posição do jogador, e o redesenha dentro da sala
SetPlayerInRoom:
	push r1
	push r2
	

	; Recalculando a posição do jogador
	loadn r1, #41
	add r1, r1, r0			; r1, é o primeiro . do canto superior direito da sala gerada
	store player, r1		; Guardando o valor de r1 em posPlayer

	; Redesenhando ele na sala
	load r2, spritePlayer
	outchar r2, r1

	pop r2
	pop r1
	rts


; SpawnItem(): Imprime o item na tela e permite a colisão
SpawnItem:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5

	; Guardando em r0 o código do item
	loadn r0, #room
	loadn r1, #5
	add r0, r0, r1
	loadi r0, r0			; r0 recebe o código do item

	; Gerando em r2, uma posição aleatória dentro da sala
	loadn r5, #2
	loadn r1, #room
	inc r1
	loadi r3, r1	
	div r3, r3, r5			; r3 recebe medade de height
	inc r3
	inc r1
	loadi r4, r1
	div r4, r4, r5			; r4 recebe metade do width
	inc r4
	load r2, room			; r2 recebe pos

	add r2, r2, r4
	loadn r5, #40
	mul r3, r3, r5			; tratando r3 para descer r2 na sala
	add r2, r2, r3			; r2 se encontra mais ou menos ao centro da sala
	
	; Carregando o sprite do item exato a partir do código em r3
	loadn r3, #0
	cmp r0, r3
	jeq SpawnItemHealth
	loadn r3, #1
	cmp r0, r3
	jeq SpawnItemCoin
	loadn r3, #2
	cmp r0, r3
	jeq SpawnItemDamage
	loadn r3, #3
	cmp r0, r3
	jeq SpawnItemMax

SpawnItemEnd:
	; Carregando a posição do item no memoryMap
	loadn r1, #memoryMap
	add r1, r1, r2
	storei r1, r3
	; Imprimindo o sprite na tela
	outchar r3, r2

	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

SpawnItemHealth:
	load r3, healthPotion 
	jmp SpawnItemEnd
SpawnItemCoin:
	load r3, CoinPotion
	jmp SpawnItemEnd
SpawnItemDamage:
	load r3, DamagePotion
	jmp SpawnItemEnd
SpawnItemMax:
	load r3, MaxHealthPotion
	jmp SpawnItemEnd


; OpenDoors(): Imprime na tela e no memoryMap as portas selecionadas
OpenDoors:
	push r0					; ponteiro para as variáveis
	push r1					; pos
	push r2					; Auxiliar para os cálculos
	push r3					; width
	push r4					; Auxiliar para os cálculos
	push r5					; recebe o código de cada porta
	push r6					; auxiliar para verificar se há uma porta
	push r7					; Indica qual a posição da porta

	; Carregando os atributos da sala para o cálculo das posições
	loadn r0, #room
	loadn r4, #2
	loadn r2, #40
	loadi r1, r0			; r1 recebe pos
	add r1, r1, r2

	add r0, r0, r4
	loadi r3, r0			; r3 recebe width
	inc r3					; Ajustando para a ultima parede

	; Calculando a primeira posição
	mov r7, r1
	add r7, r7, r3
	loadn r4, #80			; r4 recebe 80 para descer 2 posições nas próximas portas

	; Verificando se existem e carregando as portas
	loadn r0, #Doors 
	loadn r6, #10
OpenDoorsLoop:
	loadi r5, r0
	inc r0
	cmp r5, r6
	jeq OpenDoorsEnd
	call DrawnDoor
	add r7, r7, r4
	jmp OpenDoorsLoop
	
OpenDoorsEnd:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


; DrawnDoor(r5 = código da porta, r7 = posPorta)
DrawnDoor:
	push r0					; ponteiro para memoryMap
	push r1					; Recebe o código da cor da porta
	push r2					; Recebe o sprite da porta '/'
	push r6					; Auxiliar para saber o que há na porta

	; Salvando a porta no mapa da memória
	loadn r0, #memoryMap
	loadn r2, #'/'
	add r0, r0, r7
	;storei r0, r2

	; Verificando qual a cor da porta
	loadn r6, #0
	cmp r5, r6
	jeq DrawnDoorGreen
	loadn r6, #1
	cmp r5, r6
	jeq DrawnDoorYellow
	loadn r6, #2
	cmp r5, r6
	jeq DrawnDoorBlue
	loadn r6, #3
	cmp r5, r6
	jeq DrawnDoorRed

DrawnDoorEnd:

	pop r6
	pop r2
	pop r1
	pop r0
	rts

DrawnDoorGreen:
	loadn r1, #512
	add r2, r2, r1
	outchar r2, r7
	storei r0, r2
	jmp DrawnDoorEnd
DrawnDoorYellow:
	loadn r1, #2816
	add r2, r2, r1
	outchar r2, r7
	storei r0, r2
	jmp DrawnDoorEnd
DrawnDoorBlue:
	loadn r1, #3072
	add r2, r2, r1
	outchar r2, r7
	storei r0, r2
	jmp DrawnDoorEnd
DrawnDoorRed:
	loadn r1, #256
	add r2, r2, r1
	outchar r2, r7
	storei r0, r2
	jmp DrawnDoorEnd



;IsItADoor(): Verifica se o jogador está em alguma porta
; Se sim, retorna em r1 1 e em r2 o código do item
IsItADoor:
	push r0						; Conteúdo da posição
	push r4						; Recebe '/'
	push r3						; Recebe as portas coloridas para comparação

	; Carregando o que há na memoria na posição do player
	loadn r4, #'/'
	load r1, player				; r1 recebe posplayer
	loadn r0, #memoryMap
	add r0, r0, r1
	loadi r0, r0				; r0 recebe o que há nessa posição do mapa

	; Verificando se é uma das portas
	loadn r1, #1				; Caso haja, r1 será um no final
	
	loadn r3, #512
	add r3, r3, r4
	cmp r0, r3
	jeq ItIsADoorGreen
	loadn r3, #2816
	add r3, r3, r4
	cmp r0, r3
	jeq ItIsADoorYellow
	loadn r3, #3072
	add r3, r3, r4
	cmp r0, r3
	jeq ItIsADoorBlue
	loadn r3, #256
	add r3, r3, r4
	cmp r0, r3
	jeq ItIsADoorRed
	
	loadn r1, #0				; Como não há portas, voltamos r1 para zero
IsItADoorEnd:
	pop r3
	pop r4
	pop r0
	rts

ItIsADoorGreen:
	loadn r2, #0
	jmp IsItADoorEnd
ItIsADoorYellow:
	loadn r2, #1
	jmp IsItADoorEnd
ItIsADoorBlue:
	loadn r2, #2
	jmp IsItADoorEnd
ItIsADoorRed:
	loadn r2, #3
	jmp IsItADoorEnd	

; Código pro item: 0: x, 1: m, 2: d, 3: v

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
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R2, #256	; Cor vermelha
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	loadn R6, #tela1Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   PrintScreen_Loop:
		call PrintString2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne PrintScreen_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
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

PrintNumber:
    ; recebe a posicao do primeiro digito no r0
    ; recebe o numero a ser impresso no r1
    push fr
    push r4                 ; posicao tela
    push r5
    push r6
    push r7                 ; Score atual
    mov r4, r0              ; move a posicao inicail
    loadn r5, #4 
    add r4, r4, r5          ; soma 4 pois serao impressos 5 digitos de tras pra frente
    mov r7, r1              ; move o numero a ser impresso, pois ele sera modificado
PrintNumberLoop:
    loadn r6, #10           ; div e mod por 10   
    mod r5, r7, r6
    div r7, r7, r6          ; divide score por 10
    loadn r6, #48           ; ascii 0
    add r5, r5, r6          ; soma resto no ascii zero
    outchar r5, r4
    dec r4                  ; decrementa posicao
    loadn r6, #0
    cmp r7, r6              ; ve se nao eh zero
    jne PrintNumberLoop
    loadn r5, #1
    mov r6, r0              ; move posicao inicial
    sub r6, r6, r5          ; subitrai 1 para criterio de aprada
PrintNumberZero:   			; completa com zero
    cmp r4, r6
    jeq PrintNumberEnd 		; se forem iguais sai
    loadn r5, #48           ; ascii 0
    outchar r5, r4
    dec r4                  ; decrementa posicao
    jmp PrintNumberZero

PrintNumberEnd:   
    pop r7
    pop r6
    pop r5
    pop r4
    pop fr
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
tela0Linha10 : string " __________                             "
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
tela1Linha2  : string "              VOCE MORREU               "
tela1Linha3  : string "              VOCE MORREU               "
tela1Linha4  : string "              VOCE MORREU               "
tela1Linha5  : string "              VOCE MORREU               "
tela1Linha6  : string "              VOCE MORREU               "
tela1Linha7  : string "              VOCE MORREU               "
tela1Linha8  : string "              VOCE MORREU               "
tela1Linha9  : string "              VOCE MORREU               "
tela1Linha10 : string "                                        "
tela1Linha11 : string "                  ..==.                 "
tela1Linha12 : string "                    .==#%%=.            "
tela1Linha13 : string "          ...:-+=.......:#**##....      "
tela1Linha14 : string "==.. .::.:+*+++*%%@%%%%%%#%@@@@@@@#---.."
tela1Linha15 : string ".++*=++*##*%%*@@%%%##+*++*#%@%##%%@#+*#="
tela1Linha16 : string "  .#%**=::..-#%%#@@%+-:.--=+%%%%%++#@@*."
tela1Linha17 : string "    ..:=+#*+*=-==+#**+++*#%*@@@@%#+#... "
tela1Linha18 : string "*%%#*%@@@%@%%%@**@%%%%%@#-. ..#%#%=...  "
tela1Linha19 : string "=###=..                     ..*%#%.     "
tela1Linha20 : string "                           :#*++.       "
tela1Linha21 : string "                          .-*#%+.       "
tela1Linha22 : string "                          .***.         "
tela1Linha23 : string "                            .           "
tela1Linha24 : string "                                        "
tela1Linha25 : string "                                        "
tela1Linha26 : string "       PRESSIONE Y PARA RESPAWNAR       "
tela1Linha27 : string "       OU N PARA VOLTAR AO INICIO       "
tela1Linha28 : string "                                        "
tela1Linha29 : string "                                        "