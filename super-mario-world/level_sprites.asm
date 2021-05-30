; Dedicated code for improving level sprites
; For widescreen SMW support

; Special thanks:
; - MarioE
; - Tattletale
; - LX5
; - Thomas
; - RussianMan
; - Romi

; TO DO: cluster sprites
; TO DO: regular sprites
; TO DO: extended sprites
; TO DO: shooter sprites
; TO DO: generator sprites (adjust spawn position)

; TO DO: check bounce sprites on vertical levels. $02925C
; TO DO: add koopaling hair fix
; TO DO: add "S" from MARIO START
; TO DO: add Luigi graphics
; TO DO: test more carefully yoshi eggs on screen edges.
; TO DO: minor star position generation fixes.
; TO DO: podoboo flames position checks.

; DONE: smoke sprites
; DONE: spinnning coin sprites (from ? block)
; DONE: score sprites
; DONE: mario turning around smoke effect
; DONE: bounce sprites
; DONE: quake sprites
; DONE: minor extended sprites

; DONE for spinning: glitter effect (using smoke sprites as proxy).
; DONE for spinning: score [10pts] sprite support

;- RAM addresses definitions
;===========================

; x position high byte for smoke sprites - given by smoke_position.asm
!smoke_x_high = $18C9

; set if "x position" is on widescreen area. Used as alternative for $15A0.
!sprite_wide_flag_table = $1FD6

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

;- Smoke sprites
;===============

; Most of the logic is dealt by smoke_position.asm

; - Score sprites
;================

pushpc
	; Rewrite general algorithm for using better the
	; 65c816 architecture and handle offscreen positions.
	
	org $02AE61
		score:
			LDA $16ED,x
			STA $0E
			LDA $16F3,x
			STA $0F
			REP #$20
			LDA $001C,y
			STA $02
			LDA $001A,y
			STA $04
			
			LDA $0E
			SEC
			SBC $04
			CMP.w #$0000-!extra_columns-$0020
			BMI .return
			CMP.w #$0100+!extra_columns+$0020
			BMI .ok
		.return
			SEP #$20
			RTS
			
			NOP #2
		
		.ok
			STA $0E
			SEP #$20

		
	; print pc
	warnpc $02AE8F
	
	org $02AEB1
		score_draw_two:
			LDA $0E
			STA $0200,y
			CLC
			ADC #$08
			STA $0204,y
			STZ $0D
			ROL $0D

	; print pc
	warnpc $02AEC0
	
	; unused "coin" score sprite support removed...
	org $02AEEC
		score_draw_msb:
			LDA $0F
			AND #$01
			STA $0420,y
			EOR $0D
			STA $0421,y
			RTS
	
	; print pc	
	warnpc $02AEFB
		

pullpc

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

;- Bounce sprites
;================

pushpc
	; Rewrite GFX routine to compress a few code sections
	; in a manner that I can check of the widescreen area
	; and draw in the correct area without using freespace.
	
	; Note that Y >= #$FFF0 should be considered, since it'll
	; just disappear, but it should be extremely rare to
	; trigger this in game to be worth allocating freespace.
	
	org $029201
		bounce_gfx:
			LDA $16A1,x	
			SEC
			SBC $001C,y
			STA $01
			LDA $16A9,x	
			SBC $001D,y		
			BNE .return
		
			LDA $16A5,x
			SEC
			SBC $001A,y
			STA $00
			XBA
			
			LDA $16AD,x
			SBC $001B,y
			XBA
			
			REP #$20
			CMP.w #$0000-!extra_columns-$0020
			BMI .return
			CMP.w #$0100+!extra_columns+$0020
			BMI .ok
			
		.return
			SEP #$20
			RTS
			
			NOP #2
		
		.ok
			AND #$0100
			ORA #$0200
			STA $02
		
			LDY $91ED,x
			LDA $00
			STA $0200,y
			
			SEP #$20
	
	; print pc
	warnpc $029246
	
	org $02925C
		bounce_set_msb:
			LDA $03
	
pullpc

;- Quake sprites
;===============

pushpc
	; Quake sprites doesn't appear on screen, it's an invisible
	; box that comes when you hit any block which if any sprite
	; touches that invisible square it's stomped immediately.
	
	; The only thing I noticed it's this typo, storing to high Y
	; instead of high X. So it's fixed now.
	
	org $0286D6
		STA $16D5,y

pullpc

;- Minor extended sprites
;========================

pushpc
	; hatch yoshi egg animatino
	org $01F7CD
		JSL minor_load_spr_x
		
	org $01F7FF
		JSL minor_store_spr_x
		NOP

pullpc

