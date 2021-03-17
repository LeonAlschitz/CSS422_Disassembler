*-----------------------------------------------------------
* Title      :  Disassembler
* Written by :  Leon Alschitz and Sarah Weheli
* Date       :  03/16/2021
* Description:  A program that can read code in memory and can then print it out
*               as human readable code
*-----------------------------------------------------------
    ORG    $1000

    
; A3 will store starting address
; A4 will store ending address
; A5 will be used for paging
; D0 is used to store values that will get compared
    
START:

        JSR         CLEAR_ALL_REG
        
        LEA         GREETING_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        BRA         START_ADDR_CHECK
        
START_ADDR_CHECK:
         ;   Ask user to enter valid starting address, convert from ascii to hex and then store it in A3                 
        LEA         START_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         STA_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15             ; D1 has the length of the address
        
        
        CLR.L       D2
        CLR.L       D4
        CLR.L       D7
        JSR         CONVERT_ASCII
        
        MOVE.B      D7, D4
        JSR         Bit0        
        CMP.B       #0, D2
        
        BNE         START_ERROR
        BRA         SAVE_START

SAVE_START:
        MOVEA.L     D7, A3
        MOVEA.L     A3, A5

        ADD.L       #32, A5
        BRA         END_ADDR_CHECK

START_ERROR:
        LEA         BAD_ADDR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         START_ADDR_CHECK 

END_ERROR:
        LEA         BAD_ADDR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         END_ADDR_CHECK   

END_ADDR_CHECK:        
        ;   Ask user to enter valid ending address, convert from ascii to hex and then store it in A4 
        
        LEA         END_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         END_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15
        
        CLR.L       D2
        CLR.L       D4
        CLR.L       D7
        JSR         CONVERT_ASCII

        JSR         CHECK_ODD
        BNE         END_ERROR
        
        BRA         SAVE_END
        
CHECK_ODD:
        MOVE.B      D7, D4
        JSR         Bit0        
        CMP.B       #0, D2
        RTS

CHECK_DATA:
        
        RTS

SAVE_END:
        MOVEA.L     D7, A4
        BRA         FILE_LOOP
    
        
CLEAR_ALL_REG:
        CLR.L       D0
        CLR.L       D1
        CLR.L       D2
        CLR.L       D3
        CLR.L       D4
        CLR.L       D5
        CLR.L       D6
        CLR.L       D7

        MOVEA.L     #$00000000, A0
        MOVEA.L     #$00000000, A1
        MOVEA.L     #$00000000, A2
        MOVEA.L     #$00000000, A3
        MOVEA.L     #$00000000, A4
        MOVEA.L     #$00000000, A5
        MOVEA.L     #$00000000, A6
        RTS

CONVERT_ASCII:                  ; Convert Ascii values to Hex. 00011111 00011110 00100001 00101011 = 31 30 33 43. 31 30 33 43 => 0001 0000 0011 1100 = 1 0 3 C
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
        MOVE.B      (A1)+, D2   ; Gives D2 the next Byte from A1
        MOVE.B      #$39, D0    ; Moves 39 into D3, Ascii Characters after 39 are not letters
        CMP.B       D0, D2
        BLE         NUM_ASCII   ; data in D2 is less than 39, Most likely a number
        BRA         LET_ASCII   ; If not a number, then it is an ASCII Letter

ASCII_DONE:
        RTS
NUM_ASCII:
        SUBI.B      #$1, D1
        MOVE.B      #$30, D0
        SUB.B       D0, D2      ; ASCII numbers start at 30. 30 = 0, 31 = 1, etc
        ADD.B       D2, D7      ; new ASCII number stored at D7
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
        ASL.L       #4, D7
        BRA         CONVERT_ASCII
LET_ASCII:
        SUBI.B      #$1, D1
        MOVE.B      #$37, D0
        SUB.B       D0, D2      ; Hex letters we care about are from A-F, we can use math do achieve this
        ADD.B       D2, D7      ; 41 is used to represent A in Hex. Hexadecimal subtraction: 41 - 37 = A
                                ; 46 is used to represent F in Hex. 46 - 37 = F        
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
        ASL.L       #4, D7
        BRA         CONVERT_ASCII

PRINT_ADDRESS:
        CLR.L       D1
        CLR.L       D2
        MOVE.L      A3, D2
  
        JSR         FLIP_START
        MOVE.L      D7, D3

        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        
        MOVE.B      #$8, D1
        BRA         PRINT_ADDRESS_LOOP

        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        RTS
        
FLIP_START:        
        CLR.L       D1
        CLR.L       D7
        MOVE.B      #$8, D1
        JSR         FLIP_LOOP
        RTS
        
FLIP_LOOP:

        ; SIMHALT
        
        CMPI.B      #$0, D1
        BEQ         FLIP_DONE
        SUBI.B      #$1, D1
        ASL.L       #4, D7
        
        CLR.L       D5
        
        MOVE.B      D2, D5
        
        MOVE.B      #28,D0    
        LSL.L       D0, D5     
        ROL.L       #4, D5
        
        ADD.B       D5, D7
        
        
        ASR.L       #4, D2
        
        BRA         FLIP_LOOP

FLIP_DONE:
        RTS


        

