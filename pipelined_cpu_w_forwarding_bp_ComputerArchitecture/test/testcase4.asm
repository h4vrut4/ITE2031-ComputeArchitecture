.text
main:
	li $t0, -1199307284
	sw $t0, 0($gp)
	li $t0, -1431028812
	sw $t0, 4($gp)
	li $t0, -1703458045
	sw $t0, 8($gp)
	li $t0, 1549399416
	sw $t0, 12($gp)
	li $t0, 628451924
	sw $t0, 16($gp)
	li $t0, 1662890255
	sw $t0, 20($gp)
	li $t0, 13763414
	sw $t0, 24($gp)
	li $t0, -510507436
	sw $t0, 28($gp)
	li $t0, -461959970
	sw $t0, 32($gp)
	li $t0, 1915726357
	sw $t0, 36($gp)
	li $t0, 16744012
	sw $t0, 40($gp)
	li $t0, 1428687250
	sw $t0, 44($gp)
	li $t0, 266267240
	sw $t0, 48($gp)
	li $t0, -600389302
	sw $t0, 52($gp)
	li $t0, 1559524730
	sw $t0, 56($gp)
	li $t0, 1080444788
	sw $t0, 60($gp)
	li $t0, -1432270075
	sw $t0, 64($gp)
	li $t0, -79704067
	sw $t0, 68($gp)
	li $t0, 251568449
	sw $t0, 72($gp)
	li $t0, 220900319
	sw $t0, 76($gp)
	li $t0, -733706261
	sw $t0, 80($gp)
	li $t0, 1108427637
	sw $t0, 84($gp)
	li $t0, -2158047
	sw $t0, 88($gp)
	li $t0, 1453370285
	sw $t0, 92($gp)
	li $t0, 1464084105
	sw $t0, 96($gp)
	li $t0, 1475776492
	sw $t0, 100($gp)
	li $t0, -1599752968
	sw $t0, 104($gp)
	li $t0, 500746649
	sw $t0, 108($gp)
	li $t0, -676985597
	sw $t0, 112($gp)
	li $t0, -1671975659
	sw $t0, 116($gp)
	li $t0, -283845000
	sw $t0, 120($gp)
	li $t0, 139993292
	sw $t0, 124($gp)
	li $t0, -1713173699
	sw $t0, 128($gp)
	li $t0, 1733426325
	sw $t0, 132($gp)
	li $t0, -1335561955
	sw $t0, 136($gp)
	li $t0, -962757852
	sw $t0, 140($gp)
	li $t0, 1893450101
	sw $t0, 144($gp)
	li $t0, 1452186215
	sw $t0, 148($gp)
	li $t0, 1361747186
	sw $t0, 152($gp)
	li $t0, -1957497628
	sw $t0, 156($gp)
	li $t0, 1996616647
	sw $t0, 160($gp)
	li $t0, -2028759989
	sw $t0, 164($gp)
	li $t0, -1114946023
	sw $t0, 168($gp)
	li $t0, 556207669
	sw $t0, 172($gp)
	li $t0, 264378253
	sw $t0, 176($gp)
	li $t0, -1412036311
	sw $t0, 180($gp)
	li $t0, 892641788
	sw $t0, 184($gp)
	li $t0, -1307852539
	sw $t0, 188($gp)
	li $t0, -78393074
	sw $t0, 192($gp)
	li $t0, 1871180526
	sw $t0, 196($gp)
	li $t0, -92388701
	sw $t0, 200($gp)
	li $t0, 1591421564
	sw $t0, 204($gp)
	li $t0, -728534920
	sw $t0, 208($gp)
	li $t0, -1936596817
	sw $t0, 212($gp)
	li $t0, 995509973
	sw $t0, 216($gp)
	li $t0, 139341462
	sw $t0, 220($gp)
	li $t0, -827367394
	sw $t0, 224($gp)
	li $t0, -472759178
	sw $t0, 228($gp)
	li $t0, -1156053191
	sw $t0, 232($gp)
	li $t0, -1792828187
	sw $t0, 236($gp)
	li $t0, -1374271919
	sw $t0, 240($gp)
	li $t0, -1894386604
	sw $t0, 244($gp)
	li $t0, 1332104196
	sw $t0, 248($gp)
	li $t0, -1061188949
	sw $t0, 252($gp)
	li $t0, 0
