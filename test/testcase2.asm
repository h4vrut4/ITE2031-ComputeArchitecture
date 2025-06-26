.text
main:
eq_branch0:
	li $t0, 376271
	li $t1, -408879
	li $t2, 455622
	li $t3, -949605
	li $s0, 477715
	li $s1, -571660
	li $s2, 217391
	li $s3, -808485
	move $t0, $s1
	beq $t0, $s0, eq_0_0_0
	beq $t0, $s1, eq_0_0_1
	beq $t0, $s2, eq_0_0_2
	beq $t0, $s3, eq_0_0_3
	beq $t1, $s0, eq_0_1_0
	beq $t1, $s1, eq_0_1_1
	beq $t1, $s2, eq_0_1_2
	beq $t1, $s3, eq_0_1_3
	beq $t2, $s0, eq_0_2_0
	beq $t2, $s1, eq_0_2_1
	beq $t2, $s2, eq_0_2_2
	beq $t2, $s3, eq_0_2_3
	beq $t3, $s0, eq_0_3_0
	beq $t3, $s1, eq_0_3_1
	beq $t3, $s2, eq_0_3_2
	beq $t3, $s3, eq_0_3_3
	j error
eq_0_0_0:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s0
	j neq_branch0
eq_0_0_1:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s1
	j neq_branch0
eq_0_0_2:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s2
	j neq_branch0
eq_0_0_3:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s3
	j neq_branch0
eq_0_1_0:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s0
	j neq_branch0
eq_0_1_1:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s1
	j neq_branch0
eq_0_1_2:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s2
	j neq_branch0
eq_0_1_3:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s3
	j neq_branch0
eq_0_2_0:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s0
	j neq_branch0
eq_0_2_1:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s1
	j neq_branch0
eq_0_2_2:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s2
	j neq_branch0
eq_0_2_3:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s3
	j neq_branch0
eq_0_3_0:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s0
	j neq_branch0
eq_0_3_1:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s1
	j neq_branch0
eq_0_3_2:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s2
	j neq_branch0
eq_0_3_3:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s3
	j neq_branch0
neq_branch0:
	li $t0, 269382
	li $t1, 269382
	li $t2, 269382
	li $t3, 269382
	li $s0, 269382
	li $s1, 269382
	li $s2, 269382
	li $s3, 269382
	li $t2, 505707
	li $s0, 505707
	bne $t0, $s0, neq_0_0_0
	bne $t0, $s1, neq_0_0_1
	bne $t0, $s2, neq_0_0_2
	bne $t0, $s3, neq_0_0_3
	bne $t1, $s0, neq_0_1_0
	bne $t1, $s1, neq_0_1_1
	bne $t1, $s2, neq_0_1_2
	bne $t1, $s3, neq_0_1_3
	bne $t2, $s0, neq_0_2_0
	bne $t2, $s1, neq_0_2_1
	bne $t2, $s2, neq_0_2_2
	bne $t2, $s3, neq_0_2_3
	bne $t3, $s0, neq_0_3_0
	bne $t3, $s1, neq_0_3_1
	bne $t3, $s2, neq_0_3_2
	bne $t3, $s3, neq_0_3_3
	j error
neq_0_0_0:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s0
	j eq_branch1
neq_0_0_1:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s1
	j eq_branch1
neq_0_0_2:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s2
	j eq_branch1
neq_0_0_3:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s3
	j eq_branch1
neq_0_1_0:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s0
	j eq_branch1
neq_0_1_1:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s1
	j eq_branch1
neq_0_1_2:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s2
	j eq_branch1
neq_0_1_3:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s3
	j eq_branch1
neq_0_2_0:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s0
	j eq_branch1
neq_0_2_1:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s1
	j eq_branch1
neq_0_2_2:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s2
	j eq_branch1
neq_0_2_3:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s3
	j eq_branch1
neq_0_3_0:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s0
	j eq_branch1
neq_0_3_1:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s1
	j eq_branch1
neq_0_3_2:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s2
	j eq_branch1
neq_0_3_3:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s3
	j eq_branch1
