;===============================================================
; Responsible for Yoshi support on widescreen mode.
;
; Makes sure tiles are drawn correctly on levels.
;===============================================================

;- Yoshi's tongue
;================

pushpc
	org $01F418
		; new y position
		STA $02
	
		; $0E receives #$FF if left, #$00 if right
		LDA #$00
		SEC
		SBC !157C,x
		STA $0E
		BCC .left
		TYA
		ADC #$07
		TAY
	.left
		LDA $F60A,y
		STA $0D
		
		; 16-bit x position calculation
		LDA !14E0,x
		XBA
		LDA !E4,x
		REP #$21
		ADC $0D
		SEC
		SBC $1A
		STA $00
		SEP #$20
		
	; print pc
	warnpc $01F43E
	
	org $01F464
		; sign extension $05 ->> $06
		JML yoshi_tongue_sign_ext

	org $01F474
		; widescreen flag for current tile.
		LDA $01
		AND #$01
		STA $0E
		
		JML yoshi_tongue_offscreen
		
	; print pc
	warnpc $01F47E
		
	org $01F47E
		; new y position
		LDA $02
		
	org $01F483
		; check which tile to draw
		LDA $0F
		
	org $01F4A3
		; new tile size, set by offscreen hijack.
		LDA $0E
		
	org $01F4AD
		; loop counter
		DEC $0F
	
pullpc

yoshi_tongue_sign_ext:
	AND #$80
	BEQ .no_sex
	ORA #$7F
.no_sex
	; $06 is $05's high byte
	STA $06
	
	; new loop counter
	LDA #$04
	STA $0F
	
	JML $01F468|!bank
	
yoshi_tongue_offscreen:	
	; calculate widescreen/offscreen value for next tile.
	LDA $01
	ADC $06
	STA $01
	
	; possible improvement for ultrawide includes checking
	; if the current position overflows screen edges and
	; stop routine to avoid the tongue wrapping screen side.
	
	JML $01F47E|!bank

;- Yoshi's throat
;================

pushpc
	org $01F065
		LDA !14E0,x
		JML yoshi_throat_x
		
	; print pc
	warnpc $01F06C
	
	org $01F071
		; save new y position
		STA $03
		
	org $01F080
		; load new y position
		LDA $03
		
	org $01F079
		JML yoshi_throat_sign_ext

	org $01F09B
		; get x position msb
		LDA $01

pullpc		

yoshi_throat_x:
	XBA
	LDA !E4,x
	REP #$20
	SEC
	SBC $1A
	STA $00
	SEP #$20
	
	JML $01F06C|!bank
	
yoshi_throat_sign_ext:
	ADC.l $03C176,x
	STA $0300|!addr
	
	LDA.l $03C176,x
	AND #$80
	BEQ .no_sex
	ORA #$7F
.no_sex
	; set x position msb
	ADC $01
	AND #$01
	STA $01
	
	JML $01F080|!bank
	
