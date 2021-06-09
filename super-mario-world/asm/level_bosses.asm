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
	STA.w $0200,Y               ;$03C0D7    ||
	CLC                         ;$03C0DA    || Store X position to OAM.
	ADC.b #$10                  ;$03C0DB    ||
	STA $00                     ;$03C0DD    |/
	LDA.b #$C4                  ;$03C0DF    |\ Store Y position to OAM.
	STA.w $0201,Y               ;$03C0E1    |/
	LDA $64                     ;$03C0E4    |\ 
	ORA.b #$09                  ;$03C0E6    || Store YXPPCCCT to OAM.
	STA.w $0203,Y               ;$03C0E8    |/
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
	STA.w $0202,Y               ;$03C0FD    |/
	TYA                         ;$03C100    |
	LSR                         ;$03C101    |
	LSR                         ;$03C102    |
	TAX                         ;$03C103    |
	LDA.b #$03                  ;$03C104    |\ Store size to OAM as 16x16.
	STA.w $0420,X               ;$03C106    |/
	PLX                         ;$03C109    |
	INY                         ;$03C10A    |\ 
	INY                         ;$03C10B    ||
	INY                         ;$03C10C    || Loop for all of the tiles.
	INY                         ;$03C10D    ||
	DEX                         ;$03C10E    ||
	BPL CODE_03C0D3             ;$03C10F    |/
	RTL                         ;$03C111    |
