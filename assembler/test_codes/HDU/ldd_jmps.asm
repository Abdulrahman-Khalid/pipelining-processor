

.org 2 
100 # this interupt address

.org 100
pop r3
add r1, r3, r5
rti # interupt logic

.org 0  #this means the the following line would be  at address  0 , and this is the reset address
10

.org 10
# Store 30 in address(18) in ram
ldm r2, 30                                                                      #10, 11
std r2, 18                                                                      #12, 13
#######################################################################################################
# Store 40 in address(1A) in ram
ldm r2, 40                                                                      #14, 15
std r2, 1A                                                                      #15, 16
#######################################################################################################
# Store 50 in address(1C) in ram
ldm r2, 50                                                                      #17, 18
std r2, 1C                                                                      #19, 1A
#######################################################################################################
# Store 200 in address(1E) in ram
ldm r2, 200                                                                     #1B, 1C
std r2, 1E                                                                      #1D, 1E
#######################################################################################################
LDD r2, 18      # r2 -> 30                                                      # 1F, 20
add r2,r3,r1    # r1 -> 30      # no stall r1 -> 30                             # 21
# jump to address 30 
jmp r1                          # stall 3 times                                 # 22

.org 30
ldd r1, 1A     # r1 -> 40                                                       # 30, 31                        
jmp r1                                      # 2 stall                           # 32

.org 40
add r6,r7,r7    # zero flag                                                     # 40
ldm r7, 60                                                                      # 41, 42
jmp r7          # r7 -> 60                  # 1 stall                           # 43

.org 60
ldd r2, 1C     # r2 -> 50                                                       # 60, 61
jmp r2         # r2 -> 140                  # 2 stall                           # 62

.org 50
ldm r2, 80                                                                      #50, 51
ldm r1, 70                                                                      #52, 53
swap r2, r1    # r1 -> 80 , r2 -> 70                                            #54
jmp r2         # r2 -> 70                   # 2 stall                           #55

#this will be executed two times        
.org 70
swap r2, r1    # (1) r1 -> 80 , r2 -> 70 , (2) r1 -> 80 , r2 -> 70              #70
add r6, r7, r7                                                                  #71
jmp r1         # r2 -> 200                  # 1 stall(swap)                     #72

.org 80
ldm r1, 0                                                                       #80, 81
ldm r2, 0                                                                       #82, 83