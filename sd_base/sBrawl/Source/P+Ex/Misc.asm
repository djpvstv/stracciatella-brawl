######################################
Grabboxes work out of any action [Eon]
######################################
op nop @ $8083D250
op nop @ $8083D25C

###################################################
Falco can use his own final smash files [DukeItOut]
###################################################
op b 0x58 @ $8084D5B8
op b 0x5C @ $8084D450

########################################
!RSP Load Character Swap Fix [DukeItOut]
########################################
op NOP  @ $8069705C			# Disabled by default. Taken from "CostumeAddition.asm". Suppress an unnecessary character texture read that would otherwise double load times! Use only if utilizing RSP loading with an Ex build.

###############################################
Mario Fireballs are Costume Based [codes, ds22]
###############################################
# Prevent storing resource ID for textures, as the hijack below sets it
op nop @ $809E8138

# Hijacks the function active/[wnMarioFireball]
HOOK @ $809E8124
{
  start:
    # get player index (0-3 for players 1-4)
    lwz r31, 0x18(r25)
    lwz r31, 0x18(r31)
    lwz r31, 0x5C(r31)
    lwz r31, 0xC4(r31)
    lbz r31, 0x55(r31)
    
    # follow pointer chain to get fighter ID
    lwz r25, 0x18(r25)
    lwz r25, 0x8(r25)
    lwz r25, 0x110(r25)

    # check if the fighter IDs are the ones we care about
    cmpwi r25, 0x4A			#Merkava
    beq- be_costume_based	#If you wish to add more Mario Clone IDs to the check, copy these two lines, and paste them underneath this line, then edit the ID to check for.
    b act_normally

  be_costume_based:
    # read into the resources list for the fighter,
    # indexing with our player index,
    # as well as a small offset which should be near where we're looking for
    lis r25, 0x80B8
    lwz r25, 0x7C50(r25)
    lwz r25, 0(r25)
    mulli r31, r31, 0x4D4
    add r25, r25, r31
    addi r25, r25, 0x18

  search_loop:
    # loop through until we pass over a value less than 0xFF.
    # words around this place can often be 0xFFFF 
    lwzu r4, 4(r25)
    cmpwi r4, 0xFF
    bge+ search_loop

    # store a value indicating the resource ID for the costume file
    # in place of the one for the MotionEtc
    stw r4, 0x2C(r1)
    b end

  act_normally:
    # this is the line NOP'd by the gecko write
    stw r5, 0x2C(r1)

  end:
    # restore hijacked code
    mr r31, r3
}

#########################################################################
Main Send Param Values Above 127 Increase Sound Volume v1.1.0 [QuickLava]
# Description:       
#        Allows MainSend values above 127 to scale up a sound's volume.
#        Sound volume scales from 1.0x at 127 to 3.0x at 255.
# Hooks:    SetMainOutVolume/[nw4r3snd6detail5VoiceFf]/snd_Voice.o
# Hooks:    Update/[nw4r3snd6detail7ChannelFb]/snd_Channel.o
#            
#########################################################################
HOOK @ $801d1474
{
    fadd f2, f2, f2                # Double Main Volume Cap to 2.0
    fadd f2, f2, f2                # Double Main Volume Cap to 4.0
    fcmpo    cr0,f1,f2            # Restore Original Instruction
}
HOOK @ $801be148
{
    fsub f2, f2, f2                # Zero out f2
    fcmpo cr0, f24, f2            # Compare f24 (Main Send Float) to f2 (0.0)
    ble SkipVolumeBoost

    lfs f2, -0x5CE0(r2)            # Set f2 to 1.0
    fadd f24, f24, f24            # Double Main Send, so Volume scales to 3x instead of 2x
    fadd f24, f24, f2            # Add 1.0 to Main Send (so multiplying it into f1 raises it)
    fmul f1, f1, f24            # Multiply Volume by Main Send
    fsub f24, f24, f2            # Subtract the 1.0 back out of Main Send
    lfs f24, -0x5CDC(r2)        # Set Main Send back to 0.0 (the normal cap)
    
SkipVolumeBoost:
    lwz r3, 0xDC(r30)            # Restore original instruction
}

