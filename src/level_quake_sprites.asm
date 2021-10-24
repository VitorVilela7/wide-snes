;===============================================================
; Code responsible for adding quake sprites support
; for Widescreen SMW
;===============================================================

;- Quake sprites
;===============

pushpc
	; Quake sprites doesn't appear on screen, it's an invisible
	; box that comes when you hit any block which if any sprite
	; touches that invisible square it's stomped immediately.
	
	; The only thing I noticed it's this typo, storing to high Y
	; instead of high X. So it's fixed now.
	
	org $0286D6
		STA $16D5|!addr,y

pullpc
