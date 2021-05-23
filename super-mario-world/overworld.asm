; Dedicated widescreen overworld patch
; Special thanks to Medic for the forcetask done together
; in https://www.smwcentral.net/?p=section&a=details&id=12773

; This is universal widescreen support and allows for any
; resolution from 288x224 to 512x224.

;- overworld maximum horizontal scrolling range
;==============================================

pushpc
	; scroll range is a bit higher ($0103) than expected ($0101)
	; this is intentional for the right most tile border don't touch
	; with the overworld border.
	
	; other values from this value not modified refers to UDLR
	; combinations and y positions.
	
	; this is when you're using START to scroll the main map.
	org $048221
		dw $0000,$0102+1,$0000,$0102+1
	
	; minimum layer 1 x position while scrolling and when standing
	org $049416
		dw $FFFF
		
	; maximum layer 1 x position while scrolling and when standing
	org $04941A
		dw $0102
	
	; interestingly, the submaps even with the original offsets works
	; as expected, because its tilemap is 16 pixels shifted to the right.
pullpc

;- overworld shrinking/expanding windowing hdma
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

pushpc
	; improve OW clouds
	
	; increase spawn range
	org $04FB4C
		ADC #$0060
		CMP #$0180

pullpc

pushpc
	; improve Mario and Luigi small sprites
	
pullpc

; - make overworld sprites render correctly on screen edges
;==========================================================

pushpc
	; this fixes benefits in particular "boo", "cloud" and "smoke"
	
	; render overworld sprite even if is x<0 but x>-32
	org $04FB11
		JML full_range_ow_sprites
		
	; push flags is no longer needed, thanks to the new
	; carry flag logic.
	org $04FB1E
		NOP
		
	; pull flags is not needed too.
	org $04FB27
		NOP
		
	; load size + 9th x bits.
	org $04FB2A
		LDA $0F

pullpc

full_range_ow_sprites:
	; carry is set if sprite is 16x16, otherwise 8x8
	; put #$02 to $0F if it's 16x16.
	ROL #2
	AND #$02
	STA $0F

	LDA $01
	BEQ .render_ok
	INC
	BNE .dont_render
	
	LDA $00
	CMP #$E0
	BCC .dont_render
	
	; set bit 0, so we know sprite is offscreen
	LDA #$01
	TSB $0F
	
	.render_ok
		JML $04FB15
	
	.dont_render
		JML $04FB36


;TO DO: check [!] blocks
;TO DO: fix mario/luigi sprites
;TO DO: add overworld border here

