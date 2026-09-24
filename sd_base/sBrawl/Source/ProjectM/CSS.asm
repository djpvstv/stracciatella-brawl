###########################################
CSS Selections Preserved in VS Mode [Magus]
###########################################
op b 0x3C @ $806DCA90

#############################
CSS Record Display Fix [ds22]
#############################
HOOK @ $8068DBCC
{
  cmpwi r29, 0x28
  beq- %END%
  cmpwi r29, 0x29
}
op beq- 0x3C @ $8068DBD0

#################################################################################
Pick Any Color You Want Fix.Ver (RSBE.Ver) [original by Igglyboo , Fixed by JOJI]
#################################################################################
* 0469A2B4 380000FF
* 0469A3C4 380000FF
* 04696FD4 380000FF
* 04684E84 380000FF

#############################
!No C-stick menu tilting [Eon]
#############################
* 040A67B8 48000034
* 040A682C 48000034

##########################################
Don't load fighter files on CSS [MarioDox]
##########################################
HOOK @ $8094601c    # processBegin/[stLoaderPlayer]
{
    lis r12,0x8002        # \
    ori r12,r12,0xd018  # |
    mtctr r12            # |
    bctrl                # / getInstance/[gfSceneManager]
    lwz r3,0x04(r3)        # gfSceneManager->currentScene
    lwz r3,0x0(r3)    # get the scene name
    lwz r0,0x0(r3)    # first half
    lis r12,0x7363    # sc
    ori r12,r12,0x5365 # Se
    cmpw r0,r12
    bne- end
    lwz r0,0x4(r3)    # second half
    lis r12,0x6c63    # lc
    ori r12,r12,0x7443  # tC
    cmpw r0,r12
    bne- end
    lis r12,0x8094        # \ branch to ending of the function
    ori r12,r12,0x650c  # |
    mtctr r12            # |
    bctr                # /
end:
    mr r3,r30
    lbz r0,0x46(r3)    # original op
}