minor_load_spr_x:
	; restore
	LDA $E4,x
	STA $00
	
	; load sprite x position high
	LDA $14E0,x
	STA $01
	RTL
	
minor_store_spr_x:
	; restore
	STA $1808,x
	
	; put logic on sprite high position
	LDA $01
	ADC #$00
	STA $18EA,x
	
	; restore
	LDA $02
	RTL
	
pushpc
	; star power sparkles
	org $0285B6
		JSL minor_load_spr_x_star
		
	org $0285DB
		JML minor_store_spr_x_star
		
	org $028602
		JSL podoboo_flame_sign_extension
		
	; sign extended...
	org $02860E
		ADC $00

pullpc

minor_load_spr_x_star:
	LDY #$00
	CMP #$00
	BPL +
	DEY
+
	CLC
	ADC $94
	STA $02
	
	TYA
	ADC $95
	STA $03
	
	RTL
	
minor_store_spr_x_star:
	; restore
	STA $1850,y
	
	LDA $03
	STA $18EA,y
	
	; end/restore
	RTL
	
podoboo_flame_sign_extension:
	STZ $00
	
	SEC
	SBC #$03
	BPL +
	DEC $00
+	
	CLC
	RTL
	
pushpc
	; unused yoshi smoke
	org $028C79
		JSL minor_x_check
		NOP
		
	org $028CB2
		LDA $0F
		
	; boo stream
	org $028D0A
		JSL minor_x_check
		NOP
		
	org $028D3C
		LDA $0E
		
	; water splash
	org $028D4F
		JSL minor_x_calc_check
		
		BRA +
		NOP #4
	+
	
	; print pc
	warnpc $028D59
	
	; water splash
	org $028D97
		JSL minor_water_x_correction
		
	org $028DCA
		LDA $0E
		
	; rip van fish 'zzz'
	org $028E23
		JSL minor_x_calc_check
		BEQ +
		
		BRA rip_van_fish_erase
		NOP #4
	
	+	LDA $00
		
	;print pc
	warnpc $028E31
	
	; rip van vish 'zzz' x msb
	org $028E6D
		LDA $0F
		
	org $028E76
		rip_van_fish_erase:
		
	org $028E4B
		JML abort_rip_van_fish_if_timeout
		
	org $02C10E
		JSL spawn_rip_van_fish_zs
		NOP
	
	; cracked yoshi egg
	org $028EA4
		JSL minor_x_calc_check
		BNE minor_yoshi_egg_stop
		
		LDA #$00
		LDA $00
		
	; print pc
	warnpc $028EAE
	
	; cracked yoshi egg x msb
	org $028EC6
		LDA $0F
		
	org $028ED7
		minor_yoshi_egg_stop:
		
	; "small star" / "glitter"
	org $028EE4
		JSL minor_x_calc_check
		BNE minor_star_erase
		
		LDA #$00
		LDA $00
		
	; print pc
	warnpc $028EEE
		
	org $028ED7
		minor_star_erase:
		
	; minor star x msb
	org $028F25
		LDA $0F
		
	; podoboo flames
	org $028F2F
		JSL minor_x_calc_check
		BNE podoboo_flames_erase
		
		BRA +
		NOP #4
	+
		
	; print pc
	warnpc $028F3B
	
	org $028F50
		LDA $00
		STA $0200,y
		
		BRA +
		NOP #2
	+
		
	; print pc
	warnpc $028F59
	
	; podoboo flames x msb
	org $028F81
		LDA $0F
		
	org $028F87
		podoboo_flames_erase:
		
	; the brick particles when you break a turn block
	; with a spin jump
	org $028FED
		JML minor_brick_check
	
	; minor brick x msb
	org $029027
		LDA $0F
		
	; $02990F is already covered by smoke_position.asm
	
pullpc
		

minor_x_check:
	LDA $18EA,x
	SBC $1B
	STA $01
	
	REP #$20
	LDA $00
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
	
.return
	SEP #$20
	LDA #$01 ; FAIL
	RTL

.ok
	SEP #$20
	LDA $01
	AND #$01
	STA $0F
	ORA #$02
	STA $0E
	
	LDA #$00 ; OK
	RTL
	
minor_x_calc_check:
	LDA $1808,x
	SEC
	SBC $1A
	STA $00
	
	BRA minor_x_check
	
minor_water_x_correction:
	STA $00
	
	LDA $18EA,x
	SBC $1B
	AND #$01
	ORA #$02
	STA $0E
	
	LDA $00
	RTL
	
spawn_rip_van_fish_zs:
	ADC #$06
	STA $1808,y
	
	LDA $14E0,x
	ADC #$00
	STA $18EA,y
	RTL

abort_rip_van_fish_if_timeout:
	CMP #$14
	BEQ .undraw
	JML $028E4F|!bank
	
