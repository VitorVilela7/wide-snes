;Proximity wrap fix, by GreenHammerBro. Please give credit, it takes more than a day of finding many of the sprites that has
;this problem. Also give credit to JackTheSpades for compressing the codes (I have learned how to make A register in 16-bit
;and CLC rolled into one REP opcode, no need to CLC). Sorry that I didn't use macros, its fine with numbers, but with names,
;I get confused. But don't worry, its not worth it, it just compress this file and nothing more (same size amount inserted
;to rom).

;This patch fixes bugs reguarding with the proximity check wrapping from the boarders of the screen, it fixes:
;-Thwomps
;-falling spike
;-yoshi egg
;-Splittin Chuck
;-Bouncin Chuck
;-Whistlin Chuck
;-Rip van fish
;-jumping Piranha plant (and its fire varient)
;-upsidedown piranha (and its classic varient)
;-swooper bat		\
;-exploding block	|fixed by RussianMan
;-ledge dwelling mole	|
;-ground dwelling mole	/

;^If you find any other sprites not listed here and uses the proximity from smw (as in, not custom sprites), feel free to update
;this patch.

;Also, its compatable with alcaro's "Thwomp Face Flip", and is a sa-1 hybrid.
;SubHorizPos16Bit and SubVertPos16Bit was made by Sonikku. 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA1 detector:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if read1($00FFD5) == $23
	!SA1 = 1
	sa1rom
else
	!SA1 = 0
endif

; Example usage
if !SA1
	; SA-1 base addresses	;Give thanks to absentCrowned for this:
				;http://www.smwcentral.net/?p=viewthread&t=71953
	!Base1 = $3000		;>$0000-$00FF -> $3000-$30FF
	!Base2 = $6000		;>$0100-$0FFF -> $6100-$6FFF and $1000-$1FFF -> $7000-$7FFF
	!long  = $000000

	!SprTbl_E4	= $322C		;>Sprite X position, low byte.
	!SprTbl_14E0	= $326E		;>Sprite X position, high byte.
	!SprTbl_D8	= $3216		;>Sprite Y position, low byte.
	!SprTbl_14D4	= $3258		;>Sprite Y position, high byte.
	!SprTbl_1528	= $329A
	!SprTbl_7FAB9E	= $6083
	!SprTbl_157C	= $3334
else
	; Non SA-1 base addresses
	!Base1 = $0000
	!Base2 = $0000
	!long  = $800000

	!SprTbl_E4	= $E4		;>Sprite X position, low byte.
	!SprTbl_14E0	= $14E0		;>Sprite X position, high byte.
	!SprTbl_D8	= $D8		;>Sprite Y position, low byte.
	!SprTbl_14D4	= $14D4		;>Sprite Y position, high byte.
	!SprTbl_1528	= $1528
	!SprTbl_7FAB9E	= $7FAB9E
	!SprTbl_157C	= $157C
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(A huge wall of) hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thwomp

org $01AECB
	autoclean JML Thwompfix_sub	;>hijacks a part of the branch.
	nop #1				;>JML takes 4 bytes total

org $01AED7
	autoclean JSL Thwompfix_range
	BRA NoNopMinus1
	nop

NoNopMinus1:
	BPL $05			; modify branch to use signed just in case.

org $01AEE5
	autoclean JSL Thwompfix_range2
	BRA NoNop0
	nop

NoNop0:
	BPL $0B			; modify branch to use signed just in case.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Falling spike

org $03924E
	autoclean JSL FallingSpike_sub_range
	BRA NoNop1
	nop #4

NoNop1:
	BPL $07			; modify branch to use signed just in case.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Yoshi egg

org $01F76E
	autoclean JSL YoshiEgg_sub_range
	BRA NoNop2
	nop #4

NoNop2:
	BPL $13			; modify branch to use signed just in case.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Chucks

org $02C360			;\Whistlin chuck.
	autoclean JSL Chuck	;|
	BRA NoNop3		;|
	nop #4			;/

NoNop3:
	BPL $04			; modify branch to use signed just in case.

org $02C602			;\Splittin' and bouncin' chuck.
	autoclean JSL Chuck2	;|
	BRA NoNop4		;|
	nop #8			;/

NoNop4:
	BPL $06			; modify branch to use signed just in case.

