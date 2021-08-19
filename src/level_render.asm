;===============================================================
; Code responsible for offseting and adjusting layer 1/2/3
; render on widescreen area.
;
; Includes camera-related code, rendering related (map16) code,
; etc.
;===============================================================

;- X-scroll fix
;==============

;pushpc
;	org $009708
;		JSL x_scroll_fix
;pullpc

; fix originally provided by Alcaro and it's required to camera
; bounds work as expected. this fix is not needed for LM 3.01+,
; keep this in mind for ROM hacks.

; basically SMW does not set the screen width on initialization,
; which makes the scrolling routine does not work correctly on
; screen edges (when you spawn nearby end of the level right
; bound)

;x_scroll_fix:
;	LDA [$65]
;	AND #$1F
;	INC A
;	STA $5E
;	
;	;I don't know why that's needed on LM3+
;	JSL $00F6DB
;	
;	RTL

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
	
;- Level specific scrolling configuration
;========================================

pushpc
	org $05D923
		JSL horz_customizer
		NOP
pullpc

; The camera is updated by the scroll routine and most of the
; time is recentered. This section makes sure that the
; selected level won't do that and will ensure the camera will
; stay centered relative to the widescreen region.

horz_customizer:
	; if it's ghost house bonus, disable scrolling
	LDA #$01
	CPY #$00FA
	BNE +
	DEC
+	STA $1411|!addr

	; set initial layer 1 position to #$0100
	; if top secret area
	CPY #$0003
	BEQ ++
	; big boo fight
	CPY #$00E4
	BEQ ++
	; yoshi's house
	CPY #$0104
	BNE +
++	STZ $1A
	STA $1B
	; required to the camera not end up adjusted again
	STZ $1411|!addr
+

	; special case for wendy
	CPY #$00D3
	BEQ ++
	; special case for lemmy
	CPY #$01F2
	BEQ ++
	; special case for cloud sublevel
	CPY #$01C9
	BNE +
++	STZ $1A
	LDA #$04
	STA $1B
	; required to the camera not end up adjusted again
	STZ $1411|!addr

+	RTL

;- Kill mario if too away from camera
;====================================

;CODE_00E9A1:        A5 7E         LDA $7E                   ;\If mario is much far to the right of the screen
;CODE_00E9A3:        C9 F0         CMP.B #$F0                ;|(position 1 block left from right edge), branch
;CODE_00E9A5:        B0 61         BCS CODE_00EA08           ;/

pushpc
	org $00E9A1
		JSL check_player_camera
pullpc

check_player_camera:
	REP #$21
	LDA $7E
	ADC.w #$0000+!extra_columns
	CMP.w #$00F0+!extra_columns+!extra_columns
	SEP #$20
	RTL
	
;- Vertical level with layer 1+2 scroll
;======================================

; Layer 1+2 vertical levels
pushpc
	org $05BEBC
		JML l2_vertx_h

	; this fixes a sign overflow, causing layer 2 sideways
	; long scroll sprite not work on widescreen mode.
	org $05BEFE
		AND #$01FF
pullpc

l2_vertx_h:
	LDA #$0000+!extra_columns
	STA $1A
	STA $1462|!addr
	STA $1E
	STA $1466|!addr
	
	JML $05BEC6|!bank

;- Regular level scroll initialization
;=====================================

; NOTE: seems to fix both horizontal and vertical levels.
; Not all horizontal levels were affected, for some reason.

pushpc
	org $05D849
		JSL init_scroll

pullpc

; Makes sure the initial position is correct
; and widescreen.	
init_scroll:
	LDA.w #!extra_columns
	STA $1A
	STA $1E
	RTL

;- Override LM behavior
;======================

; Only required if you use a recent version
; of Lunar Magic. In case this is addressed
; by LM, it's required to this be removed.

pushpc
	org $05DA1C
		JML l2_workaround
		
pullpc

l2_workaround:
	; preserve
	PHA
	
	; offset
	REP #$21
	LDA $1E
	ADC.w #!extra_columns
	STA $1E
	SEP #$20
	
	; restore
	PLA	
	CMP #$52
	BCC CODE_05DA24
	
	JML $05DA20|!bank
	
CODE_05DA24:
	JML $05DA24|!bank
