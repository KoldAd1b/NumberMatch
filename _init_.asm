
.globl initialize_randomized_board   

initialize_randomized_board:
  
    
    move $s6, $ra
    
    jal clear_board
    
    move $ra,$s6
    	
    la $s0, board             # Pointer to the main game board
    la $s1, problem_assignments  # Pointer to the assignments array
    la $s2, problems          # Pointer to the problems array
    la $s3, answers           # Pointer to the answers array
    la $s4, shuffled_indices  # Pointer to shuffled indices array

    # Step 1: Prepare the shuffled_indices array
    li $t0, 0                 # Counter for index
initialize_indices:
    sw $t0, 0($s4)            # Store index value in shuffled_indices
    addi $s4, $s4, 4          # Move to the next slot
    addi $t0, $t0, 1          # Increment counter
    blt $t0, 16, initialize_indices

    # Reset pointer to start of shuffled_indices
    la $s4, shuffled_indices

    # Shuffle the indices array
    li $t0, 16                # Number of elements to shuffle
shuffle_indices:
    # Generate a random index in range [0, t0)
    li $a0, 0
    move $a1, $t0             # Set upper bound
    li $v0, 42                # SysRandIntRange
    syscall                   # Random index in $a0

    # Swap shuffled_indices[a0] and shuffled_indices[t0-1]
    sll $t1, $a0, 2           # Calculate offset for shuffled_indices[a0]
    add $t1, $s4, $t1
    lw $t2, 0($t1)            # Load shuffled_indices[a0]

    subi $t3, $t0, 1          # Calculate offset for shuffled_indices[t0-1]
    sll $t3, $t3, 2
    add $t3, $s4, $t3
    lw $t4, 0($t3)            # Load shuffled_indices[t0-1]

    sw $t4, 0($t1)            # Write shuffled_indices[t0-1] to shuffled_indices[a0]
    sw $t2, 0($t3)            # Write shuffled_indices[a0] to shuffled_indices[t0-1]

    subi $t0, $t0, 1          # Decrement number of elements to shuffle
    bgtz $t0, shuffle_indices

    # Reset pointer to start of shuffled_indices
    la $s4, shuffled_indices

    # Step 2: Sequentially assign problems and answers
    li $t0, 8                 # Number of problems to place
    li $t1, 8                 # Number of answers to place
    li $t2, 0                 # Cards placed counter

assign_cards:
    lw $t3, 0($s4)            # Load the next shuffled index
    addi $s4, $s4, 4          # Move to the next shuffled index

    # Calculate board offset
    sll $t4, $t3, 2           # Convert index to byte offset
    add $t4, $s0, $t4         # Calculate board address

    # Assign problem or answer
    bgtz $t0, assign_problem_card  # Place problem if remaining
    b assign_answer_card

assign_problem_card:
    lw $t5, ($s2)             # Load the next problem
    sw $t5, ($t4)             # Place it on the board
    addi $s2, $s2, 4          # Move to the next problem
    addi $t0, $t0, -1         # Decrement problem count

    # Calculate factors for the problem
    move $a0, $t5             # Pass the problem value to factor_number
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t3, 0($sp)
    jal factor_number         # Call factorization function
    lw $t3, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    # Store factors in the assignments array
    sll $t6, $t3, 3           # Convert board index to assignments offset
    add $t7, $s1, $t6         # Calculate assignments address
    sw $v0, 0($t7)            # Store first factor
    sw $v1, 4($t7)            # Store second factor

    j increment_cards

assign_answer_card:
    lw $t5, ($s3)             # Load the next answer
    sw $t5, ($t4)             # Place it on the board
    addi $s3, $s3, 4          # Move to the next answer
    addi $t1, $t1, -1         # Decrement answer count

increment_cards:
    addi $t2, $t2, 1          # Increment cards placed
    blt $t2, 16, assign_cards # Repeat until all cards are placed

done_randomization:
    
    jr $ra                    # Return to caller
    
    
# Clear board function that properly resets all game state
clear_board:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Clear the main game board (4x4 grid = 16 words)
    la $t0, board            # Base address of board array
    li $t1, 16               # Counter for number of cells
    li $t2, 0                # Value to clear with (0)
clear_board_loop:
    sw $t2, 0($t0)           # Clear current cell
    addi $t0, $t0, 4         # Move to next cell
    subi $t1, $t1, 1         # Decrement counter
    bnez $t1, clear_board_loop

    # Clear the problem assignments array (16 pairs of factors = 32 words)
    la $t0, problem_assignments
    li $t1, 16               # Counter for number of assignments
clear_assignments_loop:
    sw $t2, 0($t0)           # Clear first factor
    sw $t2, 4($t0)           # Clear second factor
    addi $t0, $t0, 8         # Move to next pair
    subi $t1, $t1, 1         # Decrement counter
    bnez $t1, clear_assignments_loop

    # Clear shuffled indices array (16 words)
    la $t0, shuffled_indices
    li $t1, 16               # Counter for number of indices
clear_indices_loop:
    sw $t2, 0($t0)           # Clear current index
    addi $t0, $t0, 4         # Move to next index
    subi $t1, $t1, 1         # Decrement counter
    bnez $t1, clear_indices_loop

    # Optional: Reset any game state variables if you have them
    # For example, if you track matched pairs or score:
    # la $t0, matched_pairs
    # sw $zero, 0($t0)        # Reset matched pairs counter
    # la $t0, score
    # sw $zero, 0($t0)        # Reset score

    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra