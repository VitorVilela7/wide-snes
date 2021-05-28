;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Smoke Sprite High Bytes
;
; This patch adds a high byte for the X and Y positions of smoke sprites. This
; will allow you to easily utilize smoke sprites without having them possibly
; appear onscreen when the sprites are actually supposed to be offscreen. 
; Two sets of 4 consecutive bytes of free RAM are required.
; by MarioE, bug fixes and sa-1 version by Tattletale
;
; Disclaimer for SA-1
; if you are using SA-1 and you reapply it for whatever reason, either make sure
; this 01AB88 doesn't JML out like it did on 1.3.1 or older versions, or reapply
; this patch right after doing that or else you are going to see some fancy breaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; New NMSTL (v1.1+), both that and SA-1 fix a bug with 140f wrapping around
; and becoming zero eventually - and that's a better check than a fixed slot
; Edit this to 0 if you are using the old nmstl, if you are using sa-1 this 
; flag doesn't matter
!NewNMSTL = 0

!dp = $0000
!addr = $0000
!sa1 = 0
!gsu = 0
!bank = $800000

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
	!bank = $000000
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!bank = $000000
endif

macro define_sprite_table(name, addr, addr_sa1, addr_gsu)
	if !sa1
		!<name> = <addr_sa1>
	elseif !gsu
		!<name> = <addr_gsu>
	else
		!<name> = <addr>
	endif
endmacro

%define_sprite_table("D8", $D8, $3216, $D8)
%define_sprite_table("E4", $E4, $322C, $E4)
%define_sprite_table("14D4", $14D4, $3258, $74D4)
%define_sprite_table("14E0", $14E0, $326E, $74E0)
%define_sprite_table("157C", $157C, $3334, $757C)

!high_x			= $18C9|!addr			; 4 consecutive bytes
!high_y			= $18C5|!addr			; 4 consecutive bytes

; I honestly didn't have any issue with this, but might as well
org $00FB9E|!bank
	autoclean JML SetEndLevelHighBytes : NOP

; player triggered sparkle effect (midway, yoshi coin etc)
org $00FD7E|!bank
	LDA $9B
	STA !high_x,y
	LDA $99
	STA !high_y,y
	LDA $1933|!addr
	BEQ +
	LDA $9A
	SEC
	SBC $26
	JSL mod_00FD7E
+	LDA #$10
	STA $17CC|!addr,y
	RTS

; not safe to override both tables aftert this
; these are related to l3 tide splash + push
warnpc $00FD9C|!bank

; player turning / smoke / skid
org $00FE8E|!bank
		JSL mod_00FE8E
		RTS

; generic routine for sprites to spawn smoke with
org $018078|!bank
if !sa1
	LDA ($EE)
else
	LDA $E4,x
endif
	CLC
	ADC $00
	STA $17C8|!addr,y
autoclean JSL FixHighX
	JSL mod_018078
	RTS
	NOP
	RTS
	
warnpc $01808B|!bank

if !sa1
	; sa-1 uses a JML instead of using the indirect pointers
	; then comes back, this patch doesn like that so I'm changing
	; that so it does use the indirect pointers
	; which means that unless someone changes the sa-1 patch to use
	; the indirect pointers (already reported to Vitor), it's not a
	; good idea to reaply sa-1 and not reaply this patch right after it
	org $01AB88
		LDA ($EE)
		STA $77C8,y
endif

; sprite was hit - graphic / smoke
org $01AB8D|!bank
	LDA #$08
	JSL mod_01AB8D
	PLY
	RTL

; hit graphic at mario's position
org $01ABC5|!bank
	JSL mod_01ABC5
	PLY
	RTL

; spawn smoke used by magikoopa
org $01BDAD|!bank
	LDA #$1B
	JSL mod_01BDAD
	RTS

; powerup / coin glitter routine
org $01C505|!bank
	LDA #$10
	JSL mod_01C505
	RTS

; mario becomes smoke / freeze the game (feather power up)
org $01C5E6|!bank
	JSL mod_01C5E6
	RTL

;Morton/Roy/Ludwig death animation
org $01D026|!bank
	; Carry is set here
	autoclean JML mod_01D026

;reznor bridge / summo bro
org $028A61|!bank
	autoclean JML SetHighByteForBridgeSmoke

