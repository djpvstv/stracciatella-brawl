#######################################################################
ThrowN Fix and Throw Release Points v1.1c 242 Variant (Throw Animation Fix) [Magus]
#######################################################################
HOOK @ $8076CCE4
{
  lwz r10, 0x70(r18)
  lwz r10, 0x24(r10)
  lwz r10, 0xC(r10)
  lwz r9, 4(r10)
  cmpwi r9, 0x2329
  bne+ loc_0x1C
  li r3, 0x3

loc_0x1C:
  lwz r4, 0x8C(r19)
}
HOOK @ $80771688
{
  stfd f1, 0x18(r2)
  lwz r3, 0x10(r31)
  lwz r3, 0x60(r3)
  addi r4, r2, 0x20
  li r5, 0x0
  lis r10, 0x8077
  ori r10, r10, 0x866C
  mtctr r10
  bctrl 
  lfd f1, 0x18(r2)
  lfs f2, 0x20(r31)
  lwz r10, 0x10(r31)# \
  lwz r9, 8(r10)	# | Char ID retrieval
  lwz r9, 0x110(r9)	# /
  cmpwi r9, 0x0;  blt- finish
  cmpwi r9, 0xF3; bgt- finish	# Change this if using Brawl EX
  
  lis r8, 0x8077		# \ Pointer to offset table, below
  lwz r8, 0x1690(r8)	# /
  mulli r9, r9, 0x8
  lfsux f0, r8, r9
  fmuls f0, f0, f1
  lwz r7, 0x18(r10)
  lfs f2, 0x40(r7)
  fmuls f0, f0, f2
  lfs f2, 0x2C(r2)
  fadds f0, f2, f0
  stfs f0, 0x14(r1)
  lfs f2, 0x3C(r2)
  stfs f2, 0xC(r1)
  lfs f2, 4(r8)
finish:  
  addi r4, r1, 0x14		# \ Operations displaced by the below
  lfs f0, 0xC(r1)		# /
}
op b 0x8 @ $8077168C

	.BA<-ThrowReleaseTable
	.BA->$80771690
	.GOTO->SkipTable

