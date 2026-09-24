####################################################
Classic and All-Star Results Music Table [DukeItOut]
####################################################
HOOK @ $806E0980		# Classic Mode
{
	lbz r0, 0x33(r15)	# Get the character ID, original operation
	rlwinm r0, r0, 1, 0, 30	# Multiply by 2
	lis r3, 0x806E		# \ Get pointer to table
	lwz r3, 0x0988(r3)	# /
	lhzx r3, r3, r0		# Get 16-bit value for the song ID
	oris r0, r3, 0xFF00	# For unknown reasons, having FF in the two highest digits is used for verification
}
HOOK @ $806E3650		# All-Star Mode
{
	lbz r0, 0x98(r6)	# Get the character ID
	rlwinm r0, r0, 1, 0, 30	# Multiply by 2
	lis r3, 0x806E		# \ Get pointer to table
	lwz r3, 0x0988(r3)	# /
	lhzx r3, r3, r0		# Get 16-bit value for the song ID
	oris r0, r3, 0xFF00	# For unknown reasons, having FF in the two highest digits is used for verification
}
op b 0x8 @ $806E0984	# Skip operation afterwards since we are using a different load method
	.BA<-ClassicResultsTable
	.BA->$806E0988
	.GOTO->SkipResultsTable
ClassicResultsTable:
	half[128] |
0x271A, 0x272D, 0x2739, 0x2748,  | # Mario, Donkey Kong, Link, Samus
0x2748, 0x2750, 0x275A, 0x276E,  | # Zero Suit Samus, Yoshi, Kirby, Fox
0x276F, 0x271C, 0x277A, 0x278F,  | # Pikachu, Luigi, Captain Falcon, Ness
0x281D, 0x271A, 0x273B, 0x273B,  | # Bowser, Peach, Zelda, Sheik
0x27C9, 0x27C9, 0x27C9, 0x280F,  | # Ice Climbers, Unknown, Unknown, Marth
0x27D4, 0x2765, 0x273F, 0x27A2,  | # Mr. Game & Watch, Falco, Ganondorf, Wario
0x275C, 0x27C0, 0x279F, 0x2796,  | # Meta Knight, Pit, Olimar, Lucas
0x272D, 0x2770, 0x2770, 0x2770,  | # Diddy Kong, Unknown, Charizard, Unknown
0x2770, 0x2770, 0x2770, 0x2758,  | # Squirtle, Unknown, Ivysaur, King Dedede
0x2776, 0x278D, 0x27C4, 0x2770,  | # Lucario, Ike, R.O.B., Jigglypuff
0x273E, 0x2767, 0x27EC, 0x27FE,  | # Toon Link, Wolf, Snake, Sonic
0x281D, 0x27A2, 0x0000, 0x0000,  | # Giga Bowser, Wario-Man, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Roxas, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Pok∈mon Trainer, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000,  | # Unknown, Unknown, Unknown, Unknown
0x0000, 0x0000, 0x0000, 0x0000 # Unknown, Unknown, Unknown, Unknown

# Original table at $80702418
SkipResultsTable:
	.RESET