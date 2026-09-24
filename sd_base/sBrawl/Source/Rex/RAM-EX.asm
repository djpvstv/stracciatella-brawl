####################################################
Disable and Unload HOME Menu Everywhere [Exul Anima]
####################################################

op b 0x60 @ $800371AC           # Forces loading HOME Menu to always be blocked when pressing HOME button.

    /* Stubs underlying loading functions for HOME Menu. */

op blr @ $80037800
op blr @ $8003798C
op blr @ $80037244
op blr @ $80037BE4


######################################################################################################
Snapshots & Classic/All-Star Mode Results Stills Optimized Completely Out Of Network Heap [Exul Anima]
######################################################################################################

    ## NOTE:
    ## This code makes the in-game snapshot feature and results screen stills use the already-existing RGB565 framebuffer copy for their purposes instead of wastefully creating an RGBA8 copy in the Network heap.
    ## Snapshots use the framebuffer copy for conversion to JPEG images while the results screen just displays it at the end of Classic/All-Star Mode matches.
    ## While the RGB565 format crushes the colors of their captures a bit, freeing the extra 1.4MB of RAM for other needs is well worth the slight color banding.

#####################
## == Snapshots == ##
#####################

# Requires that "op li r9, 6 @ $8084FE2C" is commented out in CompressPAC.asm

HOOK @ $800F1BF4
{
    li r3, 0x0                  # Prevents RGBA8 framebuffer copy (size 1.2MB) from being created in Network heap. Apparently it won't create the copy if it's told to write it to 0x00000000. Works on console too for some reason.
    lis r4, 0x9012              # \
    ori r4, r4, 0xC800          #  > Moves JPEG encoding buffer (size 100KB) to free area of RAM early in MEM2.
    stw r4, 0x88(r21)           # /
}

HOOK @ $800F2AB8
{
    lis r4, 0x9012              # \
    ori r4, r4, 0xC800          #  > Moves JPEG encoding buffer (size 100KB) to free area of RAM early in MEM2.
    stw r4, 0x88(r3)            # /
    li r6, 0x0                  # Original instruction.
}

# Use heaps 0x28 (InfoInstance) & 0x34 (OverlayMenu) since they have enough unused RAM for converting the JPEG.
# Before anyone asks, I can't free these for characters since they're in MEM1 instead of MEM2, and character modules have more than enough space.
# MAKE SURE HEAPS IN OVERLAYMENU ARE FREED AT THE END OF SCREENSHOTTING!

# Requires "Reduce InfoInstance in SSE v2 [Sammi Husky, Kapedani]" code

HOOK @ $800F1C00
{
    li r3, 0x34					# \ Store ID of heap to allocate to.
    stw r3, 0xD4(r21)			# /
    lwz r3, 0xD4(r21)			# Original instruction.
}

HOOK @ $800F2BF8
{
    li r4, 0x28					# \ Store ID of heap to allocate to.
    stw r4, 0xD4(r31)			# /
    lwz r4, 0x88(r31)			# Original instruction.
}

HOOK @ $800F2C3C
{
    li r4, 0x28					# \ Store ID of heap to allocate to.
    stw r4, 0x4(r3)				# /
    lwz r4, 0x88(r31)			# Original instruction.
}

HOOK @ $800F1C0C
{
    stw r3, 0x88(r21)			# Original instruction.
    stw r3, 0xEC(r21)			# Stores value of allocation for later deallocation during IfSnapSaveTask destructor.
}

op li r5, 0x4 @ $800F2B5C       # Sets expected framebuffer type to RGB565.
op li r3, 0x2E @ $800387D0      # Moves JPEG quantization tables (important for JPEG encoding, size 7KB) to GameGlobal heap.

HOOK @ $800387EC
{
    mr r11, r3					# Saves r3.
    li r3, 0x2C					# \
    lis r12, 0x8002				#  \
    ori r12, r12, 0x49CC		#   > Gets address of CopyFB heap.
    mtctr r12					#  /
    bctrl						# /
    addis r3, r3, 0x9			# \
    addi r3, r3, 0x6200			#  > Offset to correct framebuffer copy.
    mr r4, r3					# /
    stw r4, 0x350(r30)          # Sets address of existing RGB565 framebuffer copy to make the screenshot from.
    mr r3, r11					# Restores r3.
}

