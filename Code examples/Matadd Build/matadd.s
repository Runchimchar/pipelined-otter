

#Matrix addition
.data 
	A: .word 1,1, 1,1, 3,3, 1,1
    B: .word 1,1, 5,5, 1,1, 1,1
	#two 2x4 matrices, M = 4, N = 2
.text
# variables: M (a4), m counter(t3), A address(t4), N(a5), n counter(t5), B address(t6), 
# calculated place in ar[] (a6)
# cell address for A is s2, for B is s3

.global main 
.type main, @function

main:

LI a4, 4 #M
LI a5, 2 #N
LI t3, 0 #M loop counter
LI t5, 0 #N loop counter
LA t4, A #A address
LA t6, B #B address
LI a6, 0 #register that holds #places off start of address 


ADDI sp, sp, -8 #allocate stack space for saved registers
SW s3, 4(sp)   
SW s2, 0(sp)  

MLOOP: BEQ t3, a4, ENDM #if M counter == M, end loop
    NLOOP: BEQ t5, a5, ENDN #if N counter == N, ned loop
    	#place equation: place = wordsize*(Mcount*#columns(N) + Ncount)
		ADDI a2, a5, 0 #set multiplication function variable a2 as N (total num of columns)
        ADDI a3, t3, 0 #set mult func variable a3 as current num of rows
        CALL MULT # product in a0
       	ADD a6, a0, t5 #a6 = Mcount*#columns(N) + Ncount
        ADDI a2, x0, 0x4 #a2 = 0x4
        ADDI a3, a6, 0 # MV a3 a6
        CALL MULT #product in a0
        ADDI a6, a0, 0 #MV a6 a0
        ADD a6, a6, t4 #add starting address (t4) with cell distance (a6) for matrix A
        LW s2, 0(a6) #get cell [Mcount][Ncount] in matrix A
        SUB a6, a6, t4
        ADD a6, a6, t6 #add starting address (t4) with cell distance (a6) for matrix B
        LW s3, 0(a6) #get cell [Mcount][Ncount] in matrix B
        ADD s2, s2, s3
        SW s2, 0(a6)
        
        ADD a6, x0, x0 #zero out the cell distance register
        ADDI t5, t5, 1 #increment N counter
        J NLOOP
    ENDN:
    ADDI t5, x0, 0 #zero out the n counter
	ADDI t3, t3, 1
    J MLOOP
ENDM:

LW s3, 4(sp)
SW s2, 0(sp)
ADDI sp, sp, 8 #deallocate stack space
J END

MULT:
#multiplication A*B
#example A=5 B=4

LI a0, 0 #product
#LI a2 2 #bigger number
#LI a3 2 #smaller number, used to count down
LOOP: BEQ a3, x0, ENDLOOP
	ADD a0, a0, a2
    ADDI a3, a3, -1
    J LOOP
ENDLOOP:
RET

END:
