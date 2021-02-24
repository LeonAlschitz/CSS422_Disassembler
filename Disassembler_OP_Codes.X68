*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

OP_CODE:
        MOVEA.L     D4, A3
        CLR.L       D1
        MOVE.B      #12, D1
        LSR.W       D1, D4

        
        
        
        
        

        
        CMP.B       #$1, D4
        BRA         OP_CODE_MOVE
        
        CMP.B       #$5, D4
        BRA         OP_CODE_ADDQ
        
        LEA         ERROR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         DONE


OP_CODE_MOVE:
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         DONE

        
OP_CODE_ADDQ:





        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         DONE


ADDQ_MSG:       DC.B        'ADDQ',0
MOVE_MSG:       DC.B        'MOVE',0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
