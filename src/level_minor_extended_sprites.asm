;===============================================================
; Code responsible for adding minor extended sprites support
; for Widescreen SMW
;===============================================================

;- Regular sprites sparkling effect
;==================================

pushpc
	org $01B170
		STA $03
		BRA +
		
	org $01B17A
		+
pullpc

;- minor extended x/y speed calculation
;======================================

pushpc
	org $02B5E5
		JML apply_speed_high_byte
pullpc

!x_speed_return_addr = $02B5C4

apply_speed_high_byte:
	PHY
	TAY
	ADC.w $17FC|!addr,x
	STA.w $17FC|!addr,x
	PHP
	
	; make it set the x position version
	; if it's called from the x position version.
	LDA $03,s
	CMP.b #!x_speed_return_addr-1
	BNE +
	LDA $04,s
	CMP.b #(!x_speed_return_addr-1)>>8
	BNE +
	LDA $1698|!addr
	ADC #$D5 ;actually #$D6
	TAX
+
	
	; restore speed, sign extend and apply with
	; previous carry flag.
	TYA
	%sign_extend()
	PLP
	ADC.w $1814|!addr,x
	STA.w $1814|!addr,x
	
	PLY
	JML $02B5EB|!bank

;- Hatching yoshi animation
;==========================

pushpc
	; hatch yoshi egg animation
	org $01F7CD
		JSL minor_load_egg_x
		
	org $01F7FF
		JSL minor_store_egg_x
		NOP

pullpc

minor_load_egg_x:
	; restore
	LDA !E4,x
	STA $00
	
	; load sprite x position high
	LDA !14E0,x
	STA $01
	RTL
	
minor_store_egg_x:
	; restore
	STA $1808|!addr,x
	
	; put logic on sprite high position
	LDA $01
	ADC #$00
	STA $18EA|!addr,x
	
	; restore
	LDA $02
	RTL
	
;- Hatched egg pieces minor extended sprite
;==========================================

; This minor extended sprite comes with a design error,
; if the x position gets offscreen it will spawn a garbage
; tile because the tile is deleted but not the OAM tile.

; Let's rewrite to make it only set the Y position when you
; know it's gonna be actually drawn on the screen.
pushpc
	org $028E97
		LDA $18EA|!addr,x
		XBA
		LDA $1808|!addr,x
		REP #$20
		SEC
		SBC $1A
		CMP.w #$0000-!extra_columns-$0008
		BMI delete_egg_tile_mx
		CMP.w #$0100+!extra_columns
		BPL delete_egg_tile_mx
		SEP #$21
		
		STA.w $0200|!addr,y
		
		LDA $17FC|!addr,x
		SBC $1C
		CMP #$F0
		BCS delete_egg_tile
		STA.w $0201|!addr,y
		
		LDA.b #$6F
		STA.w $0202|!addr,y
		
		JML finish_egg_tile
		
	delete_egg_tile_mx:
		SEP #$20
		BRA delete_egg_tile
		
	return_egg_tile:
		RTS
	
	; print pc
	warnpc $028ECB+1
	
	org $028E76
		delete_egg_tile:
pullpc

finish_egg_tile:
	LDA.w $1850|!addr,x
	AND.b #$C0
	ORA.b #$03
	ORA $64	
	STA.w $0203|!addr,y
	
	TYA
	LSR
	LSR
	TAY
	
	XBA
	AND #$01
	STA.w $0420|!addr,y

	JML return_egg_tile|!bank

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
	STA $1850|!addr,y
	
	LDA $03
	STA $18EA|!addr,y
	
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
		STA $0200|!addr,y
		
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
	LDA $18EA|!addr,x
	SBC $1B
	STA $01
	
	REP #$20
	LDA $00
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
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
	LDA $1808|!addr,x
	SEC
	SBC $1A
	STA $00
	
	BRA minor_x_check
	
minor_water_x_correction:
	STA $00
	
	LDA $18EA|!addr,x
	SBC $1B
	AND #$01
	ORA #$02
	STA $0E
	
	LDA $00
	RTL
	
spawn_rip_van_fish_zs:
	ADC #$06
	STA $1808|!addr,y
	
	LDA !14E0,x
	ADC #$00
	STA $18EA|!addr,y
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
	STA $0420|!addr,y

	JML $028E76|!bank

minor_brick_check:
	XBA
	LDA $01
	REP #$20
	CMP.w #$0000-!extra_columns-$0010
	BMI .return
	CMP.w #$0100+!extra_columns+$0010
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
