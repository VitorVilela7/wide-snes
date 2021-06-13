;===============================================================
; Code responsible for adding extended sprites support
; for Widescreen SMW
;===============================================================

;- Extended sprites
;==================

; NOT NEEDED: $01FD16
; Iggy/Larry only and they don't interact on widescreen!

; Volcano Lotus: $029B54
pushpc
	org $029B5C
		JSL extended_x_test
		NOP
		
	org $029BA0
		LDA $0F
pullpc

extended_x_test:
	LDA $1733|!addr,x
	SBC $1B
	XBA
	LDA $00
	REP #$20
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	LDA #$01
	RTL
.ok
	SEP #$20
	XBA
	AND #$01
	STA $0F
	
	LDA #$00
	RTL

; Wiggler flower / cloud coin
pushpc
	org $029D04
		; calculat x position 16-bit
		JML extended_x_test_cloud_wiggler
		
	org $029D13
		; optimize
		LDA $00
		BRA +
		
	org $029D1D
		+
		
	org $029D3F
		; x position msb + 8x8
		LDA $0F
		
	org $029D54
		; x position msb + 16x16
		LDA $0E
pullpc

extended_x_test_cloud_wiggler:
	LDA $1733|!addr,x
	XBA
	LDA $171F|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	JML $029D5D|!bank

.ok
	SEP #$20	
	STA $00
	XBA
	AND #$01
	STA $0F
	ORA #$02
	STA $0E

	JML $029D10|!bank

; Unused extended sprite - ignored: $029DC7

; Lava splash: $029EA0

; This particle in particular appears every time a sprite
; "falls" in lava and you can see some splashes appearing
; from the lava to the top. Don't confuse with the podoboo
; particles while jumping.
pushpc
	org $029EA0
		; calculat x position 16-bit
		JML extended_x_test_lava
		
	org $029EDD
		; x position msb + 8x8
		LDA $0F
pullpc

extended_x_test_lava:
	LDA $1733|!addr,x
	XBA
	LDA $171F|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	JML $029EE6|!bank

.ok
	SEP #$20	
	XBA
	AND #$01
	STA $0F
	XBA

	JML $029EB1|!bank

; General / fireball / mode 7: $02A05A
; General / fireball / regular: $02A1B1
pushpc
	; reznor
	org $02A19D
		LDA $0E

	; mode 7 case
	org $02A05A
		JML extended_x_test_2
		
	org $02A0A0
		LDA $0F
		
	org $02A1B1
		LDA $1733|!addr,x
		XBA
		LDA $171F|!addr,x
		REP #$20
		JML extended_x_test_3
		
	; print pc
	warnpc $02A1C0
	
	org $02A208
		LDA $0F
		
	; other general cases that reuses the routine:
	; smoke trail
	org $029C61
		LDA $0E
		
	; torpedo ted arm
	org $029E7C
		LDA $0E
		
	; air bubble
	org $029F4F
		JML bubble_rollout_carry
	
	; yoshi fire
	org $029F93
		LDA $0E
	
	; hammer/bone
	org $02A33D
		LDA $0E
	
pullpc

; fix a 1.2% chance of flickering happening
bubble_rollout_carry:
	STA $0200|!addr,y
	ROL
	XBA
	
	TYA
	LSR
	LSR
	TAY
	
	XBA
	AND #$01
	BIT $00
	BPL +
	EOR #$01
+	EOR $0420|!addr,y
	STA $0420|!addr,y
	
	LDY $A153,x
	LDA $0201|!addr,y
	JML $029F55|!bank

extended_x_test_2:
	LDA $1733|!addr,x
	XBA
	LDA $171F|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	JML $02A0A9|!bank

.ok
	SEP #$20
	XBA
	AND #$01
	STA $0F
	ORA #$02
	STA $0E
	XBA
	JML $02A064|!bank
	
extended_x_test_3:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	JML $02A211|!bank

.ok
	SEP #$20
	STA $01
	XBA
	AND #$01
	STA $0F
	ORA #$02
	STA $0E

	JML $02A1C0|!bank
	
; Baseball / bone extended sprites: $02A271
pushpc
	org $02A271
		LDA $1733|!addr,x
		XBA
		LDA $171F|!addr,x
		REP #$20
		SEC
		JML baseball_x_check
		
	; print pc
	warnpc $02A280
	
	org $02A2B9
		LDA $0F

pullpc

baseball_x_check:
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	XBA
	; get high byte and XOR with direction
	; to decide if it'll get erased or not.
	JML $02A280|!bank

.ok
	SEP #$20
	STA $00
	XBA
	AND #$01
	STA $0F
	JML $02A287|!bank

; Puff of smoke - regular: $02A36C
; Puff of smoke - mode 7: $02A3B4
pushpc
	org $02A36C
		LDA $1733|!addr,x
		XBA
		LDA $171F|!addr,x
		REP #$20
		JML puff_smoke_x_check
		
	; print pc
	warnpc $02A379
	
	org $02A3B4
		LDA $1733|!addr,x
		XBA
		LDA $171F|!addr,x
		REP #$20
		JML puff_smoke_x_check_mode7
		
	; print pc
	warnpc $02A3C1
	
	org $02A3A5
		LDA $0F
		
	org $02A3F0
		LDA $0F
	
pullpc

puff_smoke_x_check:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	
	; erase
	JML $02A211|!bank
	
.ok
	SEP #$20
	STA $0200|!addr,y
	XBA
	AND #$01
	ORA #$02
	STA $0F
	
	JML $02A379|!bank
	
puff_smoke_x_check_mode7:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
	BMI .ok
.return
	SEP #$20
	
	; erase
	JML $02A211|!bank
	
.ok
	SEP #$20
	STA $0300|!addr,y
	XBA
	AND #$01
	ORA #$02
	STA $0F
	
	JML $02A3C1|!bank

; TO DO: $02A42C --> note that smoke high bytes might have done something.
