

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
.org 18
30
40
50
200
.ORG 10
LDD r2, 18
add r2,r3,r1 # r1 -> 18 # stall 1 time r1 -> 30
jmp r1
.org 30
ldd r1, 19 # r1 -> 40
jmp r1      # stall 3 times
.org 40
ldm r7, 60
jz r7       # r7 -> 60 # no stall
.org 60
ldd r2, 20 # r2 -> 50
jz r2       # r2 -> 140 # no stall
.org 50
ldd r2, 21 # r2 -> 200
call r2       # r2 -> 200 # stall 3 times