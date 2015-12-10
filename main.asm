.data

pong: .asciiz "PONG"

.text

initialize: nop

    # load left paddle
    #########################
    li $s0,0                # starting oam
    push $s0                #
                            #
    li $s1,0                # x (left)
    push $s1                #
                            #
    li $s2,0                # y (top)
    push $s2                #
                            #
    li $s3,paddle_width     # paddle width
    push $s3                #
                            #
    li $s4,paddle_height    # paddle height
    push $s4                #
                            #
    li $s5,paddle_index     # paddle index
    push $s5                #
                            #
    call load_sprite_img    # load sprite into oam
    add $s0,$0,$v0          # get next free position in oam
    #########################

    # load right paddle
    #########################
    push $s0                # starting oam
                            #
    addi $s1,$s1,248        # x (right)
    push $s1                # 
                            #
    push $s2                # y (top)
                            #
    push $s3                # paddle width
                            #
    push $s4                # paddle height
                            #
    push $s5                # paddle index
                            #
    call load_sprite_img    # load sprite into oam
    add $s0,$0,$v0          # get next free position in oam
    #########################

    # load ball
    #########################
    push $s0                # starting oam
                            #
    li $s1,8                # x (8 from left)
    push $s1                #
                            #
    li $s2,8                # y (8 from top)
    push $s2                #
                            #
    li $s3,ball_width       # ball width
    push $s3                #
                            #
    li $s4,ball_height      # ball height
    push $s4                #
                            #
    li $s5,ball_index       # ball index
    push $s5                #
                            #
    call load_sprite_img    # load sprite into oam
    add $s0,$0,$v0          # get next free position in oam
    #########################

main_loop: nop

b main_loop

# handle game tick interrupt
game_tick_interrupt: nop
    jr $epc

# handle keyboard interrupt 
keyboard_interrupt: nop
    jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc

end_game_instructions: nop