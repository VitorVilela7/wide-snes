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
; TO DO: minor extended sprites
; TO DO: generator sprites (adjust spawn position)

; DONE: smoke sprites
; DONE: spinnning coin sprites (from ? block)
; DONE: score sprites
; DONE: mario turning around smoke effect
; DONE: bounce sprites
; DONE: quake sprites

; TO DO: check bounce sprites on vertical levels. $02925C

; TO DO: add koopaling hair fix
; TO DO: add "S" from MARIO START
; TO DO: add Luigi graphics

; TO DO for spinning: glitter effect (using smoke sprites as proxy). TODO for minor extended sprites.
; DONE for spinning: score [10pts] sprite support

;- RAM addresses definitions
;===========================

; x position high byte for smoke sprites - given by smoke_position.asm
!smoke_x_high = $18C9

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

pullpc

minor_load_spr_x_star:
	ADC $94
	STA $02
	
	LDA $95
	ADC #$00
	STA $03
	
	RTL
	
minor_store_spr_x_star:
	; restore
	STA $1850,y
	
	LDA $03
	STA $18EA,y
	
	; end/restore
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
	
	org $028E6D
		LDA $0F
		
	org $028E76
		rip_van_fish_erase:
		
	org $028E4B
		JML abort_rip_van_fish_if_timeout
		
	org $02C10E
		JSL spawn_rip_van_fish_zs
		NOP
		
	; ignore horizontal offscreen flag (standard sprite)
	; for rip van fish ($15A0+x)
	org $02C0DC
		LDA #$00
		NOP
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
