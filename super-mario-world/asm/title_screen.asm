;===============================================================
; Special patch for dealing with title screen.
;===============================================================

;- Title screen movement
;=======================

pushpc
	org $9329+(7*2)
		dw GM7
		
	org $9C66
		GM7:
			JSR $9A74
			JSR $9CBE
			BNE +
			JSR $F62D
			JSL load_index
			
	; print pc
	warnpc $009C75
			
	org $009C9F
		+
			
pullpc

load_index:
	LDX $1DF4|!addr
	DEC $1DF5|!addr
	RTL

pushpc
	if !widetype == !normal
		org $9C1F
			; #$0000
			db $41,$0F,$C1,$30,$00,$10,$42,$20
			; #$0008
			db $41,$70,$81,$11,$00,$80,$82,$0C
			; #$0010
			db $00,$30,$C1,$30,$41,$60-12,$C1,$10+6
			; #$0018
			db $41,$20,($00),$20,$01,$30,$E1,$01,$00,$60
			; #$0020
			db $41,$4E,$80,$10,$00,$30,$41,$58+3
			; #$0028
			db $00,$20,$60,$01,$00,$30,$60,$01
			; #$0030
			db $00,$30,$60,$01,$00,$30,$60,$01
			; #$0038
			db $00,$30,$60,$01,$00,$30,$41,$1A+8
			; #$0040
			db $C1,$30-8,$00,$30+3
			db $FF
		
		warnpc $009C66
	endif
	
	if !widetype == !extra
		org $9C1F
			; #$0000
			db $41,$0F,$C1,$30,$00,$10,$42,$20
			; #$0008
			db $41,$70,$81,$11,$00,$80,$82,$0C
			; #$0010
			db $00,$30,$C1,$30,$41,$60-12,$C1,$10+6
			; #$0018
			db $41,$20,($00),$20,$01,$30,$E1,$01,$00,$60
			; #$0020
			db $41,$4E,$80,$10,$00,$30,$41,$58+3
			; #$0028
			db $00,$20,$60,$01,$00,$30,$60,$01
			; #$0030
			db $00,$30,$60,$01,$00,$30,$60,$01
			; #$0038
			db $00,$30,$60,$01,$00,$30,$41,$1A+8
			; #$0040
			db $C1,$30-8,$00,$30+3
			db $FF
		
		warnpc $009C66	
	endif
pullpc

;- Title screen border
;=====================

pushpc
	org $0084D0+3
		dl title_screen_border
pullpc

; Select based on the type of patch.
if !widetype == !normal
	title_screen_border:
		incbin "title-screen.stim"
endif

if !widetype == !extra
	title_screen_border:
		incbin "title-screen-extrawide.stim"
endif

if !widetype == !ultra
	title_screen_border:
		incbin "title-screen-ultrawide.stim"
endif

if !widetype == !hyper
	;title_screen_border:
	;	incbin "title-screen.stim"
endif
