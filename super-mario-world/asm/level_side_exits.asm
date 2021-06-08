;===============================================================
; Special patch for side-exit widescreen support.
;===============================================================

pushpc
	org $00E991
		REP #$21
	
	org $00E995
		JSL widescreen_sideexit
		NOP
pullpc

widescreen_sideexit:
	ADC.W #$0008+!extra_columns
	CMP.W #$00F8+!extra_columns+!extra_columns+$0008
	SEP #$20
	RTL