PRINT_ADDRESS_LOOP:
        ; SIMHALT
        
        CMPI.B      #$0, D1
        BEQ         PRINT_ADDRESS_EXIT
        
        
        SUBI.B      #$1, D1
        
        MOVE.B      D3, D2
        MOVE.B      #28,D0    
        LSL.L       D0,D2     
        ROL.L       #4,D2 
        
        
        ASR.L       #4, D3
        
        
        CMP.B       #0,D2
        BEQ         PRINT_ADR0
        CMP.B       #1,D2
        BEQ         PRINT_ADR1
        CMP.B       #2,D2
        BEQ         PRINT_ADR2
        CMP.B       #3,D2
        BEQ         PRINT_ADR3
        CMP.B       #4,D2
        BEQ         PRINT_ADR4
        CMP.B       #5,D2
        BEQ         PRINT_ADR5
        CMP.B       #6,D2
        BEQ         PRINT_ADR6
        CMP.B       #7,D2
        BEQ         PRINT_ADR7
        CMP.B       #8,D2
        BEQ         PRINT_ADR8
        CMP.B       #9,D2
        BEQ         PRINT_ADR9
        CMP.B       #$A,D2
        BEQ         PRINT_ADRA
        CMP.B       #$B,D2
        BEQ         PRINT_ADRB
        CMP.B       #$C,D2
        BEQ         PRINT_ADRC
        CMP.B       #$D,D2
        BEQ         PRINT_ADRD
        CMP.B       #$E,D2
        BEQ         PRINT_ADRE
        CMP.B       #$F,D2
        BEQ         PRINT_ADRF



        BRA         PRINT_ADDRESS_LOOP
        

        

PRINT_ADDRESS_EXIT:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        RTS
        
PRINT_ADR0:
        LEA         ZERO_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR1:
        LEA         ONE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR2:
        LEA         TWO_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR3:
        LEA         THREE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR4:
        LEA         FOUR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR5:
        LEA         FIVE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR6:
        LEA         SIX_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR7:
        LEA         SEVEN_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR8:
        LEA         EIGHT_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADR9:
        LEA         NINE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRA:
        LEA         A_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRB:
        LEA         B_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRC:
        LEA         C_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRD:
        LEA         D_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRE:
        LEA         E_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP
PRINT_ADRF:
        LEA         F_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         PRINT_ADDRESS_LOOP


FILE_LOOP:
        CLR.L       D0
        CLR.L       D1
        CLR.L       D2
        CLR.L       D3
        CLR.L       D4
        CLR.L       D5
        CLR.L       D6
        CLR.L       D7
        



        ;       Add branch here that will take the current address in A3
        ;       Turn it into characters and print it to the screen with space
        JSR         PRINT_ADDRESS
        
        
        MOVE.W      (A3)+, D4
        ; SIMHALT
        JSR         JUMP_OP_CODE
        
        LEA         NEW_LINE, A1
        MOVE.B      #14, D0
        TRAP        #15


        CMP.L      A3, A4
        ;       If our pointer is at the end or beyond, BRA to DONE
        BEQ         DONE_CHECK
        BLE         DONE_CHECK
        

        CMP.L       A3, A5
        BEQ         PRINT_DELAY
        BLE         PRINT_DELAY


       
        BRA         FILE_LOOP



PRINT_DELAY:
        ; SIMHALT
        LEA         NEXT_PAGE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        

        MOVE.B      #5, D0
        TRAP        #15

        CMPI.B      #13, D1
        BNE         PRINT_DELAY

        ADD.L       #32, A5
        BRA         FILE_LOOP


DONE_CHECK:
        LEA         REPEAT_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        

        MOVE.B      #5, D0
        TRAP        #15

        CMPI.B      #13, D1
        BNE         DONE
        
        BRA         START

DONE:   
        LEA         GOODBYE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        MOVE.B      #9, D0
        TRAP        #15
        

*---------OPCODE functions-----------------------
*------------------------------------------------
*------------------------------------------------
*------------------------------------------------

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
        CMP.B       #11, D3
        BEQ         JUMP_B ; 
        CMP.B       #12, D3
        BEQ         JUMP_C ;
        CMP.B       #13, D3
        BEQ         JUMP_D ;
        CMP.B       #14, D3
        BEQ         JUMP_E ;
        BRA         JUMP_ERROR




       
        
*0000 - ORI      
JUMP_0:
        *ORI
        CLR.L       D2
        JSR         Bits11to8
        CMP.B       #$0, D2  
        BEQ         OP_CODE_ORI
        CMP.B       #$2, D2  
        BEQ         OP_CODE_ANDI
        CMP.B       #$4, D2  
        BEQ         OP_CODE_SUBI
        CMP.B       #$6, D2  
        BEQ         OP_CODE_ADDI
        CMP.B       #$A, D2  
        BEQ         OP_CODE_EORI
        CMP.B       #$C, D2  
        BEQ         OP_CODE_CMPI
        
        BRA         INVALID_INSTR
        RTS
        
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

*0100 - NOP, LEA, JSR
JUMP_4:

        CLR.L       D2
        MOVE.W      D4, D2
        CMP.W       #$4E71, D2 ;NOP 
        BEQ         OP_CODE_NOP
        CMP.W       #$4E72, D2 ;STOP 
        BEQ         OP_CODE_STOP
        CMP.W       #$4E73, D2 ;RTE 
        BEQ         OP_CODE_RTE
        CMP.W       #$4E75, D2 ;RTS 
        BEQ         OP_CODE_RTS
        
        
        JSR         Bits11to8
        CMP.B       #2, D2
        BEQ         OP_CODE_CLR
        CMP.B       #6, D2
        BEQ         OP_CODE_NOT
        *CMP.B       #8, D2
        *BEQ         OP_CODE_EXT

        JSR         Bits9to7
        CMP.B       #1, D2
        BEQ         OP_CODE_MOVEM
        
        
        
        
        JSR         Bits8to6     ;
        CMP.B       #7, D2
        BEQ         OP_CODE_LEA ;LEA        

        CMP.B       #2, D2
        BEQ         OP_CODE_JSR ;JSR
        CMP.B       #3, D2
        BEQ         OP_CODE_JMP ;JMP
        
        


        
        
        BRA INVALID_INSTR
        
        RTS   




