

.globl display_current_time
.globl calculate_time
# Display current game time
display_current_time:
    # Get current time
    li $v0, 30
    syscall

    # Load start time
    lw $t0, start_time

    # Calculate elapsed time
    sub $t1, $a0, $t0  # Milliseconds elapsed

    # Convert to minutes:seconds format
    li $t2, 60000   # Milliseconds in a minute
    div $t1, $t2
    mflo $t3        # Minutes
    mfhi $t4        # Remaining milliseconds

    # Convert remaining milliseconds to seconds
    li $t2, 1000
    div $t4, $t2
    mflo $t5        # Seconds

    # Display time message
    li $v0, SysPrintString
    la $a0, time_msg
    syscall

    # Display minutes
    li $v0, 1
    move $a0, $t3
    syscall

    # Display minutes text
    li $v0, SysPrintString
    la $a0, minute_msg
    syscall

    # Display seconds
    li $v0, SysPrintInt
    move $a0, $t5
    syscall

    # Display seconds text
    li $v0, SysPrintString
    la $a0, second_msg
    syscall

    jr $ra

# Calculate and display final time
calculate_time:
    # Get current time
    li $v0, 30
    syscall

    # Load start time
    lw $t0, start_time

    # Calculate elapsed time
    sub $t1, $a0, $t0  # Milliseconds elapsed

    # Convert to minutes:seconds format
    li $t2, 60000   # Milliseconds in a minute
    div $t1, $t2
    mflo $t3        # Minutes
    mfhi $t4        # Remaining milliseconds

    # Convert remaining milliseconds to seconds
    li $t2, 1000
    div $t4, $t2
    mflo $t5        # Seconds

   

    # Display minutes
    li $v0, SysPrintInt
    move $a0, $t3
    syscall

    # Display colon
    li $v0, 4
    la $a0, colon_msg
    syscall

    # Display seconds
    li $v0, SysPrintInt
    move $a0, $t5
    syscall

    # Display newline
    li $v0, SysPrintString
    la $a0, newline
    syscall

    jr $ra
