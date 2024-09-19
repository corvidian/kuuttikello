; I/O osoitteita
PORTB = $6000                       ; Data for port B
PORTA = $6001                       ; Data for port A
DDRB  = $6002                       ; Data direction register for port B
DDRA  = $6003                       ; Data direction register for port A
T1CL  = $6004                       ; Timer 1 counter low
T1CH  = $6005                       ; Timer 1 counter high
ACR   = $600B                       ; Auxiliary control register
PCR   = $600C                       ; Peripheral control register
IFR   = $600D                       ; Interrupt flag register
IER   = $600E                       ; Interrupt enable register

; RAM-osoitteita
hundredths = $10
secs = $11
mins = $12
hours = $13

kuutti = $20                        ; 0 = perus, 1 = uni

irq_temp = $30

; Arvoja
SEC_POS = $86
MIN_POS = $83
HOUR_POS = $80
SEP_POS_1 = $82
SEP_POS_2 = $85

KUUT_POS_1 = $88
KUUT_POS_2 = $C8

LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000

    .org $8000

reset:
    jsr lcd_init
    jsr init_timer
    jsr init_buttons
    cli

    stz kuutti

    stz hundredths
    stz secs
    stz mins
    stz hours
 
    jsr write_hours_mins_secs
    jsr draw_hymykuutti

main_loop:
    jsr check_secs

    jsr write_hours_mins_secs
    jsr choose_kuutti

    bra main_loop

check_secs:
    sec
    lda hundredths
    cmp #100
    bcc end_check_secs

    stz hundredths
    jsr inc_secs

end_check_secs:
    rts

inc_secs:
    inc secs
    lda secs
    cmp #60
    bne end_inc

reset_secs:
    stz secs
inc_mins:
    inc mins
    lda mins
    cmp #60
    bne end_inc

reset_mins:
    stz mins
inc_hours:
    inc hours
    lda hours
    cmp #24
    bne end_inc

reset_hours:
    stz hours

end_inc:
    rts

write_hours_mins_secs:
    lda #HOUR_POS
    jsr lcd_instruction

    lda hours
    clc
    adc hours
    tax
    lda numbers,x
    jsr write_char
    inx
    lda numbers,x
    jsr write_char

    lda #":"
    jsr write_char

    lda mins
    clc
    adc mins
    tax
    lda numbers,x
    jsr write_char
    inx
    lda numbers,x
    jsr write_char

    lda #":"
    jsr write_char

    lda secs
    clc
    adc secs
    tax
    lda numbers,x
    jsr write_char
    inx
    lda numbers,x
    jsr write_char
    rts

lcd_init:
    lda #%11111111                  ; Set all pins on port B to output
    sta DDRB

    lda #%11100000                  ; Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000                  ; Set 8-bit mode ; 2-line display ; 5x8 font
    jsr lcd_instruction

    lda #%00001100                  ; Display on ; cursor off ; blink off
    jsr lcd_instruction

    lda #%00000110                  ; Increment ; No shift
    jsr lcd_instruction

    lda #%00000001                  ; Clear screen
    jsr lcd_instruction

lcd_wait:
    pha
    stz DDRB                        ; Port B is input
lcd_busy:
    lda #LCD_RW                     ; Set RW bit
    sta PORTA
    lda #(LCD_RW | LCD_E)           ; Set Enable to send instruction
    sta PORTA
    lda PORTB                       ; Read the result from the data lines
    bmi lcd_busy                    ; Branch if top bit is set

    lda #LCD_RW                     ; Clear Enable bit
    sta PORTA
    lda #%11111111                  ; Port B is output
    sta DDRB
    pla
    rts

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    stz PORTA                       ; Clear RS/RW/E bits
    lda #LCD_E                      ; Set E bit to send instruction
    sta PORTA
    stz PORTA                       ; Clear LCD_RS/RW/E bits
    rts

write_char:
    jsr lcd_wait
    sta PORTB
    lda #LCD_RS                     ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(LCD_RS | LCD_E)           ; Set E bit to send instruction
    sta PORTA
    lda #LCD_RS                     ; Clear E bits
    sta PORTA
    rts