*0101 - ADDQ       
JUMP_5:
        CLR.L       D2
        MOVE.L      D4, D2
        BTST        #8,D2 
        BEQ         OP_CODE_ADDQ  
        BRA         OP_CODE_SUBQ
        RTS  
*BRA, BSR        
JUMP_6:
        CLR.L       D2
        JSR     Bits11to8     ;
        CMP.B   #0, D2        ;
        BEQ     OP_CODE_BRA   ; 
        CMP.B   #1, D2        ;
        BEQ     OP_CODE_BSR   ;
        CMP.B   #7, D2        ;
        BEQ     OP_CODE_BEQ   ;

        BRA INVALID_INSTR

        RTS  
*MOVEQ
JUMP_7:
        ; CLR.L       D2
        ; LEA         MOVEQ_MSG, A1
        ; MOVE.B      #14, D0
        ; TRAP        #15
        
        JSR         OP_CODE_MOVEQ
        
        ; BRA         INVALID_INSTR 
        RTS

*1000 - DIVU,DIVS   
JUMP_8:
        CLR.L       D2
        JSR         Bits8to6  ;
        CMP.B       #3, D2    ;
        BEQ         OP_CODE_DIVU ;
        CMP.B       #7, D2    ;
        BEQ         OP_CODE_DIVS ;
        BRA         OP_CODE_OR
        RTS

JUMP_9:
        JSR         OP_CODE_SUB


        RTS         

JUMP_A:
        BRA         INVALID_INSTR
        RTS 
JUMP_B:
        CLR.L       D2
        JSR         Bits8to6  ;
    ;CHECKING OPMODE FIELD
        CMP.B       #0, D2   ;
        BEQ         OP_CODE_CMP ;
        CMP.B       #1, D2    ;
        BEQ         OP_CODE_CMP ;
        CMP.B       #2, D2    ;
        BEQ         OP_CODE_CMP ;
        BRA         INVALID_INSTR
        RTS         

JUMP_C:
        CLR.L       D2
        JSR         Bits8to6  ;
        CMP         #3, D2    ;
        BEQ         OP_CODE_MULU ;
        CMP         #7, D2   ;
        BEQ         OP_CODE_MULS ;
        CMP         #8, D2   ;
        BEQ         OP_CODE_AND ;

        BRA         INVALID_INSTR
        RTS 

JUMP_D:
        CLR.L       D2
        JSR         Bits7to6  ;
        CMP.B       #3, D2    ;
        BEQ         OP_CODE_ADDA
        JMP         OP_CODE_ADD
        BRA         INVALID_INSTR
        RTS 
 
 
JUMP_E:
        CLR.L       D2
        
        JSR         Bits7to6

        CMP.B       #3, D2
        BEQ         OP_CODE_ASD_MEM
        
        BRA         OP_CODE_ASD_REG
        
        RTS  
         
JUMP_ERROR:       
        LEA         ERROR_OP_MSG, A1
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
Bits4to3:
        MOVE.W      D4, D2
        MOVE.B      #11, D0     ; Shift 11 bits
        LSL.W       D0, D2      ; cut to 5th bit
        MOVE.B      #14, D0     ; Shift 14 bits
        LSR.W       D0, D2      ; Isolate bits 4-3
        RTS
        
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

*----ISOLATE INSTRUCTION FIELD-----      
Bit0:
        MOVE.W      D4, D2
        MOVE.B      #15, D0
        LSL.W       D0, D2     
        MOVE.B      #15, D0     
        LSR.W       D0, D2     
        RTS

Bit5:
        MOVE.W      D4, D2
        MOVE.B      #10, D0
        LSL.W       D0, D2     
        MOVE.B      #15, D0     
        LSR.W       D0, D2     
        RTS
        
Bit6:
        MOVE.W      D4, D2
        MOVE.B      #11, D0
        LSL.W       D0, D2     
        MOVE.B      #15, D0     
        LSR.W       D0, D2     
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

*ORI/ANDI/SUBI/ADDI/EORI/CMPI - 0000
*-------------------------------------------------------------
OP_CODE_ORI:
        LEA         ORI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
        
OP_CODE_ANDI:
        LEA         ANDI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
        
OP_CODE_SUBI:
        LEA         SUBI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
        
OP_CODE_ADDI:
        LEA         ADDI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
        
OP_CODE_EORI:
        LEA         EORI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
        
OP_CODE_CMPI:
        LEA         CMPI_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT    
        JSR         ABS_DATASRC_EA
        RTS
*NOP/JSR/JMP/LEA/CLR/NOT/EXT - 0100
*-------------------------------------------------------------
OP_CODE_CLR:
        LEA         CLR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         OPMODE_ASHIFT
        JSR         EA_GENERIC

        RTS
OP_CODE_NOT:
        LEA         NOT_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         OPMODE_ASHIFT
        JSR         EA_GENERIC

        RTS
OP_CODE_EXT:
        LEA         EXT_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         OPMODE_ASHIFT
        JSR         EA_GENERIC

        RTS


OP_CODE_NOP:
        LEA         NOP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
OP_CODE_STOP:
        LEA         STOP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3
        JSR         DATA_TABLE

        RTS        
        
OP_CODE_RTE:
        LEA         RTE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
OP_CODE_RTS:
        LEA         RTS_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
           

OP_CODE_JSR:
        LEA         JSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_GENERIC

        RTS
        
OP_CODE_JMP:
        LEA         JMP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_GENERIC

        RTS        
        
OP_CODE_LEA:
        LEA         LEA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        CLR.L       D3
        MOVE.B      #2, D3

        *EA
        JSR         EA_ASRC

        RTS

*MOVEM/EXT - 0100
*-------------------------------------------------------------
OP_CODE_MOVEM:
        ;JSR         Bits9to7 ;check for MOVEM and EXT
        ;CMP.B       #1, D2   ;
        ;BEQ         MOVEM_OR_EXT
        ;JMP         INVALID_INSTR 
        BTST        #6, D2
        BEQ         MOVEM_W
        BRA         MOVEM_L
        
        
        RTS
        
        
        
