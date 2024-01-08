operands     dcd     -23, -5 ; operands
operation    dcd     4 ; 0: exit, 1: sum, 2: subtract, 3: product, 4: division
result       fill    4 ; allocating memory for future result
rem          fill    4 ; allocating space for the remain

             ;       r0: first operand or the remain of the division
             ;       r1: second operand
             ;       r2: operation
             ;       r10: result
main         
             ;       register loading
             mov     r0, #operands
             mov     r2, #operation
             mov     r10, #0
             ldr     r1, [r0, #4]
             ldr     r0, [r0]
             ldr     r2, [r2]

             ;       comparing for the operation

             ;       jumping to the end
             cmp     r2, #0
             beq     finish

             ;       jumping to the sum
             cmp     r2, #1
             beq     sum

             ;       jumping to the subtraction
             cmp     r2, #2
             beq     subtraction

             ;       jumping to the product
             cmp     r2, #3
             beq     product

             ;       jumping to the division
             cmp     r2, #4
             beq     division


             ;       SUM
sum          
             add     r10, r0, r1 ; operation
             b       finish ; jumping to the end


             ;       SUBTRACTION
subtraction  
             sub     r10, r0, r1 ; operation
             b       finish ; jumping to the end


             ;       PRODUCT
product      
             ;       conditional
             cmp     r1, #0 ; check if is negative or zero
             blt     calcNeg
             cmp     r0, #0 ; check if is zero
             beq     zero

             ;       if the second operand is positive
calcPos      
             add     r10, r10, r0 ; operation with a cicle
             subs    r1, r1, #1
             bgt     calcPos ; jumping to the cicle

             b       finish ; jumping to the

             ;       if the second operand is negative
calcNeg      
             sub     r10, r10, r0
             adds    r1, r1, #1
             ble     calcNeg

             b       finish

             ;       if the first of second operand is zero
zero         
             mov     r10, #0
             b       finish ; jumping to the end


             ;       DIVISION
division     ;       a = qb + r is the formula of the euclidean division

             cmp     r0, #0
             cmp     r1, #0
             moveq   r0, #0
             moveq   r10, #0
             beq     finish

             ;       in the euclidean division there'll be four different scenarios
             ;       depending on the sign of the operands. This algorithm will use r3 and r4
             ;       as bits of control to check the different scenarios because the division will be taken the
             ;       absolute value of the operands
             ;       r3: 1 if first operand > 0 else 0
             ;       r4: 1 if second operand > 0 else 0

             cmp     r0, #0 ; comparing first operand with zero
             movgt   r3, #1
             movlt   r3, #0
             rsblt   r0, r0, #0

             cmp     r1, #0 ; comparing second operand with zero only if the first one is greater than 0
             movgt   r4, #1
             movlt   r4, #0
             rsblt   r1, r1, #0

             ;       if first operand < second operand skip to the sign check
             cmp     r0, r1
             blt     firstCheck

             ;       division loop
divisionLoop 
             add     r10, r10, #1
             sub     r0, r0, r1

             cmp     r0, r1
             bge     divisionLoop

firstCheck   ;       condition check of the control bits
             cmp     r3, #0
             bgt     secondCheck
             cmp     r4, #0
             bgt     firstCase
             beq     thirdCase

secondCheck  
             cmp     r4, #0
             bgt     finish
             beq     secondCase

firstCase    ;       first case: first operand < 0, second operand > 0 aka r3 = 0, r4 = 1
             rsb     r10, r10, #0
             sub     r10, r10, #1
             sub     r0, r1, r0
             b       finish

secondCase   ;       second case: first operand > 0, second operand < 0 aka r3 = 1, r4 = 0
             rsb     r10, r10, #0
             b       finish

thirdCase    ;       third case: first operand < 0, second operand < 0 aka r3 = 0, r4 = 0
             add     r10, r10, #1
             sub     r0, r1, r0 ; should be -(second operand) - remainder but we changed the sign before
             b       finish


             ;       FINISH
finish       
             mov     r11, #result ; moving to r11 the address of the result
             str     r10, [r11] ; storing the result from register r10 to the result allocation, previously stored on r11

             cmp     r2, #4 ; if the operation is the division, also save in memory the remainder
             moveq   r12, #rem
             streq   r0, [r12]

             ;       clearing the registers
             mov     r0, #0
             mov     r1, #0
             mov     r2, #0
             mov     r10, #0
             mov     r11, #0
             ;       end of the program
             end
