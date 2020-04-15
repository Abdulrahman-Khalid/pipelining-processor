// COMMENT

.ORG 1e     //comment
inc R1
label2:
add r0,#4 // comment here
cmp r0,r3
.org 30
Beq label2   
V .word 13e    
Br label1   //31 br rqm => 31 + (rqm) = 35
MoV R1,R2   //comment
dec R2
mov #4,R0
mov @#V,#ffff
Add R4,R2
label1:
add R4,R2
HLT
