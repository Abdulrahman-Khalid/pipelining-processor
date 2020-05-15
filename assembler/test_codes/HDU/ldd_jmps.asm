

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.org 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.org 10
ldm r2, 30                                                     #10
std r2, 18                                                     #11, 12
ldm r2, 40                                                     #13
std r2, 20                                                     #14, 15
ldm r2, 50                                                     #16
std r2, 22                                                     #17, 18
ldm r2, 200                                                    #19
std r2, 24                                                     #1A, 1B

LDD r2, 18 # r2 -> 30                                           # 1C, 1D

#add r2,r3,r1 # r1 -> 30 # stall 1 time r1 -> 30                 # 1E
#jmp r1 # jump to address 30                                     # 1F
#.org 30
#ldd r1, 18 # r1 -> 40                                          
#jmp r1      # stall 3 times
#.org 40
#ldm r7, 60
#jz r7       # r7 -> 60 # no stall
#.org 60
#ldd r2, 20 # r2 -> 50
#jz r2       # r2 -> 140 # no stall
#.org 50
#ldd r2, 22 # r2 -> 200
#call r2       # r2 -> 200 # stall 3 times