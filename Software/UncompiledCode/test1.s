PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

reset:
    LDA #%11111111
    STA DDRB
    LDA #%11100000
    STA DDRA
    LDA #%00111000
    STA PORTB
    LDA #0
    STA PORTA
    LDA #E
    STA PORTA
    LDA #0
    STA PORTA
    LDA #%00001110
    STA PORTB
    LDA #0
    STA PORTA
    LDA #E
    STA PORTA
    LDA #0
    STA PORTA
    LDA #%00000110
    STA PORTB
    LDA #0
    STA PORTA
    LDA #E
    STA PORTA
    LDA #0
    STA PORTA
    LDA #"H"
    STA PORTB
    LDA #RS
    STA PORTA
    LDA #(RS | E)
    STA PORTA
    LDA #RS
    STA PORTA
loop:
    JMP loop

    .org $FFFC
    .word reset
    .word $0000