;===============================================================
; Code responsible for adding generator support
; for Widescreen SMW
;===============================================================

;- Sprite Generators
;===================

; Eeries
pushpc
	org $02B2D0
		db $F0-!extra_columns
		db $FF+!extra_columns
pullpc

; Para goomba, bob-omb, etc,
; Ignored.

; Dolphins

pushpc
	org $02B25E
		db $10+!extra_columns
		db $E0-!extra_columns
pullpc

; Fish Generator: ignored;
; because the range is already tight.
; and couldn't find much benefit.

; Super koopa, bubble and bullet bill generator
pushpc
	org $02B1B8
		db $E0-!extra_columns
		db $10+!extra_columns

pullpc

; Multiple bullet generator
; the -$10 and +$10 aren't needed, these are personal improvements.
pushpc
	org $02B135
		JSL generator_high_table
		
	org $02B0FA
		; surrounded
		db $00-!extra_columns-$10
		db $00-!extra_columns-$10
		db $40
		db $C0
		db $F0+!extra_columns+$10
		
		; diagonal
		db $00-!extra_columns
		db $00-!extra_columns
		db $F0+!extra_columns
		db $F0+!extra_columns
		
pullpc

generator_high_table:
	LDA $1B
	ADC.l multi_bullet_high_table,x
	RTL

multi_bullet_high_table:
	; surrounded
	db $FF
	db $FF
	db $00
	db $00
	db $01
	
	; diagonal
	db $FF
	db $FF
	db $01
	db $01
	
; Bowser fire
pushpc
	org $02B06D
		ADC.b #$FF+!extra_columns
		
	org $02B073
		ADC.b #$01
pullpc
