pushpc
; $0AF6 - Used by the baby Yoshis in the credits as downwards acceleration.
; $0B05 - Sprite Y speed.
; $0B14 - Sprite X speed.
; $0B23 - Sprite Y speed accumulating fraction bits.
; $0B32 - Sprite X speed accumulating fraction bits.
; $0B41 - Sprite Y position (low).
; $0B50 - Sprite X position (low).
; $0B5F - Sprite Y position (high).
; $0B6E - Sprite X position (high).
; $0B7D - Used by the debris in Lemmy's cutscene as downwards acceleration.
; $0B8C - Used by the debris in Lemmy's cutscene to indicate a taken slot.

	;peach/other colored yoshies,shared with prev screen
	;org $0ca885
;		lda #$00
	;org $0ca88a
	;	lda #$00
	
	; render peach, other yoshies, etc., including
	; offscreen
	org $0CA83E
		NOP #2
	
	org $0CA840
		JSL solve_a
		
	org $0CA851
		JSL toggle_a
		
	org $0CA885
		LDA $0A
	org $0CA88A
		LDA $0B
	
	;yoshi house festive things
	;org $0ca110
	;	lda #$00
	
	;center festive yoshi angles
	;org $0caa4a
	;	lda #$00
	
	; render eggs even if offscreen
	org $0CA8E9
		NOP #2
		
	; seven yoshi eggs x high
	org $0CA8F5
		JSL yoshii
	
	; the seven yoshi eggs
	org $0CA927
		LDA $0F
	
	;seems to configure egg pos
	;org $0CA429
	;	LDA #$00
	
	
	;org $0CA61B
	;	NOP #2
	
	;0CA61B -> egg shards!
	
	; fix mario/yoshi
	org $0CA3DB
		LDA #$02
		
	; fix peach multiple times
	org $0CA29B
		ADC #$FF
		
	org $0CA23A
		ADC #$FF
	
	org $0CA6F6
		ADC #$FF
		
	org $0CA1A1
		JSL thank_you
		NOP
		
	org $0CA67A
		JML thank_you_proper
		
	org $0CA185
		NOP #2
pullpc

thank_you_proper:
	LDA !addr|$0B50,x
	CMP #$F8
	BCC +
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	STZ $04
	STZ $05
	BRA ++
	
+	STA $00
	STA $02
	STA $04
	LDA !addr|$0B6E,x
	STA $01
	STA $03
	STA $05
++	JML $0CA686|!bank
	
thank_you:
	LDA $01
	AND #$01
	ORA #$02
	STA !addr|$0460,x

solve_a:
	LDA $01
	AND #$01
	ORA #$02
	STA $0A
	STA $0B
	RTL

toggle_a:
	LDA $0B
	EOR #$01
	STA $0B
	RTL

yoshii:
	LDA.w $0B6E|!addr,y
	AND #$01
	ORA #$02
	STA $0F
	
	; restore
	LDX $02
	LDA $00
	RTL

; enemy cast
pushpc
	org $009625
		JML set_logic
pullpc

set_logic:
	
	PHK
	PEA.w .jslrtsreturn-1
	PEA.w $0084CF-1
	JML $009629
.jslrtsreturn

	LDA $0100|!addr
	CMP #$1C
	BCC +

	LDA #$40
	STA $2126
	LDA #$C0
	STA $2127
	LDA #$1F
	STA $212E
	STA $212F

	LDA.B #$03
	STA $41    
	LDA.B #$33 
	STA $42    
	LDA.B #$23
	STA $43    
	LDA.B #$12
	STA $44
	LDA #$20
	STA $40
	
+	LDA #$09
	STA $3E
	JML $00968D|!bank
	
                    