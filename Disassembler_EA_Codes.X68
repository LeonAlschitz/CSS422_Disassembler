*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


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












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
