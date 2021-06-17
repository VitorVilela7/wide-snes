;===============================================================
; Dedicated Widescreen overworld patch. Covers everything
; with the exception of windowing HDMA effects taken care by
; windowing_effects.asm
;
; Special thanks to Medic for the original widescreen overworld
; patch, which while it had another context it was useful for
; adding real widescreen support to the game. See also:
; https://www.smwcentral.net/?p=section&a=details&id=12773
;
; This file is universal, works for any resolution from 288x224
; to 512x224, thanks for the overworld border and window effects
;===============================================================

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

;- make the overworld clouds work correctly on widescreen
;========================================================

pushpc
	; initial cloud x position spawn related to the layer 1
	; x position. Make these always spawn "behind"
	; layer 1 x position, so they won't appear out of sudden
	; on screen.
	
	; only positions that has higher chances of spawning
	; inside screen (given y positions at $04F6E8) were
	; shifted by -64
	org $04F6D8
		dw $FFF0-64, $0020, $00C0, $FFF0-64
		dw $FFF0, $0080, $00F0-64, $0000
	
	; increase spawn range
	org $04FB4C
		ADC #$0060
		CMP #$0180

pullpc

;- make the mario/luigi overworld sprites set 9th x-bit
;======================================================

pushpc
	; make both mario and luigi render even if they are
	; offscreen.
	org $048639
		BRA +
		NOP #2
	+
		PHA
	
	org $04865F
		BRA +
		NOP #2
	+
		PHA

	org $0486E1
		JML apply_main_player_high_bit
		
	org $04876E
		JML apply_other_player_high_bit
		
	org $04870C|!bank
		BNE free_stack
		
	org $048741|!bank
		BEQ free_stack
		
	org $048748|!bank
		BCS free_stack
		
	org $04874F|!bank
		BCS free_stack
		
	; in case the other player is not drawn, use the unused space
	; for freeing up stack space.
	org $048781|!bank
		free_stack:
			; we don't know if it's 16-bit mode or not
			SEP #$30
		.axy
			PLA
			PLA
			PLA
			PLA
			RTS
			
		warnpc $048788|!bank
	
pullpc

; we take the initial relative x position, offset to the
; initial tile position and adjust 9th bit based on left
; and right tiles.

; put repetitive code on a macro
macro apply_offscreen_correction(pos, use_table, offset)
	REP #$21
	LDA <pos>,s
	
	if <use_table> == 1
		SBC.l overworld_player_offsets,x
	endif
	
	if <offset> != 0
		CLC
		ADC.w #<offset>
	endif
	
	SEP #$20
	
	XBA
	AND #$01
endmacro

apply_main_player_high_bit:
	; if main player has yoshi, store animation number on x, else store 0.
	LDA $0DD6|!addr
	LSR
	TAY
	LSR
	TAX
	LDA $0DBA|!addr,x
	BEQ +
	LDA $1F13|!addr,y
+	TAX
	
	; deals when there's player + yoshi, left tile
	%apply_offscreen_correction($03, 1, 0)
	STA $0447|!addr
	STA $0449|!addr
	
	; deals when there's player + yoshi, right tile
	%apply_offscreen_correction($03, 1, 8)
	STA $0448|!addr
	STA $044A|!addr

	; general case (optimized)
	; carry calculation for left side
	LDA $03,s
	SEC
	SBC #$08

	; this is for the right side tiles (x - 8 + 8)
	LDA $04,s
	AND #$01
	STA $044C|!addr
	STA $044E|!addr
	
	; this is for the left side tiles (x - 8)
	BCS +
	EOR #$01
+	STA $044B|!addr
	STA $044D|!addr
	
	JML $0486F9|!bank

apply_other_player_high_bit:
	; if other player has yoshi, store animation number on x, else store 0.
	LDA $0DD6|!addr
	EOR #$04
	LSR
	TAY
	LSR
	TAX
	LDA $0DBA|!addr,x
	BEQ +	
	LDA $1F13|!addr,y
