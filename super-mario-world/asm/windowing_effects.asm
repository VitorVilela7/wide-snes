;===============================================================
; Responsible for windowing HDMA effects on widescreen mode.
;
; Windowing support is done universal, regardless of the
; widescreen resolution. This uses the 8-bit window registers,
; the low quality version but with support for any size.
;===============================================================

;- Circle/keyhole HDMA effect
;============================

; Configure x position to use 512/center offset system.
pushpc
	org $00CA74
		JML set_up_x_pos
		
pullpc

set_up_x_pos:
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
	SEP #$20

	JML $00CA79|!bank

pushpc
	; size calculation
	if !sa1 == 0
		org $00CC51
			JSL circle_window_halve
			PLY
			RTS
	else
		org $00CC14
			CLV				;
			PHY				;
			LDA #$01			;
			STA $2250			;
			LDA $01				;
			BPL +				;
			LSR				;
			SEP #$40			;
		+	STA $2252			;
			STZ $2251			;
			LDA $7433			;
			STA $2253			;
			STZ $2254			;
			NOP				;
			REP #$20			;
			LDA $2306			;
			BVS +				;
			LSR				;
		+	TAY				;
			SEP #$20			;
			STZ $2250			;
			LDA $7433			;
			STA $2251			;
			STZ $2252			;
			LDA ($06),y			;
			STA $2253			;
			STZ $2254			;
			JML Jump
		Back:	LDA $2307			;
			STA $02				;
			PLY				;
			RTS				;
		
		print pc
		warnpc $00CC5C
	endif
pullpc


if !sa1 == 0
	circle_window_halve:
		LDA $4217
		LSR
		STA $02
		
		LSR $03
		
		;A's value is used
		RTL
else
Jump:
	NOP				;
	LDA $2307			;
	STA $03				;
	LDA ($04),y			;
	STA $2253			;
	STZ $2254			;
	NOP				;
	JML Back			;
endif
	
; TO DO: spotlight
; TO DO: this still needs fixing (spotlight)

pushpc
	org $03C612
		NOP #3
pullpc

;- continue/save dialogs windowing HDMA
;======================================

pushpc
	org $04F453
		LSR
		
	org $04F46E
		STA $00
		ADC $1B89|!addr
		LSR
		AND #$FE
		TAX
		JSL set_save_window_side_right
	; print pc
	warnpc $04F47B

pullpc

set_save_window_side_right:
	LDA #$80
	SEC
	SBC $00
	RTL

;- overworld shrinking/expanding windowing HDMA
;==============================================

pushpc
	; effective OW area increases from 28 to 32 8x8 blocks.

	; window animation speed - horizontal axis
	org $04DB08
		dw -$0700/2*32/28
		dw $0700/2*32/28
		
	; minimum/maximum size
	org $04DB0C
		dw $0000/2*32/28
		dw $7000/2*32/28
		
	; initial size when it's the shrinking animation.
	org $049630
		LDA #$7000/2*32/28

pullpc