#Throw Release Offset Data
ThrowReleaseTable:
	float[486] |
         0.0,       7.2672,  | # Mario
        -0.5,      13.0311,  | # Donkey Kong
      0.2257,       8.5516,  | # Link
     -0.4884,      11.3475,  | # Samus
         0.0,          7.0,  | # Yoshi
         0.0,          5.0,  | # Kirby
         0.0,          8.3,  | # Fox
         0.0,       5.7997,  | # Pikachu
         0.0,       7.2672,  | # Luigi
     -0.4884,      11.3475,  | # Captain Falcon
         0.0,       6.0042,  | # Ness
        -0.6,       13.725,  | # Bowser
         0.0,          9.4,  | # Peach
         0.0,          9.4,  | # Zelda
      0.3466,       8.2405,  | # Sheik
         0.0,       6.0042,  | # Ice Climbers
         NaN,          NaN,  | # Unknown
      0.4263,       9.8485,  | # Marth
         0.0,       5.1937,  | # Mr. Game & Watch
         0.0,          8.3,  | # Falco
     -0.4884,      12.3475,  | # Ganondorf
         0.0,          7.0,  | # Wario
         0.0,          5.0,  | # Meta Knight
      0.2257,       8.5516,  | # Pit
      0.3466,       8.2405,  | # Zero Suit Samus
         0.0,       6.0042,  | # Olimar
         0.0,       6.0042,  | # Lucas
         0.0,       7.2672,  | # Diddy Kong
         NaN,          NaN,  | # Unknown
        -0.6,       9.5311,  | # Charizard
         0.0,          5.0,  | # Squirtle
         0.0,       5.7997,  | # Ivysaur
        -0.6,       13.725,  | # King Dedede
         0.0,          8.3,  | # Lucario
      0.4263,       9.8485,  | # Ike
      0.2257,      10.3076,  | # R.O.B.
         0.0,          9.4,  | # Lyn
         0.0,          5.0,  | # Jigglypuff
      0.2257,      10.3076,  | # Mewtwo
      0.4263,       9.8485,  | # Roy
      0.2257,       8.5516,  | # Waluigi
         0.0,       6.0042,  | # Toon Link
        -0.6,       13.725,  | # Ridley
      0.2257,       8.5516,  | # Isaac
         0.0,          8.3,  | # Wolf
         0.0,          8.3,  | # Knuckles
     -0.4884,      11.3475,  | # Snake
         0.0,       7.2672,  | # Sonic
         0.0,          0.0,  | # Giga Bowser
         0.0,          7.0,  | # Wario
     -0.4884,      11.3475,  | # Unknown
         0.0,          9.4,  | # Unknown
         0.0,       7.2672,  | # Unknown
         0.0,          5.0,  | # Unknown
         0.0,          0.0,  | # Unknown
     -0.4884,      11.3475,  | # Mega Man X
         0.0,       7.2672,  | # Dr. Mario
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          8.3,  | # Sami
         0.0,          0.0,  | # Unknown
      0.2257,       8.5516,  | # Young Link
     -0.4884,      11.3475,  | # Dark Samus
         0.0,       5.7997,  | # Pichu
         0.0,       7.2672,  | # Metal Sonic
         0.0,       7.2672,  | # Bomberman
     -0.4884,      11.3475,  | # Big Boss
     -0.4884,      11.3475,  | # Ken
     -0.4884,      12.3475,  | # Phantom Ganon
     -0.4884,      11.3475,  | # Blood Falcon
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
      0.4263,       9.8485,  | # Lucina
         0.0,       7.2672,  | # Dr. Luigi
         0.0,       7.2672,  | # Shadow
     -0.4884,      11.3475,  | # Nu-13
      0.4263,       9.8485,  | # Cloud
      0.2257,       8.5516,  | # Dark Pit
         0.0,       7.2672,  | # Sukapon
     -0.4884,      11.3475,  | # Ryu
         0.0,       6.0042,  | # Ninten
        -0.6,       13.725,  | # Dry Bowser
      0.2257,       8.5516,  | # Geno
      0.4263,       9.8485,  | # Elizabeth
      0.4263,       9.8485,  | # Navarre
         0.0,       6.0042,  | # Alph
      0.4263,       9.8485,  | # Chrom
      0.4263,       9.8485,  | # Shulk
      0.4263,       9.8485,  | # Yu Narukami
      0.2257,       8.5516,  | # Squall
         0.0,          9.4,  | # Toon Zelda
         0.0,          9.4,  | # Daisy
         0.0,       6.0042,  | # Knuckle Joe
         0.0,       6.0042,  | # Louie
      0.4263,       9.8485,  | # Corrin
        -0.6,       9.5311,  | # Sceptile
     -0.4884,      11.3475,  | # Little Mac
         0.0,       7.2672,  | # PAC-MAN
         0.0,       7.2672,  | # Toad
     -0.4884,      11.3475,  | # Blaziken
     -0.4884,      11.3475,  | # Zero
     -0.4884,      12.3475,  | # Black Knight
         0.0,       6.0042,  | # Masked Man
     -0.4884,      11.3475,  | # Red Alloy
         0.0,          9.4,  | # Blue Alloy
         0.0,       7.2672,  | # Yellow Alloy
         0.0,          5.0,  | # Green Alloy
      0.4263,       9.8485,  | # Robin
         0.0,       6.0042,  | # Sans
         0.0,       6.0042,  | # Isabelle
         0.0,          9.4,  | # Palutena
         0.0,          8.3,  | # Zeraora
         0.0,       7.2672,  | # Tails
         0.0,          5.0,  | # Bandana Dee
     -0.4884,      11.3475,  | # Sub-Zero
         0.0,       5.7997,  | # Sandbag
     -0.4884,      11.3475,  | # Simon
     -0.4884,      11.3475,  | # Richter
     -0.4884,      12.3475,  | # Black Shadow
        -0.6,       13.725,  | # Metal Face
     -0.4884,      11.3475,  | # Terry
      0.2257,       8.5516,  | # Fierce Deity
      0.3466,       8.2405,  | # Joker
     -0.4884,      11.3475,  | # VectorMan
      0.3466,       8.2405,  | # Wii Fit Trainer
      0.3466,       8.2405,  | # Zero Suit Samus
      0.4263,       9.8485,  | # Robin
      0.4263,       9.8485,  | # Corrin
         0.0,          0.0,  | # Unknown
      0.4263,       9.8485,  | # Lucina
     -0.4884,      12.3475,  | # Deathborn
      0.2257,       8.5516,  | # Hero
         0.0,          0.0,  | # Unknown
         0.0,          8.3,  | # Wolf
      0.4263,       9.8485,  | # Mythra
         0.0,       7.2672,  | # Super Sonic
      0.4263,       9.8485,  | # Sephiroth
         0.0,          0.0,  | # Kumatora
         0.0,          0.0,  | # Unknown
      0.4263,       9.8485,  | # Pyra
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
      0.2257,       8.5516,  | # Banjo-Kazooie
     -0.4884,      12.3475,  | # Incineroar
         0.0,          0.0,  | # Unknown
        -0.6,       9.5311,  | # Mega Charizard X
      0.4263,       9.8485,  | # Roy
         0.0,          0.0,  | # Unknown
      0.4263,       9.8485,  | # Zack
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Giga Dry Bowser
      0.3466,       8.2405,  | # Bayonetta
         0.0,          5.0,  | # Meta Knight
         0.0,          5.0,  | # Big Jigglypuff
         0.0,       7.2672,  | # Silver
         0.0,          0.0,  | # Unknown
      0.2257,      10.3076,  | # Mega Mewtwo Y
         0.0,          0.0,  | # Unknown
         0.0,       7.2672,  | # Metal Mario
      0.2257,       8.5516,  | # Sora
         0.0,          8.3,  | # Mega Lucario
     -0.4884,      12.3475,  | # Ganondorf
      0.3466,       8.2405,  | # Suitless Samus
        -0.5,      13.0311,  | # Giant D.K.
         0.0,          8.3,  | # Falco
         0.0,       6.0042,  | # Lucas
      0.3466,       8.2405,  | # Wii Fit Trainer
         0.0,          0.0,  | # Unknown
     -0.4884,      12.3475,  | # King K. Rool
      0.4263,       9.8485,  | # Alucard
         0.0,          0.0,  | # Chrom
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
     -0.4884,      11.3475,  | # Rock
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,       7.2672,  | # Shovel Knight
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
     -0.4884,      12.3475,  | # Kazuya Mishima
         0.0,          0.0,  | # Unknown
         0.0,       7.2672,  | # Super Shadow
         0.0,          0.0,  | # Unknown
     -0.4884,      12.3475,  | # Master Chief
         0.0,       7.2672,  | # Primid
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
     -0.4884,      11.3475,  | # Dark Samus
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Sol Badguy
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Dragon King
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0,  | # Unknown
         0.0,          0.0 # Unknown

SkipTable:
	.RESET