MOVEM_W:
        LEA         MOVEM_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         WORD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3
  
        JSR         EA_MOVEM
        RTS
        
MOVEM_L:
        LEA         MOVEM_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         LONG_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        MOVE.B      #2, D3
  
        JSR         EA_MOVE      
        RTS               


*ADDQ/SUBQ - 0101, BScc, Scc
*-------------------------------------------------------------        
OP_CODE_ADDQ:
        LEA         ADDQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT
        
        JSR         EA_ADDQ
        
        RTS
OP_CODE_SUBQ:
        LEA         SUBQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ASHIFT
        
        JSR         EA_ADDQ
        
        RTS        
 
*CMP - 1011
*-------------------------------------------------------------
OP_CODE_CMP:

        LEA         CMP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE
        JSR         REVERSESRC_EA
        
        RTS
        
*DIVU - 1000
*-------------------------------------------------------------
OP_CODE_DIVU:
        LEA         DIVU_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3        
        JSR         EA_DSRC
        
        RTS
        
OP_CODE_DIVS:
        LEA         DIVS_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #1, D3        
        JSR         EA_DSRC
        
        RTS
OP_CODE_OR:
        LEA         OR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE
        
        JSR         REVERSESRC_EA
        
        RTS

*SUB - 1001
*-------------------------------------------------------------
OP_CODE_SUB:
        LEA         SUB_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE
        
        JSR         REVERSESRC_EA
        
        RTS
        
*Byte Word Long
*000 001 010 100 101 110
*Operation
*Dn – < ea > ? Dn < ea > – Dn ? < ea >        
OPMODE:
        JSR         Bits8to6
        CMP.B       #0, D2
        BEQ         PRINT_BYTE
        CMP.B       #4, D2
        BEQ         PRINT_BYTE
        
        CMP.B       #1, D2
        BEQ         PRINT_WORD
        CMP.B       #5, D2
        BEQ         PRINT_WORD
        
        CMP.B       #2, D2
        BEQ         PRINT_LONG
        CMP.B       #6, D2
        BEQ         PRINT_LONG
        
        JSR         WRONG_SIZE
        
OPMODE_ADDA:
        JSR         Bits8to6
        CMP.B       #3, D2
        BEQ         PRINT_WORD 
        CMP.B       #7, D2
        BEQ         PRINT_LONG
        JSR         WRONG_SIZE        

OPMODE_ASHIFT:
        JSR         Bits7to6
        CMP.B       #0, D2
        BEQ         PRINT_BYTE
        CMP.B       #1, D2
        BEQ         PRINT_WORD
        CMP.B       #2, D2
        BEQ         PRINT_LONG

        JSR         WRONG_SIZE
        
PRINT_BYTE:
        LEA         BYTE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #0, D3
        RTS

PRINT_WORD:
        LEA         WORD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #1, D3
        RTS

PRINT_LONG:
        LEA         LONG_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #2, D3
        RTS

WRONG_SIZE:
        LEA         ERROR_SIZE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        RTS
        
*BRA/BSR/BEQ - 0110
*-------------------------------------------------------------
OP_CODE_BRA:
        LEA         BRA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_BRA
        
        RTS

OP_CODE_BSR:
        LEA         BSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_BRA
        
        RTS
OP_CODE_BEQ:
        LEA         BEQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_BRA
        
        RTS
        
        
        
*MOVEQ - 0111
*-------------------------------------------------------------
OP_CODE_MOVEQ:
        LEA         MOVEQ_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_MOVEQ
        
        RTS

*MULU - 1100
*-------------------------------------------------------------
OP_CODE_MULS:
        LEA         MULS_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         REVERSESRC_EA
        
        RTS
        
OP_CODE_MULU:
        LEA         MULU_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         REVERSESRC_EA
        RTS
OP_CODE_AND:
        LEA         AND_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         OPMODE
        
        JSR         REVERSESRC_EA
        RTS        

*ADD/ADDA - 1101
*-------------------------------------------------------------
OP_CODE_ADD:
        LEA         ADD_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE
        JSR         EA_ADD
        
        RTS
        
OP_CODE_ADDA:
        LEA         ADDA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         OPMODE_ADDA
        JSR         EA_ASRC
        
        RTS
        
      
*ASL/ASR/LSL/LSR/ROL/ROR - 1110
*-------------------------------------------------------------

OP_CODE_ASD_REG:
        CLR.L       D2
        MOVE.W      D4, D2
        BTST        #8, D2
        BEQ         RIGHT_REG
        BRA         LEFT_REG
        RTS

        RTS
LEFT_REG:
        CLR.L       D2
        JSR         Bits4to3
        CMP.B       #0, D2
        BEQ         ASL_REG
        CMP.B       #1, D2
        BEQ         LSL_REG
        CMP.B       #3, D2
        BEQ         ROL_REG
        
        RTS
        
RIGHT_REG:
        CLR.L       D2
        JSR         Bits4to3
        CMP.B       #0, D2
        BEQ         ASR_REG
        CMP.B       #1, D2
        BEQ         LSR_REG
        CMP.B       #3, D2
        BEQ         ROR_REG
        
        RTS   
ASL_REG:
        LEA         ASL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS
LSL_REG:
        LEA         LSL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS
ROL_REG:
        LEA         ROL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS
ASR_REG:
        LEA         ASR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS
LSR_REG:
        LEA         LSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS
ROR_REG:
        LEA         ROR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        JSR         OPMODE_ASHIFT
        JSR         EA_AS
        
        RTS

OP_CODE_ASD_MEM:
        CLR.L       D2
        MOVE.W      D4, D2
        BTST        #8, D2
        BEQ         RIGHT_MEM
        BRA         LEFT_MEM
        RTS

        RTS
