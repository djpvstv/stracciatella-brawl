#################################################################################
Memory Extension for FighterXResource1 [Dantarion, ASF1nk, DukeItOut, Exul Anima]
#
# This code requires Syriinge to be running in order to clear memory
# It also requires a very small sc_selcharacter.pac, so best remove all CSPs
# and use syriinge for loading CPSs via RSPs
#
# 5.33MB -> 5.57MB
#################################################################################
# int 0x5ABDC0 @ $80421B44
# int 0x5ABDC0 @ $80421B64
# int 0x5ABDC0 @ $80421B84
# int 0x5ABDC0 @ $80421BA4
# int 0x5ABDC0 @ $80421E0C
# int 0x5ABDC0 @ $80421E2C
# int 0x5ABDC0 @ $80421EAC
# int 0x5ABDC0 @ $80421ECC
# #int 0x592000 @ $80421ECC	Original line for reference.
# P+ version
int 0x592000 @ $80421B44
int 0x592000 @ $80421B64
int 0x592000 @ $80421B84
int 0x592000 @ $80421BA4
int 0x592000 @ $80421E0C
int 0x592000 @ $80421E2C
int 0x592000 @ $80421EAC
int 0x592000 @ $80421ECC

##############################################################
Memory Extension for FighterXResource2 [Dantarion, Exul Anima]
#
# 0.53MB -> 0.62MB
##############################################################
int 0x9E680 @ $80421B54
int 0x9E680 @ $80421B74
int 0x9E680 @ $80421B94
int 0x9E680 @ $80421BB4
int 0x9E680 @ $80421E1C
int 0x9E680 @ $80421E3C
int 0x9E680 @ $80421EBC
int 0x9E680 @ $80421EDC

#########################################
!Stage Resource 6.4MB -> 6.1MB [DukeItOut]
#########################################
int 0x6199a0 @ $80421D64 # 6.1MB

#################################################################################################
StageResource In 'scVsResult' Now Same Size As In 'scMelee' In VS Mode & Derivatives [Exul Anima]
#################################################################################################
int 0x666700 @ $80422334

################################################################
!Memory Extension for CSS/SSS MenuResource (+0.58MB) [DukeItOut]
################################################################
/* Not used in REX as this will be managed separately for the CSS rules menu until modern RSP loading is integrated. */
int 0x73EA00 @ $80422384 #+0.88MB version. Disabled for now so characters can take advanage of an extra 0.3MB due to the above code
#int 0X6F1CA0 @ $80422384  #+0.58MB version. Keep this size synchronized with the Stage Resource change! (i.e. if Stage Resource = 6.4MB, this can be made +0.88)

###########################################
!Network Resource 1.4MB -> 1.1MB [DukeItOut]
###########################################
#Currently disabled, as with this active, entering the Home menu crashes. May consider just disabling the Home menu if things get desperate in terms of memory.
/* Not used in REX as the Network heap no longer exists. */
int 0x119B00 @ $804218AC

################################################
MeleeFont Resource 0.45MB -> 0.33MB [Exul Anima]
################################################
# Using this will remove a lot of important text unless you get a smaller font from Common3.pac / Misc Data [10].
# Also helpful to use the Remix/Tags.asm to increse the size of text. Removes the hira font from memory (Classic brawl tag font)
int 0x53400 @ $8042193C

#################################################
!InfoExtraResource 13.90MB -> 14.90MB [Exul Anima]
#################################################
int 0xEE6700 @ $80422214	# Used to prepare the Sound Test soundtrack and SFX lists for (future) expansion. It might not end up being strictly necessary but better safe than sorry.

