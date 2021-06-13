; Dedicated code for improving level sprites
; For widescreen SMW support

;- Horizontal/vertical level spawning range
;==========================================

pushpc
	; Make sprites X spawn range much larger than normal
	; db $D0,$00,$20
	org $02A7F6
		horz_range:
			db $D0-!extra_columns
			db $00
			db $20+!extra_columns
	    
	; Remap table if vertical level, to not break
	; vertical levels spawning.
	org $02A80C
		ADC.w vert_range,y
		
	; Mirror table to unused space, so vertical
	; levels still works as normal.
	org $02FFE2
		vert_range:
			db $D0
			db $00
			db $20
		
pullpc

;- SUB_OFF_SCREEN tables range for widescreen
;============================================

; Adjust off-screen routines
macro adjust_offscreen(v)
	if <v> >= $8000
		!r = <v>-!extra_columns

		assert !r >= $8000, "offscreen underflow error"
	else
		!r = <v>+!extra_columns

		assert !r <= $7FFF, "offscreen overflow error"
	endif

	db !r
	skip 8-1
	
	db (!r)>>8
	skip -8
endmacro

pushpc
	;SpriteOffScreen3:
	;	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
	;SpriteOffScreen4:
	;	db $01,$FF,$01,$FF,$01,$FF,$01,$FF

	org $01AC11
		%adjust_offscreen($0130)
		%adjust_offscreen($FFC0)
		%adjust_offscreen($01A0)
		%adjust_offscreen($FFC0)
		%adjust_offscreen($01A0)
		%adjust_offscreen($FFF0)
		%adjust_offscreen($0160)
		%adjust_offscreen($FF90)
		warnpc $01AC11+8
    
	;DATA_02D007:
	;	db $30,$C0,$A0,$C0,$A0,$70,$60,$B0
	;DATA_02D00F:
	;	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
	
	org $02D007
		%adjust_offscreen($0130)
		%adjust_offscreen($FFC0)
		%adjust_offscreen($01A0)
		%adjust_offscreen($FFC0)
		%adjust_offscreen($01A0)
		%adjust_offscreen($FF70)
		%adjust_offscreen($0160)
		%adjust_offscreen($FFB0)
		warnpc $02D007+8

	;DATA_03B83F
	;	db $30,$C0,$A0,$80,$A0,$40,$60,$B0
	;DATA_03B847
	;	db $01,$FF,$01,$FF,$01,$00,$01,$FF
	org $03B83F
		%adjust_offscreen($0130)
		%adjust_offscreen($FFC0)
		%adjust_offscreen($01A0)
		%adjust_offscreen($FF80)
		%adjust_offscreen($01A0)
		%adjust_offscreen($0040)
		%adjust_offscreen($0160)
		%adjust_offscreen($FFB0)
		warnpc $03B83F+8
pullpc

pushpc
	;DATA_02FEC5:
	;	db $40,$B0
	;DATA_02FEC7
	;	db $01,$FF
	;DATA_02FEC9
	;	db $30,$C0
	;DATA_02FECB
	;	db $01,$FF
	
	org $02FEC5
		db $40+!extra_columns
		db $B0-!extra_columns
	    
	org $02FEC9
		db $30+!extra_columns
		db $C0-!extra_columns
pullpc

; The following changes avoids the game out of sudden
; not drawing sprites anymore (even though they are active)
pushpc

	;CODE_01A385:        69 40 00      ADC.W #$0040
	;CODE_01A388:        C9 80 01      CMP.W #$0180
	org $01A385
		ADC.W #$0040+!extra_columns
		CMP.W #$0180+!extra_columns+!extra_columns
	    
	;CODE_01C9F9:        69 10 00      ADC.W #$0010
	;CODE_01C9FC:        C9 20 01      CMP.W #$0120
	org $01C9F9
		ADC.W #$0010+!extra_columns
		CMP.W #$0120+!extra_columns+!extra_columns

	;CODE_03B780:        69 40 00      ADC.W #$0040
	;CODE_03B783:        C9 80 01      CMP.W #$0180
	org $03B780
		ADC.W #$0040+!extra_columns
		CMP.W #$0180+!extra_columns+!extra_columns

	;CODE_02D398:        69 40 00      ADC.W #$0040
	;CODE_02D39B:        C9 80 01      CMP.W #$0180
	org $02D398
		ADC.W #$0040+!extra_columns
		CMP.W #$0180+!extra_columns+!extra_columns

