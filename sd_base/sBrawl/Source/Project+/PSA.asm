####################################################################################
PSA If Compare now accepts basics passed into them instead of requiring floats [Eon]
####################################################################################
#first arg
CODE @ $807827EC
{
    lwz r0, 0x0(r3)
    cmplwi r0, 1
    beq 0xC
}
HOOK @ $807827f8
{
    lwz r0, 0x4(r3)
    xoris r0, r0, 0x8000
    stw r0, 0x4FC(r1)
    lfd f1, 0x4F8(r1)
    lfd f2, 0x150(r31)
    fsubs f1, f1, f2
}
#second arg
CODE @ $807828C8 
{
    lwz r0, 0x0(r3)
    cmpwi r0, 0x5
    beq 0xC
    nop #this is that hook below this 
    b 0x44 
}
HOOK @ $807828D4
{
    lwz r0, 0x4(r3)
    xoris r0, r0, 0x8000
    stw r0, 0x4FC(r1)
    lfd f1, 0x4F8(r1)
    lfd f2, 0x150(r31)
    fsubs f1, f1, f2
}