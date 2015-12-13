 ########################################################################################################################
#  _____                   _     _           _____  _____       ______                                                   #
# |_   _|                 (_)   | |         |____ |/ __  \      | ___ \                                                  #
#   | |_ __ ___  _ __  ___ _ ___| |_ ___ _ __   / /`' / /'______| |_/ /__  _ __   __ _                                   #
#   | | '__/ _ \| '_ \/ __| / __| __/ _ \ '__|  \ \  / / |______|  __/ _ \| '_ \ / _` |                                  #
#   | | | | (_) | | | \__ \ \__ \ ||  __/ | .___/ /./ /___      | | | (_) | | | | (_| |                                  #
#   \_/_|  \___/|_| |_|___/_|___/\__\___|_| \____/ \_____/      \_|  \___/|_| |_|\__, |                                  #
#                                                                                 __/ |                                  #
#                                                                                |___/                                   #
#                                                                                                                        #
##########################################################################################################################
#                                                                                                                        #
#   A simple classic for the Tronsistor-32 ISA.                                                                          #
#                                                                                                                        #
##########################################################################################################################
#                                                                                                                        #
#   Special Notes:                                                                                                       #
#       $at is used as a flag register                                                                                   #
#       -------------------------------                                                                                  #
#           $at[0] - game reset flag                                                                                     #
#                                                                                                                        #
##########################################################################################################################

.data

left_score:         .word 0
right_score:        .word 0

left_paddle_oam:    .word 0
left_paddle_xvel:   .word 0
left_paddle_yvel:   .word 0

right_paddle_oam:   .word 0
right_paddle_xvel:  .word 0
right_paddle_yvel:  .word 0

ball_oam:           .word 0
ball_xvel:          .word 1
ball_yvel:          .word 0

.text

initialize: nop

    #############################
    # reset velocities          #
    #############################
    sw $0,$0,left_paddle_xvel
    sw $0,$0,left_paddle_yvel
    sw $0,$0,right_paddle_xvel
    sw $0,$0,right_paddle_yvel
    sw $0,$0,ball_xvel
    sw $0,$0,ball_yvel

    #############################
    # load left paddle          #
    #############################
    li $s0,0                    # starting oam
    push $s0                    #
    sw $s0,$0,left_paddle_oam   #
                                #
    li $s1,0                    # y (top)
    push $s1                    #
                                #
    li $s2,0                    # x (left)
    push $s2                    #
                                #
    li $s3,paddle_width         # paddle width
    push $s3                    #
                                #
    li $s4,paddle_height        # paddle height
    push $s4                    #
                                #
    li $s5,paddle_index         # paddle index
    push $s5                    #
                                #
    call load_sprite_img        # load sprite into oam
    add $s0,$0,$v0              # get next free position in oam
    #############################

    #############################
    # load ball                 #
    #############################
    push $s0                    # starting oam
    sw $s0,$0,ball_oam          #
                                #
    li $s1,8                    # y (8 from top)
    push $s1                    #
                                #
    li $s2,10                   # x (8 from left)
    push $s2                    #
                                #
    li $s3,ball_width           # ball width
    push $s3                    #
                                #
    li $s4,ball_height          # ball height
    push $s4                    #
                                #
    li $s5,ball_index           # ball index
    push $s5                    #
                                #
    call load_sprite_img        # load sprite into oam
    add $s0,$0,$v0              # get next free position in oam
    #############################

    #############################
    # load right paddle         #
    #############################
    push $s0                    # starting oam
    sw $s0,$0,right_paddle_oam  #
                                #
    li $s1,0                    # y (top)
    push $s1                    #
                                #
    li $s2,248                  # x (right)
    push $s2                    # 
                                #
    li $s3,paddle_width         # paddle width
    push $s3                    #
                                #
    li $s4,paddle_height        # paddle height
    push $s4                    #
                                #
    li $s5,paddle_index         # paddle index
    push $s5                    #
                                #
    call load_sprite_img        # load sprite into oam
    add $s0,$0,$v0              # get next free position in oam
    #############################

main_loop: nop

    # game reset flag
    check_flag0: nop
        andi $s0,$at,1
        addi $s0,$s0,-1
        bne check_flag1
    
        b initialize

    # unassigned flag
    check_flag1: nop

    b main_loop

