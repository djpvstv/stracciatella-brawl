###################################################
!Decimal Damage Display, Ultimate-Style [Exul Anima]
###################################################

## NOTE:
## This code requires changes to other files, see further notes and Stamina.ASM for more details.

#######################################################
## == Floating Point (Decimal)-Compatible Backend == ##
#######################################################

## == General Changes == ##

HOOK @ $800E0C8C
{
    lwz r12, 0x28(r30)      # \ Load damage float value.
    lfs f1, -0x4(r12)       # /
    fctiwz f13, f1          # \
    stfd f13, -0x18(r1)     #  > Convert to integer for use by other functions.
    lwz r29, -0x14(r1)      # /
}

HOOK @ $800E0CE0
{
    mr r3, r30              # Original instruction.
    lwz r12, 0x28(r3)       # \ Load for later reference.
    lfs f1, -0x4(r12)       # /
}

op lwz r4, 0x20(r3) @ $80947878     # Previously loaded half-word (2 bytes), now loads 4 bytes for moving value to another address.

HOOK @ $800E38E8
{
    mr r3, r29              # Original instruction.
    lwz r12, 0x28(r3)       # \ Load for later reference.
    lfs f1, -0x4(r12)       # /
}

HOOK @ $800E37F4
{
    mr r3, r29              # Original instruction.
    lwz r12, 0x28(r3)       # \ Load for later reference.
    lfs f1, -0x4(r12)       # /
}

op nop @ $8081C1B4                      # \
op nop @ $808471B4                      #  \
op ps_merge11 f1, f1, f1 @ $809E2670    #   > Prevent overriding the total damage with the damage being currently added.
op ps_merge00 f1, f1, f1 @ $8081C1B4    #  /
op ps_merge00 f1, f31, f31 @ $80835F50  # /

HOOK @ $809482B8
{
    lwz r12, 0x0(r3)        # \ Get starting damage.
    lfs f1, 0x2C(r12)       # /
}

op nop @ $809482BC          # \
op nop @ $809482C8          #  \
op nop @ $809482CC          #   \ Remove instructions that convert float damage value to integer.
op nop @ $809482D0          #   /
op nop @ $809482D8          #  /
op nop @ $809482DC          # /

op lfs f1, 0x20(r31) @ $809468DC    # Get starting damage.
op stfs f1, 0x54(r1) @ $809468E8    # Move damage value to another memory address.
op nop @ $809468EC          # \
op nop @ $809468F0          #  > Remove instructions that convert float damage value to integer.
op nop @ $809468F8          # /

HOOK @ $80953E90
{
    lfs f11, 0x34(r3)       # \ Store the float damage value. Fixes All-Star Mode.
    stfs f11, 0xB8(r4)      # /
}

HOOK @ $800E3F78
{
    lis r3, 0x80B8          # \ g_ftManager
    lwz r3, 0x7C28(r3)      # /
    lwz r4, 0x4C(r27)       # Get slot number.
    bla 0x8159E4            # Call getOwner/[ftManager].
    lwz r3, 0x0(r3)         # \ Get starting damage.
    lfs f1, 0x2C(r3)        # /
    fctiwz f13, f1          # \
    stfd f13, -0x30(r1)     #  > Convert to integer for use by other functions.
    lwz r31, -0x2C(r1)      # /
    mr r3, r28              # Original instruction.
}

HOOK @ $8096281C
{
    /* Convert integer in r26 to float (code snippet and original comments credit to salmon01). */

    lis r12, 0x4330
    stw r12, -0x8(r1)
    lis r12, 0x8000
    stw r12, -0x4(r1)
    lfd f12, -0x8(r1)       # load magic double into f2
    xoris r11, r26, 0x8000  # flip sign bit
    stw r11, -0x4(r1)       # store lower half (upper half already stored)
    lfd f11, -0x8(r1)
    fsub f11, f11, f12      # complete conversion
    
    stfs f11, 0xB8(r3)      # Store the float damage value.
}

