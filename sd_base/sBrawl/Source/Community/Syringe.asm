#######################################################
Reduce InfoInstance in SSE v2 [Sammi Husky, Kapedani]
######################################################
word 0x12B440 @ $80421f9c
word 0x12B440 @ $8042204C # Great Maze save room

#################################################
Don't clear memory on game launch [Sammi Husky]
#################################################
op nop @ $801d5f64
op nop @ $801d5f68

#######################################################
run codehandler after initializing memory [Sammi Husky]
#######################################################
HOOK @ $80016c30 
{
    # __memfill
    lis r12, 0x8000
    ori r12, r12, 0x443c
    mtctr r12
    bctrl
    
    # codehandler
    lis r12, 0x8000
    ori r12, r12, 0x18a8
    mtctr r12
    bctrl
    
}

##################################################
run codehandler after loading rels [Sammi Husky]
##################################################
HOOK @ $800272b8
{
    stwu r1, -0x80(r1)
    mflr r0
    stw r0, 0x84(r1)
    stmw r3, 8(r1)
    
    # codehandler
    lis r12, 0x8000
    ori r12, r12, 0x18a8
    mtctr r12
    bctrl
    
    lmw r3, 8(r1)
    lwz r0, 0x84(r1)
    mtlr r0
    addi r1, r1, 0x80
    
    lwz r4, 0x0(r30)
}



#############################################
Syringe Core Loader [Sammi Husky, Exul Anima]
#############################################

#######################
# Create Syringe heap #
#######################
HOOK @ $800244E4
{
    ## NOTE:
    ## This build has reduced the size of MeleeFont to make room for Syringe
    ## in the now freed space. The reason why the Syringe heap isn't just at the end is to prevent
    ## any internal shifts of the memory map that could compromise hardcoded patches we may not know about.

    ## NOTE:
    ## Tmp always comes before MeleeFont, so we squeeze in Syringe between 
    ## the two if Tmp is about to be allocated.

    lwz r3, 0x4(r30)    # \ If Tmp heap is about to be allocated, allocate Syringe before it.
    cmplwi r3, 0xC      # /
    bne _end            # Otherwise skip to end.
    
    # simple stack frame
    stwu r1, -0xa0(r1)
    mflr r0
    stw r0, 0xa4(r1)
    stmw r3, 0x20(r1)   # store all our registers on the stack
    bl _main            # branch to our main code, this puts data section addr in LR

    #############################
    # pseudo data section
    #############################
    word 0x20800    # Syringe heap size
    
    word 0x53797269 # "Syriinge"
    word 0x696E6765
    word 0x00000000
    #############################

_main:
    mflr r31

_createHeap:
    li r3, 0x3C         # heap ID 60
    addi r4, r31, 0x4   # "Syriinge"
    lis r5, 0x0         # heap in MEM1 (arena 0)
    lwz r6, 0x0(r31)    # heap size
    lis r12, 0x8002
    ori r12, r12, 0x4544
    mtctr r12
    bctrl   # createHeap/[gfHeapManager]

    # clean up our stack frame
    lmw r3, 0x20(r1)
    lwz r0, 0xa4(r1)
    mtlr r0
    addi r1, r1, 0xa0

_end:
    lwz r4, 0x0(r30)    # Original instruction.
}

#####################
# Load Syringe core #
#####################
HOOK @ $800180a0
{
    # simple stack frame
    stwu r1, -0xa0(r1)
    mflr r0
    stw r0, 0xa4(r1)
    stmw r3, 0x20(r1)   # store all our registers on the stack
    bl _main            # branch to our main code, this puts data section addr in LR

    #############################
    # pseudo data section
    #############################
    word 0x6476643A # "dvd:/module/sy_core.rel"
    word 0x2F6D6F64
    word 0x756C652F
    word 0x73795F63
    word 0x6F72652E
    word 0x72656C00
    #############################

_main:
    mflr r31

_loadModule:
    li r6, 0            # \ Zero out space on the stack for 
    stw r6, 0x8(r1)     # / gfFileIOHandle object

    # ---------------------- #
    # gfFileIOHandle::read
    # ---------------------- #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    addi r4, r31, 0x0   # "dvd:/module/sy_core.rel"
    li r5, 0x3c         # Syringe heap id
    lis r12, 0x8002
    ori r12, r12, 0x19e0
    mtctr r12
    bctrl

    # ----------------------- #
    # gfHeapManager::getHeap
    # ----------------------- #
    li r3, 0x3c         # Syringe heap id
    lis r12, 0x8002
    ori r12, r12, 0x49cc
    mtctr r12
    bctrl
    mr r28, r3

    # ------------------------ #
    # gfFilIOHandle::getBuffer
    # ------------------------ #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1f94
    mtctr r12
    bctrl
    mr r27, r3

    # ---------------------- #
    # gfFilIOHandle::getSize
    # ---------------------- #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1f88
    mtctr r12
    bctrl
    mr r26, r3

    # ------------------ #
    # gfModule::create
    # ------------------ #
    mr r3, r28          # syringe heap addr we got earlier
    mr r4, r27          # rel file data buffer
    mr r5, r26          # rel filesize
    lis r12, 0x8002
    ori r12, r12, 0x64d8
    mtctr r12
    bctrl

    # ----------------- #
    # module->_prolog
    # ----------------- #
    lwz r3, 0(r3)
    lwz r12, 0x34(r3)
    mtctr r12
    bctrl

    # ------------------------ #
    # gfFileIOHandle::release
    # ------------------------ #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1fac
    mtctr r12
    bctrl

    # clean up our stack frame
    lmw r3, 0x20(r1)
    lwz r0, 0xa4(r1)
    mtlr r0
    addi r1, r1, 0xa0

    li r5, 0x32 # original instruction
}