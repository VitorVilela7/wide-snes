;===============================================================
; Cluster sprites
;===============================================================

; Note 1: : Ultrawide revision may be required.
; Note 2: Bonus game 1up is not needed of a widescreen version.


;- Reappearing Ghosts
;====================
; CODE_02F83D

if !sa1 == 1

pushpc
	org $02F880
		JML spread_boo_buddies
pullpc

spread_boo_buddies:
	STZ $2250
	LDA $00
	STA $2251
	STZ $2252
	REP #$21
	LDA.w #!screen_size
	STA $2253
	LDA $1A
	ADC $2307
	;SEC
	;SBC.w #!extra_columns
	SEP #$20
	STA $1E16|!addr,x
	XBA
	STA $1E3E|!addr,x
	
	JML $02F88F|!bank
endif

;- Sumo bros flame
;=================

; Aside from terrible interaction system, it's ready for
; widescreen/ultrawide.

;- Boo ring
;==========

; Note about ultrawide: $02FAD6
; As is it seems to be functional on regular
; widescreen.

;- Boo ceiling
;=============

; Note about ultrawide: $02FC9F

; Boo is transparent, but doesn't draw high bits:
pushpc
	org $02AAF6
		JSL spawn_more_rand
		NOP

	org $02FD4D
		JSL boo_get_x
		NOP #2
		
	org $02FD8C
		XBA
		NOP
pullpc

spawn_more_rand:
	LDA $148D|!addr
	CLC
	ADC $148E|!addr
	REP #$20
	BPL +
	ORA #$FFE0
	BRA ++
+	AND #$001F
++	STA $00
	SEP #$20
	
	LDA $1E16|!addr,x
	CLC
	ADC $00
	STA $1E16|!addr,x
	LDA $1E3E|!addr,x
	ADC $01
	STA $1E3E|!addr,x
	
	LDA $148E|!addr
	AND #$3F
	RTL

boo_get_x:
	LDA $1E3E|!addr,x
	XBA
	LDA $1E16|!addr,x
	REP #$20
	SEC
	SBC $1A
	
	; x position msb
	AND #$01FF
	; 16x16
	ORA #$0200
	SEP #$20
	RTL
	

;- Castle Candles
;================

pushpc
	org $02AA71
		; use 8 candles instead of 4
		; should make it work with 512px BGs
		LDX.b #$07
		
	org $02AA78
		JSL candles_high_bytes
		NOP #2

	org $02FA2B
		JML candles_grab_screen_x
	
	org $02FA59
		XBA
		NOP
		
	org $02FA5F
		RTS
pullpc

candles_low_x:
	db $10,$50,$90,$D0
	db $10,$50,$90,$D0
candles_high_x:
	db $00,$00,$00,$00
	db $01,$01,$01,$01

candles_high_bytes:
	LDA.l candles_low_x,x
	STA $1E16|!addr,x
	LDA.l candles_high_x,x
	STA $1E3E|!addr,x
	RTL
	
DATA_02FA0A:
	db $E0,$E4,$E8,$EC
	db $F0,$F4,$F8,$FC
	
candles_grab_screen_x:
	LDA.l DATA_02FA0A,x
	TAY
	
	LDA $1E3E|!addr,x
	XBA
	LDA $1E16|!addr,x
	REP #$20
	SEC
	SBC $1E
	AND #$01FF
	ORA #$0200
	SEP #$20
	
	JML $02FA34|!bank
