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

  lda #%00001110 ; Display on ; cursor on ; blink off 
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
 
  lda #SEP_POS_1
  jsr lcd_instruction
  lda #":"
  jsr write_char

  lda #SEP_POS_2
  jsr lcd_instruction
  lda #":"
  jsr write_char

  jsr write_secs
  jsr write_mins
  jsr write_hours

main_loop:
  inc SECS
  lda SECS
  cmp #60
  beq reset_secs

  jsr write_secs
  bra main_loop

reset_secs:
  stz SECS
  jsr write_secs
  inc MINS
  lda MINS
  cmp #60
  beq reset_mins

  jsr write_mins
  bra main_loop

reset_mins:
  stz MINS
  jsr write_mins
  inc HOURS
  lda HOURS
  cmp #24
  beq reset_hours

  jsr write_hours
  bra main_loop

reset_hours:
  stz HOURS
  jsr write_hours
  bra main_loop

write_secs:
  lda #SEC_POS
  jsr lcd_instruction

  lda SECS
  adc SECS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

write_mins:
  lda #MIN_POS
  jsr lcd_instruction

  lda MINS
  adc MINS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

write_hours:
  lda #HOUR_POS
  jsr lcd_instruction

  lda HOURS
  adc HOURS
  tax
  lda numbers,x
  jsr write_char
  inx
  lda numbers,x
  jsr write_char
  rts

lcd_instruction:
  sta PORTB
  stz PORTA         ; Clear RS/RW/E bits
  lda #E            ; Set E bit to send instruction
  sta PORTA
  stz PORTA         ; Clear RS/RW/E bits
  rts

write_char:
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
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

  .org $fffc
  .word reset
  .word $0000
