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
        ; SIMHALT
        CLR.L       D3
        MOVE.L      D4, D3
        CLR.L       D1
        CLR.L       D2
        MOVE.B      #12, D1
        LSR.W       D1, D3  ; D3 = 0000 0000 0000 XXXX


        CMP.B       #$0, D3
        BEQ         JUMP_0 
        CMP.B       #$1, D3
        BEQ         JUMP_1 
        CMP.B       #$2, D3
        BEQ         JUMP_2
        CMP.B       #$3, D3
        BEQ         JUMP_3
        CMP.B       #$4, D3
        BEQ         JUMP_4
        CMP.B       #$5, D3
        BEQ         JUMP_5
        CMP.B       #$6, D3
        BEQ         JUMP_6
        CMP.B       #$7, D3
        BEQ         JUMP_7
        CMP.B       #$8, D3
        BEQ         JUMP_8
        CMP.B       #$9, D3
        BEQ         JUMP_9

        BRA         JUMP_ERROR




       
        
*0000 - ORI      
JUMP_0:
        *ORI
        JSR         Bits11to8
        CMP.B       #$0, D2  
        BEQ         OP_CODE_ORI
        
        BRA         INVALID_INSTR
        
*0001 - MOVE.B     
JUMP_1:

        JSR         OP_CODE_BASE_MOVE
        JSR         EA_MOVE 
        RTS


*0010 - MOVE.L, MOVEA.L
JUMP_2:

        JSR         Bits8to6
        CMP.B       #$1, D2 
        BEQ         J_MOVEA_L 
        BNE         J_MOVE_L


        BRA         INVALID_INSTR
        RTS
        
*0011 - MOVE.W, MOVEA.W
JUMP_3:

        JSR         Bits8to6
        CMPI.B       #$1, D2 
        BEQ         J_MOVEA_W
        BNE         J_MOVE_W
        
        
        
        BRA INVALID_INSTR
        
        RTS
MOVEM_CHECK:
        CLR.L       D2
        MOVE.L      D4, D2
        BTST        #11,D2 ;
        BNE         OP_CODE_MOVEM
        JMP         INVALID_INSTR
        
*0100 - NOP, LEA, JSR
JUMP_4:

        CLR.L       D2
        MOVE.W      D4, D2
        CMP.W       #$4E71, D3 ;NOP 
        BEQ         OP_CODE_NOP
        
        JSR         Bits7to6     ;
        CMPI.B      #2, D2
        BEQ         OP_CODE_JSR ;JSR
        JMP         MOVEM_CHECK ;
        
        JSR         Bits8to6     ;
        CMPI.B      #7, D2
        BEQ         OP_CODE_LEA ;LEA
        
        
        BRA INVALID_INSTR
        
        RTS  



*0101 - ADDQ       
JUMP_5:
        CLR.L       D2
        MOVE.L      D4, D2
        BTST        #8,D2 
        BEQ         OP_CODE_ADDQ  
        BRA         INVALID_INSTR
        RTS  
        
JUMP_6:

        BRA         INVALID_INSTR
        RTS  
JUMP_7:
        BRA         INVALID_INSTR 
        RTS
JUMP_8:
        BRA         INVALID_INSTR
        RTS

JUMP_9:
        BRA         INVALID_INSTR
        RTS         

JUMP_A:
        BRA         INVALID_INSTR
        RTS 
JUMP_B:
        BRA         INVALID_INSTR
        RTS         

JUMP_C:
        BRA         INVALID_INSTR
        RTS 

JUMP_D:
        BRA         INVALID_INSTR
        RTS 
 
JUMP_E:
        JSR         Bits7to6
        
        BRA         INVALID_INSTR
        RTS  
         
JUMP_ERROR:       
        LEA         ERROR_INSTR, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS

INVALID_INSTR:
        LEA         IMPLEMENT_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        RTS


