

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.ORG 10
inc r0
inc r0
inc r1
swap r1,r0
swap r0,r1
add r0,r1,r3
swap r0,r3
iadd r3,r4,4
ldd r0,0
inc r1