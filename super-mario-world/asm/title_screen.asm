;===============================================================
; Special patch for dealing with title screen.
;===============================================================

pushpc

	org $0084D0+3
		dl title_screen_border

pullpc

if !ultrawide == 1
	title_screen_border:
		incbin "title-screen-ultrawide.stim"
else
	title_screen_border:
		incbin "title-screen.stim"
endif