+	TAX
	
	; deals when there's player + yoshi, left tile
	%apply_offscreen_correction($01, 1, 0)
	STA.W $044F|!addr
	STA.W $0451|!addr

	; deals when there's player + yoshi, right tile
	%apply_offscreen_correction($01, 1, 8)
	STA.W $0450|!addr
	STA.W $0452|!addr
	
	; carry calculation for left side
	LDA $01,s
	SEC
	SBC #$08

	; this is for the right side tiles (x - 8 + 8)
	LDA $02,s
	AND #$01
	STA.W $0454|!addr
	STA.W $0456|!addr
	
	; this is for the left side tiles (x - 8)
	BCS +
	EOR #$01
+	STA.W $0453|!addr
	STA.W $0455|!addr
	
	; end
	JML free_stack_axy
	
overworld_player_offsets:
	; special treatment when (it's left or right) and (if using yoshi)
	; -1 is to compensate the SBC with carry clear.
	dw $0008-1, $0008-1, $0000-1, $0010-1
	dw $0008-1, $0008-1, $0008-1, $0008-1
	dw $0008-1, $0008-1, $0008-1, $0008-1

;- make overworld sprites render correctly on screen edges
;=========================================================

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
		JML $04FB15|!bank
	
	.dont_render
		JML $04FB36|!bank
		
;- [!] switch palace blocks
;===========================

pushpc
	org $04F31A
		JSL cache_palace_color

	org $04F34C
		JML palace_blocks_check_range
pullpc

cache_palace_color:
	; restore
	STA $0F

	; current palace color -> yxppCCCt
	; useful speedup without SA-1
	LDA $13D2|!addr
	DEC
	ASL
	ORA #$30
	STA $0E
	
	; restore
	LDX #$00
	RTL

palace_blocks_check_range:
	; draw only if y < 224
	CMP #$00E0
	BCS .no
	STA $02
	
	; draw only if -15 < x < 256
	LDA $00
	CMP #$0100
	BCC .ok
	CMP #$FFF0
	BCC .no
.ok
	SEP #$20
	
	LDY $0F
	STA $0340|!addr,y
	
	LDA $02
	STA $0341|!addr,y
	
	LDA #$E6
	STA $0342|!addr,y
	LDA $0E
	STA $0343|!addr,y
	
	TYA
	LSR
	LSR
	TAY
	
	LDA $01
	AND #$01
	ORA #$02
	JML $04F375|!bank
	
.no
	SEP #$20
	JML $04F378|!bank
	
;- layer 2 fade reveal
;=====================

pushpc
	; copy $00 to $0E and zero $0F
	org $04EAC9
		JML setup_reset_wide_l2_reveal_x
		
	; copy $00 to $0E and zero $0F
	org $04EAE9
		JSL reset_wide_l2_reveal_x
		
	; increment $0E by 16-bit and assign
	; x position msb.
	org $04EB16
		JSL increment_l2_reveal_x
		
	; skip zering oam extra properties
	org $04EB30
		BRA +
		
	org $04EB38
		+
pullpc

setup_reset_wide_l2_reveal_x:
	LDA.w $1B83|!addr			;$04EC6F	|
	CLC					;$04EC72	|
	SBC $20					;$04EC73	|
	STA $01					;$04EC75	|

	LDA.w $1B82|!addr
	SEC					;$04EC6A	|
	SBC $1E					;$04EC6B	|
	STA $00					;$04EC6D	|
	STA $0E
	STZ $0F
	
	REP #$30
	JML $04EACE|!bank
	
reset_wide_l2_reveal_x:
	STA $03
	
	LDA $00
	STA $0E
	STZ $0F
	
	RTL

increment_l2_reveal_x:	
	INX

	PHY
	REP #$20
	TYA
	LSR
	LSR
	TAY
	SEP #$20
	LDA $0F
	AND #$01
	STA $0474|!addr,y
	PLY
	
	REP #$21
	LDA $0E
	ADC #$0008
	STA $0E
	SEP #$20
	RTL


;- add universal overworld border (works with any size)
;======================================================

pushpc	
	org $0084D0+6
		dl overworld_border
		
pullpc

overworld_border:
	incbin "overworld-universal.stim"
