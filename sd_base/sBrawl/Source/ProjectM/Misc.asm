# Moved Relative to PM
# 9019BDA0 -> 80546DB0	Grab During Jumpsquat (Jump-Canceled Grabs) 
# 9019B200 -> 80545300	Grab Has Priority over Roll
# 9019B280 -> 80545350	Teching Now has SFX
# 9019BC00 -> 80540820	Z now triggers aerials instead of air dodge

################################################################
Grab During Jumpsquat (Jump-Canceled Grabs) v3.0 [Shanus, Magus]
################################################################
.alias PSA_Off = 0x80546DB0
CODE @ $80546DB0
{
	word 2; word 0x80FA973C
	word 2; word PSA_Off+0x10
	word 0x00070100; word 0x80FAD96C
	word 0x00070100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FC1808
{
	word 0x00070100; word PSA_Off+0x08
}

#########################################
Grab Has Priority over Roll v1.2 [Shanus]
#########################################
.alias PSA_Off = 0x80545300
CODE @ $80545300
{
	word 2; word PSA_Off+0x08
	word 0x02010300; word 0x80FA970C
	word 0x02040200; word 0x80FA9724
	word 0x02040100; word 0x80FA9734
	word 0x02040100; word 0x80FAC03C
	word 0x02000401; word 0x80FACFEC
	word 0x02040400; word 0x80FAD00C
	word 0x02040400; word 0x80FAD02C
	word 0x02040100; word 0x80FAD04C
	word 0x00080000; word 0
}
CODE @ $80FAD14C		# offset D52C of 80F9FC20
{
	word 0x00070100; word PSA_Off
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}

############################################
Teching Now has SFX [Standardtoaster, Magus]
############################################
.alias PSA_Off = 0x80545350
CODE @ $80545350
{
	word 0; word 0x36
	word 0; word 0x7D
	word 2; word PSA_Off+0x18
	word 0x0A000100; word PSA_Off
	word 0x0A000100; word PSA_Off+0x08
	word 0x0A000100; word PSA_Off+0x08
#	this command sets combo counter to 0, removed to allow techchases to count in combo counter
#	word 0x0C2B0000; word 0 
	word 0x00080000; word 0
}
CODE @ $80FB5594
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB561C
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB57F4
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB5984
{
	word 0x00070100; word PSA_Off+0x10
}

###################################################################
Z now triggers aerials instead of air dodge v1.2 [Shanus, Wind Owl]
###################################################################
.alias PSA_Off = 0x80540820
CODE @ $80540820
{
	word 6; word 0x80000030 # NOT 0x30 
	word 0; word 0
	word 0x02000401; word 0x80FAA76C
	word 0x02040100; word 0x80FAA78C
	word 0x02040200; word PSA_Off
	word 0; word 0
}
op word PSA_Off+0x10 @ $80FBFF20