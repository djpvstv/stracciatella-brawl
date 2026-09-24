
#############################################
Jumps Calculate One Frame Earlier [DukeItOut]
#############################################
#
# Fakes out the physics delay by calculating
# gravity, jump speed and position in advance
#
# Also makes jumping out of water easier
# by increasing jump height in that context
#############################################
HOOK @ $8086BD34	# Grounded or Swimming
{
	lfs f0, 0x24(r1)	 # Desired movement Y speed. Some branches don't have this set.
    lwz r29, 0xD0(r30)   # \ Retrieve the gravity for the character
    lfs f31, 0x70(r29)   # /
	
	lwz r29, 0x7C(r30)	 # \ Get previous action
	lhz r29, 0x06(r29)	 # /

	cmpwi r29, 0xBA		 # Check if we are trying to leap out of water

	
    lwz r29, 0x18(r30)   # \
    lfs f1, 0x1C(r29)    # | Simulate one frame of vertical movement
    fadds f1, f0, f1     # |
	bne+ notSwimming	 # |
	fadds f1, f0, f1	 # | We want to make it easier to get out of the water, so let's boost it a bit!
notSwimming:			 # |
	fsubs f1, f1, f31	 # |
    stfs f1, 0x10(r29)   # / 
    fsubs f1, f0, f31    # \ Jump/Hop "Velocity" now calculates as if it is the second frame, because . . . .
    stfs f1, 0x24(r1)    # /
	
    lis r29, 0x80AE      # Original operation
}

HOOK @ $8086BE60	# Mid-Air Jump
{
    lwz r31, 0xD0(r30)   # \ Retrieve the gravity for the character
    lfs f31, 0x70(r31)   # / 

	lwz r31, 0x18(r30)   # \
    lfs f0, 0x1C(r31)    # | Simulate one frame of vertical movement
    fadds f0, f0, f1     # |
	fsubs f0, f0, f31	 # |
    stfs f0, 0x10(r31)   # /

    fsubs f1, f1, f31    # Jump/Hop "Velocity" now calculates as if it is the second frame, because . . . .
    lis r31, 0x80AE      # Original operation
}
