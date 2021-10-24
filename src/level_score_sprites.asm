;===============================================================
; Code responsible for adding score sprites support
; for Widescreen SMW
;===============================================================

; - Score sprites
;================

pushpc
	; Rewrite general algorithm for using better the
	; 65c816 architecture and handle offscreen positions.
	
	org $02AE61
		score:
			LDA $16ED|!addr,x
			STA $0E
			LDA $16F3|!addr,x
			STA $0F
			REP #$20
			LDA $001C|!dp,y
			STA $02
			LDA $001A|!dp,y
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
			STA $0200|!addr,y
			CLC
			ADC #$08
			STA $0204|!addr,y
			STZ $0D
			ROL $0D

	; print pc
	warnpc $02AEC0
	
	; unused "coin" score sprite support removed...
	org $02AEEC
		score_draw_msb:
			LDA $0F
			AND #$01
			STA $0420|!addr,y
			EOR $0D
			STA $0421|!addr,y
			RTS
	
	; print pc	
	warnpc $02AEFB
		

pullpc
