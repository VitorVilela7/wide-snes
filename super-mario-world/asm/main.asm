; Super Mario World - Widescreen Patch v1.00
; by Vitor Vilela

; WARNING: only works with vanilla SMW or vanilla SMW + SA-1 Pack

; Special thanks:
; - MarioE
; - Tattletale
; - LX5
; - Thomas
; - RussianMan
; - Romi
; - FuSoYa
; - Smallhacker
; - Alcaro
; - JamesD28
; - Mattrizzle

; TO DO: title screen demo
; TO DO: credits
; TO DO: special camera/scrolling status

; TO DO: cluster sprites
; TO DO: regular sprites

; TO DO: add "S" from MARIO START
; TO DO: add Luigi graphics

; TO DO: test more carefully yoshi eggs on screen edges. (fix needed)
; TO DO: fix jump 'strings' (pea sprite), interaction
; TO DO: key/keyhole windowing hdma
; TO DO: spike fall at widescreen area.
; TO DO: kicking shell doesn't hit turn blocks at widescreen area.
; TO DO: figure out why yoshi wings doesn't have glitter effect.
; TO DO: fix thwomp detection range (>$0100)
; TO DO: fix lakitu cloud smile
; TO DO: fix magikoopa magic wand on widescreen.
; TO DO: fix spiny on line (tbm o liquidificador) guide wrapping around screen.
; TO DO: fix contact smoke sprite when hitting multiple koopas on Yoshi's Island 2 and shoot fireball at the same time.
; TO DO: fix flying '?' block particles generation

; TO DO: fix Lugwig background

; DONE: fix Reznor puff smoke disappearing platform sometimes
; DONE: fix Reznor puff smoke not appearing on right side bridge

; DONE: smoke sprites
; DONE: spinnning coin sprites (from ? block)
; DONE: score sprites
; DONE: mario turning around smoke effect
; DONE: bounce sprites
; DONE: quake sprites
; DONE: minor extended sprites
; DONE: shooter sprites
; DONE: extended sprites
; DONE: generator sprites (adjust spawn position)

; DONE: for spinning: glitter effect (using smoke sprites as proxy).
; DONE: for spinning: score [10pts] sprite support
; DONE: podoboo flames position checks.
; DONE: minor star position generation fixes.
; DONE: title screen fix (ow sprites appearing)
; DONE: check bounce sprites on vertical levels. $02925C
; DONE: add koopaling hair fix
; DONE: fix Ludwig sprite decision camera...
; DONE: fix yoshi wings.
; DONE: fix 'smushed' OAM on koopas without shell.
; DONE: fix winged sprites...
; DONE: fix reznor fireball on widescreen.
; DONE: fix torpedo ted's arm on widescreen area.
; DONE: dry bones throwing bones at widescreen area.
; DONE: hammer bro's hammers.
; DONE: yoshi's flames
; DONE: air bubbles
; DONE: fix Yoshi's tongue
; DONE: fix Yoshi's throat
; DONE: wiggler's flower, game coin and lava splash (see level_sprites.asm)

; 1 for 21:9, 0 for 16:9
!ultrawide = 0

; Extra pixels added to the left/right side
!extra_columns = 48

if !ultrawide == 1
	!extra_columns = 96
endif

; Effective screen width
!screen_size = 256+(2*!extra_columns)

; CRT Screen Aspect Correction Ratio Theory #1:
; (4/3) / (8/7) = 4/3 * 7/8 = 1/3 * 7/2 = 7/6

; CRT Screen Aspect Correction Ratio Theory #2:
; Most analysis leads to, possibly due of NTSC clock differences = 8/7

; Either way for both to be used, !extra_columns must be 44 according bsnes-hd spec.
; Keeping in mind that it must be divisible by 16.

assert !extra_columns%16 == 0, "Extra columns must be divisible by 16."

; Hybrid SA-1 support
if read1($00FFD5) == $23
	sa1rom

	!sa1	= 1
	!dp	= $3000
	!addr	= $6000
	!bank	= $000000
	
	!E4	= $322C
	!14E0	= $326E
	!157C	= $3334
	
	!smoke_x_high = $78C9
	!sprite_wide_flag_table = $766E
