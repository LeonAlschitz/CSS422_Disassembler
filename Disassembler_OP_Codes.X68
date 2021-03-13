CR              EQU     $0D                 
LF              EQU     $0A 
; D4 Contains Original hex code
; D3 Contains modified hex code

; D1 is used to bit shift
; D3 = OP size. ie. Byte, Word, Long
; D4 = Original hex code
; D5 = Current Register or Mode being isolated

; A3 will store starting address
; A4 will store ending address


; D4 = XXXX YYYY YYYY YYYY
PRINT_CRLF:
        LEA         BREAK, A1
        MOVE.B      #14, D0
        TRAP        #15

*Prints size of opcode (.B, .W, .L) when input is two bits
SizeTwoBits:
    MOVEM.L  A0-A6/D0-D6,-(SP) ; store registers to stack
    CMP.B    #0,D3             ;
    BEQ      PRINT_BYTE        ;
    CMP.B    #1,D3             ;
    BEQ      PRINT_WORD        ;
    CMP.P    #2,D3             ;
    BEQ      PRINT_LONG        ;
    
    BRA RESTORE_STACK          ;
    
*Prints size of opcode (.W, .L) when input is three bits
*(xxx).L or (xxx).W
SizeThreeBits:
    CMP.B    #1,D3             ;
    BEQ      PRINT_WORD        ;
    CMP.P    #2,D3             ;
    BEQ      PRINT_LONG        ;
    
    BRA RESTORE_STACK          ;

*.B  
PRINT_BYTE:
    LEA  BYTE_MSG, A1       ;
    MOVE.B #0, STORE_SIZE   ;
    JSR PRINT_TAB           ;
    RTS
*.W
PRINT_WORD:
    LEA  WORD_MSG, A1       ;
    MOVE.B #1, STORE_SIZE   ;
    JSR PRINT_TAB           ;
    RTS
*.L
PRINT_LONG:
    LEA  LONG_MSG, A1       ;
    MOVE.B #2, STORE_SIZE   ;
    JSR PRINT_TAB           ;
    RTS

*print size of opcode
PRINT_SIZE:
    MOVE.B #14, D0 ;
    TRAP   #15     ;
    RTS
      
PRINT_TAB:
    CLR.L D3      ;
    MOVE.B TAB, D3;
    RTS
      
*when no matches      
RESTORE_STACK:
    MOVEM.L  (SP)+, A0-A6/D0-D6 ; restore registers from stack
    RTS ;

*-----------ISOLATE BITS------------------------------------
*---------ISOLATE SRC REG-------
Bits2to0:
    MOVE.W D4, D3;
    MOVE.B #13, D0; Shifting 13 bits
    LSL.W D0,D3; shorten to two bits
    LSR.W D0,D3; isolate two bits
    RTS
*-------------------------------
    
Bits3to0:
    MOVE.W D4, D3;
    MOVE.B #12, D0; Shift 12 bits
    LSL.W D0,D3; Shorten to 4th bit
    LSR.W D0,D3; Isolate 4 bits
    RTS
    
*---------ISOLATE SRC REG-------    
Bits5to3:
    MOVE.W D4, D3;
    MOVE.B #10, D0; Shift 10 bits
    LSL.W D0,D3; cut to 5th bit
    MOVE.B #13, D0; Shift 13 bits
    LSR.W D0,D3; Isolate bits 5-3
    RTS
*-------------------------------

*------ISOLATE SRC--------    
Bits7to0:
    MOVE.W D4, D3;
    LSL.W #8,D3; cut to 8th bit
    LSR.W #8,D3; Isolate 7-0
    RTS
*-------------------------    
Bits7to4: 
    MOVE.W D4, D3;
    LSL.W #8,D3; cut to 8th bit
    MOVE.B #12, D0; shift 12 bits
    LSR.W D0,D3; isolate 7-4
    RTS
    
Bits7to6:
    MOVE.W D4, D3;
    LSL.W #8,D3; cut to 8th bit
    MOVE.B #14, D0; shift 14 bits
    LSR.W D0,D3; isolate 7-6
    RTS
    
Bits8to3:
    MOVE.W D4, D3;
    LSL.W #7,D3; cut to 9th bit
    MOVE.B #10, D0; shift 10 bits
    LSR.W D0,D3; isolate 8-3
    RTS
    
