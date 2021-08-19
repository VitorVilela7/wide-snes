        ;lorom
        !bank   = $800000
if read1($00FFD5) == $23
        ;sa1rom
        !bank   = $000000
endif

; Well, LM writes 94-97 at 05D97D :duk:
; so this needed to be moved down
;org $05D971
;        autoclean JSL Mymain

org $05D984
		autoclean JSL Mymain0
org $05D9FC
        autoclean JML Mymain2
org $05DA03
        autoclean JSL Mymain3

freedata
Mymain0:
		STA $02
		AND #$03
		XBA
		
		; this is important
		PHA
		LDA $94
        STA $D1
        LDA $95
        STA $D2
        LDA $96
        STA $D3
        LDA $97
        STA $D4
		PLA
		
		XBA
        RTL

Mymain2:
        STA $95
        STA $D2
        JML $05DA17|!bank

Mymain3:
        STA $97
        STA $D4
        STA $1D
        RTL
