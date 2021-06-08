lorom

!bank = $800000

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
endif

org $009AA4
autoclean JSL Mymain

freespace noram
Mymain:
JSL $04F675|!bank
JML $7F8000
