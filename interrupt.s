PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

LCD_E  = %10000000
LCD_RW = %01000000
RS = %00100000

message = $0204                     ; 5 bytes?
counter = $020a                     ; 2 bytes

hex_temp = $f0

  .org $8000
reset:
  ldx #$ff
  txs
  cli

  lda #%11111111                  ; Set all pins on port B to output
  sta DDRB

  lda #%11100000                  ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000                  ; Set 8-bit mode ; 2-line display ; 5x8 font
  jsr lcd_instruction

  lda #%00001110                  ; Display on ; cursor on ; blink off
  jsr lcd_instruction

  lda #%00000110                  ; Increment ; No shift
  jsr lcd_instruction

  lda #%00000001                  ; Clear screen
  jsr lcd_instruction

  stz message
  stz message + 1
  stz message + 2
  stz message + 3
  stz message + 4

  stz counter
  stz counter + 1

loop:
  lda #%00000010  ; Reset cursor to home
  jsr lcd_instruction

  lda counter + 1 ; Read hexes from counter to message
  jsr hex_high
  sta message
  lda counter + 1
  jsr hex_low
  sta message + 1
  lda counter
  jsr hex_high
  sta message + 2
  lda counter
  jsr hex_low
  sta message + 3

  ldx #0
print:
  lda message,x
  beq loop
  jsr write_char
  inx
  jmp print

  jmp loop

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
  stz PORTA                       ; Clear RS/RW/E bits
  rts

write_char:
  jsr lcd_wait
  sta PORTB
  lda #RS                         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | LCD_E)               ; Set E bit to send instruction
  sta PORTA
  lda #RS                         ; Clear E bits
  sta PORTA
  rts

hex_low:
  sta hex_temp
  lda #$0F
  and hex_temp
  tay
  lda hexes,y
  rts

hex_high:
  sta hex_temp
  lda #$F0
  and hex_temp
  ror
  ror
  ror
  ror
  tay
  lda hexes,y
  rts

hexes:
  .asciiz "0123456789ABCDEF"

nmi:
irq:
  inc counter
  bne exit_irq
  inc counter + 1
exit_irq:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
