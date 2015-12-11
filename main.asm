.data

left_paddle_oam:    .word 0
left_paddle_xvel:   .word 0
left_paddle_yvel:   .word 0

right_paddle_oam:   .word 0
right_paddle_xvel:  .word 0
right_paddle_yvel:  .word 0

ball_oam:           .word 0
ball_xvel:          .word 0
ball_yvel:          .word 0

.text

initialize: nop

    # load left paddle
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

    # load right paddle
    #############################
    push $s0                    # starting oam
    sw $s0,$0,right_paddle_oam  #
                                #
    push $s1                    # y (top)
                                #
    li $s2,248                  # x (right)
    push $s2                    # 
                                #
    push $s3                    # paddle width
                                #
    push $s4                    # paddle height
                                #
    push $s5                    # paddle index
                                #
    call load_sprite_img        # load sprite into oam
    add $s0,$0,$v0              # get next free position in oam
    #############################

    # load ball
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

main_loop: nop

    ######
    # Move left paddle
    ######
    lw $t0,$0,left_paddle_yvel
    push $t0

    lw $t0,$0,left_paddle_xvel
    push $t0

    lw $t0,$0,left_paddle_oam
    push $t0

    call move_sprite_img

    #####
    # Move right paddle
    #####
    lw $t0,$0,right_paddle_yvel
    push $t0

    lw $t0,$0,right_paddle_xvel
    push $t0

    lw $t0,$0,right_paddle_oam
    push $t0

    call move_sprite_img

b main_loop

# handle game tick interrupt
game_tick_interrupt: nop
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
        addi $t0,$0,0x73
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