;===============================================================
; Code responsible for adding bounce sprites support
; for Widescreen SMW
;===============================================================

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
			LDA $16A1|!addr,x	
			SEC
			SBC $001C|!dp,y
			STA $01
			LDA $16A9|!addr,x	
			SBC $001D|!dp,y		
			BNE .return
		
			LDA $16A5|!addr,x
			SEC
			SBC $001A|!dp,y
			STA $00
			XBA
			
			LDA $16AD|!addr,x
			SBC $001B|!dp,y
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
			STA $0200|!addr,y
			
			SEP #$20
	
	; print pc
	warnpc $029246
	
	org $02925C
		bounce_set_msb:
			LDA $03
	
pullpc