HOOK @ $800E3570
{
    lwz r12, 0x28(r31)      # \ Load damage value stored in HUD.
    lfs f13, -0x4(r12)      # /

    lis r3, 0x80B8          # \ g_ftManager
    lwz r3, 0x7C28(r3)      # /
    mr r4, r30              # \
    bla 0x815C40            #  > Fetch slot number.
    mr r4, r3               # /
    lis r3, 0xFFFF          # \
    ori r3, r3, 0xFFFF      #  \ If slot doesn't exist, fall back to vanilla codepath.
    cmplw r3, r4            #  /
    beq fallback            # /
    lis r3, 0x80B8          # \ g_ftManager
    lwz r3, 0x7C28(r3)      # /
    bla 0x8159E4            # Call getOwner/[ftManager].
    bla 0x81C264            # \ Call getDamage/[ftOwner] to get damage value.
    ps_merge00 f10, f1, f1  # /

    lwz r0, 0x18(r31)       # \ Original instructions.
    lwz r3, 0x1C(r31)       # /
    fcmpo cr0, f10, f13     # \ If damage is greater than or equal to value stored in HUD, fall back.
    bge fallback            # /
    cmplw r0, r3            # \ If vanilla integer damage values aren't equal, fall back.
    bne fallback            # /
    cmpwi r3, 0x0           # \ If integer damage isn't zero, initialize special case where start and end values are between two integers.
    bne nonZero             # /
    
    li r12, 0x0             # \
    stw r12, -0x30(r1)      #  > Load float zero.
    lfs f1, -0x30(r1)       # /

    stw r0, 0x1C(r31)       # \
    lwz r4, 0x1C(r31)       #  > Original instructions.
    mr r3, r31              # /
    lis r12, 0x800E         # \
    ori r12, r12, 0x35A0    #  \ Skip custom HUD healing routine.
    mtctr r12               #  /
    bctr                    # /
nonZero:
    lwz r0, 0x18(r31)       # \ Original instructions.
    lwz r3, 0x1C(r31)       # /
    fadds f1, f13, f30      # \
    lwz r12, 0x28(r31)      #  > Add one to HUD damage to offset subtraction later.
    stfs f1, -0x4(r12)      # /
    lis r12, 0x800E         # \
    ori r12, r12, 0x3594    #  \ Branch to custom HUD healing routine.
    mtctr r12               #  /
    bctr                    # /
fallback:
    lwz r0, 0x18(r31)       # Original instruction.
}

HOOK @ $800E359C
{
    lwz r12, 0x28(r31)      # \ Load damage value stored in HUD.
    lfs f13, -0x4(r12)      # /
    fsubs f1, f13, f30      # Subtract one from HUD damage.
    
    fctiwz f13, f1          # \
    stfd f13, -0x34(r1)     #  > Convert to integer.
    lwz r10, -0x30(r1)      # /

    lis r12, 0x4330
    stw r12, -0x8(r1)
    lis r12, 0x8000
    stw r12, -0x4(r1)
    lfd f12, -0x8(r1)       # load magic double into f2
    xoris r10, r10, 0x8000  # flip sign bit
    stw r10, -0x4(r1)       # store lower half (upper half already stored)
    lfd f11, -0x8(r1)
    fsub f13, f11, f12      # complete conversion
    
    lis r3, 0x80B8          # \ g_ftManager
    lwz r3, 0x7C28(r3)      # /
    mr r4, r30              # \
    bla 0x815C40            #  > Fetch slot number.
    mr r4, r3               # /
    lis r3, 0xFFFF          # \
    ori r3, r3, 0xFFFF      #  \ If slot doesn't exist, fall back to backup codepath (for SSE only).
    cmplw r3, r4            #  /
    bne notSSE              # /
    lbz r4, 0x3(r31)        # Fetch slot number. This shouldn't fail because of other checks passing prior to this point. If it does... whelp.
notSSE:
    lis r3, 0x80B8          # \ g_ftManager
    lwz r3, 0x7C28(r3)      # /
    bla 0x8159E4            # Call getOwner/[ftManager].
    bla 0x81C264            # \ Call getDamage/[ftOwner] to get damage value.
    ps_merge00 f10, f1, f1  # /

    fctiwz f9, f10          # \
    stfd f9, -0x34(r1)      #  > Convert to integer.
    lwz r10, -0x30(r1)      # /

    lis r12, 0x4330
    stw r12, -0x8(r1)
    lis r12, 0x8000
    stw r12, -0x4(r1)
    lfd f12, -0x8(r1)       # load magic double into f2
    xoris r10, r10, 0x8000  # flip sign bit
    stw r10, -0x4(r1)       # store lower half (upper half already stored)
    lfd f11, -0x8(r1)
    fsub f9, f11, f12       # complete conversion

    fsubs f10, f10, f9      # \ Combine integer and fractional parts of resulting incremental damage.
    fadds f1, f13, f10      # /

    lwz r4, 0x1C(r31)       # \ Original instructions.
    mr r3, r31              # /
}

## == Subspace Emissary-Specific Changes == ##

HOOK @ $809E26BC
{
    ps_merge11 f4, f4, f4   # \
    fadds f1, f1, f4        #  > Get total damage.
    stfs f1, 0xB8(r5)       # /
}

