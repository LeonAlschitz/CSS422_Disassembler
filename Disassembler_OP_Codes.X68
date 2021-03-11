*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------



; D4 Contains Original hex code
; D3 Contains modified hex code

; D1 is used to bit shift


; D4 = XXXX YYYY YYYY YYYY
JUMP_OP_CODE:
        CLR.L       D3
        MOVE.L      D4, D3
        CLR.L       D1
        CLR.L       D2
        MOVE.B      #12, D1
        LSR.W       D1, D3  ; D3 = 0000 0000 0000 XXXX

        BRA         JUMP_1
        
        
JUMP_0:

        RTS 
        
        
JUMP_1:
        CMP.B       #$1, D3 ;First 4 bits:  0001
        BNE         JUMP_2
        JSR         OP_CODE_BASE_MOVE
        JSR         EA_MOVE 
        RTS


JUMP_2:             ; MOVE.L or MOVEA.L
        CMP.B       #$2, D3 ;First 4 bits:  0010
        BNE         JUMP_3
        JSR         ISOLATE_DESTM
        CMP.B       #$1, D3 
        BEQ         J_MOVEA_L
        CMP.B       #$2, D3 
        BEQ         J_MOVE_L
        JSR         EA_MOVE 
        RTS
        

JUMP_3:             ; MOVE.W or MOVEA.W
        CMP.B       #$3, D3  ;First 4 bits:  0011
        ; BNE         JUMP_4
        JSR         ISOLATE_DESTM
        CMP.B       #$1, D3 
        BEQ         J_MOVEA_W
        CMP.B       #$2, D3
        BEQ         J_MOVE_W
        
        JSR         EA_MOVE
        
        RTS


JUMP_4:

        RTS 



JUMP_5:
        CMP.B       #$5, D3
        BRA         OP_CODE_ADDQ
        RTS 
        
JUMP_6:

        RTS 

        
;.
;.
;.
;.
;.
;.
;.
 
JUMP_E:

        RTS 
         
        
        

        
        ;LEA         ERROR_MSG, A1
        ;MOVE.B      #14, D0    
        ;TRAP        #15
        BRA         DONE




        ;  Move valid sizes: 00, 11 10
        ;  MoveA valid sizes: 11, 10
        ; Code = 103C




; Functions to help isolate bits
; 0000 000X XX00 0000
; MOVE = 0011/0010 XXXY YYXX XXXX
; MOVEA = 0011/0010 XXX0 01XX XXXX
ISOLATE_DESTM:
        CLR.L       D3          
        MOVE.W      D4,D3 ; D3 = YYYY YYYX XXYY YYYY
        LSL.W       #7,D3 ; Shift left 7 bits to 0 out those values  D3 = XXXY YYYY Y000 0000 
        MOVE.B      #13,D1
        LSR.W       D1,D3 ; Shift right 13. 7 to compensate for previous shift and another 6 on top; XXXY YYYY Y000 0000  => 0000 0000 0000 0XXX
        RTS 




        
        
        
; MOVE/MOVEA BLOCK ----------------------------------
OP_CODE_BASE_MOVE:
        ; This should only execute for Move.B
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         BYTE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        RTS         


; first 4 bits = 0010 BLOCK --------------------    
J_MOVEA_L:
    LEA         MOVEA_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    LEA         LONG_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    RTS    
J_MOVE_L:
    LEA         MOVE_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    LEA         LONG_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    RTS
; /BLOCK --------------------

; first 4 bits = 0011 BLOCK --------------------   

J_MOVEA_W:
    LEA         MOVEA_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    LEA         WORD_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    RTS  
    
J_MOVE_W:
    LEA         MOVE_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    LEA         WORD_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    RTS  
    
; /BLOCK --------------------


; END MOVE BLOCK ------------------------------

        
OP_CODE_ADDQ:

        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         DONE


ADDQ_MSG:       DC.B        'ADDQ',0
MOVE_MSG:       DC.B        'MOVE',0
MOVEA_MSG:       DC.B        'MOVEA',0

; Size messages

BYTE_MSG:       DC.B        '.B',0
WORD_MSG:       DC.B        '.W',0
LONG_MSG:       DC.B        '.L',0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
