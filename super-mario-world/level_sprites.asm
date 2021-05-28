; Dedicated code for improving level sprites
; For widescreen SMW support

; TO DO: cluster sprites
; TO DO: regular sprites
; TO DO: bounce sprites
; TO DO: quake sprites
; TO DO: extended sprites
; TO DO: shooter sprites
; TO DO: smoke sprites
; TO DO: spinnning coin sprites (from ? block)
; TO DO: minor extended sprites
; TO DO: generator sprites (adjust spawn position)

; TO DO: add koopaling hair fix
; TO DO: add "S" from MARIO START
; TO DO: add Luigi graphics

;- RAM addresses definitions
;===========================

; x position high byte for smoke sprites.
!smoke_x_high = $18C5

;- Spinning coins
;================

pushpc
	org $0299E3
		spinning_despawn:
			; make sure AXY is 8-bit
			SEP #$30
			STZ $17D0,x
			RTS

		warnpc $0299E9
		
	org $029A6D
		spinning_return:
		
	org $029A18
		; optimize NES legacy to SNES
		LDA $17D4,x
		CMP $02
		LDA $17E8,x
		SBC $001D,y
		BNE spinning_return
	
		; 16-bit calculation
		JSL spinning_wide
		
		; widescreen bounds
		CMP.w #$0000-!extra_columns
		BMI spinning_despawn
		CMP.w #$0100+!extra_columns
		BPL spinning_despawn
		
		SEP #$20
	
	; print pc
	warnpc $029A35
	
	org $029A5C
		JSL spinning_load_high
		
	org $029A7A
		JSL spinning_add4
		STA $0E
	
	; print pc
	warnpc $029A80
	
	org $029A9E
		LDA $0E

pullpc

spinning_wide:
	LDA $17E0,x
	SEC
	SBC $03
	STA $00

	LDA $17EC,x
	SBC $001B,y
	STA $0E
	XBA
	LDA $00

	REP #$20
	RTL

spinning_load_high:
	; load MSB x position + tile size
	LSR
	TAY
	LDA $0E
	AND #$01
	ORA #$02
	RTL
	
spinning_add4:
	STA $0200,y
	STA $0204,y
	LDA $0E
	ADC #$00
	AND #$01 ;mask it already for the MSB bit
	RTL

; TO DO for spinning: smoke sprites at 029AE5
; TO DO for spinning: score [10pts] sprite support

	