#########################################################
Sound Resource 12.76MB -> 12.76MB [DukeItOut, Exul Anima]
#
# Space used: 12.06MB (94%) -> 12.39MB (97%)
#########################################################
.alias size = 0x28000    # Normally E6000
.alias size_hi = size / 0x10000
.alias size_lo = size & 0xFFFF
op li r4, 0x880 @ $8007A0D8    # \ 0x66680 block -> 0x880
op li r5, 0x880 @ $8007A0EC    # /
CODE @ $8007326C
{
    lis r31, size_hi
    ori r4, r31, size_lo
}
op ori r8, r31, size_lo @ $800732A4
#int 0xAEBC00 @ $804217B4    # Normally 0xCC7C00, commented out for REX.
op li r31, 4 @ $801C8B8C    # \ Reduced from 8 music buffers to 4. (2 stereo tracks to allow music switches)
op li r31, 4 @ $801C8BC4    # /
HOOK @ $801C32C4
{
	lis r11, 0xCCCC			# \
	ori r11, r11, 0xCCCC	# | Failsafe for inaccessible SEQ files.
	cmplw r4, r11			# |
	bgelr-					# |
	cmpwi r4, 0				# |
	bgelr-					# /
	stwu r1, -0x30(r1)		# Original operation
}
HOOK @ $80079578			# Where to place new 3D sound actors
{
	li r3, 5				# 5: Sound Resource
	bla 0x0249CC			# Get pointer to it
	li r4, 5				# 5: Sound Resource
	lhz r12, 0x14(r3)		# Amount of allocations
	cmpwi r12, 0x100		# Of normal stages, the largest overall do not go higher than this. Adjusted from P+ to work in REX. Original value in patch was 0xA2.
	blt Finish				#
	li r4, 17				# 17: Stage Resource	# SSE can generate a lot, so place in here!
Finish:
	li r3, 196				# Original operation. Allocation size.
}

#####################################################
Sound Resource sndHeap[0] 2.91MB -> 4.41MB [MarioDox]
#####################################################
# Requires SoundResource increase above. Used for the expanded announcer.
op lis r29,0x43 	@ $80079f70
op addi r4,r29,0x4cfa 	@ $80079f78
op addi r5,r29,0x4cfa	@ $80079f98

#######################################################
!Decrease GlobalMode and MenuResource Heaps [Exul Anima]
#######################################################

#word 0x00026F00 @ $804218DC		# Reduce GlobalMode by 80KB. This fucked up saving to NAND so don't enable this.
#word 0x00710000 @ $80422384		# Reduce MenuResource by 100KB. Will be reduced by more once modern RSP loading is integrated. This is actually modified in bx_fighter.rel, might change that.
#word 0x00146B00 @ $80421BC4		# (No longer needed) Increase FighterTechniq by 180KB. Increasing this won't be necessary once modern RSP loading is integrated, and the RAM can be used elsewhere.

	## NOTE:
	## This code was originally required to get around some jank involving the rules menu on the CSS.
	## Now that the CSS is loaded via its own scene instead of adding onto the CSS, this code has been adjusted and now powers additional expansion for the FighterXResource1 heaps.
	## The original note is left in for archival purposes.

	## !!!OUTDATED!!! NOTE:
	## There is code hamfisted into Section[5] of sora_menu_sel_char.rel (affectionately called the tumor code) that (among other things) relocates loading the CSS rules menu to a different heap than the MenuResource heap in vBrawl.
	## Previously this allocated the rules menu to the Network heap during the CSS.
	## Now this will be allocated to FighterTechniq, increased to accommodate the rules menu's 1.3MB allocation. (WHY DOES IT ALLOCATE SO MUCH???)
	## Once modern asyncrhonous RSP loading is integrated into REX, then we can do away with this tumor code and relocate the CSS rules menu to the MenuResource heap, which will be significantly freed up due to RSP loading.
	
######################################
Reduce FighterEffect Heap [Exul Anima]
######################################

word 0x00001000 @ $80421B04		# \
word 0x00001000 @ $80421DCC		#  > Reduce FighterEffect to 4KB.
word 0x00001000 @ $80422434		# /

	## NOTE:
	## This heap is used in vBrawl for Pokemon Trainer, redundantly storing effect files to reduce load times when switching characters.
	## If for some reason you want Pokemon Trainer in your build, why are you here? Don't include this code then.
	## This heap isn't being outright destroyed so that the Debug Menu and other functions can neatly allocate to it instead of storing values in arbitrary areas of RAM.
