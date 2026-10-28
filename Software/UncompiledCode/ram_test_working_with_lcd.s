PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

reset:
    LDA #$FF
    TXS

    LDA #%11111111
    STA DDRB

    LDA #%11100000
    STA DDRA

    LDA #%00111000
    JSR lcd_instruction

    LDA #%00001110
    JSR lcd_instruction

    LDA #%00000110
    JSR lcd_instruction

    LDA #"H"
    JSR print_char
    LDA #"e"
    JSR print_char
    LDA #"l"
    JSR print_char
    LDA #"l"
    JSR print_char
    LDA #"o"
    JSR print_char

loop:
    JMP loop

lcd_instruction:
    STA PORTB
    LDA #0
    STA PORTA
    LDA #E
    STA PORTA
    LDA #0
    STA PORTA
    RTS

print_char:
    STA PORTB
    LDA #RS
    STA PORTA
    LDA #(RS | E)
    STA PORTA
    LDA #RS
    STA PORTA
    RTS

    .org $FFFC
    .word reset
    .word $0000