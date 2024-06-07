jmp main

; Data
Str: string "Mundo mundo vasto mundo..."

clrTable: var #7
static clrTable + #0, #256
static clrTable + #1, #512
static clrTable + #2, #1024
static clrTable + #3, #2304
static clrTable + #4, #768
static clrTable + #5, #2816
static clrTable + #6, #3328


main:
    loadn r0, #40                ; Posição inicial na tela
    loadn r1, #Str               ; Endereço base de Str
    loadn r2, #clrTable          ; Variável que soma a cor
    loadn r3, #'\0'              ; Usado para comparar com o fim da string

    loadn r6, #6
    add r6, r6, r2

    loadi r4, r1                 ; Inicializando r4 com o primeiro char de str
    loadi r5, r2                 ; Carregando a cor em r5
loop:
    add r4, r4, r5               ; Se o loop iterou, troque a cor do valor
    outchar r4, r0               ; Imprime e incrementa os vetores
    inc r0
    inc r1
    inc r2
    
    cmp r2, r6                   ; Resetando o index da cor, caso necessário
    jne continue
    loadn r2, #clrTable 

continue:
    loadi r4, r1                 ; Carrega o próximo valor e a próxima cor
    loadi r5, r2
    cmp r3, r4
    jne loop                     ; Itera enquanto r3 != r4

    halt
