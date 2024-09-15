PORTB = $6000 ; Data for port B
PORTA = $6001 ; Data for port A
DDRB  = $6002 ; Data direction register for port B
DDRA  = $6003 ; Data direction register for port A
T1CL  = $6004 ; Timer 1 counter low
T1CH  = $6005 ; Timer 1 counter high
ACR   = $600B ; Auxiliary control register
IFR   = $600D ; Interrupt flag register

  .org $8000

reset:
  lda #$ff
  sta DDRA
  lda #0
  sta PORTA
  sta ACR
  
loop:
  inc PORTA
  jsr delay
  dec PORTA
  jsr delay
  jmp loop

delay:
  lda #$50
  sta T1CL
  lda #$c3
  sta T1CH
delay1:
  bit IFR
  bvc delay1
  lda T1CL
  rts

  .org $fffc
  .word reset
  .word $0000
