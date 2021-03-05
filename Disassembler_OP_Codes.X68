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

<<<<<<< Updated upstream
=======

; D4 = XXXX YYYY YYYY YYYY
PRINT_BYTE:

PRINT_WORD:

PRINT LONG:


INVALID_INSTR:
        LEA         ERROR_INSTR, A6
        MOVE.B      #14, D0
        TRAP        #15
        BRA         DONE
        
JUMP_OP_CODE:
        CLR.L       D3
        MOVE.L      D4, D3
        SWAP       D3
        ROL.L      #2, D3 ;
        AND.B      #$03,D3 ;ISOLATE 
        CMP.B      #$0,D3 ;
        BEQ        JUMP_0 ;MOVE,MOVEA,ORI

        CLR.L       D3
        MOVE.L      D4, D3
        SWAP       D3
        ROL.L       #4, D3 ;
        AND.B       #$0F,D3 ; MASK 

        
        CMP.B       #1, D3
        BEQ         JUMP_1 ;
        
	    CMP.B       #3, D3
        BEQ         JUMP_3 ;
        
        CMP.B       #4, D3
        BEQ         JUMP_4 ;

	    CMP.B       #5, D3
        BEQ         JUMP_5 ;
  
        CMP.B       #6, D3
        BEQ         JUMP_6 ;
        
	    CMP.B       #7, D3
        BEQ         JUMP_7 ;
        
        CMP.B       #8, D3
        BEQ         JUMP_8 ;
>>>>>>> Stashed changes
        
        
        
        
        

        
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
