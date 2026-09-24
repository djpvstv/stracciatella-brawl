#############################################
CSS Rules goes to Main Menu Rules [MarioDox, Squidgy]
#############################################
.alias RulesState = 0x80002860
.alias RulesStateHi = RulesState / 0x10000
.alias RulesStateLo = RulesState & 0xFFFF
# $80002860 = Rules State, used to check if it's custom rules:
# 0x1 = CSS to Rules transition
# 0x2 = in Menu Rules
# 0x3 = Rules to CSS transition
# we replace the normal CSS function to change to rule as it won't be used at all
CODE @ $80692ea8	#changeToRule/[muSelCharTask]
{
    li r3,0x1					# \ CUSTOM RULES STATE: IN TRANSITION
    lis r12,RulesStateHi		# |
    stw r3,RulesStateLo(r12)	# /

    lis r12,0x8002				# \ getInstance/[gfSceneManager]
    ori r12,r12,0xd018			# |
    mtctr r12					# |
    bctrl						# /

    li r12,0x0					# \
    stw r12,0x284(r3)			# | flags used to trigger scene change
    li r12,0x2					# |
    stw r12,0x288(r3)			# /

    mr r3,r31
    lis r12,0x8068              # \
    ori r12,r12,0x46e0          # | setToGlobal/[muSelCharTask]
    mtctr r12                   # |
    bctrl                       # /
end:
	lwz r0,0x24(r1)
	mtlr r0
	addi r1,r1,32
	blr
}

# moved to sora_menu_main.rel
# selects rules and hides the menu behind
# Moved back here? Idk how to get it to work
HOOK @ $8117a4bc				# init/[muProcVs] (maps have wrong function names here)
{
	lis r12,RulesStateHi
	lwz r12,RulesStateLo(r12)
	cmpwi r12,0x1				# CUSTOM RULES STATE: IN TRANSITION
	bne- end
	cmpwi r30,0x0				# check if it's also returning from versus, just in case
	bne- end
	li r30,0x4					# \ set selected button to VS's rules button
	sth r30,0x42(r31)			# /

	lis r12,0x3					# \ set menu control to rules
	stw r12,0x664(r31)			# / so other menu buttons can't be clicked

	lis r12,0x8117				# \ skip setSelectAnim[muProcMenu]
	ori r12,r12,0xa4d0			# |
	mtctr r12					# |
	bctr						# /
end:
	sth r30,0x42(r31)			# original op
}

# handles opening and closing the new rules menu
HOOK @ $806ce938				# process/[muMenuMain]
{
	lis r12,RulesStateHi
	lwz r12,RulesStateLo(r12)
	cmpwi r31,0x1				# are we closing rules?
	beq- customRulesClose
	cmpwi r31,0x0				# check if we're not doing anything with rules (safety check)
	bne- end
	cmpwi r12,0x1				# CUSTOM RULES STATE: IN TRANSITION
	bne- end
	li r6,0x1					# \ important flags
	li r30,0x1E					# /
	li r31,0x2					# lie and say we pressed A
	li r5,0x2					# CUSTOM RULES STATE: IN RULES
	lis r12,RulesStateHi		# \ write flag
	stw r5,RulesStateLo(r12)	# /
	b end
customRulesClose:
	cmpwi r12,0x2				# CUSTOM RULES STATE: IN RULES
	bne- end

    # portion of code normally called from process/[muMenuMain] to adjust the frame buffer
    lis r12,0x8002              # \ getInstance/[gfFrameBuffer]
    ori r12,r12,0x3ac8          # |
    mtctr r12                   # |
    bctrl                       # /
    li r12,0x0
    stb r12,0x2C(r3)            # \ frame buffer now set to color 00000000
    stb r12,0x2D(r3)            # |
    stb r12,0x2E(r3)            # |
    stb r12,0x2F(r3)            # /


    lis r12,0x8068				# \ getSelCharType/[muSelCharTask] (this is kept until reopening the css)
    ori r12,r12,0x3b28			# | 
    mtctr r12					# |
    bctrl						# /
    cmpwi r3,0x2				# is special vs?
    li r5,0x3
    beq- changeScene
    li r5,0x1

changeScene:
    lis r12,0x8002				# \ getInstance/[gfSceneManager]
    ori r12,r12,0xd018			# |
    mtctr r12					# |
    bctrl						# /

    stw r5,0x284(r3)			# \ css flag
    li r12,0x2					# | setting up flags for scene change
    stw r12,0x288(r3)			# / scene change flag

    lis r12,0x805a				# \ gfKeepFrameBuffer
    lwz r3,-0x54(r12)			# |
    addi r3,r3,208				# /

    lis r12,0x8002				# \ render/[gfKeepFrameBuffer]
    ori r12,r12,0x4e20			# |
    mtctr r12					# |
    bctrl						# /

	li r5,0x0					# CUSTOM RULES STATE: NO RULES
	lis r12,RulesStateHi		# \ write flag
	stw r5,RulesStateLo(r12)	# /
end:
	cmpwi r31,0x2				# original op
}

# moved to sora_menu_main.rel
# hide special versus settings menu
HOOK @ $81190b04				# init/[muProcSpecial] (function map wrong again)
{
	lis r12,RulesStateHi
	lwz r12,RulesStateLo(r12)
	cmpwi r12,0x1				# CUSTOM RULES STATE: IN TRANSITION
	bne- end
	lis r12,0x8119				# \ skip to the end of this function
	ori r12,r12,0x0eac			# |
	mtctr r12					# |
	bctr						# /
end:
	li r0,0x0					# original op
}