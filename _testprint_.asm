.text

.globl test_print_board
# Test print the game board in a 4x4 grid format
test_print_board:
    la $s1, board            # Board base address
    la $s2, problem_assignments # Assignments array base address
    li $s3, 0                # Row counter
    li $s4, 0                # Column counter

test_row_loop:
    # Print horizontal divider before each row
    li $v0, SysPrintString                # Syscall to print string
    la $a0, board_line       # Address of horizontal line
    syscall

    # Process cards in the row
    li $s4, 0                # Reset column counter for each row

test_column_loop:
    # Calculate the current board index (row * 4 + column)
    sll $t5, $s3, 2          # Multiply row index by 4
    add $t6, $t5, $s4        # Add column index to get the board index
    

    # Load the card value from the board
    lw $a0, 0($s1)           # Load card value (from board)
       

    # Check if it is a problem or an answer
    sll $t7, $t6, 3          # Calculate offset for assignments (8 bytes each)
    add $t8, $s2, $t7        # Address of the corresponding assignment
    lw $t9, 0($t8)           # Load first factor

    beqz $t9, test_display_answer # If the assignment is zero, it's an answer

    # Display the problem pair
    lw $a0, 0($t8)           # Load first factor
    lw $a1, 4($t8)           # Load second factor
    move $t1, $ra		#Storing the return address
    jal display_problem_pair # Print the problem pair
    move $ra, $t1		#Restoring the return address
    j test_display_next_card

test_display_answer:
    # Display the answer with proper padding
    move $s5, $a0            # Store the answer of the card for display

    # Check if the answer is single-digit or two-digit
    li $t0, 10               # Compare against 10
    blt $s5, $t0, display_single_digit_answer

    # Format for two-digit answer
    li $v0, SysPrintString               # Print string syscall
    la $a0, triple_space    # Print three leading spaces
    syscall

    li $v0, SysPrintInt            # Print integer syscall
    move $a0, $s5            # Print the two-digit answer
    syscall

    li $v0, SysPrintString              # Print string syscall
    la $a0, double_space      # Print two trailing spaces
    syscall
    j test_display_next_card

display_single_digit_answer:
    # Format for single-digit answer
    li $v0, SysPrintString              # Print string syscall
    la $a0, triple_space     # Print three leading spaces
    syscall

    li $v0, SysPrintInt              # Print integer syscall
    move $a0, $s5            # Print the single-digit answer
    syscall

    li $v0, SysPrintString                # Print string syscall
    la $a0, triple_space     # Print three trailing spaces
    syscall

test_display_next_card:
    # Add column divider '|'
    li $v0, 11               # Print character syscall
    li $a0, '|'              # Column divider character
    syscall

    # Move to the next card in the board
    addi $s1, $s1, 4         # Move to the next card in the board
    addi $s4, $s4, 1         # Increment column counter

    # Check if all columns in the row are displayed
    blt $s4, 4, test_column_loop

    # Print newline after each row
    li $v0, SysPrintString                # Print string syscall
    la $a0, newline
    syscall

    addi $s3, $s3, 1         # Increment row counter
    blt $s3, 4, test_row_loop

    # Final horizontal divider at the end of the board
    li $v0, SysPrintString              # Syscall to print string
    la $a0, board_line
    syscall

    jr $ra                   # Return to caller

# Subroutine to display a problem pair
# Input: $a0 = first value
#        $a1 = second value
# Output: " T X T " format (7 characters, space-padded)
display_problem_pair:

    move $s0, $a0  #Saving the argument so that we can print the spaces
    
    # Print leading space
    li $v0, SysPrintString
    la $a0, single_space
    syscall
    
    move $a0, $s0 #Restoring the argument 

    # Print the first factor
    li $v0, SysPrintInt             # Print integer syscall
    syscall

    # Print the " X " separator
    li $v0, SysPrintString
    la $a0, times_string
    syscall

    # Print the second factor
    li $v0, SysPrintInt               # Print integer syscall
    move $a0, $a1
    syscall

    # Print trailing space
    li $v0, SysPrintString
    la $a0, single_space
    syscall

    jr $ra                   # Return to caller