draw_peruskuutti:
    lda #%01000000                  ; Set LCD address to start of CGRAM (first custom character)
    jsr lcd_instruction

    ldx #0
:
    lda peruskuutti,x
    jsr write_char
    inx
    cpx #64
    bne :-

    rts

draw_kaanteiskuutti:
    lda #%01000000                  ; Set LCD address to start of CGRAM (first custom character)
    jsr lcd_instruction

    ldx #0
:
    lda kaanteiskuutti,x
    eor #$ff
    jsr write_char
    inx
    cpx #64
    bne :-

    rts

choose_kuutti:
    lda hours
    cmp #23
    bcs choose_unikuutti
    cmp #8
    bcc choose_unikuutti
    jmp draw_hymykuutti

choose_unikuutti:
    jmp draw_unikuutti

draw_hymykuutti:
    lda #KUUT_POS_1
    jsr lcd_instruction

    ldx #0
:
    lda hymykuutti_string1,x
    beq hymykuutti_toinen_rivi
    jsr write_char
    inx
    bra :-

hymykuutti_toinen_rivi:
    lda #KUUT_POS_2
    jsr lcd_instruction

    ldx #0
:
    lda hymykuutti_string2,x
    beq hymykuutti_draw_font
    jsr write_char
    inx
    bra :-

hymykuutti_draw_font:
    bit kuutti
    bpl exit_hymykuutti

    lda #%01000000                  ; Set LCD address to start of CGRAM (first custom character)
    jsr lcd_instruction

    ldx #0
:
    lda hymykuutti,x
    jsr write_char
    inx
    cpx #64
    bne :-

    smb7 kuutti

exit_hymykuutti:
    rts

draw_unikuutti:
    lda #KUUT_POS_1
    jsr lcd_instruction

    ldx #0
:
    lda unikuutti_string1,x
    beq unikuutti_toinen_rivi
    jsr write_char
    inx
    bra :-

unikuutti_toinen_rivi:
    lda #KUUT_POS_2
    jsr lcd_instruction

    ldx #0
:
    lda unikuutti_string2,x
    beq unikuutti_draw_font
    jsr write_char
    inx
    bra :-

unikuutti_draw_font:
    bit kuutti
    bmi exit_unikuutti

    lda #%01000000                  ; Set LCD address to start of CGRAM (first custom character)
    jsr lcd_instruction

    ldx #0
:
    lda unikuutti,x
    jsr write_char
    inx
    cpx #64
    bne :-

    rmb7 kuutti

exit_unikuutti:
    rts

init_timer:
    stz hundredths
    lda #%01000000
    sta ACR
    lda #$0e
    sta T1CL
    lda #$27
    sta T1CH
    lda #%11000000
    sta IER
    rts

init_buttons:
    lda #%10000011
    sta IER
    stz PCR
    rts

irq:
    bit IFR
    bvs timer_irq
    pha
    lda IFR
    sta irq_temp
    ror irq_temp
    bcs minute_button
    ror irq_temp
    bcs hour_button
    rti

hour_button:
    jsr inc_hours
    bra end_button_irq

minute_button:
    jsr inc_mins

end_button_irq:
    jsr debounce_delay
    bit PORTA                   ; Clear interrupt from VIA
    pla
    rti

timer_irq:
    bit T1CL                    ; Clear interrupt from VIA
    inc hundredths
    rti

debounce_delay:
    phx
    phy

    ldy #$80
    ldx #$FF
:
    dex                         ; Sets X to $FF when 0 after decreasing Y
    bne :-
    dey
    bne :-

    ply
    plx
    rts

nmi:
    stz hundredths
    stz secs
    rti

numbers:
    .byte "00","01","02","03","04","05","06","07","08","09"
    .byte "10","11","12","13","14","15","16","17","18","19"
    .byte "20","21","22","23","24","25","26","27","28","29"
    .byte "30","31","32","33","34","35","36","37","38","39"
    .byte "40","41","42","43","44","45","46","47","48","49"
    .byte "50","51","52","53","54","55","56","57","58","59"
    .byte "60","61","62","63","64","65","66","67","68","69"
    .byte "70","71","72","73","74","75","76","77","78","79"
    .byte "80","81","82","83","84","85","86","87","88","89"
    .byte "90","91","92","93","94","95","96","97","98","99"
    .byte "A0","A1","A2","A3","A4","A5","A6","A7","A8","A9"
    .byte "B0","B1","B2","B3","B4","B5","B6","B7","B8","B9"
    .byte "C0","C1","C2","C3","C4","C5","C6","C7","C8","C9"
    .byte "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9"
    .byte "F0","F1","F2","F3","F4","F5","F6","F7","F8","F9"