HOOK @ $8081F3C8
{
    lwz r3, 0x28(r31)       # Original instruction.
    ps_merge00 f4, f5, f5   # Override with zero to prevent damage erroneously changing when swapping between transforming characters.
}

HOOK @ $80861B98
{
    mr r11, r5              # Back up r5.

    lis r12, 0x8002         # \
    ori r12, r12 0xD018     #  > Call getInstance/[gfSceneManager].
    mtctr r12               # /
    bctrl                   # Scene manager address is placed into r3.
    lwz r3, 0x10 (r3)       # Load currentSequence (10th offset from scene manager) into r3.
    lwz r3, 0 (r3)          # \ Load address of currentSequence name into r3 and save for later.
    mr r4, r3               # /

    lis r4, 0x8070          # \ Load address of string "sqAdventure" into r4.
    ori r4, r4, 0x1814      # /
    lis r12, 0x803F         # \
    ori r12, r12, 0xA3FC    #  \ Call strcmp.
    mtctr r12               #  /
    bctrl                   # /
    cmpwi r3, 0             # Check string compare result.

    beq Adventure           # \ If sequence name strings match, do mode-specific code.
    b Default               # /

Adventure:
    ps_merge00 f1, f31, f31 # Override total damage with the damage currently being added. Not having this change per mode results in weirdness with environmental hitbox damage values.
Default:
    mr r5, r11              # Restore r5.
    lwz r3, 0x0(r28)        # Original instruction.
}

op nop @ $80861B9C          # Prevent overriding the total damage with the damage being currently added.

op fmr f1, f16 @ $809488C0  # Pegs SSE respawn damage to 0%. If you want this customizable in the future then that's on you to do, not me.
op nop @ $809488C4          # \
op nop @ $809488D0          #  \
op nop @ $809488D4          #   \ Remove instructions that convert float damage value to integer.
op nop @ $809488D8          #   /
op nop @ $809488E0          #  /
op nop @ $809488E4          # /

op lwz r4, 0x20(r30) @ $80950774        # \ Previously loaded half-word (2 bytes), now loads 4 bytes for moving value to another address.
op stw r4, 0x20(r30) @ $80950780        # /

###################################################
## == Inject Float Value Into Main Damage HUD == ##
###################################################
    
    ## NOTE:
    ## The decimal display always rounds down (so internal value 4.99 -> displayed value 4.9). This is done to parallel Brawl's previous rounding behavior, which is by default in hardware due to decimal truncation.
    ## Ultimate's rounding behavior would be used instead, but there is no documentation on how this works (whether it rounds normally or always up/down).
    ## To make the display round normally, add 0.05 to the damage value used in this function right before it's stored and processed, though due to floating point imprecision this might not always work.

HOOK @ $800E1594
{
    stfd f31, 0x60(r1)      # Original instruction.

    ps_mr f13, f1               # \
    ps_merge10 f13, f13, f13    #  \
    ps_cmpo0 cr0, f1, f13       #   \
    bgt first                   #    \ If some residual decimal value remains in either paired single of the floating point register, get the greater of the two.
    ps_merge11 f13, f1, f1      #    /
    b store                     #   /
first:                          #  /
    ps_merge00 f13, f1, f1      # /
store:
    lwz r12, 0x28(r3)       # \ Store for later reference.
    stfs f13, -0x4(r12)     # /
    stw r6, -0x4(r3)        # Store flag for if damage display is exploding (resetting for new stock).
}

