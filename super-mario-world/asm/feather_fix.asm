;Getting a feather during auto-scroll fix
;As you might know, if Mario gets a feather outside the display during auto-scroll, the game freezes.
;To fix this problem, patch this file to your ROM using Asar. 
;Patch created by: Romi

org $01C5AE
			; Vitor edit: give smoke regardless of
			; offscreen status.
			BRA +
			NOP #4	
		+
