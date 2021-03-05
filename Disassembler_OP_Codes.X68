; D4 Contains Original hex code
; D3 Contains modified hex code

; D1 is used to bit shift


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
        
	    CMP.B       #9, D3
        BEQ         JUMP_9 ;
        
        CMP.B       #B, D3
        BEQ         JUMP_B ; 
        
        CMP.B       #C, D3
        BEQ         JUMP_C ;

        CMP.B       #D, D3
        BEQ         JUMP_D ;
        
        CMP.B       #E, D3
        BEQ         JUMP_E ;

             
        
JUMP_0:
        *ORI/MOVE/MOVEA
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
        CLR.L       D3
        MOVE.L      D4, D3
        BTST         #8,D3 ;
        BEQ          OP_CODE_ADDQ ; 
        RTS
        
JUMP_6:
        CLR.L       D3
        MOVE.W      D4, D3
        CMP.W  #$4E71, D3 ;NOP 
        BEQ OP_CODE_NOP
        
        CLR.L       D3
        MOVE.W      D4, D3
        LSR.L  #8, D3 
        LSR.L  #1,D3
        AND.B  #$07,D3 ;
        CMP.B  #$07, D3 
        BEQ    OP_CODE_JSR ;JSR
        
        MOVE.W   D4, D3
        LSR.L    #6, D3
        AND.B  #$07,D3
        CMP.B  #$07,D3
        BEQ    OP_CODE_LEA ;LEA
                
        RTS 

JUMP_7:
 *MOVEQ HAS NO SIZE, KEEP DATA REGISTER IN TRACK OF SIZES?
    LEA         MOVEQ_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    BRA DONE
    
JUMP_8:


JUMP_9:
    MOVE.L      (A1), D3
    LSR.L   #6,D3
    AND.B   #$03,D3
    CMP.B   #$3,D3
    BEQ     INVALID_INSTR
    MOVE.W  (A1),D3
    BTST    #8,D3 
    BNE     INVALID_INSTR


JUMP_B:


JUMP_C:



JUMP_D:
    CLR.L       D3
    MOVE.W      D4, D3
    BTST     #8,D3 
    BEQ      CHECK_FOR_ADDA
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
    RTS
    
; /BLOCK --------------------


; END MOVE BLOCK ------------------------------

*ADDQ - 0101, BScc, Scc
*-------------------------------------------------------------        
OP_CODE_ADDQ:

        CLR.L       D3
        MOVE.L      D4, D3
        LSR.L       #6,D3
        AND.B       #%011,D3
        CMP.B       #%011,D3
        BEQ         INVALID_INSTR
        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        ; DO EA AND CHECK FOR SIZES


*NOP/JSR/LEA - 0100
*-------------------------------------------------------------
CHECK_FOR_MOVEM:
        CLR.L       D3
        MOVE.L      D4, D3
        BTST         #11,D2 ;
        BEQ          OP_CODE_MOVEM:;

OP_CODE_NOP:
        LEA         NOP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

OP_CODE_JSR:
        CLR.L       D3
        MOVE.W      D4, D3
        LSR.L  #8, D3 
        LSR.L  #1,D3
        AND.B  #$07,D3 ;
        CMP.B  #$07, D3 
        LEA         JSR_MSG, A1
        ;MOVE.B      #14, D0
        ;TRAP        #15
        *CAN WE HAVE A JMP AFTER TRAP?
        JMP CHECK_FOR_MOVEM 
        
OP_CODE_LEA:
        LEA         LEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15




*MOVEM - 0100
*-------------------------------------------------------------
OP_CODE_MOVEM:

*CHECK FOR FURTHER VALIDATION


*BRA/BSR - 0110
*-------------------------------------------------------------
OP_CODE_:




*MOVEQ - 0111
*-------------------------------------------------------------
OP_CODE_MOVEQ:





*MULU - 1100
*-------------------------------------------------------------
OP_CODE_MULUQ:





*ADD/ADDA - 1101
*-------------------------------------------------------------
OP_CODE_ADD:

CHECK_FOR_ADDA:
    
OP_CODE_ADDA:
    LSR      #6, D3
    AND.B    #$07, D3 ;
    CMP.B    #$03, D3 ; 011 OR 111 = ADDA
    LEA         ADDA_MSG, A1
    CMP.B    #$07, D3 
    LEA         ADDA_MSG, A1

*ASL/ASR - 1110
*-------------------------------------------------------------
OP_CODE_ASD:






*DIVU - 1000
*-------------------------------------------------------------
OP_CODE_DIVU:






*SUB - 1001
*-------------------------------------------------------------
OP_CODE_SUB:






*CMP - 1011
*-------------------------------------------------------------
OP_CODE_CMP:









ADDQ_MSG:       DC.B        'ADDQ',0
MOVE_MSG:       DC.B        'MOVE',0
MOVEA_MSG:       DC.B        'MOVEA',0
ORI_MSG:       DC.B        'ORI',0
NOP_MSG:       DC.B        'NOP',0
MOVEM_MSG:       DC.B        'MOVEM',0
LEA_MSG:       DC.B        'LEA',0
BRA_MSG:       DC.B        'BRA',0
BSR_MSG:       DC.B        'BSR',0
MOVEQ_MSG:       DC.B        'MOVEQ',0
DIVU_MSG:       DC.B        'DIVU',0
SUB_MSG:       DC.B        'SUB',0
CMP_MSG:       DC.B        'CMP',0
MULU_MSG:       DC.B        'MULU',0
ADD_MSG:       DC.B        'ADD',0
ADDA_MSG:       DC.B        'ADDA',0
ASL_MSG:       DC.B        'ASL',0
ASR_MSG:       DC.B        'ASR',0

ERROR_INSTR:    DC.B  'INVALID INSTRUCTION',0
; Size messages

BYTE_MSG:       DC.B        '.B',0
WORD_MSG:       DC.B        '.W',0
LONG_MSG:       DC.B        '.L',0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
