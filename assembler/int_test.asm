
# all numbers in hex format
# we always start by reset signal
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines
.org 2 
90 # this interupt address



.ORG 10
NOP
Not R1
inc r2
SHR R1,3
SHL r2,7



.ORG 90
Not r5
dec r6
dec r7
RTI