else
	!sa1	= 0
	!dp	= $0000
	!addr	= $0000
	!bank	= $800000
	
	!E4	= $E4
	!14E0	= $14E0
	!157C	= $157C
	
	!smoke_x_high = $18C9
	
	; set if "x position" is on widescreen area. Used as alternative for $15A0.
	!sprite_wide_flag_table = $1FD6
endif



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

;SpriteOffScreen3:                 .db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
;SpriteOffScreen4:                 .db $01,$FF,$01,$FF,$01,$FF,$01,$FF
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
    
;DATA_02D007:                      .db $30,$C0,$A0,$C0,$A0,$70,$60,$B0
;DATA_02D00F:                      .db $01,$FF,$01,$FF,$01,$FF,$01,$FF
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

;DATA_02FEC5:                      .db $40,$B0
;DATA_02FEC7:                      .db $01,$FF
;DATA_02FEC9:                      .db $30,$C0
;DATA_02FECB:                      .db $01,$FF
org $02FEC5
	db $40+!extra_columns
	db $B0-!extra_columns
    
org $02FEC9
	db $30+!extra_columns
	db $C0-!extra_columns

;DATA_03B83F:                      .db $30,$C0,$A0,$80,$A0,$40,$60,$B0
;DATA_03B847:                      .db $01,$FF,$01,$FF,$01,$00,$01,$FF
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

; The following changes avoids the game out of sudden
; not drawing sprites anymore (even though they are active)

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

; this is for vertical levels...
; Control camera screen scrolling:
; CODE_00F789:        A5 02         LDA $02                   ;>Load distance
; CODE_00F78B:        18            CLC                       ;\..going right from left edge of screen
; CODE_00F78C:        65 1A         ADC RAM_ScreenBndryXLo    ;/
; CODE_00F78E:        10 03         BPL CODE_00F793           ;>if not past left edge of screen, branch
; CODE_00F790:        A9 00 00      LDA.W #$0000              ;>Load #$0000 to prevent screen from scrolling past left edge of level.
; CODE_00F793:        C9 01 01      CMP.W #$0101              ;\Is nintendo stupid? Because you load a fixed value, compare it to a fixed
; CODE_00F796:        30 03         BMI CODE_00F79B           ;/means that the branch will not change at all.
; CODE_00F798:        A9 00 01      LDA.W #$0100              ;>The furthest right the screen can scroll rightwards
; CODE_00F79B:        85 1A         STA RAM_ScreenBndryXLo    ;>Store screen position (this is how Mario moves the screen horizontally, vertical levels only)

org $00F78E
	autoclean JML camera_x_limit_vert
    
; CODE_00F73F:        65 1A         ADC RAM_ScreenBndryXLo    ;/
; CODE_00F741:        10 03         BPL CODE_00F746           ;>if not past the left edge, good.
; CODE_00F743:        A9 00 00      LDA.W #$0000              ;\Prevent screen from scrolling past left edge of level.
; CODE_00F746:        85 1A         STA RAM_ScreenBndryXLo    ;/(this is how Mario moves the screen horizontally, horizontal levels only)
; CODE_00F748:        A5 5E         LDA $5E                   ;\Prevent screen from scrolling past the
; CODE_00F74A:        3A            DEC A                     ;|last screen in a horizontal level.
; CODE_00F74B:        EB            XBA                       ;|
; CODE_00F74C:        29 00 FF      AND.W #$FF00              ;|
; CODE_00F74F:        10 03         BPL CODE_00F754           ;|
; CODE_00F751:        A9 80 00      LDA.W #$0080              ;|
; CODE_00F754:        C5 1A         CMP RAM_ScreenBndryXLo    ;|
; CODE_00F756:        10 02         BPL CODE_00F75A           ;|
; CODE_00F758:        85 1A         STA RAM_ScreenBndryXLo    ;/
; CODE_00F75A:        80 41         BRA CODE_00F79D           ;>Go to layer 2 scrolling

