; I/O addresses
PORTB = $6000 ; Data for port B
PORTA = $6001 ; Data for port A
DDRB  = $6002 ; Data direction register for port B
DDRA  = $6003 ; Data direction register for port A
T1CL  = $6004 ; Timer 1 counter low
T1CH  = $6005 ; Timer 1 counter high
ACR   = $600B ; Auxiliary control register
IFR   = $600D ; Interrupt flag register
IER   = $600E ; Interrupt enable register

; RAM addresses
ticks = $00   ; timer ticks, 4 bytes up to $03
toggle_time = $04  ; 1 byte

  .org $8000

reset:
  lda #$ff
  sta DDRA
  lda #0
  sta PORTA
  jsr init_timer

loop:
  sec
  lda ticks
  sbc toggle_time
  cmp #25
  bcc loop

  lda #$01
  eor PORTA
  STA PORTA
  lda ticks
  sta toggle_time
  jmp loop

init_timer:
  stz ticks
  stz ticks + 1
  stz ticks + 2
  stz ticks + 3
  lda #%01000000
  sta ACR
  lda #$0e
  sta T1CL
  lda #$27
  sta T1CH
  lda %11000000
  sta IER
  cli
  rts

irq:
  bit T1CL
  inc ticks
  bne end_irq
  inc ticks + 1
  bne end_irq
  inc ticks + 2
  bne end_irq
  inc ticks + 3
end_irq:
  rti

  .org $fffc
  .word reset
  .word irq
