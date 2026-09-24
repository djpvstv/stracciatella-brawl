#####################################################################
No Powershield Buffering and Powershield Reflect v4.1 [Shanus, Magus]
#####################################################################
.alias PSA_Off  = 0x80545928
.alias PSA_Off2 = 0x80545A28
CODE @ $80545928
{
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 1
	word 1; scalar 1.0
	word 6; word 0x30
	word 0; word 3
	word 0; word 3
	word 0; word 0
	word 0; word 1
	word 6; word 7
	word 5; RA_Basic 1
	word 0; word 0
	word 1; scalar 2.0
	word 6; word 7
	word 5; IC_Basic 20001
	word 0; word 1
	word 1; scalar 26.0
	word 2; word PSA_Off+0x90
	word 0x000A0400; word PSA_Off+0x68
	word 0x000A0400; word PSA_Off
	word 0x000B0400; word PSA_Off+0x20
	word 0x12000200; word 0x80FB0BDC
	word 0x06170300; word PSA_Off+0x30
	word 0x000E0000; word 0
	word 0x000A0400; word PSA_Off+0x48
	word 0x06180300; word PSA_Off+0x30
	word 0x000F0000; word 0
	word 0x000F0000; word 0
	word 0x000F0000; word 0
	word 0x12080200; word 0x80FB0A74
	word 0x00070100; word PSA_Off2+0xE8
	word 0x00080000; word 0
}
CODE @ $80FC2158 # 80F9FC20 + 22538
{
	word 0x00070100; word PSA_Off+0x88
}
CODE @ $80FB0C5C # 80F9FC20 + 1103C
{
	word 0x00020000; word 0
}

CODE @ $80545A28
{
	word 6; word 8
	word 5; RA_Bit 10
	word 5; RA_Bit 10
	word 0; word 0x6A
	word 0; word 0x12C
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.115
	word 3; word 0
	word 0; word 0
	word 5; IC_Basic 21029
	word 0; word 0x35
	word 0; word 0x12C

	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.3
	word 3; word 0
	word 0; word 0
	word 5; IC_Basic 21029
	word 0; word 0x1EF6
	word 0; word 0x1F81
	word 2; word PSA_Off2+0xF0
	word 0x000A0200; word PSA_Off2
	word 0x120B0100; word PSA_Off2+0x10
	word 0x11010C00; word PSA_Off2+0x18
	word 0x11010C00; word PSA_Off2+0x78
	word 0x0A000100; word PSA_Off2+0xD8
	word 0x0A000100; word PSA_Off2+0xE0
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