LEFT_MEM:
        BRA         ASL_MEM

        RTS
        
RIGHT_MEM:

        BRA         ASR_MEM

        RTS        

ASL_MEM:
        LEA         ASL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15        
        JSR         EA_GENERIC        
        RTS
LSL_MEM:
        LEA         LSL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         EA_GENERIC
        RTS        
ROL_MEM:
        LEA         ROL_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15        
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15      
        JSR         EA_GENERIC        
        RTS
ASR_MEM:
        LEA         ASR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15        
        JSR         EA_GENERIC        
        RTS
LSR_MEM:
        LEA         LSR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15 
        JSR         EA_GENERIC
        RTS        
ROR_MEM:
        LEA         ROR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15        
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15      
        JSR         EA_GENERIC        
        RTS

*------Effective Addressing Functions------------
*------------------------------------------------
*------------------------------------------------
*------------------------------------------------

; D3 = OP size. ie. Byte, Word, Long
; D4 = Original hex code
; D5 = Current Mode being isolated
; D6 = Current Register being isolated

; A3 will store starting address
; A4 will store ending address



; based on the size of the move operation Print out an amount of data as is.
; MOVE.B will print out the operation and 1 additional Byte after the OP code as text.
EA_MOVE:
        CLR.L       D5
        CLR.L       D6
        JSR         Bits5to3
        MOVE.B      D2, D5
        JSR         Bits2to0
        MOVE.B      D2, D6
        JSR         MODE_TABLE
        
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        CLR.L       D5
        CLR.L       D6

        JSR         Bits8to6
        MOVE.B      D2, D5
        JSR         Bits11to9
        MOVE.B      D2, D6
        JSR         MODE_TABLE
        
        RTS

; Generic Effective addressing function that get called by a lot of different op codes        
EA_GENERIC:
    
        JSR         Bits5to3
        MOVE.B      D2, D5
        JSR         Bits2to0
        MOVE.B      D2, D6
        JSR         MODE_TABLE

        RTS
        
        ; #data, ea
DATASRC_EA:
        
        JSR         J_ABS_TABLE
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_GENERIC
        
        RTS
        
        ; #$data, ea
ABS_DATASRC_EA:

        JSR         DATA_TABLE
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_GENERIC



        RTS        


        ; ea, #data
REVERSESRC_EA:
    
        JSR         EA_GENERIC
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         Bits11to9
        MOVE.B      D2, D6
        JSR         MODE_TABLE
        RTS        
        ; effective addresing for add and similair op codes
EA_ADD:
        JSR         EA_GENERIC
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15

        JSR         Bits11to9
        MOVE.B      D2, D6
        JSR         Bits8to6
        MOVE.B      D2, D5
        
        JSR         MODE_TABLE
        RTS  
        
        
        
        ; ea, A source
EA_ASRC:
        JSR         EA_GENERIC
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.B      #1, D5
        JSR         Bits11to9
        MOVE.B      D2, D6
        
        JSR         MODE_TABLE

        RTS
        ; ea, D source
EA_DSRC:
        JSR         EA_GENERIC
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.B      #0, D5
        JSR         Bits11to9
        MOVE.B      D2, D6
        
        JSR         MODE_TABLE

        RTS

*-----------Effective addressing for Arithmetic shift functions----------
EA_AS:

        JSR         Bit5
        CMP.B       #0, D2
        BEQ         AS_COUNT
        
        BRA         AS_REGISTER
        
        RTS    
AS_FIX:
        MOVE.B      #8, D2
        RTS
        
AS_COUNT:
        LEA         POUND_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        JSR         Bits11to9
        CMP.B       #0, D2
        BEQ         AS_FIX
        MOVE.B      D2, D6
        JSR         DISPLAY_REG
        
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #0, D5
        JSR         Bits2to0
        MOVE.B      D2, D6
        
        JSR         MODE_TABLE


        RTS
        
AS_REGISTER:

        LEA         MODE_0_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        JSR         Bits11to9
        CMP.B       #0, D2
        BEQ         AS_FIX
        MOVE.B      D2, D6
        JSR         DISPLAY_REG

        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        MOVE.B      #0, D5
        JSR         Bits2to0
        MOVE.B      D2, D6
        
        JSR         MODE_TABLE

        RTS 
*---------------Effective addressing for Movem-------------------    
EA_MOVEM:
        MOVE.L      D4, D2
        BTST        #10,D2 
        BEQ         MOVEM_REG
        BRA         MOVEM_SRC

        RTS
        ; D, A
MOVEM_REG:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        CLR.L       D3
        CLR.L       D5
        CLR.L       D6
        CLR.L       D7
        
        MOVE.W      (A3)+, D2
        JSR         MOVEM_START
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         Bit6
        MOVE.B      D2, D3
        
        
        JSR         EA_GENERIC
        RTS
        ; A, D
MOVEM_SRC:

        JSR         Bit6
        MOVE.B      D2, D3

        JSR         EA_GENERIC
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        CLR.L       D3
        CLR.L       D5
        CLR.L       D6
        CLR.L       D7
        
        MOVE.W      (A3)+, D2
        JSR         MOVEM_START

        RTS        

*-----------MOVEM------------------------------------

MOVEM_START:
        MOVE.B      #4, D3
        CLR.L       D5
        CLR.L       D6
        CLR.L       D7
        JSR         MOVEM_LOOP
        RTS
        
; D5 helps identify reg out of group
; D6 helps identify Group out of word
; D7 keeps track of the number of reg's    
MOVEM_LOOP:

        CMP.B       #0, D3
        BEQ         MOVEM_DONE
        SUB         #1, D3


        MOVE.B      D2, D5
        ASR.L       #4, D2
        
        CMP.B       #1, D5
        BEQ         MOVEM_0
        CMP.B       #2, D5
        BEQ         MOVEM_1
        CMP.B       #4, D5
        BEQ         MOVEM_2
        CMP.B       #8, D5
        BEQ         MOVEM_3
        
        ADD         #1, D6
        BRA         MOVEM_LOOP


