
# all numbers in hex format
# we always start by reset signal
#this is a commented line

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
NOP
Not R1
inc r2
dec r3
dec r0
out r3
in r4
jz r5
jmp r2
Call R6
RET
RTI
push r7
pop r7
ldm r2, ffff
ldd r1, fffff
std r3, fffff
SWAP r6, r7
iadd r2, r1, ffff
shl r7, 1f
shr r6, 0
shr r6, f
add r1, r2, r3
sub r1, r2, r3
and r1, r2, r3
or r1, r2, r3
NOP
RTI
RET
setC
clrC
HLT