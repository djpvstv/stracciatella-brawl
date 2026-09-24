#######################################################################################
[Project+] Custom Training Mode AI Options based on Stop + Random DI [Eon, PyotrLuzhin]
#######################################################################################
.alias totalOptions = 14
.alias lastOption = totalOptions-1
#Based on code by PyotrLuzhin
#https://smashboards.com/threads/enhanced-training-mode.444318/

#Now loads Stop AI option, and places its inputs on top of it, meaning it will recover etc automatically


HOOK @ $809031B4
{
#Inputs saved at end of hook/straight after
#r0 = Current Button Input = 0x8(r1)
#f1 = Current Stick X axis = 0xC(r1)
#f0 = Current Stick Y axis = 0x10(r1)
#0x24(r1) = current trainingmode option, 0 if not in training mode
  lwz r0, 0x00B8(r1)
  stwu r1, -0x50(r1)

  stw r3, 0x14(r1)
  stw r4, 0x18(r1)
  stw r5, 0x1C(r1)

  stw r0, 0x8(r1)
  stfs f1, 0xC(r1)
  stfs f0, 0x10(r1)
  
#turned off so samus can work
#  #makes sure items dont get caught up in the code
#  cmpwi r25, 0
#  beq end
#  lwz r3, 0xC(r25)
#  cmpwi r3, 0
#  beq end
#  lwz r3, 0x60(r3)
#  cmpwi r3, 0
#  beq end

  lis r12, 0x805B			# \
  lwz r12, 0x50AC(r12)		# | Retrieve the game mode name
  lwz r12, 0x10(r12)		# |
  lwz r12, 0x4(r12)			# |
  lwz r12, 0x15(r12)		# / And grab the 2nd-through-5th characters in the string (string starts at 0x14)
  lis r3, 0x7154			# \
  ori r3, r3, 0x7261		# / "qTra", as in "sqTraining"
  
  cmpw r3, r12 				#if not training mode, stores 0 as selected option 
  bne end

  lis r3, 0x8167 			# \
  ori r3, r3, 0xE324 		# | stores current training mode cpu option
  lwz r12, 0x0(r3) 			# |


trainingModeOptions:
  cmpwi r12, 6
  blt end

checkShield:
  cmpwi r12, 6
  bne checkCrouch
  ori r0, r0, 0x0008 #sets shielding bit
  stw r0, 0x8(r1)	 # Update variable for behavior
  b end
checkCrouch:
  cmpwi r12, 7
  bne next
  #check if above the ground
  mr r3, r26
  lis r12, 0x8091
  ori r12, r12, 0x5F7C
  mtctr r12
  bctrl 
  cmpwi r3, 1
  bne end
  #if above ground, hold down
  lis r3, 0x805A
  lfs f2, 0x170C(r3) #0
  lfs f3, 0x1720(r3) #-1
  stfs f2, 0xC(r1)  #stores 0 to x-stick location
  stfs f3, 0x10(r1) #stores -1 to y-stick location
  b end
  
next:
end:

  lwz r0, 0x8(r1) 	#load buttons from stack

  lfs f1, 0xC(r1) 	#load x stick pos frpm stack
  lfs f0, 0x10(r1) 	#load y stick pos from stack

  #load original arguments + offset
  lwz r3, 0x14(r1)
  lwz r4, 0x18(r1)
  lwz r5, 0x1C(r1)

  stfs f1, 0x10(r31)#store stick location
  stfs f0, 0x14(r31)

  addi r1, r1, 0x50
  #storing inputs for nana
  stw r0, 0xB8(r1)
  stfs f1, 0xF0(r1)
  stfs f0, 0xF4(r1)
  stfs f1, 0x168(r1)
  stfs f0, 0x16C(r1)
}
op nop @ $809031AC
op nop @ $809031B0