*-----------ISOLATE BITS------------------------------------
*---------ISOLATE SRC REG-------
Bits2to0:
        MOVE.W      D4, D2
        MOVE.B      #13, D0     ; Shifting 13 bits
        LSL.W       D0, D2      ; shorten to two bits
        LSR.W       D0, D2      ; isolate two bits
        RTS
*-------------------------------
    
Bits3to0:
        MOVE.W      D4, D2
        MOVE.B      #12, D0     ; Shift 12 bits
        LSL.W       D0, D2      ; Shorten to 4th bit
        LSR.W       D0, D2      ; Isolate 4 bits
        RTS
    
*---------ISOLATE SRC REG-------    
Bits5to3:
        MOVE.W      D4, D2
        MOVE.B      #10, D0     ; Shift 10 bits
        LSL.W       D0, D2      ; cut to 5th bit
        MOVE.B      #13, D0     ; Shift 13 bits
        LSR.W       D0, D2      ; Isolate bits 5-3
        RTS
*-------------------------------

*------ISOLATE SRC--------    
Bits7to0:
        MOVE.W      D4, D2
        LSL.W       #8, D2      ; cut to 8th bit
        LSR.W       #8, D2      ; Isolate 7-0
        RTS
*-------------------------    
Bits7to4: 
        MOVE.W      D4, D2
        LSL.W       #8, D2      ; cut to 8th bit
        MOVE.B      #12, D0     ; shift 12 bits
        LSR.W       D0, D2      ; isolate 7-4
        RTS
    
Bits7to6:
        MOVE.W      D4, D2
        LSL.W       #8, D2      ; cut to 8th bit
        MOVE.B      #14, D0     ; shift 14 bits
        LSR.W       D0, D2      ; isolate 7-6
        RTS
    
Bits8to3:
        MOVE.W      D4, D2
        LSL.W       #7, D2      ; cut to 9th bit
        MOVE.B      #10, D0     ; shift 10 bits
        LSR.W       D0, D2      ; isolate 8-3
        RTS
    
Bits8to4:
        MOVE.W      D4, D2
        LSL.W       #7, D2      ; cut to 9th bit
        MOVE.B      #11, D0     ; shift 11 bits
        LSR.W       D0, D2      ; isolate 8-4
        RTS
    
Bits8to6:
        MOVE.W      D4, D2
        LSL.W       #7, D2      ; cut to 9th bit
        MOVE.B      #13, D0     ; shift 13 bits
        LSR.W       D0, D2      ; isolate 8-6
        RTS
Bits9to7:
        MOVE.W      D4, D2
        LSL.W       #6, D2      ; cut to 10th bit
        MOVE.B      #13, D0     ; shift 13 bits
        LSR.W       D0, D2      ; isolate 8-6
        RTS
*----ISOLATE DEST---------    
Bits11to6:
        MOVE.W      D4, D2
        LSL.W       #4, D2      ; cut to 12th bit
        MOVE.B      #10, D0     ; shift 10 bits
        LSR.W       D0, D2      ; isolate 11-6
        RTS
*-------------------------

     
Bits11to8:
        MOVE.W      D4, D2
        LSL.W       #4, D2      ; cut to 12th bit
        MOVE.B      #12, D0     ; shift 12 bits
        LSR.W       D0, D2      ; isolate 11-8
        RTS

*----ISOLATE DEST REG-----      
Bits11to9:
        MOVE.W      D4, D2
        LSL.W       #4, D2      ; cut to 12th bit
        MOVE.B      #13, D0     ; shift 13 bits
        LSR.W       D0, D2      ; isolate 11-9
        RTS
*-------------------------


*MOVE.B - 0001
*------------------------------------------------------------- 
OP_CODE_BASE_MOVE:
        ; This should only execute for Move.B
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         BYTE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #0, D3
        
        
        
        RTS         

*MOVE.L, MOVEA.L - 0010
*-------------------------------------------------------------  
J_MOVEA_L:
        LEA         MOVEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         LONG_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #2, D3
        JSR         EA_MOVE
        RTS    
J_MOVE_L:
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         LONG_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #2, D3
        JSR         EA_MOVE
        
        RTS