; glitter routine used by the spinning coin
org $029AEA|!bank
	LDA $17E0|!addr,x
	STA $17C8|!addr,y
	LDA $17EC|!addr,x
	STA !high_x,y
	LDA $17D4|!addr,x
	STA $17C4|!addr,y
	LDA $17E8|!addr,x
	STA !high_y,y
	JSL mod_029AEA
	RTS

; extended sprite interaction with player - coin glitter
org $02A438|!bank
	JSL mod_02A438
	NOP

; bulletbill smoke
org $02B513|!bank
	JSL mod_02B513
	RTS

; torpedo ted smoke
org $02B969|!bank
	LDA #$01
	STA $17C0|!addr,y
	LDA #$0F
	STA $17CC|!addr,y
if !sa1
	LDA ($EE)
else
	LDA $E4,x
endif
	PHY
	LDY !157C,x
	CLC
	ADC $B94E,y
	PLY
	STA $17C8|!addr,y
	LDA !14E0,x
	PHY
	LDY !157C,x
	ADC $B950,y
	PLY
	STA !high_x,y
	
if !sa1
	LDA ($CC)
else
	LDA $D8,x
endif
	STA $17C4|!addr,y
	LDA !14D4,x
	STA !high_y,y
	RTS

; blue koopa skid
org $038A2E|!bank
	LDA !14E0,x
	ADC #$00
	STA !high_x,y
	JSL mod_038A2E
	RTS

; all of the smoke
; rewrites all of the smoke sprite main + pointers + call 
; + oam handling, which remains basically the same
org $0296C0|!bank
	STZ $0F
	REP #$30
	TXA
	AND #$00FF
	TAX
	SEP #$30
	
	LDA $17CC|!addr,x
	BEQ kill
	LDA $17C0|!addr,x
	BMI decTimer
	LDA $9D
	BNE no_dec
decTimer:	
	DEC $17CC|!addr,x
no_dec:	
	LDA $17C0|!addr,x
	AND #$7F
	print pc
	JSL $0086DF|!bank
	
	dw return
	dw puff
	dw contact
	dw skid
	dw return
	dw glitter
		
oam_1:
	dw $0020,$0024,$0028,$002C
oam_2:
	dw $0090,$0094,$0098,$009C
oam_3:
	dw $0190,$0194,$0198,$019C

kill:
	STZ $17C0|!addr,x
return:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

puff_tile:
	db $66,$66,$64,$62,$60,$62,$60

puff:	
	REP #$30
	PHX
	TXA
	ASL
	TAX
	SEP #$20
	LDY oam_1,x
	
if !sa1 || !NewNMSTL
	; both sa1 and the new nmstl fix an issue with wrap around with 140f
	; so it can actually be used to detect reznor now
	LDA $140F|!addr
	BNE +
else
	LDA $A5
	CMP #$A9
	BEQ +
endif
	BIT $0D9B|!addr
	BVC +
	LDY oam_3,x
+	
	PLX
	
	JSR check_y
	BCS .return
	STA $0201|!addr,y
	
	LDA $17CC|!addr,x
	PHX
	LSR
	LSR
	TAX
	LDA puff_tile,x
	STA $0202|!addr,y
	PLX
	
	LDA $64
	STA $0203|!addr,y
	
	JSR check_x
	STA $0200|!addr,y
	BCC .on_scr
	INC $0F
	
.on_scr
	REP #$20
	TYA
	LSR
	LSR
	TAY
	SEP #$20
	LDA $0F
	ORA #$02
	STA $0420|!addr,y
	
.return	
	SEP #$10
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

contact_tiles:
	db $7C,$7D,$7D,$7C

contact:
	REP #$10
	LDY #$00F0
	BIT $0D9B|!addr
	BVC +
	LDA $0D9B|!addr
	DEC
	BEQ +
	LDY #$0190
+	
	JSR check_y
	BCS .return
	STA $0201|!addr,y
	STA $0205|!addr,y
	CLC
	ADC #$08
	STA $0209|!addr,y
	STA $020D|!addr,y
	
	LDA $17CC|!addr,x
	AND #$02
	PHX
	TAX
	LDA contact_tiles,x
	STA $0202|!addr,y
	STA $020E|!addr,y
	INX
	LDA contact_tiles,x
	STA $0206|!addr,y
	STA $020A|!addr,y
	PLX
	
	LDA $17CC|!addr,x
	ASL #5
	AND #$40
	ORA $64
	STA $0203|!addr,y
	STA $0207|!addr,y
	EOR #$C0
	STA $020B|!addr,y
	STA $020F|!addr,y
	
	JSR check_x
	STA $0200|!addr,y
	STA $0208|!addr,y
	PHP
	CLC
	ADC #$08
	PLP
	STA $0204|!addr,y
	STA $020C|!addr,y
	BCC .on_scr
	INC $0F
