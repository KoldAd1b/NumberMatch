
.include "Syscalls.asm"



.data
    # Game board (4x4 grid, 4 bytes per cell)
    board:      .space 64     # 4x4 board of cards (8 unique pairs)
    revealed:   .space 64     # Track revealed cards
    matched:    .space 64     # Track matched cards
    shuffled_indices: .space 64 #For randomness
    
       
    # Multiplication problems and answers
    problems:   .word 4,8, 12,16, 20,24, 28,32    # Problem pairs
    answers:    .word 4,8, 12,16, 20,24, 28,32   # Corresponding answers
    
    #Problem assignments ( to store the pairs for display ) 
    #We are multiplying by 2 to store the indexes to account for overlap
    problem_assignments: .space 128  
    
    
    #Formatting 
    board_line: .asciiz "+------+-------+-------+-------+\n"
    times_string:  .asciiz " X "              # Separator for factor pairs
    block_string : .asciiz "|"
    single_space: .asciiz " "
    double_space: .asciiz "  "
    triple_space: .asciiz "   "
    x_string: .asciiz "   X   "
    

    # Game messages
    welcome_msg:    .asciiz "Welcome to Math-Match Multiplication (4x4)\n"
    intro_msg:      .asciiz "Match multiplication problem cards with their answers!\n"
    select_msg:     .asciiz "Select card (0-15): "
    match_msg:      .asciiz "Match found!\n"
    nomatch_msg:    .asciiz "No match. Try again.\n"
    matcherr_msg:   .asciiz  "Card selection out of bounds. Must be within (0-15)\n"
    menu_msg:       .asciiz  "Choose an option:\n- Restart (1) \n- Quit (2) \n Enter : "
    reveal_msg:     .asciiz "Card is already revealed\n"
    time_msg:       .asciiz "Time elapsed: "
    counter_msg:    .asciiz "Number of unmatched cards : "
    minute_msg:     .asciiz " minutes "
    second_msg:     .asciiz " seconds\n"
    win_msg:        .asciiz "Well Done! You finished in "
    quit_msg: 	    .asciiz "Thank you for playing !"
    colon_msg:      .asciiz ":"
    newline:        .asciiz "\n"

    # Timer variables
    start_time:     .word 0
    current_time:   .word 0

    # Game state variables
    total_cards:    .word 8     # 8 unique pairs
    cards_matched:  .word 0
    unmatched_cards:.word 8
    moves_count:    .word 0
    
    
.text

.globl main

main:
    
    # Save $ra since we'll be making function calls
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize game state
    jal init_new_game

game_loop:
    #Printing the board if you want to cheat, i.e debug 
    #jal test_print_board
    
    # Display board
    jal display_board

    # Check if all cards matched
    lw $t0, total_cards
    lw $t1, cards_matched
    beq $t0, $t1, game_won
    
    # Display current game time
    jal display_current_time
    
    li $v0, SysPrintString
    la $a0, counter_msg
    syscall
    
    #Printing the counter
    li $v0, SysPrintInt
    lw $s7, unmatched_cards 
    move $a0, $s7
    syscall
    
   
    #Printing the newline
    li $v0, SysPrintString
    la $a0, newline
    syscall
 
    
   
    # First card selection
    li $v0, SysPrintString
    la $a0, select_msg
    syscall
    li $v0, SysReadInt
    syscall
    move $s0, $v0   # First card index
    
    # Check for reset command (-1)
    li $t0, -1
    beq $s0, $t0, handle_reset
    
    # Check for quit command (-2)
    li $t0, -2
    beq $s0, $t0, game_quit
    
     #Simulate game won
    li $t0,-3
    beq $s0, $t0, game_won

    

    
    # Reveal first card
    move $a0, $s0
    jal reveal_card

    # Display updated board
    jal display_board
    
    # Display current game time
    jal display_current_time

    # Second card selection
    li $v0, SysPrintString
    la $a0, select_msg
    syscall
    li $v0, SysReadInt
    syscall
    move $s1, $v0   # Second card index

    # Check for reset/quit on second selection too
    li $t0, -1
    beq $s1, $t0, handle_reset
    li $t0, -2
    beq $s1, $t0, game_quit
    
    #Simulate game won
    li $t0,-3
    beq $s1, $t0, game_won


    # Reveal second card
    move $a0, $s1
    jal reveal_card

    # Display updated board
    jal display_board

    # Increment moves count
    lw $t0, moves_count
    addi $t0, $t0, 1
    sw $t0, moves_count

    # Check for match
    move $a0, $s0
    move $a1, $s1
    jal check_match

    # Continue game loop
    j game_loop

# Initialize new game state
init_new_game:
    
    # Print welcome messages
    li $v0, SysPrintString
    la $a0, welcome_msg
    syscall
    la $a0, intro_msg
    syscall
	
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize random seed
    li $v0, 30      # Get system time
    syscall
    move $a1, $a0   # Use system time as seed

    # Clear all game state
    jal clear_board
    
    # Initialize board with randomization
    jal initialize_randomized_board
    
    # Reset game state variables
    li $t0, 0
    sw $t0, cards_matched     # Reset matched cards counter
    sw $t0, moves_count       # Reset moves counter
    
    li $t0, 8
    sw $t0, unmatched_cards   # Reset unmatched cards (8 pairs)
    
    # Reset revealed and matched arrays
    la $t0, revealed
    la $t1, matched
    li $t2, 16               # 16 total cards
    li $t3, 0               # Value to clear with
clear_arrays_loop:
    sw $t3, 0($t0)          # Clear revealed status
    sw $t3, 0($t1)          # Clear matched status
    addi $t0, $t0, 4        # Next revealed slot
    addi $t1, $t1, 4        # Next matched slot
    subi $t2, $t2, 1
    bnez $t2, clear_arrays_loop
    
    # Record new start time
    li $v0, 30  #System call for 
    syscall
    sw $a0, start_time

    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Handle reset command
handle_reset:
    jal init_new_game
    j game_loop

invalid_selection:
    li $v0, 4
    la $a0, matcherr_msg
    syscall
    j game_loop

game_won:
    # Display winning message
    li $v0, SysPrintString
    la $a0, win_msg
    syscall
    
    # Calculate and display final time
    jal calculate_time
    
    # Display menu and handle input
    j display_menu

game_quit:
    li $v0, SysPrintString
    la $a0, quit_msg
    syscall
    # Exit program
    li $v0, 10
    syscall

# Menu display and handling
display_menu:
    # Display menu options
    li $v0, SysPrintString
    la $a0, menu_msg
    syscall

    # Get player choice
    li $v0, SysReadInt
    syscall
    move $t0, $v0

    # Handle menu choices
    li $t1, 1          # Restart
    beq $t0, $t1, handle_reset

    li $t1, 2          # Quit
    beq $t0, $t1, game_quit
    
    # Invalid choice, show menu again
    j display_menu
   
.include "_init_.asm"
.include "_product_.asm"     
.include "_testprint_.asm"
.include "_display_.asm"
.include "_operator_.asm"
.include "_time_.asm"
    
