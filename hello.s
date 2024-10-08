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

  ldx #$ff
xloop:
  ldy #$ff
yloop:
  dey
  bne yloop
  dex
  bne xloop

; Write the message

  lda #"H"
  jsr write_char

  lda #"e"
  jsr write_char

  lda #"l"
  jsr write_char

  lda #"l"
  jsr write_char

  lda #"o"
  jsr write_char

  lda #","
  jsr write_char

  lda #" "
  jsr write_char

  lda #"w"
  jsr write_char

  lda #"o"
  jsr write_char

  lda #"r"
  jsr write_char

  lda #"l"
  jsr write_char

  lda #"d"
  jsr write_char

  lda #"!"
  jsr write_char

;  lda #%11001111 ; Set cursor to low-right corner
;  jsr lcs_instruction

  lda #%00000111 ; Increment ; With shift
  jsr lcd_instruction

  ldx #$ff

:
  jmp :-
 
loop:
  inx
  stx PORTB 
  lda #RS        ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)  ; Set E bit to send instruction
  sta PORTA
  lda #RS        ; Clear E bit
  sta PORTA

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
  nop
  nop
  nop
  nop
  nop
  rts

  .org $fffc
  .word reset
  .word $0000