HOOK @ $80038844
{
    mr r11, r3					# Saves r3.
    li r3, 0x2C					# \
    lis r12, 0x8002				#  \
    ori r12, r12, 0x49CC		#   > Gets address of CopyFB heap.
    mtctr r12					#  /
    bctrl						# /
    addis r3, r3, 0x9			# \
    addi r3, r3, 0x6200			#  > Offset to correct framebuffer copy.
    mr r4, r3					# /
    stw r4, 0x350(r30)          # Sets address of existing RGB565 framebuffer copy to make the screenshot from.
    mr r3, r11					# Restores r3.
}

op lwz r3, 0xEC(r29) @ $800F1D6C	# Prevents deallocation of the RGBA8 buffer in Network since it was never allocated to begin with, and instead deallocates RAM in OverlayMenu not otherwise deallocated.

########################################################
## == Classic/All-Stars Mode Results Screen Stills == ##
########################################################

HOOK @ $800DEDFC
{
    /* Checks for certain modes (either Classic or All-Star). If not either of these skip this code. */
    
    lis r12, 0x8002				# \
    ori r12, r12 0xD018			#  > Call getInstance/[gfSceneManager].
    mtctr r12					# /
    bctrl						# Scene manager address is placed into r3.
    lwz r3, 0x10 (r3)			# Load currentSequence (10th offset from scene manager) into r3.
    lwz r3, 0 (r3)				# \ Load address of currentSequence name into r3 and save for later.
    mr r11, r3					# /

    lis r4, 0x8070				# \ Load address of string "sqSingleSimple" into r4.
    ori r4, r4, 0x24D0 			# /
    lis r12, 0x803F				# \
    ori r12, r12, 0xA3FC		#  \ Call strcmp.
    mtctr r12					#  /
    bctrl						# /
    cmpwi r3, 0					# \ If sequence name strings match, do mode-specific code.
    beq is_mode					# /

    mr r3, r11					# Restore address of currentSequence name to r3.
    lis r4, 0x8070				# \ Load address of string "sqSingleAllstar" into r4.
    ori r4, r4, 0x27E0 			# /
    lis r12, 0x803F				# \
    ori r12, r12, 0xA3FC		#  \ Call strcmp.
    mtctr r12					#  /
    bctrl						# /
    cmpwi r3, 0					# \ If sequence name strings match, do mode-specific code.
    beq is_mode					# /
    
    b skip_to_end				# Otherwise skip to end: this is not Classic or All-Star Mode.


    /* Hide HUD for just long enough for the framebuffer copy to not have it, approximately 2 frames. */

is_mode:
    lis r3, 0x8067				# \ Address of layer visibility settings, as per Code Menu.
    ori r3, r3, 0x2F40			# /
    li r4, 0x8					# Set to HUD layer.
    li r5, 0x0					# Make disappear.
    lis r12, 0x8000				# \
    ori r12, r12, 0xD234		#  \ Call function setLayerDispStatus/[gfSceneRoot]/gf_3d_scene.o to hide HUD.
    mtctr r12					#  /
    bctrl						# /
skip_to_end:
    lwz r3, 0x0008(r30)			# Original instruction.
}

HOOK @ $800DEBBC
{
    /* Checks for certain modes (either Classic or All-Star). If not either of these skip this code. */
    
    lis r12, 0x8002				# \
    ori r12, r12 0xD018			#  > Call getInstance/[gfSceneManager].
    mtctr r12					# /
    bctrl						# Scene manager address is placed into r3.
    lwz r3, 0x10 (r3)			# Load currentSequence (10th offset from scene manager) into r3.
    lwz r3, 0 (r3)				# \ Load address of currentSequence name into r3 and save for later.
    mr r11, r3					# /

    lis r4, 0x8070				# \ Load address of string "sqSingleSimple" into r4.
    ori r4, r4, 0x24D0 			# /
    lis r12, 0x803F				# \
    ori r12, r12, 0xA3FC		#  \ Call strcmp.
    mtctr r12					#  /
    bctrl						# /
    cmpwi r3, 0					# \ If sequence name strings match, do mode-specific code.
    beq is_mode					# /

    mr r3, r11					# Restore address of currentSequence name to r3.
    lis r4, 0x8070				# \ Load address of string "sqSingleAllstar" into r4.
    ori r4, r4, 0x27E0 			# /
    lis r12, 0x803F				# \
    ori r12, r12, 0xA3FC		#  \ Call strcmp.
    mtctr r12					#  /
    bctrl						# /
    cmpwi r3, 0					# \ If sequence name strings match, do mode-specific code.
    beq is_mode					# /
    
    b skip_to_end				# Otherwise skip to end: this is not Classic or All-Star Mode.


    /* Hide HUD for just long enough for the framebuffer copy to not have it, approximately 2 frames. */

is_mode:
    lis r3, 0x8067				# \ Address of layer visibility settings, as per Code Menu.
    ori r3, r3, 0x2F40			# /
    li r4, 0x8					# Set to HUD layer.
    li r5, 0x0					# Make disappear.
    lis r12, 0x8000				# \
    ori r12, r12, 0xD234		#  \ Call function setLayerDispStatus/[gfSceneRoot]/gf_3d_scene.o to hide HUD.
    mtctr r12					#  /
    bctrl						# /
skip_to_end:
    li r3, 0x0                  # Original instruction.
}