vec_add:
	li $t1, 128
	beq $t0, $t1, add_end
	addu $t2, $gp, $t0
	lw $t3, ($t2)
	lw $t4, 128($t2)
	addu $t3, $t3, $t4
	sw $t3, 256($t2)
	addiu $t0, $t0, 4
	j vec_add
add_end:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	lw $s0, 0($gp)
	addu $t5, $t5, $s0
	lw $s0, 4($gp)
	addu $t0, $t0, $s0
	lw $s0, 8($gp)
	addu $t2, $t2, $s0
	lw $s0, 12($gp)
	addu $t3, $t3, $s0
	lw $s0, 16($gp)
	addu $t0, $t0, $s0
	lw $s0, 20($gp)
	addu $t2, $t2, $s0
	lw $s0, 24($gp)
	addu $t5, $t5, $s0
	lw $s0, 28($gp)
	addu $t0, $t0, $s0
	lw $s0, 32($gp)
	addu $t4, $t4, $s0
	lw $s0, 36($gp)
	addu $t5, $t5, $s0
	lw $s0, 40($gp)
	addu $t1, $t1, $s0
	lw $s0, 44($gp)
	addu $t3, $t3, $s0
	lw $s0, 48($gp)
	addu $t1, $t1, $s0
	lw $s0, 52($gp)
	addu $t2, $t2, $s0
	lw $s0, 56($gp)
	addu $t3, $t3, $s0
	lw $s0, 60($gp)
	addu $t1, $t1, $s0
	lw $s0, 64($gp)
	addu $t4, $t4, $s0
	lw $s0, 68($gp)
	addu $t5, $t5, $s0
	lw $s0, 72($gp)
	addu $t3, $t3, $s0
	lw $s0, 76($gp)
	addu $t3, $t3, $s0
	lw $s0, 80($gp)
	addu $t5, $t5, $s0
	lw $s0, 84($gp)
	addu $t3, $t3, $s0
	lw $s0, 88($gp)
	addu $t5, $t5, $s0
	lw $s0, 92($gp)
	addu $t2, $t2, $s0
	lw $s0, 96($gp)
	addu $t1, $t1, $s0
	lw $s0, 100($gp)
	addu $t3, $t3, $s0
	lw $s0, 104($gp)
	addu $t0, $t0, $s0
	lw $s0, 108($gp)
	addu $t0, $t0, $s0
	lw $s0, 112($gp)
	addu $t4, $t4, $s0
	lw $s0, 116($gp)
	addu $t0, $t0, $s0
	lw $s0, 120($gp)
	addu $t2, $t2, $s0
	lw $s0, 124($gp)
	addu $t3, $t3, $s0
	lw $s0, 128($gp)
	addu $t1, $t1, $s0
	lw $s0, 132($gp)
	addu $t4, $t4, $s0
	lw $s0, 136($gp)
	addu $t4, $t4, $s0
	lw $s0, 140($gp)
	addu $t2, $t2, $s0
	lw $s0, 144($gp)
	addu $t4, $t4, $s0
	lw $s0, 148($gp)
	addu $t1, $t1, $s0
	lw $s0, 152($gp)
	addu $t4, $t4, $s0
	lw $s0, 156($gp)
	addu $t5, $t5, $s0
	lw $s0, 160($gp)
	addu $t1, $t1, $s0
	lw $s0, 164($gp)
	addu $t0, $t0, $s0
	lw $s0, 168($gp)
	addu $t1, $t1, $s0
	lw $s0, 172($gp)
	addu $t0, $t0, $s0
	lw $s0, 176($gp)
	addu $t5, $t5, $s0
	lw $s0, 180($gp)
	addu $t2, $t2, $s0
	lw $s0, 184($gp)
	addu $t1, $t1, $s0
	lw $s0, 188($gp)
	addu $t1, $t1, $s0
	lw $s0, 192($gp)
	addu $t3, $t3, $s0
	lw $s0, 196($gp)
	addu $t4, $t4, $s0
	lw $s0, 200($gp)
	addu $t3, $t3, $s0
	lw $s0, 204($gp)
	addu $t1, $t1, $s0
	lw $s0, 208($gp)
	addu $t3, $t3, $s0
	lw $s0, 212($gp)
	addu $t1, $t1, $s0
	lw $s0, 216($gp)
	addu $t0, $t0, $s0
	lw $s0, 220($gp)
	addu $t0, $t0, $s0
	lw $s0, 224($gp)
	addu $t4, $t4, $s0
	lw $s0, 228($gp)
	addu $t3, $t3, $s0
	lw $s0, 232($gp)
	addu $t2, $t2, $s0
	lw $s0, 236($gp)
	addu $t5, $t5, $s0
	lw $s0, 240($gp)
	addu $t2, $t2, $s0
	lw $s0, 244($gp)
	addu $t3, $t3, $s0
	lw $s0, 248($gp)
	addu $t5, $t5, $s0
	lw $s0, 252($gp)
	addu $t2, $t2, $s0
	lw $s0, 256($gp)
	addu $t4, $t4, $s0
	lw $s0, 260($gp)
	addu $t3, $t3, $s0
	lw $s0, 264($gp)
	addu $t0, $t0, $s0
	lw $s0, 268($gp)
	addu $t0, $t0, $s0
	lw $s0, 272($gp)
	addu $t3, $t3, $s0
	lw $s0, 276($gp)
	addu $t4, $t4, $s0
	lw $s0, 280($gp)
	addu $t3, $t3, $s0
	lw $s0, 284($gp)
	addu $t0, $t0, $s0
	lw $s0, 288($gp)
	addu $t5, $t5, $s0
	lw $s0, 292($gp)
	addu $t4, $t4, $s0
	lw $s0, 296($gp)
	addu $t0, $t0, $s0
	lw $s0, 300($gp)
	addu $t4, $t4, $s0
	lw $s0, 304($gp)
	addu $t3, $t3, $s0
	lw $s0, 308($gp)
	addu $t1, $t1, $s0
	lw $s0, 312($gp)
	addu $t5, $t5, $s0
	lw $s0, 316($gp)
	addu $t4, $t4, $s0
	lw $s0, 320($gp)
	addu $t3, $t3, $s0
	lw $s0, 324($gp)
	addu $t3, $t3, $s0
	lw $s0, 328($gp)
	addu $t5, $t5, $s0
	lw $s0, 332($gp)
	addu $t1, $t1, $s0
	lw $s0, 336($gp)
	addu $t4, $t4, $s0
	lw $s0, 340($gp)
	addu $t4, $t4, $s0
	lw $s0, 344($gp)
	addu $t0, $t0, $s0
	lw $s0, 348($gp)
	addu $t2, $t2, $s0
	lw $s0, 352($gp)
	addu $t3, $t3, $s0
	lw $s0, 356($gp)
	addu $t2, $t2, $s0
	lw $s0, 360($gp)
	addu $t2, $t2, $s0
	lw $s0, 364($gp)
	addu $t5, $t5, $s0
	lw $s0, 368($gp)
	addu $t5, $t5, $s0
	lw $s0, 372($gp)
	addu $t5, $t5, $s0
	lw $s0, 376($gp)
	addu $t3, $t3, $s0
	lw $s0, 380($gp)
	addu $t1, $t1, $s0
