################################
Tag Font Adjustments [MarioDox]
################################
# beginPrint/[MuMsg]
op nop @ $800b90b0			# fontFace

# makeStringTex/[IfPlayer]
op lfs f0,-0x7270(r2) @ $800e12a4	# setScale (0.05 = 1)
op lfs f1,-0x6e0c(r2) @ $800e12b8	# fixedWidth
#op li r4,0x4 @ $800e12e0	# fontFace
op nop @ $800e12cc		# autoWidth