eq_branch1:
	li $t0, -655708
	li $t1, 700173
	li $t2, 894630
	li $t3, -418835
	li $s0, 194426
	li $s1, -690485
	li $s2, -856880
	li $s3, 13619
	move $t1, $s2
	beq $t0, $s0, eq_1_0_0
	beq $t0, $s1, eq_1_0_1
	beq $t0, $s2, eq_1_0_2
	beq $t0, $s3, eq_1_0_3
	beq $t1, $s0, eq_1_1_0
	beq $t1, $s1, eq_1_1_1
	beq $t1, $s2, eq_1_1_2
	beq $t1, $s3, eq_1_1_3
	beq $t2, $s0, eq_1_2_0
	beq $t2, $s1, eq_1_2_1
	beq $t2, $s2, eq_1_2_2
	beq $t2, $s3, eq_1_2_3
	beq $t3, $s0, eq_1_3_0
	beq $t3, $s1, eq_1_3_1
	beq $t3, $s2, eq_1_3_2
	beq $t3, $s3, eq_1_3_3
	j error
eq_1_0_0:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s0
	j neq_branch1
eq_1_0_1:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s1
	j neq_branch1
eq_1_0_2:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s2
	j neq_branch1
eq_1_0_3:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s3
	j neq_branch1
eq_1_1_0:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s0
	j neq_branch1
eq_1_1_1:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s1
	j neq_branch1
eq_1_1_2:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s2
	j neq_branch1
eq_1_1_3:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s3
	j neq_branch1
eq_1_2_0:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s0
	j neq_branch1
eq_1_2_1:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s1
	j neq_branch1
eq_1_2_2:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s2
	j neq_branch1
eq_1_2_3:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s3
	j neq_branch1
eq_1_3_0:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s0
	j neq_branch1
eq_1_3_1:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s1
	j neq_branch1
eq_1_3_2:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s2
	j neq_branch1
eq_1_3_3:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s3
	j neq_branch1
neq_branch1:
	li $t0, 10974
	li $t1, 10974
	li $t2, 10974
	li $t3, 10974
	li $s0, 10974
	li $s1, 10974
	li $s2, 10974
	li $s3, 10974
	li $t0, 514056
	li $s3, 514056
	bne $t0, $s0, neq_1_0_0
	bne $t0, $s1, neq_1_0_1
	bne $t0, $s2, neq_1_0_2
	bne $t0, $s3, neq_1_0_3
	bne $t1, $s0, neq_1_1_0
	bne $t1, $s1, neq_1_1_1
	bne $t1, $s2, neq_1_1_2
	bne $t1, $s3, neq_1_1_3
	bne $t2, $s0, neq_1_2_0
	bne $t2, $s1, neq_1_2_1
	bne $t2, $s2, neq_1_2_2
	bne $t2, $s3, neq_1_2_3
	bne $t3, $s0, neq_1_3_0
	bne $t3, $s1, neq_1_3_1
	bne $t3, $s2, neq_1_3_2
	bne $t3, $s3, neq_1_3_3
	j error
neq_1_0_0:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s0
	j eq_branch2
neq_1_0_1:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s1
	j eq_branch2
neq_1_0_2:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s2
	j eq_branch2
neq_1_0_3:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s3
	j eq_branch2
neq_1_1_0:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s0
	j eq_branch2
neq_1_1_1:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s1
	j eq_branch2
neq_1_1_2:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s2
	j eq_branch2
neq_1_1_3:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s3
	j eq_branch2
neq_1_2_0:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s0
	j eq_branch2
neq_1_2_1:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s1
	j eq_branch2
neq_1_2_2:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s2
	j eq_branch2
neq_1_2_3:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s3
	j eq_branch2
neq_1_3_0:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s0
	j eq_branch2
neq_1_3_1:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s1
	j eq_branch2
neq_1_3_2:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s2
	j eq_branch2
neq_1_3_3:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s3
	j eq_branch2