HOOK @ $806D3838
{
    lis r3, 0x8067				# \ Address of layer visibility settings, as per Code Menu.
    ori r3, r3, 0x2F40			# /
    li r4, 0x8					# Set to HUD layer.
    li r5, 0x1					# Make reappear.
    lis r12, 0x8000				# \
    ori r12, r12, 0xD234		#  \ Call function setLayerDispStatus/[gfSceneRoot]/gf_3d_scene.o to reshow HUD.
    mtctr r12					#  /
    bctrl						# /
    lis r3, 0x805A				# Original instruction.
}

    /* Force results screen to use existing RGB565 framebuffer copy. */

HOOK @ $800EEC88
{
    addi r5, r29, 0x258			# Original instruction.
    mr r11, r3					# Saves r3.
    li r3, 0x2C					# \
    lis r12, 0x8002				#  \
    ori r12, r12, 0x49CC		#   > Gets address of CopyFB heap.
    mtctr r12					#  /
    bctrl						# /
    addis r3, r3, 0x9			# \
    addi r12, r3, 0x6200		#  > Offset to correct framebuffer copy.
    mr r3, r11					# /
    rlwinm r12, r12, 27, 0, 31	# \ Forces results screen to use existing RGB565 framebuffer copy for its ending photo. It's stored shifted right 5 bits for some reason and is masked into a physical address, though it can take either.
    stw r12, 0xC(r5)			# /
    li r12, 0x4					# \ Sets expected framebuffer format to RGB565.
    stw r12, 0x14(r5)			# /
    addi r4, r31, 0x3A0			# Repeat instruction right before hook to restore value of r4.
}

HOOK @ $800EDD9C
{
    lbz r0, 0 (r3)				# Beginning instruction of endKeepScreen/[gfKeepFrameBuffer]/gf_keep_fb.o
    li r4, 0x0					# Stops RGB565 framebuffer copy from being deleted once it stops displaying.
    lis r12 0x800E				# \
    ori r12, r12, 0xDDA0		#  > Branch back to processAnim/[ifSimpleResultTask]/if_simple_result.o at the end of this excursion.
    mtlr r12					# /
    lis r12, 0x8002				# \
    ori r12, r12, 0x4e40		#  \ Branch to middle of endKeepScreen/[gfKeepFrameBuffer]/gf_keep_fb.o to patch this function just for this call.
    mtctr r12					#  /
    bctr						# /
}


################################################################
Costume Decompression Now In FighterXResource Heaps [Exul Anima]
# NOTE! - This forces a requirement for wario and bowser to have
# the same number of pacs as wario man and gigabowser
################################################################

HOOK @ $8082AFB0
{
    cmplwi r7, 0x0				# There seems to be a file request mask that's wasted on nothing (REX-exclusive bug). Make it a feature by loading FitFighterXX.pac first, before any other files are loaded in.
    mflr r11					# Saves value of link register.
    bl bltrick					# \
    word 0xFFFFFFFF				#  \ Persistent storage of heap ID and fighter ID.
bltrick:						#  /
    mflr r6						# /
    mtlr r11					# Restores value of link register.
    bne mask_is_used			# If request mask is not 0, mask is used, use different codepath.
    li r11, 0x0					# Sets up testing flag.
    lhz r3, 0x0(r6)				# Load stored heap ID.
    cmplw r3, r9				# \
    bne skip_heap_flag			#  > If current heap ID is the same, increment flag.
    addi r11, r11, 0x1			# /
skip_heap_flag:
    lwz r4, 0x0008(r27)			# Load current fighter ID.
    lhz r3, 0x2(r6)				# Load stored fighter ID.
    cmplw r3, r4				# \
    beq skip_fighter_flag		#  > If fighter ID is different, increment flag.
    addi r11, r11, 0x1			# /
skip_fighter_flag:
    cmplwi r11, 0x2				# \ If all conditions are met (loading the costume of a different fighter to the same heap), loading the new costume file is skipped.
    beq skip_load				# /
    li r7, 0x100				# Otherwise change request mask to load in costume file.	
skip_load:
    sth r9, 0x0(r6)				# Store new heap ID to persistent storage.
    sth r4, 0x2(r6)				# Store new costume ID to persistent storage.
    mr r6, r5					# Original instruction.
    b %END%
mask_is_used:
    lwz r4, 0x0008(r27)			# Load current fighter ID.
    cmplwi r4, 0x15				# \ If Wario is the currently loading character, have a special check for his Final Smash assets. Otherwise skip.
    bne not_WariomanFS			# /
    cmplwi r7, 0xC0				# \
    bne not_WariomanFS			#  > If loading Wario's animations and etc, don't reset the flags so that the Warioman costume doesn't get preloaded before the Final Smash.
    b WariomanFS				# /
not_WariomanFS:
    lis r11, 0xFFFF				# \
    ori r11, r11, 0xFFFF		#  > If the request mask is not zero, then it's already passed the ones that normally are 0, so we can safely reset the flag for the next player's fighter.
    stw r11, 0x0(r6)			# /
WariomanFS:
    mr r6, r5					# Original instruction.
}