HOOK @ $800E16EC
{
    fsubs f1, f0, f31       # Original instruction.
    
    ## NOTE:
    ## When updating the digits in the damage display, it always starts with the ones place model first, so the ones and tenths were combined into one model to piggyback off this.
    ## r25 is the loop counter that iterates 3 times to go through all the digits. If it's 0x0, it's on the ones (now the combined ones and tenths) place, so enact the following code. Otherwise skip.
    
    ## NOTE:
    ## Make sure when using this code you have the proper models and animations set up prior, otherwise it'll either glitch out your damage display or crash.
    ## Some modes (SSE, non-endless Multiman Brawl, etc) have more stringent filesize restrictions. Luckily there are duplicate online mode models that can be deleted down to the bones (NOT FULLY DELETED) to make room.
    ## There are 11 used versions of the damage display, found in /info2 (info*.pac), and /menu2 (if_adv_mngr.pac). Info.brres in /info also has a damage display model, but appears to be unused.

    cmplwi r25, 0x0         # \ If not the first digit processed (now ones & tenths place), exit hook.
    bne %END%               # /

    lwz r12, -0x4(r19)      # \
    cmplwi r12, 0x1         #  > If the display is resetting, reset to zero.
    beq setToZero           # /

    lwz r12, 0x28(r19)      # \ Load stored damage value.
    lfs f13, -0x4(r12)      # /

    b extendDecimal

setToZero:
    li r10, 0x0             # \ Load zero to be used.
    b toFloat               # /

extendDecimal:
    lis r12, 0x4120         # \
    stw r12, -0x18(r1)      #  > Load float single value 10.0
    lfs f12, -0x18(r1)      # /
    fmul f11, f13, f12      # Multiply untruncated value by 10. Since the ones model is now the ones AND tenths model, it has 100 frames (for 0.0 -> 9.9) instead of just 10 (for 0 -> 9).
    fctiwz f11, f11         # \
    stfd f11, -0x18(r1)     #  > Convert to integer.
    lwz r12, -0x14(r1)      # /
    li r11, 0x64            # \
    divw r10, r12, r11      #  \ Get remainder modulo 100.
    mullw r10, r10, r11     #  /
    subf r10, r10, r12      # /

    /* Convert integer in r10 to float (code snippet and original comments credit to salmon01). */

toFloat:
    lis r12, 0x4330
    stw r12, -0x8(r1)
    lis r12, 0x8000
    stw r12, -0x4(r1)
    lfd f12, -0x8(r1)       # load magic double into f2
    xoris r10, r10, 0x8000  # flip sign bit
    stw r10, -0x4(r1)       # store lower half (upper half already stored)
    lfd f11, -0x8(r1)
    fsub f11, f11, f12      # complete conversion
    
    fmr f1, f11             # Move result to f1 for use as argument to change the frame number.
}

###################################################
## == Inject Float Value Into Head Cursor HUD == ##
###################################################

HOOK @ $800E544C
{
    fsubs f1, f0, f31       # Original instruction.
    
    ## NOTE:
    ## To avoid too much reduncancy, refer to the notes under the "Inject Float Value on Main Damage HUD" subsection.
    ## The code here and there is almost identical, differences being fetching values that have already been calculated before, and sometimes using different registers.

    cmplwi r24, 0x0         # \ If not the first digit processed (now ones & tenths place), exit hook.
    bne %END%               # /

    lwz r12, 0x28(r25)      # \ Load stored damage value.
    lfs f13, -0x4(r12)      # /

    b extendDecimal

extendDecimal:
    lis r12, 0x4120         # \
    stw r12, -0x18(r1)      #  > Load float single value 10.0
    lfs f12, -0x18(r1)      # /
    fmul f11, f13, f12      # Multiply untruncated value by 10. Since the ones model is now the ones AND tenths model, it has 100 frames (for 0.0 -> 9.9) instead of just 10 (for 0 -> 9).
    fctiwz f11, f11         # \
    stfd f11, -0x18(r1)     #  > Convert to integer.
    lwz r12, -0x14(r1)      # /
    li r11, 0x64            # \
    divw r10, r12, r11      #  \ Get remainder modulo 100.
    mullw r10, r10, r11     #  /
    subf r10, r10, r12      # /

    /* Convert integer in r10 to float (code snippet and original comments credit to salmon01). */

toFloat:
    lis r12, 0x4330
    stw r12, -0x8(r1)
    lis r12, 0x8000
    stw r12, -0x4(r1)
    lfd f12, -0x8(r1)       # load magic double into f2
    xoris r10, r10, 0x8000  # flip sign bit
    stw r10, -0x4(r1)       # store lower half (upper half already stored)
    lfd f11, -0x8(r1)
    fsub f11, f11, f12      # complete conversion
    
    fmr f1, f11             # Move result to f1 for use as argument to change the frame number.
}


########################################################
Increased Resolution Battle Portraits (BPs) [Exul Anima]
########################################################

## NOTE:
## The way this build utilizes the doubled resolution is by doubling the size of the polygon the BP is rendered on, then increasing the transparent area around the image without altering its apparent resolution.
## This gives the result of standard size BPs with increased margins to have protrusions out of the frame of the BP (similarly to Ultimate).
## Doubling the resolution for finer detail in the same screen space is unnecessary for this UI element, so the increase is instead used to increase the "canvas size" while maintaining the current level of detail.
## This will be much more apparent looking at the actual images.

op li r4, 0x2D80 @ $800E06AC    # 3584 bytes to 11648 bytes (48 x 56 CI8 -> 96 x 102 CI8).

word 0x00147140 @ $80421D54     # \ Slightly increase InfoInstance heap (and decrease MenuInstance heap to compensate) during VS-based gameplay to accommodate larger BPs in Multi-Man modes.
word 0x00069B00 @ $80421D84     # /