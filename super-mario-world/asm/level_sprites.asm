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
		
	org $01BF0F
		ORA.w !sprite_wide_flag_table,x
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
	
  