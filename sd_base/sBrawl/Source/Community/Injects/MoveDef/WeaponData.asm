######################################################
BrawlEx Weapon Data Patches [MarioDox, Phantom Wings]
######################################################
# link start

.macro LinkPatch()
{
	lwz r3,0x0(r3)
	mulli r0,r4,0xC
	lwzx r3,r3,r0
}

CODE @ $808527B0	#getLinkBowParam/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	nop
	%LinkPatch()
	lwz r3,0x7C(r3)
	blr
	lwz r3,0x0(r3)
	mulli r0,r4,0xC
	lwzx r3,r3,r0
}

CODE @ $80852848	#getWeaponData12/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	%LinkPatch()
}

CODE @ $808528D8	#getWeaponData13/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	%LinkPatch()
}

CODE @ $80852910	#getWeaponData14/[ftCommonDataAccesser]
{
	%LinkPatch()
}

CODE @ $80852924	#getWeaponData15/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	%LinkPatch()
}

# v also shared by toon link v
op li r3,0x1 @ $80893cf8	#is_link_final_captured/[soModuleAccesser]

CODE @ $809e9918	#exitStatus/[ftLinkStatusUniqProcessSpecialBow]
{
	cmpwi r3,0x5
	beq 0x5C
	mr r4,r3
	nop
	nop
}

## toonlink start

.macro ToonLinkPatch()
{
	lwz r3,0x0(r3)
	mulli r4,r4,0xC
	lwzx r3,r3,r4
}

CODE @ $808543a0	#getToonLinkBowParam/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	nop
	cmpwi r4,0x5
	beq 0x18
	%ToonLinkPatch()
}

CODE @ $80854448	#getWeaponData143/[ftCommonDataAccesser]
{
	nop
	%ToonLinkPatch()
}

CODE @ $808544D8	#getWeaponData144/[ftCommonDataAccesser]
{
	nop
	%ToonLinkPatch()
}

CODE @ $80854508	#getWeaponData145/[ftCommonDataAccesser]
{
	%ToonLinkPatch()
}

CODE @ $8085451c	#getWeaponData146/[ftCommonDataAccesser]
{
	nop
	nop
	nop
	%ToonLinkPatch()
}

CODE @ $80ab0bb0	#exitStatus/[ftToonLinkStatusUniqProcessSpecialBow]
{
	nop
	nop
	nop
	nop
	mr r4,r3
}

## pikachu start

.macro PikachuPatch()
{
	lwz r3,0x0(r3)
	mulli r4,r4,0xC
	lwzx r3,r3,r4
}

CODE @ $80852abc	#getWeaponData30/[ftCommonDataAccesser]
{
	%PikachuPatch()
}

CODE @ $80852b38	#getWeaponData31/[ftCommonDataAccesser]
{
	%PikachuPatch()
}

CODE @ $80852b70	#getWeaponData32/[ftCommonDataAccesser]
{
	%PikachuPatch()
}

CODE @ $80852b84	#getWeaponData33/[ftCommonDataAccesser]
{
	%PikachuPatch()
}

CODE @ $80852b98	#getWeaponData34/[ftCommonDataAccesser]
{
	%PikachuPatch()
}

## wolf start

.macro WolfPatch()
{
	lwz r3,0x0(r3)
	mulli r4,r4,0xC
	lwzx r3,r3,r4
}

CODE @ $80852f1c	#getWeaponData51/[ftCommonDataAccesser]
{
	%WolfPatch()
	lwz r3,0xA8(r3)
	blr
	b -0x14
}

CODE @ $80852f84	#getWeaponData52/[ftCommonDataAccesser]
{
	%WolfPatch()
	lwz r3,0xAC(r3)
	blr
	b -0x14
}

CODE @ $808530dc	#getWeaponData56/[ftCommonDataAccesser]
{
	stwu r1,-0x10(r1)
	mflr r0
	stw r0,0x14(r1)
	stw r31,0xC(r1)
	nop
	nop
	nop
	nop
	cmpwi r4,0x5
	beq 0x18
	%WolfPatch()
}

CODE @ $80853170	#getWeaponData57/[ftCommonDataAccesser]
{
	stwu r1,-0x10(r1)
	mflr r0
	stw r0,0x14(r1)
	stw r31,0xC(r1)
	nop
	nop
	nop
	nop
	cmpwi r4,0x5
	beq 0x18
	%WolfPatch()
}


CODE @ $80853204	#getWeaponData58/[ftCommonDataAccesser]
{
	%WolfPatch()
}

CODE @ $80a1c1c8	#initStatus/[ftFoxStatusUniqProcessFinal]
{
	b 0x40
	cmpwi r3,0x2C
	beq 0x38
	b 0x34
}

## snake start

.macro SnakePatch()
{
	lwz r3,0x0(r3)
	mulli r0,r4,0xC
	lwzx r3,r3,r0
}

CODE @ $8085294C	#getWeaponData16/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852960	#getWeaponData17/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852974	#getWeaponData18/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852988	#getWeaponData19/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $8085299c	#getWeaponData20/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $808529b0	#getWeaponData21/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $808529c4	#getWeaponData22/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $808529d8	#getWeaponData23/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $808529ec	#getWeaponData24/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852a00	#getWeaponData25/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852a14	#getWeaponData26/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852a28	#getWeaponData27/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852a3c	#getWeaponData28/[ftCommonDataAccesser]
{
	%SnakePatch()
}

CODE @ $80852a50	#getWeaponData29/[ftCommonDataAccesser]
{
	%SnakePatch()
}

## pikmin start

.macro PikminPatch()
{
	lwz r3,0x0(r3)
	mulli r4,r4,0xC
	lwzx r3,r3,r4
}

CODE @ $80853594	#getWeaponData78/[ftCommonDataAccesser]
{
	%PikminPatch()
}

CODE @ $808535a8	#getWeaponData79/[ftCommonDataAccesser]
{
	%PikminPatch()
}

CODE @ $808535bc	#getWeaponData80/[ftCommonDataAccesser]
{
	%PikminPatch()
}

CODE @ $80A6BB38	#getPullOutParam/[ftPikminTransactor]
{
	cmpwi r3,0x5
	beq 0x20
	mr r4,r3
	lis r3,0x817D
	subi r3,r3,0x60C0
}