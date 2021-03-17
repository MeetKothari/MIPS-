#####################################################
#                                                   #
#						    # 
# Meet Kothari	                                    #
#             					    #
#						    #
#                                                   #
# Homework 4                                        #
#                                                   #
#                                                   #
#                                                   #
# Time To Complete: 45 minutes                      #
#                                                   #
#                                                   #
#                                                   #
#####################################################

# I would like to note that I had some friends help me understand some of the logic of this assignment, 
# but I'd like to note that they are not currently in any assembly classes this semester, this 
# is because they took it last year. Other than that, I worked completely alone on
# this assignment and all work is my own. I coded everything myself.

	.data

inBuf:		.space	80
TOKEN:		.space	8
TYPE:		.word	0
tabToken: 	.word	0:30		# 10-entry token table
	
	.text
#######################################################
#						      #
# MAIN Driver                                         #
#                                                     #
# $t3:	index to inBuf                                #
# 		:	index to TOKEN                #
#		:	index to tabToken             #
#		#s4:	curChar                       #
#                                                     #
#		$s0:	T                             #
#		$s1:	CUR                           #
#	                                              #
#######################################################

main:

# $t3 indeX to inBuf
# $s1 cur state
# s4 cur char
# s0 type of cur char

newLine:

	jal	getline
	li	$t3, 0		# index to inBuf
	
	la	$s1, Q0		# CUR = Q0
	li	$s0, 1		# T = 1
	
nextState:	
	
	#STAB[CUR][0] is the location in the state table. [CUR][TYPE] returns where I should go
	lw	$s2, 0($s1)	# $s2 = STAB[CUR][0]
	jalr	$v1, $s2	# Call action; Save return addr in $v1

	sll	$s0, $s0, 2	# 4*T
	add	$s1, $s1, $s0	# CUR+4*T
	sra	$s0, $s0, 2
	lw	$s1, 0($s1)	# CUR = STAB[CUR][T]
	b	nextState

dump:	

	jal	printTabToken
	jal	clearInBuf
	jal	clearTabToken
	b	newLine
	
###################3
#
#	ACTS:
#
#		$t3 - global index to inBuf
#
####################
ACT1:
#Act1	
	lb	$s4,inBuf($t3)		# curChar = inBuf[i]
	jal	lin_search		# s0 = lin_search($s4)
	addi	$t3, $t3, 1		# i++
	jr	$v1
	
ACT2:  

	sw	$s4, TOKEN  		# TOKEN = curChar;
	move    $s3, $s0  		# tokType = charType;
	li	$s5, 1  		# tokIndex = 1;
	jr	$v1  			# return;

ACT3:  


	sb	$s4, TOKEN($s5)  	# TOKEN[tokIndex] = curChar;
	addi    $s5, $s5, 1  		# tokIndex += 1;
	jr	$v1  			# return;

ACT4:  


	lw	$t8, TOKEN + 0  	# $t8 = TOKEN[0:4];
	lw	$t9, TOKEN + 4  	# $t9 = TOKEN[4:8];
	

	sw 	$t8, tabToken + 0($s6)  # tabToken[tabTokIndex] += $t8;
	sw	$t9, tabToken + 4($s6)  # tabToken[tabTokIndex] += $t9;
	
	# Save tokType into tabToken
	sw	$s3, tabToken + 8($s6)  # tabToken[tabTokIndex] += tokType;
	
	# Increment tabTokIndex by 12 (=3 words) to get to next row
	
	addi    $s6, $s6, 12  		# tabTokIndex += 12;
	
	jal clearToken  		# Clear TOKEN, tokType, and tokIndex after saving
	
	jr	$v1  # return to nextState;

ERROR:

	b	dump
	

RETURN:

	b	dump
	
clearTabToken:

	li	$t9, 0  		# i = 0;
	
loop:

	bge	$t9, 120, FINISH  	# if (i >= 120) goto FINISH;
	sw	$0, tabToken($t9)  	# tabToken[i] = 0;
	addi    $t9, $t9, 4  		# i += 4;  
	j	loop
	
FINISH:

	jr	$ra
	
clearToken:

	# Clear TOKEN
	sw	$0, TOKEN + 0($0)  	# TOKEN[0-4]  = 0;
	sw	$0, TOKEN + 4($0)  	# TOKEN[4-8]  = 0;
	sw	$0, TOKEN + 8($0)  	# TOKEN[8-12] = 0;
	# Clear token type
	li	$s3, 0  		# tokType = 0;
	jr	$ra
	# Clear token index
	li	$s5, 0  		# tokIndex = 0;
	
##########################
#
# getline
#
##########################

	.data
	
prompt:	.asciiz	"Enter an input string:\n"

	.text
	
getline: 

	la	$a0, prompt		# Prompt to enter a new line
	li	$v0, 4
	syscall

	la	$a0, inBuf		
	li	$a1, 80	
	li	$v0, 8			#read in the line
	syscall

	jr	$ra
	
##############################
#
# lin_search()
#	argument - $s4 for key
#	return val - $s0 for char type
#
#############################
lin_search:

	li	$t2, 0			# j = 0;
	li	$t4, -1			#load in exit character
	lw	$a2, Tabchar($t2)	#a2 = tabchar(j)
	
	b	whileLoop		#goto while loop
	
	jr	$ra
	
whileLoop:

	addi	$t5, $t2, 4 		#t5 = t2 + 4
	lw	$a3, Tabchar($t5)	#a3 = tabchar[j+4]
	lw	$a2, Tabchar($t2)	#a2 = tabchar(j)
	beq	$a3, $t4, return	#if(tabchar[j+4] == -1) goto return
	bne	$a2, $s4, reLoop	#if(tabchar[j] != key) goto reLoop
	b	ifStatement 		#else goto if statement
		
