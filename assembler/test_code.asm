ldd r1, fffff 
std r0, fffff
ldm r0, ffff
iadd r0, r1, ffff
shl r7, 1f
shr r6, 0
SWAP r6, r7
NOP
RTI
RET
setC
HLT