peruskuutti:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000001
    .byte %00000011
    .byte %00000110
    .byte %00000100
    .byte %00001000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00001000
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000010
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00010000
    .byte %00011000
    .byte %00001100
    .byte %00000100
    .byte %00000010

    .byte %00001000
    .byte %00001011
    .byte %00001000
    .byte %00001011
    .byte %00011000
    .byte %00010100
    .byte %00010011
    .byte %00001110

    .byte %00001100
    .byte %00001100
    .byte %00000001
    .byte %00000101
    .byte %00000011
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000110
    .byte %00000110
    .byte %00010000
    .byte %00010100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000010
    .byte %00011010
    .byte %00000010
    .byte %00011010
    .byte %00000011
    .byte %00000101
    .byte %00011001
    .byte %00001110

hymykuutti_string1: .byte $a1, $eb,  8,  9, 10, 11, $eb, $a1, 0
hymykuutti_string2: .byte " ", " ", 12, 13, 14, 15, " ", " ", 0

hymykuutti:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000001
    .byte %00000011
    .byte %00000110
    .byte %00000100
    .byte %00001000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00001000
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000010
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00010000
    .byte %00011000
    .byte %00001100
    .byte %00000100
    .byte %00000010

    .byte %00001000
    .byte %00001011
    .byte %00001000
    .byte %00001011
    .byte %00011000
    .byte %00010100
    .byte %00010011
    .byte %00001110

    .byte %00001000
    .byte %00010100
    .byte %00000001
    .byte %00000101
    .byte %00000011
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000010
    .byte %00000101
    .byte %00010000
    .byte %00010100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000010
    .byte %00011010
    .byte %00000010
    .byte %00011010
    .byte %00000011
    .byte %00000101
    .byte %00011001
    .byte %00001110

unikuutti_string1: .byte  8,  9, 10, 11, "Z", "z", "Z", "z", 0
unikuutti_string2: .byte 12, 13, 14, 15, " ", " ", " ", " ", 0

unikuutti:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000001
    .byte %00000011
    .byte %00000110
    .byte %00000100
    .byte %00001000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00001000
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000010
    .byte %00000000

    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00010000
    .byte %00011000
    .byte %00001100
    .byte %00000100
    .byte %00000010

    .byte %00001000
    .byte %00001011
    .byte %00001000
    .byte %00001011
    .byte %00011000
    .byte %00010100
    .byte %00010011
    .byte %00001110

    .byte %00000000
    .byte %00001100
    .byte %00000001
    .byte %00000101
    .byte %00000011
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000000
    .byte %00000110
    .byte %00010000
    .byte %00010100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000010
    .byte %00011010
    .byte %00000010
    .byte %00011010
    .byte %00000011
    .byte %00000101
    .byte %00011001
    .byte %00001110

kaanteiskuutti:
    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00011110
    .byte %00011100
    .byte %00011100
    .byte %00011000

    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00001000
    .byte %00000000

    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000010
    .byte %00000000

    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00011111
    .byte %00001111
    .byte %00000111
    .byte %00000111
    .byte %00000011

    .byte %00011000
    .byte %00011011
    .byte %00011000
    .byte %00011011
    .byte %00011000
    .byte %00000100
    .byte %00000011
    .byte %00010011

    .byte %00001100
    .byte %00001100
    .byte %00000001
    .byte %00000101
    .byte %00000011
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000110
    .byte %00000110
    .byte %00010000
    .byte %00010100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte %00011111

    .byte %00000011
    .byte %00011011
    .byte %00000011
    .byte %00011011
    .byte %00000011
    .byte %00000101
    .byte %00011001
    .byte %00011111

    .org $fffa
    .word nmi
    .word reset
    .word irq
