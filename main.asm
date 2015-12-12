.data

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
    li $s2,8                    # x (8 from left)
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
        lw $t0,$0,ball_oam
        li $t1,oam_copy
        add $t0,$t0,$t1
        lw $a0,$t0,0
        call get_x

        add $a0,$0,$v0
        call negate

        add $a0,$0,$t0
        add $a1,$0,$v0
        call set_x

        lw $t1,$0,ball_oam
        sld $t1,$v0

        li $t0,oam_copy
        add $t1,$t1,$t0
        sw $v0,$t1,0
        end_handle_paddle_ball_collide: nop

    ##########################################
    # Check for ball out of bounds           #
    ##########################################

    ############################
    # Move left paddle         #
    ############################
    lw $s0,$0,left_paddle_yvel
    push $s0

    lw $s0,$0,left_paddle_xvel
    push $s0

    li $s0,$0,paddle_size
    push $s0

    lw $s0,$0,left_paddle_oam
    push $s0

    call move_sprite_img

    ############################
    # Move right paddle        #
    ############################
    lw $s0,$0,right_paddle_yvel
    push $s0

    lw $s0,$0,right_paddle_xvel
    push $s0

    li $s0,$0,paddle_size
    push $s0

    lw $s0,$0,right_paddle_oam
    push $s0

    call move_sprite_img

    ############################
    # Move ball                #
    ############################
    lw $s0,$0,ball_yvel
    push $s0

    lw $s0,$s0,ball_xvel
    push $s0

    li $s0,$0,ball_size
    push $s0

    lw $s0,$s0,ball_oam
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

        addi $t0,$0,1
        sw $t0,$0,left_paddle_yvel
        b ki_ret
    end_if_w: nop

    if_s: nop
        addi $t0,$0,0x73
        sub $0,$idr,$t0
        bne end_if_s

        addi $t0,$0,-1
        sw $t0,$0,left_paddle_yvel
        b ki_ret
    end_if_s: nop

    if_i: nop
        addi $t0,$0,0x69
        sub $0,$idr,$t0
        bne end_if_i

        addi $t0,$0,1
        sw $t0,$0,right_paddle_yvel
        b ki_ret
    end_if_i: nop

    if_k: nop
        addi $t0,$0,0x6B
        sub $0,$idr,$t0
        bne end_if_k

        addi $t0,$0,-1
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