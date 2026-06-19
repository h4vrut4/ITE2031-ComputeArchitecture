.text
main:
random_0:
	li $t0, 1141988164
	sw $t0, 0($gp)
	li $t0, -1333632164
	sw $t0, 4($gp)
	li $t0, 1141988164
	sw $t0, 8($gp)
	li $t0, 330547012
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_0_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_0_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_0_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_0_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_0_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_0_2_3
	j error
eq_0_0_1:
	addiu $t4, $t4, -24850
	j random_1
eq_0_0_2:
	addiu $t4, $t4, 26827
	j random_1
eq_0_0_3:
	addiu $t4, $t4, -4588
	j random_1
eq_0_1_2:
	addiu $t4, $t4, -7506
	j random_1
eq_0_1_3:
	addiu $t4, $t4, 3242
	j random_1
eq_0_2_3:
	addiu $t4, $t4, -19758
	j random_1
random_1:
	li $t0, 305743529
	sw $t0, 0($gp)
	li $t0, 1252220601
	sw $t0, 4($gp)
	li $t0, 1252220601
	sw $t0, 8($gp)
	li $t0, -1461295617
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_1_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_1_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_1_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_1_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_1_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_1_2_3
	j error
eq_1_0_1:
	addiu $t4, $t4, 22928
	j random_2
eq_1_0_2:
	addiu $t4, $t4, -14383
	j random_2
eq_1_0_3:
	addiu $t4, $t4, -21273
	j random_2
eq_1_1_2:
	addiu $t4, $t4, -29628
	j random_2
eq_1_1_3:
	addiu $t4, $t4, -11015
	j random_2
eq_1_2_3:
	addiu $t4, $t4, -30981
	j random_2
random_2:
	li $t0, 651962523
	sw $t0, 0($gp)
	li $t0, -1304832515
	sw $t0, 4($gp)
	li $t0, -340802484
	sw $t0, 8($gp)
	li $t0, -1304832515
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_2_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_2_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_2_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_2_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_2_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_2_2_3
	j error
eq_2_0_1:
	addiu $t4, $t4, 6385
	j random_3
eq_2_0_2:
	addiu $t4, $t4, -15393
	j random_3
eq_2_0_3:
	addiu $t4, $t4, 15554
	j random_3
eq_2_1_2:
	addiu $t4, $t4, -20169
	j random_3
eq_2_1_3:
	addiu $t4, $t4, 26144
	j random_3
eq_2_2_3:
	addiu $t4, $t4, -702
	j random_3
random_3:
	li $t0, 1453669229
	sw $t0, 0($gp)
	li $t0, -1116906937
	sw $t0, 4($gp)
	li $t0, -124272025
	sw $t0, 8($gp)
	li $t0, -1116906937
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_3_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_3_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_3_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_3_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_3_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_3_2_3
	j error
eq_3_0_1:
	addiu $t4, $t4, 3766
	j random_4
eq_3_0_2:
	addiu $t4, $t4, 28403
	j random_4
eq_3_0_3:
	addiu $t4, $t4, 15055
	j random_4
eq_3_1_2:
	addiu $t4, $t4, 30209
	j random_4
eq_3_1_3:
	addiu $t4, $t4, 18857
	j random_4
eq_3_2_3:
	addiu $t4, $t4, 7509
	j random_4
random_4:
	li $t0, 2090828257
	sw $t0, 0($gp)
	li $t0, 1060490249
	sw $t0, 4($gp)
	li $t0, 1060490249
	sw $t0, 8($gp)
	li $t0, 1035380850
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_4_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_4_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_4_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_4_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_4_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_4_2_3
	j error
eq_4_0_1:
	addiu $t4, $t4, -10380
	j random_5
eq_4_0_2:
	addiu $t4, $t4, -25448
	j random_5
eq_4_0_3:
	addiu $t4, $t4, 32699
	j random_5
eq_4_1_2:
	addiu $t4, $t4, 560
	j random_5
eq_4_1_3:
	addiu $t4, $t4, -13828
	j random_5
eq_4_2_3:
	addiu $t4, $t4, -829
	j random_5
random_5:
	li $t0, -1831855794
	sw $t0, 0($gp)
	li $t0, -428893194
	sw $t0, 4($gp)
	li $t0, 1377955098
	sw $t0, 8($gp)
	li $t0, -428893194
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_5_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_5_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_5_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_5_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_5_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_5_2_3
	j error
eq_5_0_1:
	addiu $t4, $t4, 27751
	j random_6
eq_5_0_2:
	addiu $t4, $t4, 31987
	j random_6
eq_5_0_3:
	addiu $t4, $t4, 17971
	j random_6
eq_5_1_2:
	addiu $t4, $t4, -2376
	j random_6
eq_5_1_3:
	addiu $t4, $t4, -22737
	j random_6
eq_5_2_3:
	addiu $t4, $t4, 6139
	j random_6
random_6:
	li $t0, 1523475871
	sw $t0, 0($gp)
	li $t0, 1630120340
	sw $t0, 4($gp)
	li $t0, 1523475871
	sw $t0, 8($gp)
	li $t0, 508679870
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_6_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_6_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_6_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_6_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_6_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_6_2_3
	j error
eq_6_0_1:
	addiu $t4, $t4, 22893
	j random_7
eq_6_0_2:
	addiu $t4, $t4, -6258
	j random_7
eq_6_0_3:
	addiu $t4, $t4, 5092
	j random_7
eq_6_1_2:
	addiu $t4, $t4, 29226
	j random_7
eq_6_1_3:
	addiu $t4, $t4, -31591
	j random_7
eq_6_2_3:
	addiu $t4, $t4, -30089
	j random_7
random_7:
	li $t0, -674818380
	sw $t0, 0($gp)
	li $t0, -1708527355
	sw $t0, 4($gp)
	li $t0, -674818380
	sw $t0, 8($gp)
	li $t0, -1440655626
	sw $t0, 12($gp)
	lw $t0, 0($gp)
	lw $t1, 4($gp)
	beq $t0, $t1, eq_7_0_1
	lw $t0, 0($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_7_0_2
	lw $t0, 0($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_7_0_3
	lw $t0, 4($gp)
	lw $t1, 8($gp)
	beq $t0, $t1, eq_7_1_2
	lw $t0, 4($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_7_1_3
	lw $t0, 8($gp)
	lw $t1, 12($gp)
	beq $t0, $t1, eq_7_2_3
	j error
eq_7_0_1:
	addiu $t4, $t4, 23363
	j random_8
eq_7_0_2:
	addiu $t4, $t4, -366
	j random_8
eq_7_0_3:
	addiu $t4, $t4, 12782
	j random_8
eq_7_1_2:
	addiu $t4, $t4, 4836
	j random_8
eq_7_1_3:
	addiu $t4, $t4, 7899
	j random_8
eq_7_2_3:
	addiu $t4, $t4, 19618
	j random_8
error:

li $a0, 5
random_8:

li $v0, 5