.undraw
	; rip van fish 'z' if lifespan timeouts,
	; it removes itself without setting $0420...
	TYA
	LSR
	LSR
	TAY
	; at least set the tile msb
	LDA $0F
	STA $0420,y

	JML $028E76|!bank

minor_brick_check:
	XBA
	LDA $01
	REP #$20
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	JML $028F87|!bank
.ok
	SEP #$20
	XBA
	AND #$01
	STA $0F
	
	LDA $01
	JML $028FF1|!bank

;- Extended sprites
;==================

; TO DO: $01FD16

; Volcano Lotus: $029B54
pushpc
	org $029B5C
		JSL extended_x_test
		NOP
		
	org $029BA0
		LDA $0F
pullpc

extended_x_test:
	LDA $1733,x
	SBC $1B
	XBA
	LDA $00
	REP #$20
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	LDA #$01
	RTL
.ok
	SEP #$20
	XBA
	AND #$01
	STA $0F
	
	LDA #$00
	RTL

; TO DO: $029D04
; Unused extended sprite - ignored: $029DC7
; TO DO: $029EA0

; General / fireball / mode 7: $02A05A
; General / fireball / regular: $02A1B1
pushpc
	; mode 7 case
	org $02A05A
		JML extended_x_test_2
		
	org $02A0A0
		LDA $0F
		
	org $02A1B1
		LDA $1733,x
		XBA
		LDA $171F,x
		REP #$20
		JML extended_x_test_3
		
	; print pc
	warnpc $02A1C0
	
	org $02A208
		LDA $0F
pullpc

extended_x_test_2:
	LDA $1733,x
	XBA
	LDA $171F,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	JML $02A0A9|!bank

.ok
	SEP #$20
	XBA
	AND #$01
	STA $0F
	XBA
	JML $02A064|!bank
	
extended_x_test_3:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	JML $02A211|!bank

.ok
	SEP #$20
	STA $01
	XBA
	AND #$01
	STA $0F

	JML $02A1C0|!bank
	
; Baseball / bone extended sprites: $02A271
pushpc
	org $02A271
		LDA $1733,x
		XBA
		LDA $171F,x
		REP #$20
		SEC
		JML baseball_x_check
		
	; print pc
	warnpc $02A280
	
	org $02A2B9
		LDA $0F

pullpc

baseball_x_check:
	SBC $1A
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	XBA
	; get high byte and XOR with direction
	; to decide if it'll get erased or not.
	JML $02A280|!bank

.ok
	SEP #$20
	STA $00
	XBA
	AND #$01
	STA $0F
	JML $02A287|!bank

; Puff of smoke - regular: $02A36C
; Puff of smoke - mode 7: $02A3B4
pushpc
	org $02A36C
		LDA $1733,x
		XBA
		LDA $171F,x
		REP #$20
		JML puff_smoke_x_check
		
	; print pc
	warnpc $02A379
	
	org $02A3B4
		LDA $1733,x
		XBA
		LDA $171F,x
		REP #$20
		JML puff_smoke_x_check_mode7
		
	print pc
	warnpc $02A3C1
	
	org $02A3A5
		LDA $0F
		
	org $02A3F0
		LDA $0F
	
pullpc

puff_smoke_x_check:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	
	; erase
	JML $02A211|!bank
	
.ok
	SEP #$20
	STA $0200,y
	XBA
	AND #$01
	ORA #$02
	STA $0F
	
	JML $02A379|!bank
	
; TO DO: Behavior still needs to be tested. Do after testing Roy/Morton.
puff_smoke_x_check_mode7:
	SEC
	SBC $1A
	CMP.w #$0000-!extra_columns-$0020
	BMI .return
	CMP.w #$0100+!extra_columns+$0020
	BMI .ok
.return
	SEP #$20
	
	; erase
	JML $02A211|!bank
	
.ok
	SEP #$20
	STA $0300,y
	XBA
	AND #$01
	ORA #$02
	STA $0F
	
	JML $02A3C1|!bank

; TO DO: $02A42C --> note that smoke high bytes might have done something.

;- Regular sprites (offscreen flag - $15A0)
;==========================================

pushpc
	org $01A36B
		get_draw_info_1:
			STZ.w !sprite_wide_flag_table,x
		
			LDA $14E0,x
			XBA	
			LDA $E4,x
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
		
			LDA $14E0,x
			XBA	
			LDA $E4,x
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
		
			LDA $14E0,x
			XBA	
			LDA $E4,x
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
	CMP.w #$0000-!extra_columns
	BMI .offscreen
	CMP.w #$0100+!extra_columns
	BMI .ok
	
.offscreen
	INC $15A0,x

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
	