reLoop:

	addi	$t2, $t2, 8		#j = j + 8
	b	whileLoop		#goto while loop
	
ifStatement:
	
	move	$s0, $a3		#s0 = Tabchar[j+4]
	
	jr	$ra			#return to loop
	
return:

	jr	$ra			#return to loop
	
	
#############################################
#
#  printTabToken:
#	print Token table header
#	copy each entry of tabToken into outBuf
#	   and print TOKEN
#	$a3 has the index (in bytes) to the last entry of tabToken
#
#############################################

		.data

outBuf:		.word	0:3			# copy token entry to outBuf to print

tableHead:	.asciiz  "TOKEN    TYPE\n"


		.text

printTabToken:

	li	$t7, 0x20		# blank in $t7  #Tabtoken start

	li	$t6, '\n'		# newline in $t6

	la	$a0, tableHead		# print table heading
	li	$v0, 4
	syscall

	li	$t0, 0

loopTok:	

	bge	$t0, $s6, doneTok	# if ($t0 <= $a3)

	

	lw	$t1, tabToken($t0)	#   copy tabToken[] into outBuf

	sw	$t1, outBuf

	lw	$t1, tabToken+4($t0)

	sw	$t1, outBuf+4

	li	$t9, -1			# for each char in outBuf

loopChar:	

	addi	$t9, $t9, 1

	bge	$t9, 8, tokType		

	lb	$t8, outBuf($t9)		#   if char == Null

	bne	$t8, $zero, loopChar	

	sb	$t7, outBuf($t9)		#       replace it by ' ' (0x20)

	b	loopChar

tokType:

	sb	$t7, outBuf+8		# insert blank

	lb	$t1, tabToken+8($t0)	# $t1 = token type

	addi	$t1, $t1, 0x30		# ASCII(token type)

	sb	$t1, outBuf+9

	sb	$t6, outBuf+10		# terminate with '\n'

	sb	$0, outBuf+11


	la	$a0, outBuf		# print token and its type
	li	$v0, 4
	syscall

	addi	$t0, $t0, 12

	sw	$0, outBuf		# clear outBuf

	sw	$0, outBuf+4

	b	loopTok

doneTok:

	jr	$ra

clearInBuf:

    li    $t0, 0            #int i = 0
    b 	loopClearBuf
    
loopClearBuf:

    bge    $t0, 80, returnClearBuf    	#if ( i >= bufSize ) goto ret
    sb    $zero, inBuf($t0)		#inBuf($t0) = 0
    
    addi    $t0, $t0, 1      		#i++
    b     loopClearBuf       		#re loop
    
returnClearBuf:

    jr    $ra
	
#clearTabToken:

	#jr	$ra	
	
	.data
tabState:
Q0:     .word  ACT1

        .word  Q1   # T1

        .word  Q1   # T2

        .word  Q1   # T3

        .word  Q1   # T4

        .word  Q1   # T5

        .word  Q1   # T6

        .word  Q11  # T7



Q1:     .word  ACT2

        .word  Q2   # T1

        .word  Q5   # T2

        .word  Q3   # T3

        .word  Q3   # T4

        .word  Q0   # T5

        .word  Q4   # T6

        .word  Q11  # T7



Q2:     .word  ACT1

        .word  Q6   # T1

        .word  Q7   # T2

        .word  Q7   # T3

        .word  Q7   # T4

        .word  Q7   # T5

        .word  Q7   # T6

        .word  Q11  # T7



Q3:     .word  ACT4

        .word  Q0   # T1

        .word  Q0   # T2

        .word  Q0   # T3

        .word  Q0   # T4

        .word  Q0   # T5

        .word  Q0   # T6

        .word  Q11  # T7



Q4:     .word  ACT4

        .word  Q10  # T1

        .word  Q10  # T2

        .word  Q10  # T3

        .word  Q10  # T4

        .word  Q10  # T5

        .word  Q10  # T6

        .word  Q11  # T7



Q5:     .word  ACT1

        .word  Q8   # T1

        .word  Q8   # T2

        .word  Q9   # T3

        .word  Q9   # T4

        .word  Q9   # T5

        .word  Q9   # T6

        .word  Q11  # T7



Q6:     .word  ACT3

        .word  Q2   # T1

        .word  Q2   # T2

        .word  Q2   # T3

        .word  Q2   # T4

        .word  Q2   # T5

        .word  Q2   # T6

        .word  Q11  # T7



Q7:     .word  ACT4

        .word  Q1   # T1

        .word  Q1   # T2

        .word  Q1   # T3

        .word  Q1   # T4

        .word  Q1   # T5

        .word  Q1   # T6

        .word  Q11  # T7



Q8:     .word  ACT3

        .word  Q5   # T1

        .word  Q5   # T2

        .word  Q5   # T3

        .word  Q5   # T4

        .word  Q5   # T5

        .word  Q5   # T6

        .word  Q11  # T7



Q9:     .word  ACT4

        .word  Q1  # T1

        .word  Q1  # T2

        .word  Q1  # T3

        .word  Q1  # T4

        .word  Q1  # T5

        .word  Q1  # T6

        .word  Q11 # T7



Q10:	.word	RETURN

        .word  Q10  # T1

        .word  Q10  # T2

        .word  Q10  # T3

        .word  Q10  # T4

        .word  Q10  # T5

        .word  Q10  # T6

        .word  Q11  # T7



Q11:    .word  ERROR 

	.word  Q4  # T1

	.word  Q4  # T2

	.word  Q4  # T3

	.word  Q4  # T4

	.word  Q4  # T5

	.word  Q4  # T6

	.word  Q4  # T7