pullpc

;- Smoke sprites
;===============

; Most of the logic is dealt by smoke_position.asm


;- Mario high position tweaks
;============================

; $7F / $81 checks
; NOTE: $81 is Y position, not interesting for widescreen.

pushpc
	org $00FD5A
		LDA #$00
	
	org $00FE50
		ORA #$00
	
	;$01C5AE skipped: feather fix.
	
	org $028AF5
		ORA #$00
	
	org $02CF5A
		ORA #$00
	
pullpc

;- Regular sprites (offscreen flag - $15A0)
;==========================================

pushpc
	org $01A36B
		get_draw_info_1:
			STZ.w !sprite_wide_flag_table,x
		
			LDA !14E0,x
			XBA
			if !sa1 == 1
				LDA ($EE)
			else
				LDA !E4,x
			endif
			REP #$20
			SEC
			SBC $1A
			BIT #$0100
			BEQ .not_wide
			INC.w !sprite_wide_flag_table,x
			
		.not_wide
			JSL test_offscreen
	
	; print pc
	warnpc $01A385
	
	org $02D37E
		get_draw_info_2:
			STZ.w !sprite_wide_flag_table,x
		
			LDA !14E0,x
			XBA
			if !sa1 == 1
				LDA ($EE)
			else
				LDA !E4,x
			endif
			REP #$20
			SEC
			SBC $1A
			BIT #$0100
			BEQ .not_wide
			INC.w !sprite_wide_flag_table,x
			
		.not_wide
			JSL test_offscreen
	
	; print pc
	warnpc $02D398
	
	org $03B766
		get_draw_info_3:
			STZ.w !sprite_wide_flag_table,x
		
			LDA !14E0,x
			XBA
			if !sa1 == 1
				LDA ($EE)
			else
				LDA !E4,x
			endif
			REP #$20
			SEC
			SBC $1A
			BIT #$0100
			BEQ .not_wide
			INC.w !sprite_wide_flag_table,x
			
		.not_wide
			JSL test_offscreen
	
	; print pc
	warnpc $03B780
	
pullpc

test_offscreen:
	CMP.w #$0000-!extra_columns-$0010
	BMI .offscreen
	CMP.w #$0100+!extra_columns
	BMI .ok
	
.offscreen
	INC !sprite_offscreen_flag_table,x

.ok
	CLC
	RTL

; modify sprites to use new flag
pushpc
	org $019DCC
		ORA.w !sprite_wide_flag_table,x
		
	org $019F51
		ORA.w !sprite_wide_flag_table,x
	
	; Magikoopa's wand, handled elsewhere.
	;org $01BF0F
	;	ORA.w !sprite_wide_flag_table,x
pullpc

;- Regular sprites (wings)
;=========================

; Note that goomba wings already works, because it uses
; the standard finish OAM routine.

; Koopa and question block wings
pushpc
	org $019E61
		JML wings_calc_high_x
		
	org $019E8D
		JML wings_set_high_x
		
pullpc

wings_calc_high_x:
	XBA
	LDA $00
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns
	BMI .ok
.return

	SEP #$20
	JML $019E93|!bank
	
.ok
	SEP #$20
	STA $0300|!addr,y
	
	JML $019E6F|!bank
	
wings_set_high_x:
	XBA
	AND #$01
	ORA.w $9E24,x
	STA $0460|!addr,y
	
	JML $019E93|!bank
	
; Yoshi wings
pushpc
	org $02BB50
		JML yoshi_wings_calc_high_x
		
	org $02BB7F
		JML yoshi_wings_set_high_x
		
pullpc

; The code is basically copy/paste from above,
; except it uses the lower half of OAM and
; different indexing tables.

yoshi_wings_calc_high_x:
	XBA
	LDA $00
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns
	BMI .ok
.return

	SEP #$20
	JML $02BB86|!bank
	
.ok
	SEP #$20
	STA $0200|!addr,y
	
	JML $02BB5E|!bank

yoshi_wings_set_high_x:
	XBA
	AND #$01
	ORA.l $02BB1F,x
	STA $0420|!addr,y
	
	JML $02BB86|!bank
	
;- Regular sprites (smushed)
;===========================

