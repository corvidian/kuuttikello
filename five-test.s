PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

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

; Write 5 to first 4 custom characters

  lda #%01000000 ; Set LCD address to start of CGRAM (first custom character)
  jsr lcd_instruction

  ldx #0
five_loop:
  lda five,x
  jsr write_char
  inx
  cpx #31
  beq write_message 
  bra five_loop
  
write_message:
  lda #%10000000 ; Set LCD address to first character on screen
  jsr lcd_instruction

  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #%10100001 ; Maru
  jsr write_char

  lda #%11000000 ; 1st char of 2nd row
  jsr lcd_instruction

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char

  lda #%10100001 ; Maru
  jsr write_char

  lda #%10000101 ; Set LCD address to 6th character on screen
  jsr lcd_instruction
 
  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #%10100001 ; Maru
  jsr write_char

  lda #%11000101 ; Set LCD address to 6th character of 2nd line
  jsr lcd_instruction

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char

  lda #%10100001 ; Maru
  jsr write_char

  lda #%10001010 ; Set LCD address to 11th character on screen
  jsr lcd_instruction
 
  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #$00
  jsr write_char

  lda #$01
  jsr write_char

  lda #%11001010 ; Set LCD address to 11th character of 2nd line
  jsr lcd_instruction

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char

  lda #$02
  jsr write_char

  lda #$03
  jsr write_char
   
loop:
  jmp loop

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

five:
  .byte %00001111
  .byte %00001111
  .byte %00001111
  .byte %00011100
  .byte %00011100
  .byte %00011100
  .byte %00011111
  .byte %00001111

  .byte %00011110
  .byte %00011110
  .byte %00011110
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00011000
  .byte %00011110

  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00011000
  .byte %00011000
  .byte %00011110
  .byte %00001111
  .byte %00000011

  .byte %00000111
  .byte %00000111
  .byte %00000111
  .byte %00000111
  .byte %00000111
  .byte %00001110
  .byte %00011100
  .byte %00011000

  .org $fffc
  .word reset
  .word $0000
