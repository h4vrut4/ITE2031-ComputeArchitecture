.text
main:	
	li $t2,40
	li $t0,0
	li $t1,0
LoopStart:
	beq  $t1,$t2,endLoop
	addu  $t0,$t0,$t1
	addiu $t1,$t1,1
	j LoopStart
endLoop:
	move $v0, $t1	
