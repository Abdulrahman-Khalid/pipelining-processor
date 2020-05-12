.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.ORG 10
ldm r0,0018
ldm r1,001c
ldm r2,0016
ldm r3,0002
inc r4
dec r3
jz r1
jmp r0
inc r5 
jmp r2
nop
nop
nop
nop
nop