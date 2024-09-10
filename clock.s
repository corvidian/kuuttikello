PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

SECS = $10
MINS = $11
HOURS = $12

SEC_POS = $86
MIN_POS = $83
HOUR_POS = $80
SEP_POS_1 = $82
SEP_POS_2 = $85

KUUT_POS_1 = $88
KUUT_POS_2 = $C8

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000
reset:
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode ; 2-line display ; 5x8 font 
  jsr lcd_instruction

  lda #%00001100 ; Display on ; cursor off ; blink off
  jsr lcd_instruction

  lda #%00000110 ; Increment ; No shift
  jsr lcd_instruction

  lda #%00000001 ; Clear screen 
  jsr lcd_instruction

  clc
  cld

  lda #19
  sta SECS
  lda #59
  sta MINS
  lda #23
  sta HOURS
 
  jsr write_hours_mins_secs

  lda #KUUT_POS_1
  jsr lcd_instruction

  lda #$00
  jsr write_char
  lda #$01
  jsr write_char
  lda #$02
  jsr write_char
  lda #$03
  jsr write_char

  lda #KUUT_POS_2
  jsr lcd_instruction

  lda #$04
  jsr write_char
  lda #$05
  jsr write_char
  lda #$06
  jsr write_char
  lda #$07
  jsr write_char

main_loop:
  clc
  inc SECS
  lda SECS
  cmp #60
  beq reset_secs

  jsr write_secs

; Viivettä, ettei sekunnit vilise
  ldx #128
xloop:
  ldy #128
yloop:
  dey
  bne yloop

  dex
  bne xloop
; Viive ohi

  bra main_loop

reset_secs:
  stz SECS
  inc MINS
  lda MINS
  cmp #60
  beq reset_mins

  lsr a
  bcc perus
  jsr draw_hymykuutti
  bra cont
perus:
  jsr draw_unikuutti

cont:
  clc
  jsr write_mins_secs
  bra main_loop

reset_mins:
  stz MINS
  inc HOURS
  lda HOURS
  cmp #24
  bne keep_hours
  stz HOURS

keep_hours:
  jsr write_hours_mins_secs
  bra main_loop

write_secs:
  lda #SEC_POS
  jsr lcd_instruction

  lda SECS
  clc
  adc SECS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

write_mins_secs:
  lda #MIN_POS
  jsr lcd_instruction

  lda MINS
  clc
  adc MINS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char

  lda #":"
  jsr write_char

  lda SECS
  clc
  adc SECS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

write_hours_mins_secs:
  lda #HOUR_POS
  jsr lcd_instruction

  lda HOURS
  clc
  adc HOURS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char

  lda #":"
  jsr write_char

  lda MINS
  clc
  adc MINS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char

  lda #":"
  jsr write_char

  lda SECS
  clc
  adc SECS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

lcd_wait:
  pha
  stz DDRB       ; Port B is input
lcd_busy:
  lda #RW        ; Set RW bit
  sta PORTA
  lda #(RW | E)  ; Set Enable to send instruction
  sta PORTA
  lda PORTB      ; Read the result from the data lines
  bmi lcd_busy   ; Branch if top bit is set

  lda #RW        ; Clear Enable bit
  sta PORTA
  lda #%11111111 ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  stz PORTA         ; Clear RS/RW/E bits
  lda #E            ; Set E bit to send instruction
  sta PORTA
  stz PORTA         ; Clear RS/RW/E bits
  rts

write_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts

draw_peruskuutti:
  lda #%01000000 ; Set LCD address to start of CGRAM (first custom character)
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
  lda #%01000000 ; Set LCD address to start of CGRAM (first custom character)
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

draw_hymykuutti:
  lda #KUUT_POS_1
  jsr lcd_instruction

  ldx #0
:
  lda hymykuutti_string1,x
  jsr write_char
  bne :-

  lda #KUUT_POS_2
  jsr lcd_instruction

  ldx #0
:
  lda hymykuutti_string2,x
  jsr write_char
  bne :-

  lda #%01000000 ; Set LCD address to start of CGRAM (first custom character)
  jsr lcd_instruction

  ldx #0
:
  lda hymykuutti,x
  jsr write_char
  inx
  cpx #64
  bne :-

  rts

draw_unikuutti:
  lda #KUUT_POS_1
  jsr lcd_instruction

  ldx #0