MOVEM_DONE
        RTS 
       
MOVEM_0:
        MOVE.B      #0, D5   
        BRA         MOVEM_CHECK_PRINT
MOVEM_1:
        MOVE.B      #1, D5   
        BRA         MOVEM_CHECK_PRINT
MOVEM_2:
        MOVE.B      #2, D5   
        BRA         MOVEM_CHECK_PRINT        
MOVEM_3:
        MOVE.B      #3, D5   
        BRA         MOVEM_CHECK_PRINT

MOVEM_CHECK_PRINT:
        CMP.B       #0, D7
        BNE         MOVEM_DIVISOR
        BRA         MOVEM_PRINT_MODE        

MOVEM_DIVISOR:
        LEA         DIVISOR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         MOVEM_PRINT_MODE


MOVEM_PRINT_MODE:        
        ADD         #1, D7

        CMP.B       #0, D6
        BEQ         MOVEM_MODE0
        CMP.B       #1, D6
        BEQ         MOVEM_MODE1
        CMP.B       #2, D6
        BEQ         MOVEM_MODE2
        BRA         MOVEM_MODE3
        
        
MOVEM_MODE0:
        LEA         MOVEM0_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        MOVE.B      D5, D1
        MOVE.B      #$3, D0
        TRAP        #15
        ADD         #1, D6
        
        BRA         MOVEM_LOOP
MOVEM_MODE1:
        ADD         #4, D5
        LEA         MOVEM0_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        MOVE.B      D5, D1
        MOVE.B      #$3, D0
        TRAP        #15
        ADD         #1, D6
        
        BRA         MOVEM_LOOP        
MOVEM_MODE2:
        LEA         MOVEM1_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        MOVE.B      D5, D1
        MOVE.B      #$3, D0
        TRAP        #15
        ADD         #1, D6
        
        BRA         MOVEM_LOOP       
 
MOVEM_MODE3:
        ADD         #4, D5
        LEA         MOVEM1_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        MOVE.B      D5, D1
        MOVE.B      #$3, D0
        TRAP        #15
        ADD         #1, D6
        
        BRA         MOVEM_LOOP 
       
*-----------Effective Addressing for BRA/BSR/etc--------------
       
EA_BRA:

        JSR         Bits7to0
        CMP.B       #0, D2
        BEQ         BRA_WORD
        CMP.B       #$FF, D2
        BEQ         BRA_LONG
        
        BRA         BRA_BYTE

        RTS

BRA_BYTE:
        
        
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.L      A3, D5
        MOVE.W      D2, D6
        ; ADD.L       D5, D6

        MOVE.L      D6, D2
        JSR         FLIP_START
        
        SWAP        D7
        
        CLR.L       D2
        MOVE.B      #4, D1
        JSR         CONVERT_HEX
        RTS

BRA_WORD:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.L      A3, D5
        MOVE.W      (A3)+, D6
        ADD.L       D5, D6

        MOVE.L      D6, D2
        JSR         FLIP_START
        
        SWAP        D7
        
        CLR.L       D2
        MOVE.B      #4, D1
        JSR         CONVERT_HEX

        RTS
BRA_LONG:

        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.L      A3, D5
        MOVE.W      (A3)+, D6
        ADD.L       D5, D6

        MOVE.L      D6, D2
        JSR         FLIP_START
        
        SWAP        D7
        
        CLR.L       D2
        MOVE.B      #8, D1
        JSR         CONVERT_HEX
       
*------------Effective addressing for MoveQ------------------------       
        
EA_MOVEQ:

        
        MOVE.B      D4, D2
        
        LEA         DATA_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15

        JSR         FLIP_START
        

        SWAP        D7
        MOVE.B      #8, D1
        LSR.W       D1, D7
        MOVE.B      #2, D1
        
        JSR         CONVERT_HEX
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15

        MOVE.B      #0, D5
        JSR         Bits11to9
        MOVE.B      D2, D6

        JSR         MODE_TABLE

        RTS
*------------Effective addressing for AddQ------------------------  
EA_ADDQ:

        MOVE.B      #1, D1
        JSR         Bits11to9
        MOVE.B      D2, D7
        
        LEA         DATA_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15

        JSR         CONVERT_HEX

        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        JSR         EA_GENERIC

        RTS        


*-----------MODE_TABLE------------------------------------
; Possible modes Dn = 0,An = 1,(An) = 2,(An)+ = 3,-(An) = 4, Absolute Data = 7
MODE_TABLE:

        CMP.B       #0,D5
        BEQ         J_TBL_D
        CMP.B       #1,D5
        BEQ         J_TBL_A
        CMP.B       #2,D5
        BEQ         J_TBL_A_P
        CMP.B       #3,D5
        BEQ         J_TBL_A_INCR
        CMP.B       #4,D5
        BEQ         J_TBL_A_DECR
        CMP.B       #7,D5
        BEQ         J_ABS
        
        RTS
        ;   deal with errors here

J_ABS:
        JSR         J_ABS_TABLE
        RTS

J_TBL_A:
        LEA         MODE_1_MSG, A1 ; A#
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG

        RTS


J_TBL_D:
        LEA         MODE_0_MSG, A1 ; D#
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG
        RTS

