  .org $8000
reset:
  lda #$ff
  sta $6002
  
  sta $6000

  tax

loop:

  inx
  stx $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000
