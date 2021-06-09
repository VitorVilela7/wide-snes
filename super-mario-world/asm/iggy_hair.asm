;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Iggy Hair Fix, by Mattrizzle, 
; Thanks to mikeyk for the full disassembly
; 
; This xkas patch gives Iggy's hair its correct graphics,
; instead of reusing Larry's hair.
;
; As far as I can tell, this is bug-free, but let me know if
; you find any problems.
;
; The blank space at the end of bank 01 is used by this. Beware
; of overwritten data! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
	!C2   = $D8
	!D8   = $3216
	!E4   = $322C
	!14D4 = $3258
	!14E0 = $326E
else
	lorom
	!addr = $0000
	!bank = $800000
	!C2   = $C2
	!D8   = $D8
	!E4   = $E4
	!14D4 = $14D4
	!14E0 = $14E0
endif

org $01FA9A|!bank
                    jsr ADDR_01FF98

org $01FC5E|!bank
                    jsr SHELL_SPIN

org $01FE9C|!bank
                    db $FC                  ; replace duplicate hair tile in turning frame with a blank tile

org $01FF14|!bank
                    bne NOT_IGGY           
                    cmp #$05                
                    bcs NOT_IGGY           
                    lsr                       
                    tax                       
                    lda.w $01FEB3|!bank,X       
                    sta $0302|!addr,Y             

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of modified data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    lda $02FE|!addr,Y
                    cmp #$0C                ;  If tile 0C... (Larry's hair)
                    bne HAIR_TILE2
                    lda #$1A                ;  Replace with tile 1A (Iggy's hair)
                    bra STORE_TILE
HAIR_TILE2:         cmp #$1C                ;  If tile 1C... (Larry's Hair while turning)
                    bne NOT_IGGY
                    lda #$1B                ;  Replace with tile 1B (Iggy's hair while turning)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of modified data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STORE_TILE:         sta $02FE|!addr,Y       
NOT_IGGY:           lda $0302|!addr,Y             
                    cmp #$4A                
                    lda $0D                   
                    bcc ADDR_01FF2D           
                    lda #$35                ;  Iggy ball palette 
ADDR_01FF2D:        ora $02                   
                    sta $0303|!addr,Y             
                    pla                       
                    and #$03                
                    tax                       
                    phy                       
                    tya                       
                    lsr                       
                    lsr                       
                    tay                       
                    lda.w $01FEB6|!bank,X       
                    sta $0460|!addr,Y             
                    ply                       
                    iny                       
                    iny                       
                    iny                       
                    iny                       
                    plx                       
                    dex                       
                    bpl BACK
                    plx                       
                    ldy #$FF                
                    lda #$03                
                    jsr.w $01B7BB|!bank         
                    rts                       ; Return 

BACK:               jmp.w $01FEDE|!bank

DATA_01FF53:        db $2C,$2E,$2C,$2E

DATA_01FF57:        db $00,$00,$40,$00

SHELL_SPIN:         phx                       
                    ldy !C2,X                 
                    lda.w $01FEB7|!bank,Y       
                    sta $0D                   
                    ldy #$70                
                    lda $14B8|!addr               
                    sec                       
                    sbc #$08                
                    sta $0300|!addr,Y             
                    lda $14BA|!addr               
                    clc                       
                    adc #$60                
                    sta $0301|!addr,Y             
                    lda $14                   
                    lsr                       
                    and #$03                
                    tax                       
                    lda.w DATA_01FF53,X       
                    sta $0302|!addr,Y             
                    lda #$30                
                    ora.w DATA_01FF57,X       
                    ora $0D                   
                    sta $0303|!addr,Y             
                    tya                       
                    lsr                       
                    lsr                       
                    tay                       
                    lda #$02                
                    sta $0460|!addr,Y             
                    plx                       
                    rts                       ; Return 

ADDR_01FF98:        lda !E4,X                 
                    clc                       
                    adc #$08                
                    sta $14B4|!addr               
                    lda !14E0,X             
                    adc #$00                
                    sta $14B5|!addr               
                    lda !D8,X                 
                    clc                       
                    adc #$0F                
                    sta $14B6|!addr               
                    lda !14D4,X             
                    adc #$00                
                    sta $14B7|!addr               
                    phx                       
                    jsl $01CC9D|!bank         
                    plx                       
                    rts                       ; Return 

                    ;padbyte $FF : pad $028000 ; You can remove the ";" from the beginning of this line if you're not using the Classic Piranha Plant Fix patch