*MOVE.W, MOVEA.W - 0011
*-------------------------------------------------------------  

J_MOVEA_W:
        LEA         MOVEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         WORD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3
        JSR         EA_MOVE
        
        RTS  
    
J_MOVE_W:
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         WORD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3
        JSR         EA_MOVE
        
        RTS  
    
*ORI - 0000
*-------------------------------------------------------------
OP_CODE_ORI:
        LEA         ORI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS


*NOP/JSR/LEA - 0100
*-------------------------------------------------------------
OP_CODE_NOP:
        LEA         NOP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
           

OP_CODE_JSR:
        LEA         JSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        *STORE DEST AND STORE IN REGISTER
        *EA

        RTS
        
OP_CODE_LEA:
        LEA         LEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #2, D0

        *EA
        *JSR         EA_LEA

        RTS

*MOVEM/EXT - 0100
*-------------------------------------------------------------
OP_CODE_MOVEM:
        JSR         Bits9to7 ;check for MOVEM and EXT
        CMP.B       #1, D2   ;
        
MOVEM_OR_EXT:
        JSR         Bits5to3  ;
        CMP.B       #0, D2    ;
        BEQ         OP_CODE_EXT ;
        
        MOVE.W      D4, D2
        BTST        #10, D2
*        BEQ         MOVEM_MEMORY
 
OP_CODE_EXT:
        LEA         EXT_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
*MOVEM_MEMORY:
               
        
MOVEM_DISPLAY:
        LEA         MOVEM_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

*ADDQ - 0101, BScc, Scc
*-------------------------------------------------------------        
OP_CODE_ADDQ:
        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        RTS
        ;JSR         Bits7to6  
        ;MOVE        #5, TAB
        ;JSR         SizeTwoBits 
 *EA STUFF, MAYBE CHECK FOR DISPLACEMENT COUNT?


*ASL/ASR - 1110
*-------------------------------------------------------------
*OP_CODE_ASL:
*        LEA         ASL_MSG, A1
*        MOVE.B      #14, D0
*        TRAP        #15
*        BRA         ROT_SHIFT
*OP_CODE_ASR:
*        LEA         ASR_MSG, A1
*        MOVE.B      #14, D0
*        TRAP        #15
*        BRA         ROT_SHIFT
*
*MEMORY SHIFTS, WORK WITH EA
*ROT_SHIFT:
*        


ADDQ_MSG:       DC.B        'ADDQ',0
MOVE_MSG:       DC.B        'MOVE',0
MOVEA_MSG:      DC.B        'MOVEA',0
ORI_MSG:        DC.B        'ORI',0
NOP_MSG:        DC.B        'NOP',0
MOVEM_MSG:      DC.B        'MOVEM',0
LEA_MSG:        DC.B        'LEA',0
JSR_MSG:        DC.B        'JSR',0
BRA_MSG:        DC.B        'BRA',0
BSR_MSG:        DC.B        'BSR',0
MOVEQ_MSG:      DC.B        'MOVEQ',0
DIVU_MSG:       DC.B        'DIVU',0
SUB_MSG:        DC.B        'SUB',0
CMP_MSG:        DC.B        'CMP',0
MULU_MSG:       DC.B        'MULU',0
ADD_MSG:        DC.B        'ADD',0
ADDA_MSG:       DC.B        'ADDA',0
ASL_MSG:        DC.B        'ASL',0
ASR_MSG:        DC.B        'ASR',0
EXT_MSG:        DC.B        'EXT',0
POUND:          DC.B        '#',0
DOLLAR:         DC.B        '$',0
PERCENT:        DC.B        '%',0

; Size messages

BYTE_MSG:       DC.B        '.B',0
WORD_MSG:       DC.B        '.W',0
LONG_MSG:       DC.B        '.L',0
IMPLEMENT_MSG:  DC.B        'OP-CODE NOT IMPLEMENTED',0
ERROR_INSTR:    DC.B  'INVALID OP-CODE',0






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
