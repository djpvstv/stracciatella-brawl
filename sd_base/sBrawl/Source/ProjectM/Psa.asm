#############################################################
[Project+] C-stick Functions Correctly During Crawl 2.1 [Eon]
#############################################################
.alias PSA_Off = 0x80540EE0
CODE @ $80FAECFC
{
	word 0x00070100; word PSA_Off
}
CODE @ $80FAEE9C
{
	word 0x00070100; word PSA_Off
}
CODE @ $80540EE0
{
	word 0x00000002; word PSA_Off+0x28
	word 6; word 7
	word 5; IC_Basic 1018
	word 0; word 1
	word 5; IC_Basic 3133
	word 0x02040100; word 0x80FAEC5C
	word 0x02040400; word PSA_Off+0x08
	word 0x00080000; word 0
}
