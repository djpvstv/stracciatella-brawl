##############################################################
Codes Sent with USB Gecko Append Existing Codeset v2.2 [Magus]
##############################################################

    ## NOTE:
    ## This code seems to modify the Gecko OS code handler, not the game's code.

HOOK @ $80001CE0
{
    lis r12, 0x8058             # \
    ori r12, r12, 0x0FE0        #  > If a USB Gecko is plugged in, this address will be populated with a flag.
    lwz r12, 0(r12)             # /
}

HOOK @ $80001ECC
{
    lis r4, 0x8058              # \
    ori r4, r4, 0x0FE0          #  > Load flag set by USB Gecko.
    lwz r3, 0(r4)               # /
    cmpwi r3, 0x0               # \ If flag is zero, no new codes have been sent during runtime.
    bne+ noneSent               # /
    subi r3, r15, 0x8           # \ If a line of new code has been sent, subtract 0x8 bytes from the lower bound of the 
    stw r3, 0(r4)               # / Gecko Code Table to later append the new code to the beginning of the existing codeset.
noneSent:
    lwz r4, 0(r18)              # Original instruction.
}

########################################################
OSREPORT Debug Logs Over USB Gecko [bushing, Exul Anima]
########################################################

HOOK @ $803F5590
{
    ## NOTE:
    ## If the code detects it's running on Dolphin Emulator, the codepath is unaltered 
    ## and logs print through the emulator log window.
    ## Otherwise logs get piped to a USB Gecko in slot B (channel 1) via EXI serial connection.
    ## 
    ## This is done by reading the SPR_ECID registers, which contain a hardware ID unique to each Broadway CPU.
    ## Dolphin has a unique ID not shared by any known real hardwawre configuration.

    word 0x7D9CE2A6             # mfspr r12, 924 (SPR_ECID_U)
    lis r11, 0x0D96
    ori r11, r11, 0xE200
    cmplw r12, r11
    beq isDolphin
    word 0x7D9DE2A6             # mfspr r12, 925 (SPR_ECID_M)
    lis r11, 0x1840
    ori r11, r11, 0xC00D
    cmplw r12, r11
    beq isDolphin
    word 0x7D9EE2A6             # mfspr r12, 926 (SPR_ECID_L)
    lis r11, 0x82BB
    ori r11, r11, 0x08E8
    cmplw r12, r11
    beq isDolphin
    
    /* __fwrite() patch courtesy of bushing (RIP). */

    mullw r4, r4, r5            # Total bytes to write to console.
    li r10, 0x0                 # Counter measuring bytes written.
    stwu r1, -0x10(r1)          # \ Prologue
    stw r31, 0xc(r1)            # /
    cmpw cr7, r10, r4           # \ If 0 or fewer (negative) bytes are requested for transfer, skip.
    bge- cr7, end               # /
    lis r8, 0xCD00              # \
    lis r11, 0xCD00             #  > Base virtual address of Starlet/IOP registers (0xCD000000).
    lis r9, 0xCD00              # /
    ori r8, r8, 0x6814          # EXI Channel 1 Command Status Register.
    ori r11, r11, 0x6824        # EXI Channel 1 Immediate Data Register.
    ori r9, r9, 0x6820          # EXI Channel 1 Control Register.
    li r12, 0xd0                # Token to set device writes to EXI channel 1 @ 27 MHz.
    li r6, 0x19                 # Token to start immediate read/write of two bytes at a time.
    li r7, 0x0                  # Token to stop writing to EXI channel 1.
startNewTransfer:
    stw r12, 0x0(r8)            # Write token to EXI Channel 1 Command Status Register.
    lbzx r0, r3, r10            # \
    rlwinm r0, r0, 20, 0, 11    #  > Format data bytes to be written.
    oris r0, r0, 0xB000         # /
    stw r0, 0x0(r11)            # Write token to EXI Channel 1 Immediate Data Register.
    stw r6, 0x0(r9)             # Write token to EXI Channel 1 Control Register.
dataTransferLoop:
    lwz r0, 0x0(r9)             # \
    andi. r31, r0, 1            #  > Check if current transfer is still running.
    bne+ dataTransferLoop       # /
    lwz r0, 0x0(r11)            # Get return value from transmission.
    stw r7, 0x0(r8)             # Unset device settings to end serial transmission.
    rlwinm r0, r0, 6, 31, 31    # \ Increment bytes written counter.
    add r10, r10, r0            # /
    cmpw cr7, r10, r4           # \ If bytes written equals the total bytes to write, then stop writing to USB Gecko.
    blt+ cr7, startNewTransfer  # /
end:
    mr r3, r5                   # \
    lwz r31, 0xc(r1)            #  \ Epilogue
    addi r1, r1, 0x10           #  /
    blr                         # /
isDolphin:
    stwu r1, -0x30(r1)          # Original instruction.
}