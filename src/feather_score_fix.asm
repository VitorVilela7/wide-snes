;fixes minor issue where feather still gives you score if dropped from item box and collected when not a cape mario, unlike other power-ups.
;By RussianMan, credit is unecessary.

if read1($00FFD5) == $23	;sa-1 compatibility
  sa1rom
  !1534 = $32B0
  !addr = $6000
  !bank = $000000
else
  !1534 = $1534
  !addr = $0000
  !bank = $800000
endif

org $01C59C
autoclean JML CapeScore		;
NOP				;

freecode

CapeScore:
LDA #$0D
STA $1DF9|!addr			;restore sound

LDA !1534,x			;if dropped from the item box
BNE .NoScore			;no score

JML $01C5A1|!bank			;

.NoScore
JML $01C5A7|!bank			;