.text

.globl display_board
# Display the game board in a 4x4 grid format
display_board:
    la $t0, board            # Board base address
    la $t1, revealed         # Revealed cards array
    la $t2, problem_assignments # Assignments array base address
    li $t3, 0                # Row counter
    li $t4, 0                # Column counter

display_row_loop:
    # Print horizontal divider before each row
    li $v0, SysPrintString
    la $a0, board_line
    syscall

    # Process cards in the row
    li $t4, 0                # Reset column counter for each row

display_column_loop:
    # Check if the card is revealed
    lw $t5, ($t1)            # Load revealed status
    bnez $t5, check_assignment  # If revealed, check the assignments array

    # Otherwise, display 'X'
    li $v0, SysPrintString
    la $a0, x_string        # Load "   X   " string
    syscall
    j display_next_card
    
check_assignment:
    # Calculate offset in assignments array
    sll $t6, $t3, 2          # Multiply row index by 4
    add $t7, $t6, $t4        # Add column index to get the board index
    sll $t7, $t7, 3          # Each assignment index takes 8 bytes (2 words)
    add $t8, $t2, $t7        # Address in assignments array

    # Check if the assignment exists (non-zero factor at first slot)
    lw $t9, ($t8)            # Load first factor
    beqz $t9, display_answer # If zero, it is an answer
    
    # Print leading space
    li $v0, SysPrintString
    la $a0, single_space
    syscall
    

    # Display the problem pair "T1 X T2"
    li $v0, SysPrintInt
    move $a0, $t9            # Load first factor
    syscall

    # Print ' X '
    li $v0, SysPrintString
    la $a0, times_string        # Load " X " string
    syscall

    # Print the second factor
    lw $a0, 4($t8)           # Load second factor
    li $v0, SysPrintInt
    syscall
    
    # Print trailing space
    li $v0, SysPrintString
    la $a0, single_space
    syscall
    
    j display_next_card
    
display_answer:

  # Display the answer value from the board
    lw $t5, 0($t0)           # Load the card value into a temporary register
    move $s5, $t5            # Store the value for formatting

    li $s2, 10               # Compare against 10
    blt $s5, $s2, single_digit_answer

    # Format for two-digit answer
    li $v0, SysPrintString
    la $a0, triple_space     # Print three leading spaces
    syscall

    li $v0, SysPrintInt
    move $a0, $s5            # Print the two-digit answer
    syscall

    li $v0, SysPrintString
    la $a0, double_space     # Print two trailing spaces
    syscall
    j display_next_card
    
single_digit_answer:

    # Format for single-digit answer
    li $v0, SysPrintString
    la $a0, triple_space     # Print three leading spaces
    syscall

    li $v0, SysPrintInt
    move $a0, $s5            # Print the single-digit answer
    syscall

    li $v0, SysPrintString
    la $a0, triple_space     # Print three trailing spaces
    syscall
    
    j display_next_card
     	
display_next_card:
    # Add column divider '|'
    li $v0, SysPrintString
    la $a0, block_string 
    syscall

    # Move to the next card
    addi $t0, $t0, 4         # Move to the next card in board
    addi $t1, $t1, 4         # Move to the next revealed status
    addi $t4, $t4, 1         # Increment column counter

    # Check if all columns in the row are displayed
    blt $t4, 4, display_column_loop

    # Print newline after each row
    li $v0, SysPrintChar
    li $a0, '\n'
    syscall

    addi $t3, $t3, 1         # Increment row counter
    blt $t3, 4, display_row_loop

    jr $ra                   # Return to caller
