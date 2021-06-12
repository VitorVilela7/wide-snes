;===============================================================
; Responsible for windowing HDMA effects on widescreen mode.
;
; Most of the simpler effects are handled on overworld.asm
;===============================================================

;- Circle/keyhole HDMA effect
;============================

; take care of window hdma

pushpc

;define x/y pos
; use CODE_00CA88 as set up $00 and $01
; X position should be adjusted.

; size calculation
org $00CC51
	JSL hack_test
	PLY
	RTS
	
org $00CA74
	JSL fix_x_pos
	NOP #3
	
; TO DO: this still needs fixing (spotlight)
org $03C612
	NOP #3

pullpc

fix_x_pos:
	REP #$20
	LDA $7E
	CLC
	ADC #$0008
	
	CLC
	ADC #$0080
	BPL +
	LDA #$0000
+	CMP #$01FF
	BMI +
	LDA #$01FF
	
+
	LSR
	STA $00
	SEP #$20
	RTL

; TO DO: SA-1
hack_test:
	LDA $4217
	LSR
	STA $02
	
	LSR $03
	
	;A's value is used
	RTL
