
.text
.globl factor_number

# Factorization function
factor_number:
    # Input: $a0 = number to factorize
    # Output: $v0 = first factor (single-digit)
    #         $v1 = second factor (single-digit)
    
    # Stack frame
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    
    # Save input number
    move $s0, $a0

    # Start search from 9 (largest single-digit factor)
    li $t0, 9

search_loop:
    # Check if current number divides input evenly
    div $s0, $t0
    mfhi $t1    # get remainder
    bnez $t1, try_next    # if remainder != 0, try next
    
    # Found a factor, check if the quotient is a single digit
    mflo $t1    # get quotient
    blez $t1, try_next     # Skip if quotient <= 0
    li $t2, 9
    bgt $t1, $t2, try_next # Skip if quotient > 9

    # Both factors are single digits; return them
    move $v0, $t0          # First factor
    move $v1, $t1          # Second factor
    j cleanup

try_next:
    addi $t0, $t0, -1      # Decrement factor
    # Don't go below 1
    li $t1, 1
    ble $t0, $t1, use_trivial
    j search_loop

use_trivial:
    # If no valid factors found, return 1 and the number itself
    li $v0, 1
    move $v1, $s0
    
cleanup:
    # Restore stack frame
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 28
    
    jr $ra