eq_branch2:
	li $t0, -397730
	li $t1, -476642
	li $t2, -448552
	li $t3, -484051
	li $s0, -669008
	li $s1, 691775
	li $s2, 554115
	li $s3, 151350
	move $t3, $s0
	beq $t0, $s0, eq_2_0_0
	beq $t0, $s1, eq_2_0_1
	beq $t0, $s2, eq_2_0_2
	beq $t0, $s3, eq_2_0_3
	beq $t1, $s0, eq_2_1_0
	beq $t1, $s1, eq_2_1_1
	beq $t1, $s2, eq_2_1_2
	beq $t1, $s3, eq_2_1_3
	beq $t2, $s0, eq_2_2_0
	beq $t2, $s1, eq_2_2_1
	beq $t2, $s2, eq_2_2_2
	beq $t2, $s3, eq_2_2_3
	beq $t3, $s0, eq_2_3_0
	beq $t3, $s1, eq_2_3_1
	beq $t3, $s2, eq_2_3_2
	beq $t3, $s3, eq_2_3_3
	j error
eq_2_0_0:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s0
	j neq_branch2
eq_2_0_1:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s1
	j neq_branch2
eq_2_0_2:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s2
	j neq_branch2
eq_2_0_3:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s3
	j neq_branch2
eq_2_1_0:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s0
	j neq_branch2
eq_2_1_1:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s1
	j neq_branch2
eq_2_1_2:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s2
	j neq_branch2
eq_2_1_3:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s3
	j neq_branch2
eq_2_2_0:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s0
	j neq_branch2
eq_2_2_1:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s1
	j neq_branch2
eq_2_2_2:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s2
	j neq_branch2
eq_2_2_3:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s3
	j neq_branch2
eq_2_3_0:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s0
	j neq_branch2
eq_2_3_1:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s1
	j neq_branch2
eq_2_3_2:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s2
	j neq_branch2
eq_2_3_3:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s3
	j neq_branch2
neq_branch2:
	li $t0, 160363
	li $t1, 160363
	li $t2, 160363
	li $t3, 160363
	li $s0, 160363
	li $s1, 160363
	li $s2, 160363
	li $s3, 160363
	li $t0, -715874
	li $s3, -715874
	bne $t0, $s0, neq_2_0_0
	bne $t0, $s1, neq_2_0_1
	bne $t0, $s2, neq_2_0_2
	bne $t0, $s3, neq_2_0_3
	bne $t1, $s0, neq_2_1_0
	bne $t1, $s1, neq_2_1_1
	bne $t1, $s2, neq_2_1_2
	bne $t1, $s3, neq_2_1_3
	bne $t2, $s0, neq_2_2_0
	bne $t2, $s1, neq_2_2_1
	bne $t2, $s2, neq_2_2_2
	bne $t2, $s3, neq_2_2_3
	bne $t3, $s0, neq_2_3_0
	bne $t3, $s1, neq_2_3_1
	bne $t3, $s2, neq_2_3_2
	bne $t3, $s3, neq_2_3_3
	j error
neq_2_0_0:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s0
	j eq_branch3
neq_2_0_1:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s1
	j eq_branch3
neq_2_0_2:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s2
	j eq_branch3
neq_2_0_3:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s3
	j eq_branch3
neq_2_1_0:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s0
	j eq_branch3
neq_2_1_1:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s1
	j eq_branch3
neq_2_1_2:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s2
	j eq_branch3
neq_2_1_3:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s3
	j eq_branch3
neq_2_2_0:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s0
	j eq_branch3
neq_2_2_1:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s1
	j eq_branch3
neq_2_2_2:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s2
	j eq_branch3
neq_2_2_3:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s3
	j eq_branch3
neq_2_3_0:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s0
	j eq_branch3
neq_2_3_1:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s1
	j eq_branch3
neq_2_3_2:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s2
	j eq_branch3
neq_2_3_3:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s3
	j eq_branch3