.on_scr	
	REP #$20
	TYA
	LSR
	LSR
	TAY
	SEP #$20
	LDA $0F
	STA $0420|!addr,y
	STA $0421|!addr,y
	STA $0422|!addr,y
	STA $0423|!addr,y
	
.return	
	SEP #$10
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
skid_tile:
	db $66,$66,$64,$62,$62
		
skid:		
	LDA $9D
	BNE .no_dec
	LDA $17CC|!addr,x
	AND #$07
	BNE .no_dec
	LDA $17C4|!addr,x
	SEC
	SBC #$01
	STA $17C4|!addr,x
	BCS .no_dec
	DEC !high_y,x
.no_dec	
	REP #$30
	PHX
	TXA
	ASL
	TAX
	SEP #$20
	LDY oam_1,x
if !sa1
	; probably could only check 140f due to sa1 / new nmstl behaviour
	; but I'm sticking with this
	LDA $3207,x
else
	LDA $A5
endif
	CMP #$A9
	BEQ .use_1
	LDA $140F|!addr
	BNE .use_1
	LDA $0D9B|!addr
	BPL .use_1
	CMP #$C1
	BEQ .use_2
	AND #$40
	BNE .use_3
.use_2	
	LDY oam_2,x
	BRA .use_1
.use_3	
	LDY oam_3,x
.use_1	
	PLX
	
	JSR check_y
	BCS .return
	STA $0201|!addr,y
	
	LDA $17CC|!addr,x
	LSR
	LSR
	PHX
	TAX
	LDA skid_tile,x
	STA $0202|!addr,y
	PLX
	
	LDA $64
	STA $0203|!addr,y
	
	JSR check_x
	STA $0200|!addr,y
	BCC .on_scr
	INC $0F
	
.on_scr
	REP #$20
	TYA
	LSR
	LSR
	TAY
	SEP #$20
	LDA $0F
	STA $0420|!addr,y
	
.return	
	SEP #$10
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
glitter_x:
	db $04,$08,$04,$00
		
glitter_y:
	db $FC,$04,$0C,$04
		
glitter:
	LDA $17CC|!addr,x
	AND #$03
	BNE .return
	
	JSL check_x_wide
	BCS .return
	JSR check_y
	BCS .return
	
	LDY #$0B
.loop
	LDA $17F0|!addr,y
	BEQ .found
	DEY
	BPL .loop
	LDY $185D|!addr
	DEY
	BPL .found
	LDY #$0B
	
.found
	LDA #$02
	STA $17F0|!addr,y
	
	LDA $17C8|!addr,x
	STA $00
	LDA $17C4|!addr,x
	STA $01
	
	LDA $17CC|!addr,x
	AND.b #$03<<2
	LSR
	LSR
	PHX
	TAX
	LDA $00
	ADC glitter_x,x
	STA $1808|!addr,y
	LDA $01
	CLC
	ADC glitter_y,x
	STA $17FC|!addr,y
	PLX
	
	LDA #$17
	STA $1850|!addr,y
	
.return
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main smoke helper routines
check_x:	
	LDA !high_x,x
	XBA
	LDA $17C8|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP #$0100
	SEP #$20
	RTS

check_y:
	LDA !high_y,x
	XBA
	LDA $17C4|!addr,x
	REP #$20
	SEC
	SBC $1C
	CMP #$00E0
	SEP #$20
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; General hijacks helper routines
mod_00FD7E:
	AND #$F0
	STA $17C8|!addr,y
	LDA $9B
	SBC $27
	STA !high_x,y
	LDA $98
	SEC
	SBC $28
	AND #$F0

	STA $17C4|!addr,y
	LDA $99
	SBC $29
	STA !high_y,y
	RTL
	