Bits8to4:
    MOVE.W D4, D3;
    LSL.W #7,D3; cut to 9th bit
    MOVE.B #11, D0; shift 11 bits
    LSR.W D0,D3; isolate 8-4
    RTS
    
Bits8to6:
    MOVE.W D4, D3;
    LSL.W #7,D3; cut to 9th bit
    MOVE.B #13, D0; shift 13 bits
    LSR.W D0,D3; isolate 8-6
    RTS
*----ISOLATE DEST---------    
Bits11to6:
    MOVE.W D4, D3;
    LSL.W #4,D3; cut to 12th bit
    MOVE.B #10, D0; shift 10 bits
    LSR.W D0,D3; isolate 11-6
    RTS
*-------------------------

     
Bits11to8:
    MOVE.W D4, D3;
    LSL.W #4,D3; cut to 12th bit
    MOVE.B #12, D0; shift 12 bits
    LSR.W D0,D3; isolate 11-8
    RTS

*----ISOLATE DEST REG-----      
Bits11to9:
    MOVE.W D4, D3;
    LSL.W #4,D3; cut to 12th bit
    MOVE.B #13, D0; shift 13 bits
    LSR.W D0,D3; isolate 11-9
    RTS
*-------------------------


INVALID_INSTR:
        LEA         ERROR_INSTR, A6
        MOVE.B      #14, D0
        TRAP        #15
        BRA         DONE
        
JUMP_OP_CODE:
*         JMP    JUMP_0
*         JMP    JUMP_1
*         JMP    JUMP_4
*         JMP    JUMP_5
*         JMP    JUMP_6
*         JMP    JUMP_7
*         JMP    JUMP_8
*         JMP    JUMP_9
*         JMP    JUMP_B
*         JMP    JUMP_C
*         JMP    JUMP_D
*         JMP    JUMP_E
        
         
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

             
*0000 - ORI      
JUMP_0:
        *ORI/MOVE/MOVEA
        JSR     Bits11to8;
        CMP.B   #$0, D3  ;
        BEQ     OP_CODE_ORI;
        
        BRA INVALID_INSTR   
        
*0001 - MOVEA/MOVE       
JUMP_1:
        CMP.B       #$1, D3 ;First 4 bits:  0001
        BNE         JUMP_2
        JSR         OP_CODE_BASE_MOVE
        JSR         EA_MOVE 
        
        BRA INVALID_INSTR

*0010 - NOP, MOVEM, LEA
JUMP_2:             ; MOVE.L or MOVEA.L
        CMP.B       #$2, D3 ;First 4 bits:  0010
        BNE         JUMP_3
        JSR         ISOLATE_DESTM
        CMP.B       #$1, D3 
        BEQ         J_MOVEA_L
        CMP.B       #$2, D3 
        BEQ         J_MOVE_L
        JSR         EA_MOVE 
        BRA INVALID_INSTR

        
*0011
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




*0010 - NOP, MOVEM, LEA        
JUMP_4:
        CLR.L       D3
        MOVE.W      D4, D3
        CMP.W  #$4E71, D3 ;NOP 
        BEQ OP_CODE_NOP
        
        JSR     Bits7to6     ;
        CMP.B  #2,D3
        BEQ    OP_CODE_JSR ;JSR
        
        JSR     Bits8to6     ;
        CMP.B  #7,D3
        BEQ    OP_CODE_LEA ;LEA
                
        BRA INVALID_INSTR

*0101 - ADDQ       
JUMP_5:
        CLR.L       D3
        MOVE.L      D4, D3
        BTST        #8,D3 ;
        BEQ         OP_CODE_ADDQ ; 
        BRA INVALID_INSTR 

*0110 - BRA, BSR
JUMP_6:
        JSR     Bits11to8     ;
        CMP.B   #0, D3        ;
        BEQ     OP_CODE_BRA   ; 
        CMP.B   #1, D3        ;
        BEQ     OP_CODE_BSR   ;
        
        BRA INVALID_INSTR
        
                
JUMP_7:
 *MOVEQ HAS NO SIZE, KEEP DATA REGISTER IN TRACK OF SIZES?
    LEA         MOVEQ_MSG, A1
    MOVE.B      #14, D0
    TRAP        #15
    BRA DONE

