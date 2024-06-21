jmp main

; Data section with the string
start : var #13
static start + #0, #'H'
static start + #1, #'e'
static start + #2, #'l'
static start + #3, #'l'
static start + #4, #'o'
static start + #5, #' '
static start + #6, #'W'
static start + #7, #'o'
static start + #8, #'r'
static start + #9, #'l'
static start + #10, #'d'
static start + #11, #'!'
static start + #12, #'\0'


main:
    loadn r0, #41        ; Posição inicial de impressão da tela
    loadn r1, #start       ; r1 receberá o endereço base de str
    loadn r2, #'\0'
    
mainLoop:
    loadi r3, r1         ; r3 recebe uma nova letra da string
    outchar r3, r0       ; Imprimindo o valor de r3 na posição de r0
    inc r0               ; r0++
    inc r1               ; fazendo r1 apontar para o endereço do próximo caracter
    mod r1, r1, r0
    cmp r3, r2
    jne mainLoop         ; Itera enquanto não chegar em \0

    halt