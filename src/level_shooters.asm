;===============================================================
; Code responsible for adding shooter support
; for Widescreen SMW
;===============================================================

;- Shooter sprites
;=================

; Torpedo Ted
pushpc
	org $02B3CC
		JML torpedo_ted
pullpc

torpedo_ted:
	LDA $17A3|!addr,x
	XBA
	LDA $179B|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns+$0010
	BMI .return
	CMP.w #$0100+!extra_columns-$0010+1
	BMI .ok
	
.return
	SEP #$20
	JML $02B3AA|!bank
	
.ok
	SEP #$20
	JML $02B3E5|!bank

; Bullet Bill Shooter
pushpc
	org $02B47C
		JML bullet_bill_shooter
pullpc

bullet_bill_shooter:
	LDA $17A3|!addr,x
	XBA
	LDA $179B|!addr,x
	REP #$20
	STA $00
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns+$0010
	BMI .return
	CMP.w #$0100+!extra_columns-$0010+1
	BMI .ok
	
.return
	SEP #$20
	JML $02B4DD|!bank
	
.ok
	LDA $94
	SEC
	SBC $00
	BPL +
	EOR #$FFFF
	INC
+	CMP #$0011
	BCC .return

	SEP #$20
	JML $02B4A1|!bank
