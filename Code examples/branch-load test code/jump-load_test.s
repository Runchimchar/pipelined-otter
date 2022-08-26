# Test: LLB LBL BLL BLB
# Test that registers get correct value
.data
	A: .word 0xA
	B: .word 0xB

# s0: addr of 0xA
# s1: addr of 0xB
# t0: data from A
# t1: data from B

.text
init:
# initialize vars
la s0, A
la s1, B
li t0, 0
li t1, 0

main:
#PASS BRANCHES
#LLB
lw t0, 0(s0) #t0 = A
lw t1, 0(s1) #t1 = B
beqz x0, POST_LLB
POST_LLB:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#LBL
lw t0, 0(s0) #t0 = A
beqz x0, POST_LBL
lw t1, 0(s1) #t1 = B
POST_LBL:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#BLL
beqz x0, POST_BLL
lw t0, 0(s0) #t0 = A
lw t1, 0(s1) #t1 = B
POST_BLL:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#BLB
beqz x0, POST_BLB
lw t0, 0(s0) #t0 = A
beqz x0, POST_BLB
POST_BLB:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#FAIL BRANCHES
#LLB
lw t0, 0(s0) #t0 = A
lw t1, 0(s1) #t1 = B
bnez x0, POST_LLBF
POST_LLBF:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#LBL
lw t0, 0(s0) #t0 = A
bnez x0, POST_LBLF
lw t1, 0(s1) #t1 = B
POST_LBLF:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#BLL
bnez x0, POST_BLLF
lw t0, 0(s0) #t0 = A
lw t1, 0(s1) #t1 = B
POST_BLLF:

# intermediate NOPs
nop
li t0, 0
li t1, 0

#BLB
bnez x0, POST_BLBF
lw t0, 0(s0) #t0 = A
bnez x0, POST_BLBF
POST_BLBF:

# intermediate NOPs
nop
li t0, 0
li t1, 0

# end
end: j end
nop