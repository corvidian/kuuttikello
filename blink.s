PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
;RS = %00100000

  .org $8000

reset:
  lda #$ff
  sta DDRA
  lda #0
  sta PORTA
  
loop:
  inc PORTA
  jsr delay
  dec PORTA
  jsr delay
  jmp loop

delay:
  ldy #$ff
delay2:
  ldx #$ff
delay1:
  nop
  dex
  bne delay1
  dey
  bne delay2
  rts

  .org $fffc
  .word reset
  .word $0000
