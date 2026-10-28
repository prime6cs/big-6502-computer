PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

value = $0200
mod10 = $0202
msg = $0204

E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

reset:
    LDA #$ff
    TXS

    LDA #%11111111 ; set all pins port b, output
    STA DDRB
    LDA #%11100000 ; set top 3 pins on port a, output
    STA DDRA

    LDA #%00111000 ; 8 bit mode; 2 line display; 5x8 font
    JSR lcd_instruction
    LDA #%00001110 ; display on; cursor on; blink off
    JSR lcd_instruction
    LDA #%00000110 ; increment cursor; no display shift
    JSR lcd_instruction
    LDA #%00000001 ; clear display
    JSR lcd_instruction

    LDA #0
    STA msg ; initialize the string to be printed with a null terminator
    
    ; initialize the value and mod10 variables with the number to be printed
    LDA number
    STA value
    LDA number + 1
    STA value + 1

divide:
    LDA #0
    STA mod10
    STA mod10 + 1
    CLC

    LDX #16
divloop:
    ; rotate quotient and remainder
    ROL value
    ROL value + 1
    ROL mod10
    ROL mod10 + 1

    SEC
    LDA mod10
    SBC #10
    TAY ; save low byte
    LDA mod10 + 1
    SBC #0
    BCC ignore_result ;branch if dividend< divisor
    STY mod10
    STA mod10 + 1

ignore_result:
    DEX
    BNE divloop
    ROL value ; shift in the last bit of the quotient
    ROL value + 1

    LDA mod10
    CLC
    ADC #"0"
    JSR push_char
    ;if value is not zero, repeat the division
    LDA value
    ORA value + 1
    BNE divide

    LDX #0
print:
    LDA msg, x
    BEQ loop
    JSR print_char
    INX
    JMP print

loop:
    JMP loop

number: .word 1729

; add the character in the A register to the beginning of the null terminated string at msg
push_char:
    PHA ; add to stack
    LDY #0

char_loop:
    LDA msg, y
    TAX
    PLA
    STA msg, y ; pull char off stack and add it to the string
    INY
    TXA
    PHA ; push char from string onto stack
    BNE char_loop

    PLA
    STA msg, y ; add the null terminator to the end of the string

    RTS

lcd_wait:
    RTS
lcdbusy:
    LDA #RW
    STA PORTA
    LDA #(RW | E)
    STA PORTA
    LDA PORTB
    AND #%10000000 ; check if busy bit is set
    BNE lcdbusy

    LDA #RW
    STA PORTA
    LDA #%11111111 ; Port B is output
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

    .org $FFFC
    .word reset
    .word $0000