pushpc
	; run the finish OAM write instead of
	; setting up the extra OAM bits manually.
	org $01E74E
		LDY #$00
		LDA #$01
		JMP $B7BB
pullpc
	
;- Lakitu's cloud face
;=====================

pushpc
	org $01E963
		JML cloud_face_calculate_x
		
	org $01E97F
		LDA $0E
		
pullpc

cloud_face_calculate_x:
	LDA !sprite_wide_flag_table,x
	STA $0E

	LDA $14B0|!addr
	CLC
	ADC.b #$04
	BCS +
	JML $01E969|!bank
	
+	XBA
	LDA #$01
	EOR $0E
	STA $0E
	XBA
	JML $01E969|!bank

;- PEA/wall springboard
;======================

pushpc
	org $02CF82
		JSL pea_decide_horizontally
pullpc

macro sign_extend()
	AND #$80
	BEQ ?no_extend
	ORA #$7F
?no_extend:

endmacro

pea_decide_horizontally:
	ADC.b #$08
	CMP.b #$14
	BCS .end
	
	; $0300,y = $00 (8-bit unsigned) + $08 (8-bit signed)
	
	; $00 is sprite x - camera x; $7E is mario x - camera x
	; $7E - $00 = sprite x - camera x - (mario x - camera x)
	; = sprite x - camera x - mario x + camera x
	; = sprite x - mario x + $08 sign extended.
	
	; $08 must be sign extended
	LDA $08
	%sign_extend()
	PHA
	LDA $08
	PHA
	
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$21
	ADC $01,s
	SEC
	SBC $94
	CLC
	ADC.w #$0008-$0002
	CMP #$0014
	
	PLA
	SEP #$20
.end
	RTL
	
;- Aggressive finish OAM routine
;===============================

pushpc
	org $01B80D
		JML test_for_offscreen
pullpc

test_for_offscreen:
	REP #$20
	LDA $04
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .delete
	CMP.w #$0100+!extra_columns
	BMI .ok
	
.delete
	SEP #$20
	; trash the tile
	JML $01B833|!bank
	
.ok
	SEP #$20

	; move tile to widescreen but don't trash it.
	TYA
	LSR
	LSR
	TAX
	JML $01B811|!bank

;- Chained platform - remove if offscreen
;========================================

pushpc
	org $01C957
		JML chain_test_for_offscreen
pullpc

chain_test_for_offscreen:
	REP #$20
	LDA $04
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0010
	BMI .delete
	CMP.w #$0100+!extra_columns
	BMI .ok
	
.delete
	SEP #$20
	; trash the tile
	JML $01C97A|!bank
	
.ok
	SEP #$20

	; move tile to widescreen but don't trash it.
	TYA
	LSR
	LSR
	TAX
	JML $01C95B|!bank

;- Climibing net door - send unused tiles to offscreen
;=====================================================

pushpc
	; we can't multiply Y by 4 because SA-1 Pack
	; hijacks the LDY #$0C at $01BBFA
	
	org $01BBFF
		JML netdoor_scale

	org $01BC06
		LDA.b #$F0   
		STA.w !addr+$0201+(4*($0463-$0420)),Y
		STA.w !addr+$0201+(4*($0464-$0420)),Y		
		STA.w !addr+$0201+(4*($0465-$0420)),Y
		
	org $01BC11
		LDA.b #$F0
		STA.w !addr+$0201+(4*($0466-$0420)),Y
		STA.w !addr+$0201+(4*($0467-$0420)),Y
		STA.w !addr+$0201+(4*($0468-$0420)),Y

pullpc

netdoor_scale:
	TYA
	ASL
	ASL
	TAY

	PLA
	BEQ .return
	CMP #$02
	
	JML $01BC04|!bank

.return
	JML $01BC1C|!bank

;- Magikoopa's wand - widescreen
;===============================

pushpc
	org $01BEDB
		JML magikoopa_calc_wand_x
		
	org $01BF0D
		LDA $0F
		BRA +
	
	org $01BF12
		+
	
pullpc

magikoopa_calc_wand_x:
	ADC $BE6C,y
	SEC
	SBC $1A
	XBA
	
	LDA !14E0,x
	SBC $1B
	AND #$01
	STA $0F
	
	XBA
	JML $01BEE1|!bank
