; Adaptação do Rogue The Videogame, para a arquitetura do ICMC
jmp main

; Variáveis do player
spritePlayer: var #1  
static spritePlayer + #0, #'@' 
posPlayer: var #1



main:
gameLoop:
    inchar r0               ; r0 recebe o comando do jogador, garantindo que nada ocorra até o input
    
    ; if r0 == 'q': saí do jogo
    loadn r1, #'q'
    cmp r0, r1
    jeq mainEnd

    ; Processando as mudanças para o jogador
    call ProcessPlayer

    jmp gameLoop
mainEnd:
    halt



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