# handle game tick interrupt
game_tick_interrupt: nop
    push $s0

    ##########################################
    # Check for ball/left paddle collision   #
    ##########################################
    addi $t0,$0,paddle_width
    push $t0

    addi $t0,$0,ball_width
    push $t0

    addi $t0,$0,paddle_height
    push $t0

    addi $t0,$0,ball_height
    push $t0

    lw $t0,$0,left_paddle_oam
    li $t1,oam_copy
    add $t0,$t0,$t1
    lw $t0,$t0,0
    push $t0

    lw $t0,$0,ball_oam
    li $t1,oam_copy
    add $t0,$t0,$t1
    lw $t0,$t0,0
    push $t0

    call check_collision
    lw $t0,$0,TRUE
    sub $0,$t0,$v0
    beq handle_paddle_ball_collide

    ##########################################
    # Check for ball/right paddle collision  #
    ##########################################
    addi $t0,$0,paddle_width
    push $t0

    addi $t0,$0,ball_width
    push $t0

    addi $t0,$0,paddle_height
    push $t0

    addi $t0,$0,ball_height
    push $t0

    lw $t0,$0,right_paddle_oam
    li $t1,oam_copy
    add $t0,$t0,$t1
    lw $t0,$t0,0
    push $t0

    lw $t0,$0,ball_oam
    li $t1,oam_copy
    add $t0,$t0,$t1
    lw $t0,$t0,0
    push $t0

    call check_collision
    lw $t0,$0,TRUE
    sub $0,$t0,$v0
    beq handle_paddle_ball_collide

    b end_handle_paddle_ball_collide
    handle_paddle_ball_collide: nop
        lw $a0,$0,ball_xvel
        call negate
        sw $v0,$0,ball_xvel
        end_handle_paddle_ball_collide: nop

    ##########################################
    # Check for ball out of bounds           #
    ##########################################
    lw $t0,$0,ball_oam
    lw $t0,$t0,oam_copy

    add $a0,$0,$t0
    call get_x
    push $v0

    add $a0,$0,$t0
    call get_y
    push $v0

    li $t0,ball_width
    push $t0

    li $t0,ball_height
    push $t0

    call check_oob

    # check ball left oob
    check_ball_oob_l: nop
        andi $t0,$v0,8
        sub $0,$0,$t0
        beq check_ball_oob_r

        lw $t0,$0,right_score
        addi $t0,$t0,1
        sw $t0,$0,right_score

    # check ball right oob
    check_ball_oob_r: nop
        andi $t0,$v0,2
        sub $0,$0,$t0
        beq check_ball_oob_tb

        lw $t0,$0,left_score
        addi $t0,$t0,1
        sw $t0,$0,left_score

    # left/right oob set reset flag
    or $at,$at,1
    b end_game_tick_interrupt

    # if top or bottom reverse y vel
    check_ball_oob_tb: nop
        andi $t0,$v0,5
        sub $0,$0,$t0
        beq end_check_ball_oob

        lw $a0,$0,ball_yvel
        call negate
        sw $v0,$0,ball_yvel

    end_check_ball_oob: nop

    ############################
    # Move left paddle         #
    ############################
    move_left_paddle: nop
        lw $s0,$0,left_paddle_yvel
        lw $s1,$0,left_paddle_xvel
        or $t1,$s0,$s1
        sub $0,$0,$t1
        beq move_right_paddle

        push $s0
        push $s1

        li $s0,paddle_size
        push $s0

        lw $s0,$0,left_paddle_oam
        push $s0

        call move_sprite_img

    ############################
    # Move right paddle        #
    ############################
    move_right_paddle: nop
        lw $s0,$0,right_paddle_yvel
        lw $s1,$0,right_paddle_xvel
        or $t1,$s0,$s1
        sub $0,$0,$t1
        beq move_ball

        push $s0
        push $s1

        li $s0,paddle_size
        push $s0

        lw $s0,$0,right_paddle_oam
        push $s0

        call move_sprite_img

    ############################
    # Move ball                #
    ############################
    move_ball: nop
        lw $s0,$0,ball_yvel
        lw $s1,$0,ball_xvel
        or $t1,$s0,$s1
        sub $0,$0,$t1
        beq end_game_tick_interrupt

        push $s0
        push $s1

        li $s0,ball_size
        push $s0

        lw $s0,$0,ball_oam
        push $s0

        call move_sprite_img

    end_game_tick_interrupt: nop
        pop $s0
        jr $epc

# handle keyboard interrupt 
#
# w/s: left paddle up/down
# i/k: right paddle up/down
# 
# w: 77
# s: 73
# i: 69
# k: 6B
#
keyboard_interrupt: nop
    push $t0

    if_w: nop
        addi $t0,$0,0x77
        sub $0,$idr,$t0
        bne end_if_w

        addi $t0,$0,-1
        sw $t0,$0,left_paddle_yvel
        b ki_ret
    end_if_w: nop

    if_s: nop
        addi $t0,$0,0x73
        sub $0,$idr,$t0
        bne end_if_s

        addi $t0,$0,1
        sw $t0,$0,left_paddle_yvel
        b ki_ret
    end_if_s: nop

    if_i: nop
        addi $t0,$0,0x69
        sub $0,$idr,$t0
        bne end_if_i

        addi $t0,$0,-1
        sw $t0,$0,right_paddle_yvel
        b ki_ret
    end_if_i: nop

    if_k: nop
        addi $t0,$0,0x6B
        sub $0,$idr,$t0
        bne end_if_k

        addi $t0,$0,1
        sw $t0,$0,right_paddle_yvel
        b ki_ret
    end_if_k: nop

    ki_ret: nop
        pop $t0
        jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc

end_game_instructions: nop