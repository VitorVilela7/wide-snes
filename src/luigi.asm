;===============================================================
; Luigi
;===============================================================

!prev = $317E

pushpc
	org $049DD6
		JSL SwitchPlayer
	
	org $009AAD
		JSL Title

	org $00A0B9
		JML Select3

pullpc

Select:
	JSL dma_gfx

	LDA $1426|!addr
	BEQ +
	JML $00A1DF

+	JML $00A1E4

SwitchPlayer:
	STA $0DB3|!addr
	TAX
	JML dma_gfx

Title:
	LDA #$33
	STA $41
	BRA dma_gfx
	
Select3:
	JSL dma_gfx
	STZ $0DDA|!addr
	LDX $0DB3|!addr
	JML $00A0BF
	
dma_gfx:
	LDA $0DB3|!addr
	CMP !prev
	BEQ +
	STA !prev
	
	ASL #2
	PHX
	TAX
	
	REP #$20
	LDA.l player_ptrs,x
	STA $4302
	LDA.l player_ptrs+2,x
	STA $4304
	
	STZ $2181
	LDA #$0020
	STA $2182
	
	LDA #$8000
	STA $4300
	LDA #$5D00
	STA $4305
	
	LDX #$01
	STX $420B

	SEP #$20
	PLX
+	RTL

player_ptrs:
	dl mario : db $00
	dl luigi : db $00

pushpc
	freedata cleaned
	
	luigi:
		incbin "!mario_bin"
	
	freedata cleaned
	
	mario:
		incbin "!luigi_bin"

pullpc