J_TBL_A_P:

        LEA         MODE_A_MSG, A1 ; (A#)
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG
        
        LEA         MODE_A_1_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        
        RTS
    
J_TBL_A_INCR:
        LEA         MODE_A_MSG, A1 ; (A#)+
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG
        
        LEA         MODE_A_2_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
        
J_TBL_A_DECR:
        LEA         MODE_MINUS_MSG, A1 ; -(A#)
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG
        
        LEA         MODE_A_1_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
        
        
*-----------Print_Register------------------------------------        
DISPLAY_REG:
        MOVE.B      D6, D1
        MOVE.B      #$3, D0
        TRAP        #15
        RTS

*-----------Absolute_addressing table-------------------------

J_ABS_TABLE:
        ; SIMHALT
        CMP.B       #0,D6
        BEQ         SUBCLASS_CHECK
            
        CMP.B       #1,D6
        BEQ         SUBCLASS_CHECK
            
        CMP.B       #4,D6
        BEQ         DATA_TABLE
            
        RTS
        
SUBCLASS_CHECK:
        MOVE.L      A3, A6
        MOVE.L      (A3)+, D1
        MOVE.L      A6, A3
        MOVE.L      #0, A6
        
        SWAP        D1
        
        CMP.W       #0, D1
        BEQ         J_SUBCLASS_0
        BRA         J_SUBCLASS_1

        
J_SUBCLASS_0:
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
       
        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        MOVE.L      (A3)+, D2
        

        JSR         FLIP_START

        CLR.L       D2
        SWAP        D7

        MOVE.B      #4, D1
        JSR         CONVERT_HEX
        


        RTS


J_SUBCLASS_1:
        ; SIMHALT
        LEA         SUBCLASS1_1, A1
        MOVE.B      #14, D0
        TRAP        #15

        CLR.L       D1
        CLR.L       D2
        CLR.L       D7


        
        MOVE.L      (A3)+, D2
        
        JSR         FLIP_START

        CLR.L       D2
        

        MOVE.B      #8, D1
        JSR         CONVERT_HEX


        LEA         SUBCLASS1_2, A1
        MOVE.B      #14, D0
        TRAP        #15
        
        RTS

;   Error
J_ABS_ERROR:
        RTS

*-----------Absolute_addressing_data_table-------------------------
;   Hard Coded Data
;   based on the OP code size, read the appropriate amount of data, and move pointer forward accordingly 

;   Size num 0 = Byte 1 = Word 2 Long

DATA_TABLE:
        ; SIMHALT
        LEA         DATA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15


        CMP.B       #0,D3 
        BEQ         DATA_B

        CMP.B       #1,D3 
        BEQ         DATA_W
        
        CMP.B       #2,D3 
        BEQ         DATA_L
        
        RTS

DATA_B:
        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        
        MOVE.W      (A3)+, D2
        * Only read first byte from the word 
        
        JSR         FLIP_START
        SWAP        D7
        ROR.L       #8,D7
        CLR.L       D2
        

        MOVE.B      #2, D1
        JSR         CONVERT_HEX



        RTS

DATA_W:
        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        
        MOVE.W      (A3)+, D2
        
        JSR         FLIP_START

        SWAP        D7

        CLR.L       D2
        
        MOVE.B      #4, D1
        
        
        JSR         CONVERT_HEX

        

        RTS

DATA_L:
        ; SIMHALT
        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        
        MOVE.L      (A3)+, D2
        
        JSR         FLIP_START

        CLR.L       D2
        

        MOVE.B      #8, D1
        JSR         CONVERT_HEX

        

        RTS


CONVERT_HEX:
        ; SIMHALT    
        CMPI.B      #$0, D1    
        BEQ         HEX_DONE
        
        SUBI.B      #$1, D1       

        CLR.L       D2
    
        MOVE.B      D7, D2
            
        MOVE.B      #28, D0    
        LSL.L       D0, D2     
        ROL.L       #4, D2
        
        ASR.L       #4, D7
        
        
        CMP.B       #0,D2
        BEQ         PRINT_ASCII0
        CMP.B       #1,D2
        BEQ         PRINT_ASCII1
        CMP.B       #2,D2
        BEQ         PRINT_ASCII2
        CMP.B       #3,D2
        BEQ         PRINT_ASCII3
        CMP.B       #4,D2
        BEQ         PRINT_ASCII4
        CMP.B       #5,D2
        BEQ         PRINT_ASCII5
        CMP.B       #6,D2
        BEQ         PRINT_ASCII6
        CMP.B       #7,D2
        BEQ         PRINT_ASCII7
        CMP.B       #8,D2
        BEQ         PRINT_ASCII8
        CMP.B       #9,D2
        BEQ         PRINT_ASCII9
        CMP.B       #$A,D2
        BEQ         PRINT_ASCIIA
        CMP.B       #$B,D2
        BEQ         PRINT_ASCIIB
        CMP.B       #$C,D2
        BEQ         PRINT_ASCIIC
        CMP.B       #$D,D2
        BEQ         PRINT_ASCIID
        CMP.B       #$E,D2
        BEQ         PRINT_ASCIIE
        CMP.B       #$F,D2
        BEQ         PRINT_ASCIIF
        
        ; error handling here
        
        

HEX_DONE:
        RTS



PRINT_ASCII0:
        LEA         ZERO_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII1:
        LEA         ONE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII2:
        LEA         TWO_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII3:
        LEA         THREE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII4:
        LEA         FOUR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII5:
        LEA         FIVE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX        
PRINT_ASCII6:
        LEA         SIX_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII7:
        LEA         SEVEN_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII8:
        LEA         EIGHT_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCII9:
        LEA         NINE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIIA:
        LEA         A_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIIB:
        LEA         B_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIIC:
        LEA         C_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIID:
        LEA         D_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIIE:
        LEA         E_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX
PRINT_ASCIIF:
        LEA         F_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        BRA         CONVERT_HEX

;               INCLUDE     'Disassembler_OP_Codes.x68'
;               INCLUDE     'Disassembler_EA_Codes.x68'


*-------Primary Disassembler  Variables and Constants----------                
START_MSG:      DC.B        'Enter a starting address:',0
END_MSG:        DC.B        'Enter an ending address:',0
GREETING_MSG:   DC.B        'Welcome to Sarah and Leons Disassembler!',CR,LF,0
REPEAT_MSG:     DC.B        'Would you like to restart the program? (Press enter to restart)',CR,LF,0
GOODBYE_MSG:    DC.B        'Thank you for using Sarah and Leons Disassembler!',CR,LF,0
BAD_ADDR_MSG:   DC.B        'The address is invalid.',CR,LF,0

              
CR              EQU         $0D
LF              EQU         $0A

SPACE_MSG:      DC.B        '  ',0

ZERO_MSG:       DC.B        '0',0
ONE_MSG:        DC.B        '1',0
TWO_MSG:        DC.B        '2',0
THREE_MSG:      DC.B        '3',0
FOUR_MSG:       DC.B        '4',0
FIVE_MSG:       DC.B        '5',0
SIX_MSG:        DC.B        '6',0
SEVEN_MSG:      DC.B        '7',0
EIGHT_MSG:      DC.B        '8',0
NINE_MSG:       DC.B        '9',0
A_MSG:          DC.B        'A',0
B_MSG:          DC.B        'B',0
C_MSG:          DC.B        'C',0
D_MSG:          DC.B        'D',0
E_MSG:          DC.B        'E',0
F_MSG:          DC.B        'F',0              
ERROR_MSG:      DC.B        'Error',0
SUCCESS_MSG:    DC.B        'Success',0
NEW_LINE:       DC.B        '',CR,LF,0
NEXT_PAGE_MSG:  DC.B        'Please press enter to continue: ',CR,LF,0
               
                
STA_ADDR        DS.B        40
END_ADDR        DS.B        40





*-------OP Code Variables and Constants----------  
ADDQ_MSG:       DC.B        'ADDQ',0
SUBQ_MSG:       DC.B        'SUBQ',0
MOVE_MSG:       DC.B        'MOVE',0
MOVEA_MSG:      DC.B        'MOVEA',0
ORI_MSG:        DC.B        'ORI',0
ANDI_MSG:       DC.B        'ANDI',0
SUBI_MSG:       DC.B        'SUBI',0
ADDI_MSG:       DC.B        'ADDI',0
EORI_MSG:       DC.B        'EORI',0
CMPI_MSG:       DC.B        'CMPI',0
NOP_MSG:        DC.B        'NOP',0
CLR_MSG:        DC.B        'CLR',0
NOT_MSG:        DC.B        'NOT',0
EXT_MSG:        DC.B        'EXT',0
STOP_MSG:       DC.B        'STOP',0
RTE_MSG:        DC.B        'RTE',0
RTS_MSG:        DC.B        'RTS',0
MOVEM_MSG:      DC.B        'MOVEM',0
LEA_MSG:        DC.B        'LEA',0
JSR_MSG:        DC.B        'JSR',0
JMP_MSG:        DC.B        'JMP',0
BRA_MSG:        DC.B        'BRA',0
BSR_MSG:        DC.B        'BSR',0
BEQ_MSG:        DC.B        'BEQ',0
MOVEQ_MSG:      DC.B        'MOVEQ ',0
DIVU_MSG:       DC.B        'DIVU',0
DIVS_MSG:       DC.B        'DIVS',0
SUB_MSG:        DC.B        'SUB',0
CMP_MSG:        DC.B        'CMP',0
MULU_MSG:       DC.B        'MULU',0
MULS_MSG:       DC.B        'MULS',0
ADD_MSG:        DC.B        'ADD',0
ADDA_MSG:       DC.B        'ADDA',0
ASL_MSG:        DC.B        'ASL',0
ASR_MSG:        DC.B        'ASR',0
LSL_MSG:        DC.B        'LSL',0
LSR_MSG:        DC.B        'LSR',0
ROL_MSG:        DC.B        'ROL',0
ROR_MSG:        DC.B        'ROR',0
OR_MSG:         DC.B        'OR',0
EOR_MSG:        DC.B        'EOR',0
AND_MSG:        DC.B        'AND',0
TRAP_MSG:       DC.B        'TRAP',0
POUND:          DC.B        '#',0
DOLLAR:         DC.B        '$',0
PERCENT:        DC.B        '%',0

; Size messages

BYTE_MSG:       DC.B        '.B',0
WORD_MSG:       DC.B        '.W',0
LONG_MSG:       DC.B        '.L',0
ERROR_OP_MSG:   DC.B        'Not A valid OP code',0
IMPLEMENT_MSG:  DC.B        'OP code not implemented yet',0
ERROR_INSTR:    DC.B        'INVALID OP-CODE',0
ERROR_SIZE_MSG: DC.B        'INVALIDE OP-CODE SIZE',0



*-------Effective Addressing Variables and Constants---------- 

MOVEM0_MSG:     DC.B        'D',0
MOVEM1_MSG:     DC.B        'A',0
MODE_0_MSG:     DC.B        ' D',0
MODE_1_MSG:     DC.B        ' A',0
MODE_A_MSG:     DC.B        ' (A',0
MODE_A_1_MSG:   DC.B        ')',0
MODE_A_2_MSG:   DC.B        ')+',0
MODE_MINUS_MSG: DC.B        ' -(A',0
DIVISOR_MSG:    DC.B        '/',0
SEPERATOR:      DC.B        ',',0
POUND_MSG:      DC.B        ' #',0
SUBCLASS1_1:    DC.B        ' ($',0
SUBCLASS1_2:    DC.B        ').L',0
DATA_MSG:       DC.B        ' #$',0
DOLLAR_MSG:     DC.B        '$',0
TEMP_MSG:       DC.B        'TMP',0
TMP_STR         DS.B        32


                
                
        END    START    









































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