*1000 - DIVU,DIVS,OR   
JUMP_8:
    JSR       Bits8to6  ;
    CMP.P     #3, D3    ;
    BEQ       OP_CODE_DIVU;
    CMP.P     #7, D3    ;
    BEQ       OP_CODE_DIVS;
    BRA INVALID_INSTR
    
*1001 - SUB
JUMP_9:
    JSR     Bits8to4  ;
    ANDI.B  #%00010011,D3       ;If index is 0, mask
    CMP.B   #%00010000,D3
    BEQ     INVALID_INSTR       ;
    BRA     OP_SUB              ;

*1011 - CMP
JUMP_B:
    JSR     Bits8to6  ;
    ;CHECKING OPMODE FIELD
    CMP.B   #0, D3    ;
    BEQ     OP_CODE_CMP ;
    CMP.B   #1, D3    ;
    BEQ     OP_CODE_CMP ;
    CMP.B   #2, D3    ;
    BEQ     OP_CODE_CMP ;
    BRA INVALID_INSTR

*1100 - MULU
JUMP_C:
    JSR     Bits8to6  ;
    CMP     #3, D3    ;
    BEQ     OP_CODE_MULU ;
    CMP     #7, D3    ;
    BEQ     OP_CODE_MULS ;
    BRA INVALID_INSTR

*1101 - ADD/ADDA
JUMP_D:
    JSR     Bits8to4  ;
    ANDI.B  #%00010011,D3       ;If index is 0, mask
    CMP.B   #%00010000,D3
    BEQ     INVALID_INSTR       ;
    
    JSR     Bits7to6  ;
    CMP.B   #3, D3
    BEQ     OP_CODE_ADDA
    
    BRA     OP_CODE_ADD
    
        
*1110 - ASL, ASR 
JUMP_E:
    JSR     Bits11to6  ;
    ANDI.B  #%00111111,D3
    JMP MEM_SHIFT
               
MEM_SHIFT:
    CMP.B   #%00000011,D3
    BEQ     OP_CODE_ASR
    CMP.B   #%00000111,D3
    BEQ     OP_CODE_ASL 
    ANDI.B  #%00111011,D3
    CMP.B   #%00010011,D3
    BEQ INVALID_INSTR  
    BRA REG_COUNT 
        
REG_COUNT:
       JSR     Bits8to3  ; 
    ANDI.B  #%00100011,D3   ;
    CMP.B   #0,D3
    BEQ     OP_CODE_ASR     ;
    CMP.B   #%00100000,D3
    BEQ     OP_ASL
    BRA INVALID_INSTR  

        
       



        ;  Move valid sizes: 00, 11 10
        ;  MoveA valid sizes: 11, 10
        ; Code = 103C




; Functions to help isolate bits
; 0000 000X XX00 0000
; MOVE = 0011/0010 XXXY YYXX XXXX
; MOVEA = 0011/0010 XXX0 01XX XXXX
*ISOLATE_DESTM:
*        CLR.L       D3          
*        MOVE.W      D4,D3 ; D3 = YYYY YYYX XXYY YYYY
*        LSL.W       #7,D3 ; Shift left 7 bits to 0 out those values  D3 = XXXY YYYY Y000 0000 
*        MOVE.B      #13,D1
*        LSR.W       D1,D3 ; Shift right 13. 7 to compensate for previous shift and another 6 on top; XXXY YYYY Y000 0000  => 0000 0000 0000 0XXX
*        RTS 




        
        
        
; MOVE/MOVEA BLOCK ----------------------------------
OP_CODE_BASE_MOVE:
        ; This should only execute for Move.B
        LEA         MOVE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         EA_MOVE;
           


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
ADD_BYTE:
    ADD.B #1, D3 ; 1 BYTE
    RTS
    
ADD_WORD:
    ADD.B #2, D3 ; 2 BYTES
    RTS

ADD_LONG:
    ADD.B #4, D3 ; 4 BYTES
    RTS

WRONG_SIZE:
    LEA WRONG_S, A1
    MOVE.B      #14, D0
    TRAP        #15


; END MOVE BLOCK ------------------------------

*ADDQ - 0101, BScc, Scc
*-------------------------------------------------------------        
OP_CODE_ADDQ:
        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         Bits7to6  ;
        MOVE        #5, TAB
        JSR         SizeTwoBits ;
 *EA STUFF, MAYBE CHECK FOR DISPLACEMENT COUNT?
        


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
        JSR         PRINT_CRLF
        RTS