HOOK @ $80827F14
{
    cmplwi r4, 0x31				# \ Check if Warioman Final Smash (Wario is the only fighter in P+ and derivative builds to reload his costume but not his animations).
    bne not_WarioFS				# /
    li r9, 0x1F					# \ Force transformation costume to load in FighterTechniq heap since it only appears in Final Smashes anyway.
    li r10, 0x1F				# /
not_WarioFS:
    lbz r8, 0x015B(r27)			# Original instruction.
}

op mr r9, r5 @ $8084FE2C        # Forces character costumes to decompress in the same heap as they're initially loaded, being the FighterXResource heap.

    ## NOTE: 
    ## The line modifying address 0x8084FE2C in "Character Costumes are decompressed in the Network Heap [Kapedani, DukeItOut]" in CompressPAC.asm ***MUST*** be commented out for this code to work.


HOOK @ $80015CB0
{
    lwz r4, 0x14(r19)           # \
    lwz r5, 0x18(r19)           #  \ If the source and destination heaps for decompression are the same, use the modified codepath.
    cmplw r4, r5                #  / Otherwise use the original codepath.
    bne not_same_heap           # /
    mr r3, r18                  # \ Sets destination of compressed FitFighterXX.pac copy to near the beginning of the current heap.
    addi r3, r3, 0x100          # /
    lis r4, 0x8001              # \
    ori r4, r4, 0x5CC0          #  \ Skip allocation of space in separate heap and force compressed data copy to the beginning of the same heap.
    mtctr r4                    #  /
    bctr                        # /
not_same_heap:
    lwz r3, 0x18(r19)           # Original instruction.
}

HOOK @ $80015D04
{
    lwz r4, 0x14(r19)           # \
    lwz r5, 0x18(r19)           #  \ If the source and destination heaps for decompression are the same, use the modified codepath.
    cmplw r4, r5                #  / Otherwise use the original codepath.
    bne not_same_heap           # /
    lis r4, 0x8001              # \
    ori r4, r4, 0x5D0C          #  \ Prevents deallocation of the compressed file since it was technically never allocated.
    mtctr r4                    #  /
    bctr                        # /
not_same_heap:
    mr r3, r23                  # Original instruction.
}


#################################
Destroy Network Heap [Exul Anima]
#################################

op ori r3, r3, 0x18A0 @ $80016C68	# Starts checking heap table on second entry.

CODE @ $80421890
{
    word 0xFFFFFFFF # @ $80421890 \
    word 0xFFFFFFFF # @ $80421894  \ Overwrites original first heap entry with 0xFFFFFFFF. Not functionally necessary but useful to indicate that it was removed.
    word 0xFFFFFFFF # @ $80421898  /
    word 0xFFFFFFFF # @ $8042189C /
    word 0x804217E8 # @ $804218A0 \
    word 0x00000004 # @ $804218A4  \ Overwrites Network heap's entry in heap table with the original first entry.
    word 0x00000000 # @ $804218A8  /
    word 0x00040100 # @ $804218AC /
}

    ## NOTE:
    ## Without code "Costume Decompression Now In FighterXResourceHeaps [Exul Anima]", this code ***BREAKS*** DukeItOut's Costume Decompression codes in CompressPAC.asm, as they rely on the Network heap.
    ## To maintain compatibility, use the above mentioned code alongside this one.
