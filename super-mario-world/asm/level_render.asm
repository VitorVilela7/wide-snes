;===============================================================
; Code responsible for offseting and adjusting layer 1/2/3
; render on widescreen area.
;
; Includes camera-related code, rendering related (map16) code,
; etc.
;===============================================================

;- X-scroll fix
;==============

pushpc
	org $009708
		JSL x_scroll_fix
pullpc

; fix originally provided by Alcaro and it's required to camera
; bounds work as expected. this fix is not needed for LM 3.01+,
; keep this in mind for ROM hacks.

; basically SMW does not set the screen width on initialization,
; which makes the scrolling routine does not work correctly on
; screen edges (when you spawn nearby end of the level right
; bound)

x_scroll_fix:
	LDA [$65]
	AND #$1F
	INC A
	STA $5E
	
	;I don't remember why I added that on LM 3.00,
	;but it's not needed here.
	
	;JSL $00F6DB
	
	RTL

;- Force rendering of the whole (512px) screen
;=============================================

; This is used on 1-screen levels like intro (C5)
pushpc
	org $0580A9
		JML force_whole_render
		
	org $0580B0
		JML restore_orig_position
		
pullpc
	
force_whole_render:
	; restore old code
	STA $4D
	STA $4F
	
	; preverse $1A
	PEI ($1A)
	
	; funny enough, $5D doesn't work there.
	; the value might be temporally changed on this routine.
	LDA $5E
	DEC
	AND #$00FF
	BNE .not_needed
	
	; why #$0080? it appears that SMW changes the scrolling
	; strategy based on the odds (0,128,256,384) which fills
	; completely the rendering screen. I'm using this for me
	; favor.
	LDA.w #$0080
	STA $1A
	
.not_needed
	JML $0580AD|!bank
	
restore_orig_position:
	; restore $1A
	PLA
	STA $1A
	
	; restore
	LDA $45
	STA $47
	
	; return
	JML $0580B4|!bank