;===============================================================
; Special patch for customizing level entrances (castle &
; ghost houses).
;===============================================================

pushpc
	org $05DAB2
		JML custom_wide_entrances

pullpc

custom_wide_entrances:
	; make initial X position
	; both background and mario
	; to start at screen '01'
	STZ $1A
	LDA #$01
	STA $1B
	STA $95
	
	PHX
	TYX
	LDA.l custom_entrance_pointers+0,x
	STA $68
	LDA.l custom_entrance_pointers+1,x
	ORA #$E0
	STA $69
	
	LDY #$00
	LDA ($68),y
	STA $65
	INY
	LDA ($68),y
	STA $66
	INY
	LDA ($68),y
	STA $67
	INY
	
	TXY
	PLX
	
	JML $05DAC1|!bank
	
custom_entrance_pointers:
	; ghost house (level 30)
	dl 3*$0030
	
	; castle entrance #1 (level 31)
	dl 3*$0031
	
	; no yoshi #1 (null)
	dl 3*$0000
	
	; no yoshi #2 (null)
	dl 3*$0000*3
	
	; no yoshi #3 (null)
	dl 3*$0000
	
	; castle entrance #2 (level 32)
	dl 3*$0032
