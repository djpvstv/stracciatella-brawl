##########################################
All-Star Rest Area Stock Display Cap[Desi]
##########################################
op stwu r1, -0x210, r1 @ $80952E8C
op addi r1, r1, 0x210 @ $80952F88
op stw r0, 0x170 r1 @ $80952E94
op lwz r0, 0x170 r1 @ $80952F80

#r4 contains number of characters remaining
#r9 contains number of characters defeated
#r10 contains the addition of the 2 previous numbers
HOOK @ $80952Ed8
{
    add r10, r9, r4 #Original Function, obtains total character count
    cmpwi r4, 0x33
    blt- UnderCap
    li r10, 0x32    #Set Character Count to 0x25
    add r4, r7, r0
    li r0, 0x32        #Set displayed stocks to 0x25
    b %END%
    
UnderCap:
    add r4, r7, r0    #Original Function
    sub r0, r10, r9    #Original Function. Subtracts Characters who have lost from Total Character Count.
}

op nop @ $80952EE0
op nop @ $80952EE4

##################################################################
Stock Rule Ignores "Removed" State (keeps swapping player in) [P+]
##################################################################
# From P+ 3.2 AllStarVs.asm (applied there unconditionally).
# checkStockCountRule / getTeamTotalStock skip any player whose rule-state byte (+0x25) is 3.
# Swapping characters (debug mode / code menu) briefly removes the fighter, which marks
# that player 3, so a 2-player stock match ends instantly. Counting players by stocks only
# keeps them in; eliminated players and empty ports still drop out (0 stocks).
op nop @ $8095506C	# checkStockCountRule: beq skip-if-state-3 (FFA stock)
op nop @ $80957DEC	# getTeamTotalStock:   beq skip-if-state-3 (team stock)