OP_CODE_JSR:
        LEA         JSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #7, TAB
        *STORE DEST AND STORE IN REGISTER
        *EA
        JSR         PRINT_CRLF
        RTS

        
OP_CODE_LEA:
        LEA         LEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #7, TAB
        *STORE DEST AND STORE IN REGISTER
        *EA
        JSR         PRINT_CRLF
        RTS





*MOVEM - 0100
*-------------------------------------------------------------
OP_CODE_MOVEM:
        LEA         MOVEM_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
*CHECK FOR FURTHER VALIDATION



*BRA/BSR - 0110
*-------------------------------------------------------------
OP_CODE_BRA:
        LEA         BRA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        *CONNECT TO RTS
        
OP_CODE_BSR:
        LEA         BSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15



*MOVEQ - 0111
*-------------------------------------------------------------
OP_CODE_MOVEQ:
        LEA         MOVEQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE #5, TAB
        JSR PRINT_TAB
        
 *PRINT IMMEDIATE DATA       
        LEA         POUND, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         DOLLAR, A1
        MOVE.B      #14, D0
        TRAP        #15
 *DISPLAY HEX, COMMA, DESTINATION AND SOURCE SHOULD BE SAVED AND PRINTED USING EA
        




*MULU - 1100
*-------------------------------------------------------------
OP_CODE_MULU:
        LEA         MULU_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B #1, STORE_SIZE
        
        MOVE #6, TAB    ;PRINT SPACE BETWEEN OP AND EA
        JSR PRINT_TAB

*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG
*PRINT SOURCE AND DEST EA



*ADD/ADDA - 1101
*-------------------------------------------------------------
OP_CODE_ADD:
        LEA         ADD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         Bits7to6  ;
        MOVE        #5, TAB
        JSR         SizeTwoBits ;
        BTST        #8, (A3)    ;EA = 1, DN=0
        BEQ         AddDnMode
        BRA         AddEAMode
*ADD <ea> + Dn --> Dn
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG 
AddDnMode:


*ADD Dn + <ea> --> <ea>
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG
AddEAMode:
        

*PRINT ADD EA

   
OP_CODE_ADDA:
        LEA         ADDA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         Bits7to6  ;
        MOVE        #4, TAB
        JSR         SizeThreeBits ;
        
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG        
*PRINT  EA

*ASL/ASR - 1110
*-------------------------------------------------------------
OP_CODE_ASL:
        LEA         ASL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         ROT_SHIFT
OP_CODE_ASR:
        LEA         ASR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         ROT_SHIFT

*MEMORY SHIFTS, WORK WITH EA
ROT_SHIFT:
        



*DIVU - 1000
*-------------------------------------------------------------
OP_CODE_DIVU:
        LEA         DICU_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B #1, STORE_SIZE
        
        MOVE #5, TAB    ;PRINT SPACE BETWEEN OP AND EA
        JSR PRINT_TAB
        
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG        
*PRINT EA




*SUB - 1001
*-------------------------------------------------------------
OP_CODE_SUB:
        LEA         SUB_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B #1, STORE_SIZE
        
        MOVE #5, TAB    ;PRINT SPACE BETWEEN OP AND EA
        JSR PRINT_TAB
        
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG        
*PRINT EA






*CMP - 1011
*-------------------------------------------------------------
OP_CODE_CMP:
        LEA         CMP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE        #5, TAB
        JSR         SizeTwoBits ;
        
        
*ISOLATE BITS AND SAVE SOURCE MODE REG, DEST MODE REG        
*PRINT EA








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
POUND:       DC.B        '#',0
DOLLAR:       DC.B        '$',0
PERCENT:       DC.B        '%',0
BREAK:      CR,LF,0
*length of space needed for parsing
TAB:          DS.B        1
*store size of opcode
STORE_SIZE:     DS.B        1

ERROR_INSTR:    DC.B  'INVALID INSTRUCTION',0
; Size messages

WRONG_S:    DC.B    'INVALID OPCODE SIZE', 0

BYTE_MSG:       DC.B        '.B',0
WORD_MSG:       DC.B        '.W',0
LONG_MSG:       DC.B        '.L',0





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