eq_branch3:
	li $t0, 55691
	li $t1, 873787
	li $t2, -763503
	li $t3, 789604
	li $s0, -290221
	li $s1, 686608
	li $s2, -529892
	li $s3, -622105
	move $t1, $s1
	beq $t0, $s0, eq_3_0_0
	beq $t0, $s1, eq_3_0_1
	beq $t0, $s2, eq_3_0_2
	beq $t0, $s3, eq_3_0_3
	beq $t1, $s0, eq_3_1_0
	beq $t1, $s1, eq_3_1_1
	beq $t1, $s2, eq_3_1_2
	beq $t1, $s3, eq_3_1_3
	beq $t2, $s0, eq_3_2_0
	beq $t2, $s1, eq_3_2_1
	beq $t2, $s2, eq_3_2_2
	beq $t2, $s3, eq_3_2_3
	beq $t3, $s0, eq_3_3_0
	beq $t3, $s1, eq_3_3_1
	beq $t3, $s2, eq_3_3_2
	beq $t3, $s3, eq_3_3_3
	j error
eq_3_0_0:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s0
	j neq_branch3
eq_3_0_1:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s1
	j neq_branch3
eq_3_0_2:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s2
	j neq_branch3
eq_3_0_3:
	addu $t4, $t4, $t0
	addu $s4, $s4, $s3
	j neq_branch3
eq_3_1_0:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s0
	j neq_branch3
eq_3_1_1:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s1
	j neq_branch3
eq_3_1_2:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s2
	j neq_branch3
eq_3_1_3:
	addu $t4, $t4, $t1
	addu $s4, $s4, $s3
	j neq_branch3
eq_3_2_0:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s0
	j neq_branch3
eq_3_2_1:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s1
	j neq_branch3
eq_3_2_2:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s2
	j neq_branch3
eq_3_2_3:
	addu $t4, $t4, $t2
	addu $s4, $s4, $s3
	j neq_branch3
eq_3_3_0:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s0
	j neq_branch3
eq_3_3_1:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s1
	j neq_branch3
eq_3_3_2:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s2
	j neq_branch3
eq_3_3_3:
	addu $t4, $t4, $t3
	addu $s4, $s4, $s3
	j neq_branch3
neq_branch3:
	li $t0, -464673
	li $t1, -464673
	li $t2, -464673
	li $t3, -464673
	li $s0, -464673
	li $s1, -464673
	li $s2, -464673
	li $s3, -464673
	li $t1, -404652
	li $s3, -404652
	bne $t0, $s0, neq_3_0_0
	bne $t0, $s1, neq_3_0_1
	bne $t0, $s2, neq_3_0_2
	bne $t0, $s3, neq_3_0_3
	bne $t1, $s0, neq_3_1_0
	bne $t1, $s1, neq_3_1_1
	bne $t1, $s2, neq_3_1_2
	bne $t1, $s3, neq_3_1_3
	bne $t2, $s0, neq_3_2_0
	bne $t2, $s1, neq_3_2_1
	bne $t2, $s2, neq_3_2_2
	bne $t2, $s3, neq_3_2_3
	bne $t3, $s0, neq_3_3_0
	bne $t3, $s1, neq_3_3_1
	bne $t3, $s2, neq_3_3_2
	bne $t3, $s3, neq_3_3_3
	j error
neq_3_0_0:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s0
	j eq_branch4
neq_3_0_1:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s1
	j eq_branch4
neq_3_0_2:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s2
	j eq_branch4
neq_3_0_3:
	addu $t5, $t5, $t0
	addu $s5, $s5, $s3
	j eq_branch4
neq_3_1_0:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s0
	j eq_branch4
neq_3_1_1:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s1
	j eq_branch4
neq_3_1_2:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s2
	j eq_branch4
neq_3_1_3:
	addu $t5, $t5, $t1
	addu $s5, $s5, $s3
	j eq_branch4
neq_3_2_0:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s0
	j eq_branch4
neq_3_2_1:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s1
	j eq_branch4
neq_3_2_2:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s2
	j eq_branch4
neq_3_2_3:
	addu $t5, $t5, $t2
	addu $s5, $s5, $s3
	j eq_branch4
neq_3_3_0:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s0
	j eq_branch4
neq_3_3_1:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s1
	j eq_branch4
neq_3_3_2:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s2
	j eq_branch4
neq_3_3_3:
	addu $t5, $t5, $t3
	addu $s5, $s5, $s3
	j eq_branch4
error:

li $a0, 5
eq_branch4:

li $v0, 5