#Random DI, caught at the DI check, so not an actual control stick input.
HOOK @ $80877954
{
  fmr f29, f1
  cmplwi r18, 0xC0DE;  beq+ %end% #if DI Check is from code menu, skip
checkCPU:   #CPU check from `Random CPU DI v1.2` by ChaseMcDizzle and Fracture
  lwz r18, 0x10C(r28)
  rlwinm r18, r18, 0, 24, 31
  lis r7, 0x8062
  ori r7, r7, 0x9A00
  lwz r7, 0x154(r7)
  lwz r7, 0(r7)
  mulli r18, r18, 0x244
  add r7, r7, r18
  lwz r7, 0x18(r7)
  mulli r7, r7, 0x1
  lis r18, 0x80B9
  ori r18, r18, 0x0
  lwz r18, -0x5D28(r18)
  addi r18, r18, 0x84
  add r18, r18, r7
  lbz r18, 0(r18)
  cmpwi r18, 0x0;  beq %end%

getKnockback:
#getKnockback
  stwu r1, -0x20(r1)

  lwz r3, 0xD8(r29)
  lwz r3, 0x7C(r3)
  lwz r3, 0x7C(r3)
  lfs f1, 0x8(r3)
  lfs f2, 0xC(r3)

#normaliseKnockbackToUnitCircle
  addi r3, r1, 0x10
  stfs f1, 0x0(r3)
  stfs f2, 0x4(r3)
  lis r12, 0x8003
  ori r12, r12, 0xdba8
  mtctr r12
  bctrl
  #value found at 0x10(r1) and 0x14(r1) now equate to if the player held stick in direction of knockback

#randi gets a value between 0 and 4
  lis r12, 0x803f
  ori r12, r12, 0x8c3c
  mtctr r12
  bctrl

  lis r12, 0x805B     # \
  lwz r12, 0x50AC(r12)    # | Retrieve the game mode name
  lwz r12, 0x10(r12)    # |
  lwz r12, 0x4(r12)     # |
  lwz r12, 0x15(r12)    # / And grab the 2nd-through-5th characters in the string (string starts at 0x14)
  lis r4, 0x7154      # \
  ori r4, r4, 0x7261    # / "qTra", as in "sqTraining"
  
  cmpw r4, r12        #if not training mode, does random DI
  bne normalRNG

  lis r4, 0x8167      # \
  ori r4, r4, 0xE324  # | loads current training mode cpu option
  lwz r4, 0x0(r4)    # /
  #GetTrainingModeSetting
  cmpwi r4, 0x8
  blt 0x14
  cmpwi r4, 0xD
  bge 0xC 
  subi r3, r4, 8
  b convertRandToDI

  cmpwi r4, 0xD 
  bne normalRNG 
  li r4, 0x2AAB   #0x8000/3 = 0x2AAA.AAAA, so picks a random number from 0 to 4
  divw r3, r3, r4
  addi r3, r3, 1
  b convertRandToDI

normalRNG:
  li r4, 0x199A   #0x8000/5 = 0x1999.999, so picks a random number from 0 to 4
  divw r3, r3, r4


convertRandToDI:
#convertRandi result to angle conversion
  cmpwi r3, 0
  bne 0x10
  lis r3, 0x3fc9
  ori r3, r3, 0x0fdb #pi/2
  b rotateDI

  cmpwi r3, 1
  bne 0x10
  lis r3, 0x3f49
  ori r3, r3, 0x0fdb #pi/2
  b rotateDI

  cmpwi r3, 2
  bne 0xC
  lis r3, 0x0      #0
  b rotateDI

  cmpwi r3, 3
  bne 0x10
  lis r3, 0xbf49
  ori r3, r3, 0x0fdb #-pi/4
  b rotateDI

  lis r3, 0xbfc9
  ori r3, r3, 0x0fdb #-pi/2

rotateDI:

  stw r3, 0x18(r1)

  lwz r3, 0xD8(r29)
  lwz r3, 0xC(r3)
  lfs f2, 0x40(r3)  #get facing Direction

  lfs f1, 0x18(r1)  #multiply rotation by facing direction, so positive always equals inwards rotation
  fmul f1, f1, f2

  addi r3, r1, 0x10


#rot/Vec2D
#r3 input, r4 output, f1 rotation in radians
  mr r4,r3
  lis r12, 0x8003 
  ori r12, r12, 0xdc64 
  mtctr r12
  bctrl 

  #saves result to stick location
  lfs f28, 0x0(r3)
  lfs f29, 0x4(r3)
  addi r1, r1, 0x20

  
  fmr f1, f29
  lfs f0, 0xC(r31)

}

op cmpwi r30, totalOptions @ $80105B70 	#If off end of menu, return to 0
op li r30, lastOption @ $80105B8C 		#If off start of menu, go to end
HOOK @ $80962504
{ 
	cmpwi r3, 0x6
	blt normal
  li r3, 0x3
normal:
	word 0x5460103A #rlwinm	r0, r3, 2, 0, 0x1D not supported currently
}
#Resource ID, Points to text in pf/info2/info_training.pac, MiscData[150], add custom name to end of list
HOOK @ $80105BCC 
{
  lwzx r5, r31, r0
  cmpwi r30, 0x6
  blt %end%
  addi r5, r5, 0x8
}
HOOK @ $80105bf8
{
  lwzx r5, r31, r0
  cmpwi r30, 0x6
  blt %end%
  addi r5, r5, 0x8
}
HOOK @ $80105bf8
{
  lwzx r5, r31, r0
  cmpwi r30, 0x6
  blt %end%
  addi r5, r5, 0x8
}
HOOK @ $80105e94
{
  lwz r6, 0x24(r31)
  cmpwi r6, 0x6
  li r6, 0
  blt %end%
  addi r5, r5, 0x8
}