org $00F73F
	autoclean JML camera_x_limit_horz
   
freecode

camera_x_limit_vert:
	CMP.W #$0000+!extra_columns
	BPL +
	LDA.W #$0000+!extra_columns
+	CMP.W #$0101-!extra_columns
	BMI +
	LDA.W #$0101-!extra_columns
+	STA $1A

	JML $00F79D|!bank
	
; this makes sure the camera position is within bounds of the widescreen region, with special
; treatment for 256 pixels wide levels.

camera_x_limit_horz:
	ADC $1A
	CMP.W #$0000+!extra_columns
	BPL +
	LDA.W #$0000+!extra_columns
    
+
	STA $1A

	; right side
	LDA $5E
	DEC A
	
	XBA            
	AND #$FF00
	BEQ .single_screen
	
	BPL .resume
	
	LDA #$0080
.resume
	SEC
	SBC.W #$0000+!extra_columns
	CMP $1A
	BPL .return
	STA $1A

.return
	JML $00F75A|!bank

.single_screen
	; static position, keep level centered.
	STZ $1A
	BRA .return

pushpc
    
; CODE_00E9B5:        69 E8 00      ADC.W #$00E8              ;|pixels from right edge of screen
; CODE_00E9B8:        C5 94         CMP RAM_MarioXPos         ;/
; CODE_00E9BA:        F0 0C         BEQ CODE_00E9C8           ;\If at or below, branch (BMI branches only less than)
; CODE_00E9BC:        30 0A         BMI CODE_00E9C8           ;/
; CODE_00E9BE:        C8            INY                       ;>Switch index to #$01
; CODE_00E9BF:        A5 94         LDA RAM_MarioXPos         ;\The left border position, where mario cannot be less than 8 pixels
; CODE_00E9C1:        38            SEC                       ;|away from left edge of screen.
; CODE_00E9C2:        E9 08 00      SBC.W #$0008              ;|
; CODE_00E9C5:        CD 62 14      CMP.W $1462               ;/
; CODE_00E9C8:        E2 20         SEP #$20                  ; Accum (8 bit)     

org $00E9B5
	ADC.W #$00E8+!extra_columns
    
org $00E9C2
	SBC.W #$0008-!extra_columns

pullpc

; take care of window hdma

pushpc

;define x/y pos
; use CODE_00CA88 as set up $00 and $01
; X position should be adjusted.

; size calculation
org $00CC51
	JSL hack_test
	PLY
	RTS
	
org $00CA74
	JSL fix_x_pos
	NOP #3
	
; TO DO: this still needs fixing (spotlight)
org $03C612
	NOP #3

pullpc

fix_x_pos:
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
	STA $00
	SEP #$20
	RTL

; TO DO: SA-1
hack_test:
	LDA $4217
	LSR
	STA $02
	
	LSR $03
	
	;A's value is used
	RTL
	
	
pushpc

org $05B25D
	JML recalc_x

pullpc

recalc_x:
	LSR
	STA $00
	CLC
	ADC #$80
	XBA
	
	LDA #$80
	SEC
	SBC $00
	JML $05B267|!bank

; Side exits
incsrc "level_side_exits.asm"
; Castle/ghost house entrances
incsrc "level_entrances.asm"	
; Sprites in general
incsrc "level_sprites.asm"
; Level rendering
incsrc "level_render.asm"
; Bosses
incsrc "level_bosses.asm"
; Overworld map
incsrc "overworld.asm"
; Title screen
incsrc "title_screen.asm"
; Yoshi widescreen support
incsrc "level_yoshi.asm"

; 3rd party - independent patches - smoke x/y high bytes patch
incsrc "smoke_position.asm"
; 3rd party - independent patches - fixes feather score bug
incsrc "feather_score_fix.asm"
; 3rd party - independent patches - fixes game freezing when getting feather
incsrc "feather_fix.asm"
; 3rd party - independent patches - removes overworld sprites at title screen load
incsrc "windex.asm"
; 3rd party - independent patches - iggy hair fix
incsrc "iggy_hair.asm"