:
  lda unikuutti_string1,x
  jsr write_char
  bne :-

  lda #KUUT_POS_2
  jsr lcd_instruction

  ldx #0
:
  lda unikuutti_string2,x
  jsr write_char
  bne :-

  lda #%01000000 ; Set LCD address to start of CGRAM (first custom character)
  jsr lcd_instruction

  ldx #0
:
  lda unikuutti,x
  jsr write_char
  inx
  cpx #64
  bne :-

  rts


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
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00001
  .byte %00011
  .byte %00110
  .byte %00100
  .byte %01000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %01000
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00010
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %00000
  .byte %10000
  .byte %11000
  .byte %01100
  .byte %00100
  .byte %00010

  .byte %01000
  .byte %01011
  .byte %01000
  .byte %01011
  .byte %11000
  .byte %10100
  .byte %10011
  .byte %01110

  .byte %01100
  .byte %01100
  .byte %00001
  .byte %00101
  .byte %00011
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00110
  .byte %00110
  .byte %10000
  .byte %10100
  .byte %11000
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00010
  .byte %11010
  .byte %00010
  .byte %11010
  .byte %00011
  .byte %00101
  .byte %11001
  .byte %01110

hymykuutti_string1: .byte $a1, $eb, 08, 09, 10, 11, $eb, $a1, 0
hymykuutti_string2: .byte " ", " ", 12, 13, 14, 15, " ", " ", 0

hymykuutti:
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00001
  .byte %00011
  .byte %00110
  .byte %00100
  .byte %01000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %01000
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00010
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %00000
  .byte %10000
  .byte %11000
  .byte %01100
  .byte %00100
  .byte %00010

  .byte %01000
  .byte %01011
  .byte %01000
  .byte %01011
  .byte %11000
  .byte %10100
  .byte %10011
  .byte %01110

  .byte %01000
  .byte %10100
  .byte %00001
  .byte %00101
  .byte %00011
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00010
  .byte %00101
  .byte %10000
  .byte %10100
  .byte %11000
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00010
  .byte %11010
  .byte %00010
  .byte %11010
  .byte %00011
  .byte %00101
  .byte %11001
  .byte %01110

unikuutti_string1: .byte 08, 09, 10, 11, "Z", "z", "Z", "z", 0
unikuutti_string2: .byte 12, 13, 14, 15, " ", " ", " ", " ", 0

unikuutti:
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00001
  .byte %00011
  .byte %00110
  .byte %00100
  .byte %01000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %01000
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00010
  .byte %00000

  .byte %00000
  .byte %00000
  .byte %00000
  .byte %10000
  .byte %11000
  .byte %01100
  .byte %00100
  .byte %00010

  .byte %01000
  .byte %01011
  .byte %01000
  .byte %01011
  .byte %11000
  .byte %10100
  .byte %10011
  .byte %01110

  .byte %00000
  .byte %01100
  .byte %00001
  .byte %00101
  .byte %00011
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00000
  .byte %00110
  .byte %10000
  .byte %10100
  .byte %11000
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00010
  .byte %11010
  .byte %00010
  .byte %11010
  .byte %00011
  .byte %00101
  .byte %11001
  .byte %01110

kaanteiskuutti:
  .byte %11111
  .byte %11111
  .byte %11111
  .byte %11111
  .byte %11110
  .byte %11100
  .byte %11100
  .byte %11000

  .byte %11111
  .byte %11111
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %01000
  .byte %00000

  .byte %11111
  .byte %11111
  .byte %11111
  .byte %00000
  .byte %00000
  .byte %00000
  .byte %00010
  .byte %00000

  .byte %11111
  .byte %11111
  .byte %11111
  .byte %11111
  .byte %01111
  .byte %00111
  .byte %00111
  .byte %00011

  .byte %11000
  .byte %11011
  .byte %11000
  .byte %11011
  .byte %11000
  .byte %00100
  .byte %00011
  .byte %10011

  .byte %01100
  .byte %01100
  .byte %00001
  .byte %00101
  .byte %00011
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00110
  .byte %00110
  .byte %10000
  .byte %10100
  .byte %11000
  .byte %00000
  .byte %00000
  .byte %11111

  .byte %00011
  .byte %11011
  .byte %00011
  .byte %11011
  .byte %00011
  .byte %00101
  .byte %11001
  .byte %11111

  .org $fffc
  .word reset
  .word $0000