mod_00FE8E:	
	LDA $97
	ADC #$00
	STA !high_y,y
	
	LDA $94
	CLC
	ADC #$04
	LDA $95
	ADC #$00
	STA !high_x,y
	
	LDA #$13
	STA $17CC|!addr,y
	RTL
		
mod_018078:
mod_038A2E:	
	STA !high_x,y
if !sa1
	LDA ($CC)
else
	LDA $D8,x
endif
	CLC
	ADC $01
	STA $17C4|!addr,y
autoclean JSL FixHighY
	STA !high_y,y
	
	LDA #$13
	STA $17CC|!addr,y
	RTL

mod_01ABC5:
	LDA #$00
	ADC $97
	STA !high_y,y
	LDA #$08
	STA $17CC|!addr,y
	
	LDA $95
	STA !high_x,y
	RTL
		
mod_01AB8D:
mod_01BDAD:	
mod_01C505:	
	STA $17CC|!addr,y
if !sa1
	LDA ($CC)
else
	; dpfix
	LDA $D8,x
endif
	STA $17C4|!addr,y
	LDA !14E0,x
	STA !high_x,y
	LDA !14D4,x
	STA !high_y,y
	RTL
		
mod_01C5E6:	
	LDA $97
	ADC #$00
	STA !high_y,y
	
	LDA $94
	STA $17C8|!addr,y
	LDA $95
	STA !high_x,y
	RTL
		
mod_029AEA:
	LDA $17E4|!addr,x
	LSR
	BCC .return
	
	LDA $17E0|!addr,x
	SEC
	SBC $26
	STA $17C8|!addr,y
	LDA $17EC|!addr,x
	SBC $27
	STA !high_x,y
	
	LDA $17D4|!addr,x
	SEC
	SBC $28
	STA $17C4|!addr,y
	LDA $17E8|!addr,x
	SBC $29
	STA !high_y,y
	
.return	
	LDA #$10
	STA $17CC|!addr,y
	RTL
		
mod_02A438:	
	LDA $1733|!addr,x
	STA !high_x,y
	LDA $1729|!addr,x
	STA !high_y,y
	
	LDA #$0A
	STA $17CC|!addr,y
	RTL

mod_02B513:
	STA $17C8|!addr,y
	DEX
	TXA
	LDX $15E9|!addr
	ADC $17A3|!addr,x
	STA !high_x,y
	LDA $1793|!addr,x
	STA !high_y,y
	RTL
warnpc $0299D2|!bank


; I'm honestly sad I couldn't keep up marioE's job at making this patch don't require freerom
freedata
;print "Code is located at: $", pc
;reset bytes

check_x_wide:
	LDA !high_x,x
	XBA
	LDA $17C8|!addr,x
	REP #$20
	SEC
	SBC $1A
	CMP.w #$0100+!extra_columns
	BPL .not_ok
	CMP.w #$0000-!extra_columns
	BMI .not_ok

.ok
	CLC
	SEP #$20
	RTL

.not_ok
	SEP #$21
	RTL

mod_01D026:
	LDA !14E0,x
	SBC #$00
	STA !high_x
	
	LDA !D8,x
	CLC
	ADC #$08
	XBA
	LDA !14D4,x
	ADC #$00
	STA !high_y
	XBA
	JML $01D02A|!bank

SetEndLevelHighBytes:
	LDA !14E0,y
	STA !high_x,x
	LDA !14D4,y
	STA !high_y,x
	; restore
	LDA #$1B
	STA $17CC|!addr,x
	JML $00FBA3|!bank
	
SetHighByteForBridgeSmoke:
	STA $17CC|!addr,x
	LDA $99
	STA !high_y,x
	LDA $9B
	STA !high_x,x
	PLX
	JML $028A65|!bank

;; these guys fix an issue this patch had with motors' smoke
;; basically motors were displacing smoke by F2
;; since we have high bytes now, displacing it by 00F2 isn't bery healthy
;; has to be FFF2
;; so for vanilla sprites, anything negative is considered as a pseudo-subtraction
;; I have yet to find an issue with this approach
FixHighX:
	LDA $00
	PHP
	LDA !14E0,x
PseudoSubtraction:
	PLP
	BMI +
		ADC #$00
		RTL
+
	ADC #$FF
	RTL

FixHighY:
	LDA $01
	PHP
	LDA !14D4,x
	BRA PseudoSubtraction
	
;print "Freespace used: ",bytes," bytes."