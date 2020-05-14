

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.ORG 10
ldd r1, 100 # r0 -> 100
jmp r1      # stall 3 times
inc r1
jz r1       # r0 -> 100 # stall 3 times
ldd r2, 100 # r0 -> 100
call r1       # r0 -> 100 # no stall
ldd r2, 100 # r0 -> 100
call r2       # r0 -> 100 # stall 3 times