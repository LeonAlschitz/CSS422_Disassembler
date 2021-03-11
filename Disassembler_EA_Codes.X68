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


; -------------------------------------
; General outline


; Get Source Mode and Registration
; Get Destination Mode and Registration
; based off of these values, you can determine the Addressing mode, and size

; Depending on the opcode, the mode can be found in a few different locations


; Print out the rest of the data as you process it


; --------------------------------------



; based on the size of the move operation Print out an amount of data as is.
; MOVE.B will print out the operation and 1 additional Byte after the OP code as text.
EA_MOVE:
        
; A = Size
; B = Destination Register
; C = Destination Mode
; D = Source Mode
; E = Source Register

; 00AA BBBC CCDD DEEE 
        ; SIMHALT
    
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
        
        
        
        CLR.L       D5
        CLR.L       D6
        MOVE.W      D4, D5
        MOVE.W      D4, D6
        
        MOVE.B      #7,D1     
        LSL.W       D1,D5       
        MOVE.B      #13,D1
        LSR.W       D1,D5  
            
        LSL.W       #4,D6  
        LSR.W       D1,D6
        
        JSR         MODE_TABLE
        
        ; Isolate Destination Mode and Register
        
        ; JSR EA_JUMP_TABLE
        
        ; Final output Format = MOVE.X D##, D##
    
        RTS
    


*-----------MODE_TABLE------------------------------------
; Possible modes Dn = 0,An = 1,(An) = 2,(An)+ = 3,-(An) = 4
MODE_TABLE:

        CMP.B       #0,D5
        BEQ         J_TBL_D
        CMP.B       #2,D5
        BEQ         J_TBL_A
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



J_TBL_D:
        LEA         MODE_0_MSG, A1 ; D#
        MOVE.B      #14, D0
        TRAP        #15
        JSR         DISPLAY_REG
        RTS

J_TBL_A:

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
        ; SIMHALT
        LEA         DOLLAR_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
       

        MOVE.W      (A3)+, A1
        

        
        CLR.L       D1
        CLR.L       D2
        CLR.L       D4
        MOVE.B      #16, D1
        JSR         CONVERT_ASCII
        
        MOVE.L      D4, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
;   Long
J_ABS_L:


        RTS

;   Error
J_ABS_ERROR:
        RTS

*-----------Absolute_addressing_data_table-------------------------
;   Hard Coded Data
;   based on the OP code size, read the appropriate amount of data, and move pointer forward accordingly 

;   Size num 0,4 = Byte 1,5 = Word 2,6 Long

DATA_TABLE:
        LEA         DATA_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15


        CMP.B       #0,D3 
        BEQ         DATA_B      
        CMP.B       #4,D3
        BEQ         DATA_B

        CMP.B       #1,D3 
        BEQ         DATA_W      
        CMP.B       #5,D3
        BEQ         DATA_W
        
        CMP.B       #2,D3 
        BEQ         DATA_L      
        CMP.B       #6,D3
        BEQ         DATA_L




        RTS

DATA_B:

        MOVE.W      (A3)+, A1
        * Only read first byte from the word        

        CLR.L       D1
        CLR.L       D2
        CLR.L       D4
        
        SIMHALT
        MOVE.B      #2, D1
        JSR         CONVERT_ASCII



        RTS

DATA_W:

        MOVE.W      (A3)+, A1

        CLR.L       D1
        CLR.L       D2
        CLR.L       D4
        
        
        MOVE.B      #4, D1
        SIMHALT
        JSR         CONVERT_ASCII

        

        RTS

DATA_L:
        
        MOVE.L      (A3)+, A1

        CLR.L       D1
        CLR.L       D2
        CLR.L       D4
        
        SIMHALT
        MOVE.B      #8, D1
        JSR         CONVERT_ASCII

        

        RTS

        RTS











MODE_0_MSG:     DC.B        'D',0
MODE_1_MSG:     DC.B        'A',0
MODE_A_MSG:     DC.B        '(A',0
MODE_A_1_MSG:   DC.B        ')',0
MODE_A_2_MSG:   DC.B        ')+',0
MODE_MINUS_MSG: DC.B        '-(A',0

SEPERATOR:      DC.B        ', ',0

POUND_MSG:      DC.B        '#',0
DOLLAR_MSG:     DC.B        '$',0
DATA_MSG:       DC.B        ' #$',0

TEMP_MSG:       DC.B        'TMP',0



TMP_STR         DS.B        32




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
