;===============================================================
; Dedicated file for dealing with bosses.
;===============================================================

;- Iggy/Larry lava stream widescreen
;===================================

pushpc
	org $03C0CD
		JML prepare_lava_stream
pullpc

prepare_lava_stream:
	; render normal tiles
	STZ $00	
	LDX #$13
	LDY #$B0
	JSL $03C0D3|!bank
	
	; render left tiles
	LDA #$00-($06*$10)
	STA $00
	
	LDX #$05
	LDY #$B0
	JSL CODE_03C0D3
	
	; render right tiles
	STZ $00
	
	LDX #$05
	; modified algorithm to use $0200+x
	
CODE_03C0D3:                        ;           |
	STX $02                     ;$03C0D3    |
	LDA $00                     ;$03C0D5    |\ 
	STA.w $0200|!addr,Y         ;$03C0D7    ||
	CLC                         ;$03C0DA    || Store X position to OAM.
	ADC.b #$10                  ;$03C0DB    ||
	STA $00                     ;$03C0DD    |/
	LDA.b #$C4                  ;$03C0DF    |\ Store Y position to OAM.
	STA.w $0201|!addr,Y         ;$03C0E1    |/
	LDA $64                     ;$03C0E4    |\ 
	ORA.b #$09                  ;$03C0E6    || Store YXPPCCCT to OAM.
	STA.w $0203|!addr,Y         ;$03C0E8    |/
	PHX                         ;$03C0EB    |
	LDA $14                     ;$03C0EC    |\ 
	LSR                         ;$03C0EE    ||
	LSR                         ;$03C0EF    ||
	LSR                         ;$03C0F0    ||
	CLC                         ;$03C0F1    || Store tile number to OAM.
	ADC.l $03C0B6,X             ;$03C0F2    ||
	AND.b #$03                  ;$03C0F6    ||
	TAX                         ;$03C0F8    ||
	LDA.l $03C0B2,X             ;$03C0F9    ||
	STA.w $0202|!addr,Y         ;$03C0FD    |/
	TYA                         ;$03C100    |
	LSR                         ;$03C101    |
	LSR                         ;$03C102    |
	TAX                         ;$03C103    |
	LDA.b #$03                  ;$03C104    |\ Store size to OAM as 16x16.
	STA.w $0420|!addr,X         ;$03C106    |/
	PLX                         ;$03C109    |
	INY                         ;$03C10A    |\ 
	INY                         ;$03C10B    ||
	INY                         ;$03C10C    || Loop for all of the tiles.
	INY                         ;$03C10D    ||
	DEX                         ;$03C10E    ||
	BPL CODE_03C0D3             ;$03C10F    |/
	RTL                         ;$03C111    |

;- Lemmy/Wendy - add one extra pipe
;==================================

pushpc
	; x position list for lemmy/wendy
	org $03CC38
		db $18+16,$38+16,$58+16,$78+16,$98+16,$B8+16,$D8+16,$08
	    
	; y position list for lemmy
	org $03CC40
		db $40,$50,$50,$40,$30,$40,$50,$30

	; random positions picker
	org $03CC5A
		; lemmy/wendy
		db $00,$01,$02,$03,$04,$05,$06,$07
		db $00,$01,$02,$03,$04,$05,$06,$07
		; dummy 1
		db $02,$03,$04,$05,$06,$07,$00,$01
		db $02,$03,$04,$05,$06,$07,$00,$01
		; dummy 2
		db $04,$05,$06,$07,$00,$01,$02,$03
		db $04,$05,$06,$07,$00,$01,$02,$03
pullpc

;- Bowser - make level interaction restricted
;============================================

pushpc
	org $009A17
		PHA
		JSR $9A1F
		JML rerender_if_bowser
		
	warnpc $009A1F
pullpc

rerender_if_bowser:
	; restore
	PLA
	STA $96
	
	LDA $0D9B|!addr
	CMP #$C1
	BNE .end
	
	; make sure the 2nd and forward screens
	; can't be interacted at all (fill with 0025)
	LDY #$10
.loop
	if !sa1 == 0
		LDA #$25
		STA $7EC9B0,x
		LDA #$00
		STA $7FC9B0,x
	else
		LDA #$25
		STA $40C9B0,x
		LDA #$00
		STA $41C9B0,x	
	endif
	
	DEX
	BNE .loop
	
.end
	; return
	JML $009283|!bank

;- Ludwig support
;================

pushpc
	; position when Ludwig should act.
	org $01CE36
		CMP.b #$7E-!extra_columns
pullpc

; TO DO: fix Ludwig background

;- Bowser's bowling ball
;=======================

pushpc
	org $03B193
		JSL get_out_of_widescreen
pullpc

; make the bowling ball fall whenever it's outside
; widescreen area...
get_out_of_widescreen:
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	SEC
	SBC $1A
	CMP #$0000-12
	BMI .outside
	CMP #$0100-4
	BPL .outside
	SEP #$20
.inside
	; restore
	LDA !D8,x
	CMP #$B0
	RTL
	
.outside
	CLC
	SEP #$20
	RTL
	
;- Bowser's arena
;================

; MAXTILE ROUTINE START
if !sa1 == 1

pushpc
	org $03B4AD
		LDA $190D|!addr
		STA $0F
		JML configure_max_tile
		
	org $03B4E0
		PHY
		LDY $0A
		INC $0A
		LDA #$02
		STA $0000,y
		PLY
	; print pc
	warnpc $03B4EB
		
	org $03B4F2
		LDX #$000F
		BRA +
		
	org $03B4FA
		+
		
	org $03B4FA
		LDA.l $03B48C,x
		SEC
		SBC $1A
		STA $6300,y
		
		LDA.l $03B49C,x
		SEC
		SBC $1C
		JML support
		
	org $03B530
		JML end_max_tile
		
	org $03B51F
		LDY $0A
		INC $0A
		LDA #$02
		STA $0000,y
	print pc
	warnpc $03B528
	
	;org $03B500
	;	STA $6300,y
		
	;org $03B509
	;	STA $6301,y
		
	org $03B514
		STA $6302,y
		
	org $03B51B
		STA $6303,y
pullpc

support:
		STA $6301,y
		
	LDA #$08
	CPX #$0006
	JML $03B510

end_max_tile:
	PLB
	SEP #$10
	JML $03B56A
	
configure_max_tile:
	REP #$30
	; get 17+16 tiles
	LDY #$0011+$0010
	; maximum priority
	LDA #$0000
	JSL maxtile_get_slot
	
	LDA $3100
	SEC
	SBC #$6300
	STA $08
	LDA $3102
	STA $0A
	
	SEP #$20
	PHB
	LDA #$40
	PHA
	PLB
	
	STZ $01
	
	LDY $08
	LDX #$0010
	JML $03B4BF

endif

;- Bowser - safe distance
;========================

pushpc
	org $03AB94
		JML safe_distance
		
pullpc

safe_distance:
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$21
	ADC #$000F
	SEC
	SBC $1A
	;STA $00
	CMP #$0000+$0030
	BMI .go_to_right
	CMP #$0100-$0030
	BPL .go_to_left
	SEP #$20
	
.done
	;debug: track bowser's position
	;LDA $00
	;STA $6200
	;LDA #$50
	;STA $6201
	;STA $6202
	;STA $6203
	;LDA #$02
	;STA $6420

	LDA $AB62,y
	STA !B6,x
	JML $03AB99|!bank
	
.go_to_right
	SEP #$20
	LDY #$00
	BRA .done
	
.go_to_left
	SEP #$20
	LDY #$01
	BRA .done
