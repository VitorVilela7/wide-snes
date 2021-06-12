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
	ADC #$0000
	SEP #$20

	JML $00CA79|!bank

; Configure x position but for keyhole animation
pushpc
	org $00C4DD
		JML set_up_keyhole_x_pos
		
	org $00C470
		; Make the keyhole window animation slighter
		; bigger (by 11%)
		db $A0,$00,$A0,$00
pullpc

set_up_keyhole_x_pos:
	LDA $1436|!addr
	SEC
	SBC $1A
	CLC
	ADC.w #$0004+$0080
	
	BPL +
	LDA #$0000
+	CMP #$01FF
	BMI +
	LDA #$01FF
+
	LSR
	ADC #$0000
	SEP #$20
	
	JML $00C4E8|!bank

; Calculate products
pushpc
	if !sa1 == 0
		org $00CC51
			JSL circle_window_halve
			PLY
			RTS
	else
		org $00CC14
			CLV
			PHY
			LDA #$01
			STA $2250
			
			LDA $01
			BPL +
			LSR
			SEP #$40
		+	STA $2252
			STZ $2251
			
			LDA $7433
			STA $2253
			STZ $2254
			
			REP #$20
			LDA $2306
			BVS +
			LSR
		+	TAY
			
			SEP #$20
			STZ $2250
			LDA $7433
			LSR
			STA $2251
			STZ $2252
			
			LDA ($06),y
			STA $2253
			STZ $2254
			
			JML finish_circle_sa1
			
		finish_circle_back:
			LDA $2307
			STA $02
			
			PLY
			RTS
		
		; print pc
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
	finish_circle_sa1:
		LDA $2307
		STA $03
		
		LDA ($04),y
		STA $2253
		STZ $2254
		JML finish_circle_back
endif

;- windowing spotlight HDMA effect
;=================================

pushpc
	; left lamp edge
	org $03C538
		LDA.b #$78+4+1
	; right lamp edge
	org $03C53D
		LDA.b #$87-4
		
	; since 512px width represented in increments
	; by 2, the lamp will run twice faster.
	
	; so let's make it cover the "double" space as
	; compensation.
	
	; we also increase the lamp expansion size by the
	; widescreen resolution. Looks cooler for me!
	
	; original values: $00,$90 (-128, +16)
	; 512-width ver: $40,$88
	; compensation: $00,$48
	org $03C52E
		LDA.b #$00
	org $03C533
		LDA.b #$48*(!screen_size)/256
		
	; original values: $FF,$90 (+127, +16)
	; 512-width ver: $BF,$88
	; compensation: $FF,$48
	org $03C491
		db $FF
		db $48*(!screen_size)/256
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