org $02C64A			;\chargin chuck part where it runs noisly
	autoclean JSL Chuck3	;|towards the player and silent if mario's
	BRA NoNop5		;|
	nop #4			;|Y position is far enough from the chuck's.
				;|
NoNop5:				;|
	BPL $12			;|
				;|
org $02C6BA			;|
	autoclean JSL Chuck4	;|
	BRA NoNop6		;|
	nop #4			;|
				;|
NoNop6:				;|
	BPL $11			;/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rip Van Fish

org $02C05C				;\Horizontal check
	autoclean JSL RipVanFish	;|
	BRA NoNop7			;|
	nop #3				;|
					;|
NoNop7:					;|
	BPL $14				;/

org $02C067				;\vertical check
	autoclean JSL RipVanFish2	;|
	BRA NoNop8			;|
	nop #3				;|
					;|
NoNop8:					;|
	BPL $09				;/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Jumping Piranha Plant

org $02E143					;\Horizontal check
	autoclean JSL JumpingPiranhaPlant	;|
	BRA NoNop9
	nop #4					;|

NoNop9:
	BMI $09					;/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Classic Piranha Plant + Upsidedown

org $018ED0					;\Horizontal check
	autoclean JSL ClassicPiranhaPlant	;|(didn't modify the branch to use signed, it uses
	BRA NoNop10				;|
	nop #4					;/the processor flag).

NoNop10:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Swooper Bat - Fixed By RussianMan

org $0388E9
	autoclean JSL SwooperBat		;
	BRA NoNop11				;geez, I'm so creative with label names
	NOP #4					;

NoNop11:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Exploding Block - Fixed By RussianMan

org $02E44D
	autoclean JSL ExplodingBlock
	BRA NoNopINFINITY
	NOP #4

NoNopINFINITY:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ledge/Ground Dwelling mole - Fixed By RussianMan

org $01E2E0
	autoclean JSL MontyMole
	BRA CleverLabelName
	NOP #4

CleverLabelName:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Search freespace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
freecode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;thwomp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Thwompfix_sub:			;>$01AECB
	BNE +			;>Restore code
	LDY #$D1		;>current x position
	JSR SubHorizPos16Bit
	JML $01AED0|!long		;>continue on determining which side mario is on.
+	JML $01AEF9|!long		;>Restore code

Thwompfix_range:		;>$01AED7
	REP #$21		;>Clear carry and 16-bit A
	LDA $02
	;CLC			;suspicious look.
	ADC #$0040		;
	CMP #$0080		;
	SEP #$20		;
	RTL

Thwompfix_range2:		;>$01AEE5
	REP #$21
	LDA $02			;angry and fall.
	;CLC			;
	ADC #$0024		;
	CMP #$0050		;
	SEP #$20		;
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Falling spike
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FallingSpike_sub_range:
	LDY #$D1
	JSR SubHorizPos16Bit
	REP #$20
	CLC
	ADC #$0040
	CMP #$0080
	SEP #$20
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Yoshi egg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YoshiEgg_sub_range:
	LDY #$D1
	JSR SubHorizPos16Bit
	REP #$20
	CLC
	ADC #$0020
	CMP #$0040
	SEP #$20
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;chuck, not that this is actually where many sprites call this routine to face mario.
;I have breakpointed at address $01AD30 and keep "step into" until after the RTS, thank god
;that help me find the routine used by the splittin chuck that splits if you get close!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Chuck:		;>$02C360
	LDY #$94		;>Next frame x position.
	JSR SubHorizPos16Bit
	REP #$20
	CLC
	ADC #$0030
	CMP #$0060
	SEP #$20
	RTL
Chuck2:		;>$02C602
	LDY #$94		;>Next frame x position.
	JSR SubHorizPos16Bit
	TYA
	STA !SprTbl_157C,x
	REP #$21
	LDA $02			;>Had to load $02 because its replaced by the TYA.
	;CLC
	ADC #$0050
	CMP #$00A0
	SEP #$20
	RTL
Chuck3:
	LDY #$96		;>Next frame y position.
	JSR SubVertPos16Bit
	REP #$20
	LDA $02
	CLC
	ADC #$0028
	CMP #$0050
	SEP #$20
	RTL
Chuck4:
	LDY #$96		;>Next frame y position.
	JSR SubVertPos16Bit
	REP #$20
	LDA $02
	CLC
	ADC #$0030
	CMP #$0060
	SEP #$20
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rip van fish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RipVanFish:	;>$02C05C

	LDY #$94		;>Next frame x position.
	JSR SubHorizPos16Bit
	REP #$20
	CLC
	ADC #$0030
	CMP #$0060
	SEP #$20
	RTL

RipVanFish2:	;>$02C067
	LDY #$96		;>Next frame y position.
	JSR SubVertPos16Bit
	REP #$20
	LDA $02
	CLC
	ADC #$0030
	CMP #$0060
	SEP #$20
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Jumping Piranha plant and its fire varient.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JumpingPiranhaPlant:		;>$02E143
	LDY #$94
	JSR SubHorizPos16Bit
	REP #$20
	LDA $02
	CLC
	ADC #$001B
	CMP #$0037
	SEP #$20
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Classic piranha plant and its upsidedown varient.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClassicPiranhaPlant:		;>$018ED0
	LDY #$D1
	LDA $00			;\$00 is reserved for something else.
	PHA			;/
	JSR SubHorizPos16Bit
	REP #$20
	LDA $02
	CLC
	ADC #$001B
	CMP #$0037
	SEP #$20
	PLA			;\Restore $00 for its sprite state.
	STA $00			;/
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Swooper bat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SwooperBat:
LDY #$D1			;check with current-frame player position
JSR SubHorizPos16Bit		;
REP #$20
TYA				;for some reason it doesn't face player correctly
EOR #$0001			;
TAY				;
LDA $02				;w/e
CLC : ADC #$0050		;
CMP #$00A0			;
SEP #$20			;
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Exploding block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExplodingBlock:
LDY #$94			;check with next-frame player position
JSR SubHorizPos16Bit		;
REP #$20
CLC : ADC #$0060		;
CMP #$00C0			;
SEP #$20			;
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ledge & Ground Dwelling Moles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MontyMole:
LDY #$D1			;i thought I can reuse exploding block fix, but this uses $D1
JSR SubHorizPos16Bit		;
REP #$20
CLC : ADC #$0060		;
CMP #$00C0			;
SEP #$20			;
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;New SubHorizPos subroutine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input: either #$D1 or #$94 in Y (RAM $D1 or $94)
; output:
;  Y=1 if Mario right to the sprite, A=absolute distance in 16-bit + stored into $02.
;  $02 = Absolute distance

SubHorizPos16Bit:
	LDA !SprTbl_14E0,x	;\Load x position high byte and transfer it to
	XBA			;/A's high byte (it still exist even if 8-bit A).
	LDA !SprTbl_E4,x	;>Load x position low byte.

	REP #$20	;>only A is 16-bit, while xy is 8-bit.
	PHA		;preserve sprite x position
	LDA !Base1,y	;$00,y = either $D1 or $94 (sa-1)
	STA $00		;mariox in $00
	LDY #$00	;so that if mario is on left (causing a >= 0 value), Y = 0
	PLA		;restore sprite x back into A
	
	SEC
	SBC $00		; A = spritex - mariox
	BPL .skipinvert	; branch if pos = spritex > mariox = mario left of sprite
	INY		; set Y=1
	EOR #$FFFF	;\ A = -A = mariox - spritex
	INC		;/
.skipinvert
	STA $02		; store distance
	SEP #$20
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SubVertPos subroutine 2, based on address $02D50C.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input: either #$D3 or #$96 in Y (RAM $D1 or $94)
; output: Y=1 if mario right to the srite, A=absolute distance in 16-bit + stored into $02.

SubVertPos16Bit:
	LDA !SprTbl_14D4,x	;\Load y position high byte and transfer it to
	XBA			;/A's high byte (it still exist even if 8-bit A).
	LDA !SprTbl_D8,x	;>Load y position low byte.

	REP #$20	;>only A is 16-bit, while xy is 8-bit.
	PHA		;preserve sprite y position
	LDA !Base1,y	;$00,y = either $D1 or $94 (sa-1)
	STA $00		;marioy in $00
	LDY #$00	;so that if mario is on left (causing a >= 0 value), Y = 0
	PLA		;restore sprite x back into A
	
	SEC
	SBC $00		; A = spritey - marioy
	BPL .skipinvert	; branch if pos = spritex > mariox = mario left of sprite
	INY		; set Y=1
	EOR #$FFFF	;\ A = -A = mariox - spritex
	INC		;/
.skipinvert
	STA $02		; store distance
	SEP #$20
	RTS