#Target Build: P+EX.
#Instructions
#1. In RSBE01.txt, find the "Individual Stock Icons" code and put an ! in front of the title. That will disable the code.
#"!Individual Stock Icons (info.pac) V2.6 PMEx + 50CC [ds22, wiiztec, DukeItOut, PyotrLuzhin, KingJigglypuff]"
#2. Add Stockless.asm to Source/Extras. Add the following line near where Individual Stock Icons was.
#".include Source/Extras/Stockless.asm"
#3. Replace the Info.pac and Results Screen file with the on of your choosing.
#4. If you have an Info.pac setup for use without BPs, in Stockless.asm, enable "BPs Always Load InfFace0000.brres [Desi]" by removing the "!" from in front of it.
#
#Credits:
#Generic Stock Icons are from Smash 3 HUD. https://smashboards.com/threads/the-smash-3-project-all-characters-released.340807/
#Base Files from P+ / P+EX
#
######################################
Player ID instead of Character ID used in Results Screen [Desi]
######################################
op stb r5, 0x34 (r6) @ $80954828   #Game stores Player ID instead of Character ID
op addi r0, r5, 0x1 @ $800E8b28    #Adds 1 to the Player ID, This is where the game would have loaded the Costume ID and added it to the player ID.
op stb r4, 0xFC (r6) @ $80954860    #Above is for KOs, this is for Falls. Character killed is in R5, character who performed the kill is in R4.
op addi r0, r5, 0x1 @ $800E8C24

##################################################
Classic CSS uses a generic stock icon. [DukeItOut]
##################################################
op nop @ $806924C8

########################################
!BPs Always Load InfFace0000.brres [Desi]
########################################
#Disabled by default. Use with an Info.pac setup for use without BPs
op li r5, 0 @ $800E206C     #This loads the stock face to use from r26. Setting it to 0 makes it load 0.