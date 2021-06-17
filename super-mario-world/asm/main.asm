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
; - JackTheSpades
; - HammerBrother

; TESTING BUGS:
; - Adam Londero
; - RupeeClock
; - z384

; TESTING:
; - FuRiOUS
; - DerKoun
; - Seathorne
; - Doctor No

; TO DO: title screen demo
; TO DO: credits

; TO DO: cluster sprites
; TO DO: regular sprites

; TO DO: add Luigi graphics

; TO DO: Sumo brother flame on widescreen
; TO DO: fix spiny on line (tbm o liquidificador) guide wrapping around screen.
; TO DO: fix contact smoke sprite when hitting multiple koopas on Yoshi's Island 2 and shoot fireball at the same time.

; TO DO: fix Lugwig background
; TO DO: decide what to do with Bowser platform and the big chains

; FIXED: Fixed some invisible tiles flashing on the screen
; while Valley of the Bowser is appearing, after beating
; Sunken Ghost Ship. - Thanks z387 for reporting

; FIXED: Fixed Koopa Troopa's eyes (when on stunned state)
; appearing outside widescreen area, including when the shell
; is shaking. - Thanks RupeeClock for reporting

; FIXED: Donut Plains 2 flickers at the beginning due of a
; conflicting Lunar Magic 3XX hijack.
; - Thanks Adam Londero for reporting

; FIXED: Vertical level horizontal scrolling limits going
; more than one píxel than it should. Fixes Vanilla Secret 1.
; - Thanks z387 for reporting.

; FIXED: On Forest of Illusion 2, it's possible to beat the level
; with so many rip-van-fish on screen that the goal point might give
; you more than 3-ups and display glitchy score values.
; - Thanks z387 for reporting.

; FIXED: an original game bug where shaking dry bones can make
; its base tile end up teleporting to the wrong spot. 
; - Thanks z387 for reporting.

; FIXED: an original game bug where if layer 2 event tiles
; is larger than the remaning horizontal screen space, it will
; wrap around the other side and affect widescreen region.
; - Thanks Adam Londero for reporting.

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
; DONE: key/keyhole windowing hdma
; DONE: special camera/scrolling status
; DONE: fix "S" palette from MARIO START (done by Lunar Magic)
; DONE: fix lakitu cloud face
; DONE: fix jump 'strings' (pea sprite) interaction
; DONE: fix magikoopa magic wand and sparkles on widescreen.
; DONE: figure out why yoshi wings doesn't have glitter effect.
; DONE: fix yoshi eggs on screen edges.
; DONE: kicking shell doesn't hit turn blocks at widescreen area.
; DONE: fix sprite memory to 0x08 on SA-1 modified levels.
; DONE: spike fall at widescreen area.
; DONE: fix thwomp detection range (>$0100)

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
	!15EA	= $33A2
	!D8	= $3216
	!B6	= $B6 ;this is not a typo.
	
	!smoke_x_high = $78C9
	!sprite_wide_flag_table = $766E
	!sprite_offscreen_flag_table = $3376
	
	maxtile_flush_nmstl         = $0084A8
	maxtile_get_sprite_slot     = $0084AC
	maxtile_get_slot            = $0084B0
	maxtile_finish_oam          = $0084B4
else
	!sa1	= 0
	!dp	= $0000
	!addr	= $0000
	!bank	= $800000
	
	!E4	= $E4
	!14E0	= $14E0
	!157C	= $157C
	!15EA	= $15EA
	!D8	= $D8
	!B6	= $B6
	
	!smoke_x_high = $18C9
	
	; set if "x position" is on widescreen area.
	; used as alternative for $15A0.
	!sprite_wide_flag_table = $1FD6
	!sprite_offscreen_flag_table = $15A0
endif

; sign extend high byte utility
macro sign_extend()
	AND #$80
	BEQ ?no_extend
	ORA #$7F
?no_extend:

endmacro

; widescreen settings
org $FFE0
	; format: --l- -uw-
	; w = enable 16:9 (352x224 mode + 8:7 PAR) widescreen hack
	; u = enable 21:9 (448x224 mode + 8:7 PAR) ultrawide hack
	; l = enable no sprite limit hack
	; - = unknown/not yet defined.
	if !ultrawide == 0
		db $22
	else
		db $24
	endif

	; widescreen identifier (dummy $51XX vector value)
	db $51

	; format: ---- ----
	; - = unknown/not yet defined.
	db $00

	; widescreen identifier (dummy $21XX vector value)
	db $21

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
	LDA.W #$0100-!extra_columns
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

; Side exits
incsrc "level_side_exits.asm"
; Castle/ghost house entrances
incsrc "level_entrances.asm"	
; Sprites in general
incsrc "level_sprites.asm"
; Spinning sprites
incsrc "level_sprite_spinning.asm"
; Minor extended sprites
incsrc "level_minor_extended_sprites.asm"
; Extended sprites
incsrc "level_extended_sprites.asm"
; Shooters
incsrc "level_shooters.asm"
; Generators
incsrc "level_generators.asm"
; Score sprites
incsrc "level_score_sprites.asm"
; Bounce sprites
incsrc "level_bounce_sprites.asm"
; Quake sprites
incsrc "level_quake_sprites.asm"
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
; Window HDMA effects
incsrc "windowing_effects.asm"

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
; 3rd party - independent patches - proximity wrap fix
incsrc "proximity_wrap_fix.asm"
; 3rd party - independent patches - goal/score sprite fix
incsrc "goal_fix.asm"
