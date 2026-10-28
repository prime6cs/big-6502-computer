PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600C
IFR = $600D
IER = $600E

value = $0200
mod10 = $0202
msg = $0204
counter = $020A

E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

reset:
    LDA #$FF
    TXS
    CLI

    LDA #$82
    STA IER
    LDA #$00
    STA PCR

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

    LDA #$01
    JSR lcd_instruction
    LDA #0
    STA counter
    STA counter+1

loop:
    LDA #%00000010
    JSR lcd_instruction
    LDA #0
    STA msg

    SEI
    LDA counter
    STA value
    LDA counter+1
    STA value+1
    CLI

divide:
    LDA #0
    STA mod10
    STA mod10+1
    CLC
    LDX #16

divloop:
    ROL value
    ROL value+1
    ROL mod10
    ROL mod10+1

    SEC
    LDA mod10
    SBC #10
    TAY
    LDA mod10+1
    SBC #0
    BCC ignore_result
    STY mod10
    STA mod10+1

ignore_result:
    DEX
    BNE divloop
    ROL value
    ROL value+1
    LDA mod10
    CLC
    ADC #"0"
    JSR push_char

    LDA value
    ORA value+1
    BNE divide

    LDX #0

print:
    LDA msg, x
    BEQ loop
    JSR print_char
    INX
    JMP print

number: .word 1729

push_char:
    PHA
    LDY #0

char_loop:
    LDA msg, y
    TAX
    PLA
    STA msg, y
    INY
    TXA
    PHA
    BNE char_loop

    PLA
    STA msg, y
    RTS

lcd_wait:
    PHA
    LDA #%00000000
    STA DDRB
lcdbusy:
    LDA #RW
    STA PORTA
    LDA #(RW | E)
    STA PORTA
    LDA PORTB
    AND #%10000000
    BNE lcdbusy

    LDA #RW
    STA PORTA
    LDA #%11111111
    STA DDRB
    PLA
    RTS

lcd_instruction:
    JSR lcd_wait
    STA PORTB
    LDA #0
    STA PORTA
    LDA #E
    STA PORTA
    LDA #0
    STA PORTA
    RTS

print_char:
    JSR lcd_wait
    STA PORTB
    LDA #RS
    STA PORTA
    LDA #(RS | E)
    STA PORTA
    LDA #RS
    STA PORTA
    RTS

nmi:
irq:
    PHA
    TXA
    PHA
    INC counter
    BNE exit_irq
    INC counter+1

exit_irq:
    LDX #$FF

delay:
    DEX
    BNE delay
    BIT PORTA
    PLA
    TAX
    PLA
    RTI

    .org $FFFA
    .word nmi
    .word reset
    .word irq