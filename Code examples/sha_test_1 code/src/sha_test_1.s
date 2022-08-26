.data
	SHA_ADDR_AD: .word 0x110F0000
	SHA_DATA_AD: .word 0x110F0004
.text

#s0 = SHA_ADDR_AD
#s1 = SHA_DATA_AD
#a0 = index
#a1 = data
.global main 
.type main, @function
main:
lw s0, SHA_ADDR_AD
lw s1, SHA_DATA_AD

# Set reset flag
li a0, 9 #reset flag
li a1, 1 #reset module
call set_sha

# Load AAB into str
# AAB = 0x00414142
li a0, 12 #first word of str
li a1, 0x00414142
call set_sha

# Load 3*8=24 bit size
li a0, 10 #lower word of str size
li a1, 24
call set_sha

# Set reset flag
li a0, 9 #reset flag
li a1, 0 #start module
call set_sha

# Poll done_flag
li a0, 0 #done flag
sw a0, (s0) #set select to done flag
li t0, 1 #correct done flag value
poll_done:
lw a1, (s1) #get done flag
bne a1, t0, poll_done

# end loop
end: j end

# Store A0 into ADDR_AD (s0)
# Store A1 into DATA_AD (s1)
set_sha:
sw a0, (s0)
sw a1, (s1)
ret