##############################################
WDSK FFFF = Weight Independant KB (MarioDox)
##############################################
HOOK @ $80769ecc #notifyEventCollsionHit2nd/[soDamageModuleImpl]
{
    lwz r0, 0x1C(r27) #original op, get wdsk
    cmplwi r0, 0xFFFF
    bne+ %END%
    lis r0, 0x3FF0        #\ Write 1 in float
    stw r0, 0x1C(r27)    #| Store it somewhere safe
    lfs f1, 0x1C(r27)    #/ Use it in weight calculations
    li r0, 0
    stw r0, 0x1C(r27)    # Reset to 0 to avoid problems
}

##########################################################################
Holding start on game end screen clears everyone (after 0.5 seconds) [Eon]
##########################################################################
HOOK @ $800ED340
{
    lwz r0, 0x218(r1)
    rlwinm. r0, r0, 0, 19, 19 # check if start held
    add r3, r27, r28
    bne inc
reset: #reset counter to 0
    li r4, 0
    stb r4, 0x68(r3)
    b end
inc: #count frames
    lbz r4, 0x68(r3)
    addi r4, r4, 1
    stb r4, 0x68(r3)
    cmpwi r4, 30
    blt end
#if start held for 30 frames then play sound and close results
playSelectSound:
    lwz r3, -0x4250(r13)
    li r4, 1
    li r5, -1
    li r6, 0
    li r7, 0
    li r8, -1
    lis r12, 0x8007
    ori r12, r12, 0x42B0
    mtctr r12 
    bctrl 
closeAllPlayers:
    li r28, 0
    lis r29, 0x800E
    ori r29, r29, 0x8040
loop:
    mr r3, r27
    mr r4, r28
    li r5, 1
    mtctr r29
    bctrl 
    addi r28, r28, 1
    cmpwi r28, 0x4
    blt loop
exit:
    lis r12, 0x800E
    ori r12, r12, 0xD43C
    mtctr r12 
    bctr
end:
    lwz r0, 0x21C(r1) #original command = check if B button pressed
}

##################################################################################
Additional Item Search Target Modes [Kapedani]
#                                                                                  #
# 0xX14: TeamOwnerTaskId | where 0xX + 0x12B = nodeId, 0 for just regular position #
####################################################################################
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

HOOK @ $8099234c    # BaseItem::searchTarget
{
    andi. r10, r30, 0xff    # filter extra parameters out to get option
    cmplwi r10, 20      # \ check if additional option 0x14
    bne+ %end%          # /
    lwz r3, 0x60(r27)   # \
    lwz r3, 0xd8(r3)    # |
    lwz r3, 0x18(r3)    # |
    lwz r12, 0x0(r3)    # | this->moduleAccesser->moduleEnumeration->teamModule->getTeamOwnerId()
    lwz r12, 0x28(r12)  # |
    mtctr r12           # |
    bctrl               # /
    %branch (0x80992924)     # branch to emitterTaskId case (case 6) but with teamOwnerTaskId in r3
}
op rlwinm r0, r10, 2, 0, 29 @ $80992358

HOOK @ $80992984
{
    stw	r0, 0x0(r28)  # Original operation
    rlwinm. r10,r30,24,28,31  # \ check if selected node is 0 (get pos if it is)
    beq+ %end%                # / mask and shift (value >> 8) & 0xf
    ## Get special node pos
    lwz r22, 0x60(r4)       # \
    addi r4, r10, 0x12B     # |
    lwz r22, 0xd8(r22)      # |
    lwz r3, 0x4(r22)        # | 
    lwz r12, 0x8(r3)        # | nodeId = stageObject->moduleAccesser->moduleEnumeration->modelModule->getCorectNodeId(0x12B + node)
    lwz r12, 0x8c(r12)      # |
    mtctr r12               # |
    bctrl                   # /
    mr r5, r3               # \
    li r6, 0x0              # |
    addi r3, r1, 80         # |
    lwz r4, 0x4(r22)        # |
    lwz r12, 0x8(r4)        # | pos = moduleEnumeration->modelModule->getNodeGlobalPosition(nodeId)
    lwz r12, 0x98(r12)      # |
    mtctr r12               # |
    bctrl                   # /
    %branch (0x8099298c)
}