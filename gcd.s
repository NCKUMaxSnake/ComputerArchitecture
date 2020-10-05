.data
in1: .word 24
in2: .word 16

.text
main:
	lw a0, in1
	lw a1, in2
	jal GCD
	li a7,1
	ecall
	j end

GCD:
	beqz a1,return      # if(a1 = 0)  t0 = 0;
	#blt a0, a1, swap   # if(a0 > a1) goto SWAP;
	rem a0, a0, a1      # a0 = a0 % a1;
swap:
	mv t1, a0
	mv a0, a1
	mv a1, t1
	j GCD
return:
	jr ra
end: