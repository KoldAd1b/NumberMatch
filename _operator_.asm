


.globl reveal_card

# Reveal a specific card
reveal_card:
    # Validate card index
    bltz $a0, reveal_error
    bge $a0, 16, reveal_error

     # Check if card is already revealed
    la $t0, revealed             # Base address of revealed array
    mul $t1, $a0, 4              # Calculate word offset (index * 4)
    add $t0, $t0, $t1            # Address of revealed[a0]
    lw $t2, ($t0)                # Load revealed status
    bnez $t2, already_revealed       # If revealed[a0] != 0, go to error
    

    # Mark card as revealed
    li $t1, 1                    # Set status to revealed (1)
    sw $t1, ($t0)                # Store back into revealed array
    
    jr $ra                       # Return
    
already_revealed:
# Handle invalid card selection
    li $v0, SysPrintString
    la $a0, reveal_msg
    syscall
    jr $ra


reveal_error:    	
    # Handle invalid card selection
    li $v0, SysPrintString
    la $a0, matcherr_msg
    syscall
    jr $ra

# Check if two cards match
check_match:
    # Validate card indices
    bltz $a0, match_error
    bge $a0, 16, match_error
    bltz $a1, match_error
    bge $a1, 16, match_error

    # Load board values
    la $t0, board
    mul $t1, $a0, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    lw $t1, ($t0)        # First card value
    
    la $t0, board
    mul $t2, $a1, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t2
    lw $t2, ($t0)        # Second card value

    #Check if they don't match
    bne $t1,$t2,no_match  
    
    # Check if same card selected
    beq $a0, $a1, no_match

   
    # Mark cards as matched
    la $t0, matched
    mul $t1, $a0, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    li $t1, 1
    sw $t1, ($t0)

    
    la $t0, matched
    mul $t1, $a1, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    sw $t1, ($t0)
    
     # Match found
    li $v0, SysPrintString
    la $a0, match_msg
    syscall

    # Increment matched cards
    lw $t0, cards_matched
    addi $t0, $t0, 1
    sw $t0, cards_matched
  
    
    # Decrement unmatched cards
    lw $t1, unmatched_cards
    addi $t1 $t1, -1
    sw $t1, unmatched_cards
    jr $ra

match_error:
  
    # Hide the first card again
   la $t0, revealed
    mul $t1, $a0, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    sw $zero, ($t0)
    
    
    # Message for invalid index
    li $v0, SysPrintString
    la $a0, matcherr_msg
    syscall
  
    b game_loop

no_match:
    	
    # Hide cards again
    la $t0, revealed
    mul $t1, $a0, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    sw $zero, ($t0)

    la $t0, revealed
    mul $t1, $a1, 4      # Multiply by 4 for word addressing
    add $t0, $t0, $t1
    sw $zero, ($t0)
    
    # No match found
    li $v0, SysPrintString
    la $a0, nomatch_msg
    syscall

    jr $ra
