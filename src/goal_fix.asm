;original 5up fix by Zeldara109,
;goal fix by JackTheSpades

;set 0 if you don't want the 5ups enabled.
!5up = 1

;which sprite palette to use.
;will ALL be ignored if !5up is zero
;uncomment section below if you want to use edit 2 and 3 up regardless.
!Pal2up = $02
!Pal3up = $03
!Pal5up = $05

if read1($00FFD5) == $23
	;sa1rom
else
	;lorom
endif


if !5up
	!max = $0B	;see http://www.smwcentral.net/?p=nmap&m=smwrom#02ACE5
else				;$0A = 3up, $0B = 5up
	!max = $0A
endif

org $00FC08			; \
	CMP.b #!max+1		; | fix the glitched goal score.
	BCC +			; | Yes, that's all it takes
	LDA.b #!max		; | SMW just fucked up the numbers.
+				; /


if !5up
	org $02AEDA
		autoclean JML fix5up
		NOP

	freecode
	
	fix5up:
		BCC Return
		CPY #$0F
		LDA #!Pal2up<<1
		BCC Return
		CPY #$10
		LDA #!Pal3up<<1
		BCC Return
		LDA #!Pal5up<<1
	Return:
		JML $02AEDF|!bank
else
	org $02AEDA
		db $90, $03, $B9, $D4, $AD		;original SMW code
		
	;if you want to, uncomment.
	;org 02ADE2
	;	db !Pal2up<<1, !Pal3up<<1
endif
