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
        
; A = Size
; B = Destination Register
; C = Destination Mode
; D = Source Mode
; E = Source Register

; 00AA BBBC CCDD DEEE 
        ;SIMHALT
        CLR.L       D1
        CLR.L       D5
        CLR.L       D6
        
        MOVE.W      D4, D5
        MOVE.W      D4, D6
        
        
        MOVE.B      #10,D1
        LSL.W       D1,D5       
        MOVE.B      #13,D1
        LSR.W       D1,D5
        ; 0000 0000 00DD D000
        ; Isolating Source Mode
        
        
        LSL.W       D1,D6
        LSR.W       D1,D6
        ; 0000 0000 0000 0EEE
        ; Isolating Source Register 
       
        JSR         MODE_TABLE
        
        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15
        ;SIMHALT
        CLR.L       D5
        CLR.L       D6
        MOVE.W      D4, D5
        MOVE.W      D4, D6
        
        MOVE.B      #7,D1     
        LSL.W       D1,D5       
        MOVE.B      #13,D1
        LSR.W       D1,D5
        ; 0000 000C CC00 0000
        ; Isolating Destination Mode  
            
        LSL.W       #4,D6  
        LSR.W       D1,D6
        ; 0000 BBB0 0000 0000
        ; Isolating Destination Register
        
        JSR         MODE_TABLE


        RTS
        
        
; X+Y = Effective addressing
; XXX = Mode
; YYY = Register
    
; 0000 0000 00XX XYYY
EA_LEA:
        CLR.L       D1
        CLR.L       D5
        CLR.L       D6

        MOVE.W      D4, D5
        MOVE.W      D4, D6


        ; Print Out ", "
        LEA         SEPERATOR, A1
        MOVE.B      #14, D0
        TRAP        #15


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
        BEQ         J_ABS_W
            
        CMP.B       #1,D6
        BEQ         J_ABS_L
            
        CMP.B       #4,D6
        BEQ         DATA_TABLE
            
        RTS
        
;   Word
J_ABS_W:
        ;SIMHALT
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
       

        MOVE.W      (A3)+, A1
        

        
        CLR.L       D1
        CLR.L       D2
        CLR.L       D7
        MOVE.B      #4, D1
        JSR         CONVERT_ASCII
        
        MOVE.L      D7, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
;   Long
J_ABS_L:
        ;SIMHALT
        LEA         DOLLAR_MSG, A1
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


        
        
        RTS

;   Error
J_ABS_ERROR:
        RTS

*-----------Absolute_addressing_data_table-------------------------
;   Hard Coded Data
;   based on the OP code size, read the appropriate amount of data, and move pointer forward accordingly 

;   Size num 0 = Byte 1 = Word 2 Long

DATA_TABLE:
        ;SIMHALT
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
        ;SIMHALT
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
    
        MOVE.B      D7,D2
            
        MOVE.B      #28,D0    
        LSL.L       D0,D2     
        ROL.L       #4,D2
        
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







MODE_0_MSG:     DC.B        ' D',0
MODE_1_MSG:     DC.B        ' A',0
MODE_A_MSG:     DC.B        ' (A',0
MODE_A_1_MSG:   DC.B        ')',0
MODE_A_2_MSG:   DC.B        ')+',0
MODE_MINUS_MSG: DC.B        ' -(A',0

SEPERATOR:      DC.B        ',',0

POUND_MSG:      DC.B        ' #',0
DOLLAR_MSG:     DC.B        ' $',0
DATA_MSG:       DC.B        ' #$',0

TEMP_MSG:       DC.B        'TMP',0



TMP_STR         DS.B        32








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
