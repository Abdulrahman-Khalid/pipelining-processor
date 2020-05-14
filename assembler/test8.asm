

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.ORG 10
inc r0 # r0 -> 1
inc r0 # r0 -> 2
inc r1 # r1 -> 1
swap r1,r0 # r0 -> 1 and r1 -> 2
swap r0,r1 # r0 -> 2 and r1 -> 1
add r0,r1,r3 # r3 -> 3
swap r0,r3 # r0 -> 3 and r3 -> 2
iadd r3,r4,4 # r3 -> 2 and r4 -> 6
ldd r0,0 # r0 -> 0
inc r1 # r1 -> 2