*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


; D3 = OP size. ie. Byte, Word, Long
; D4 = Original hex code
; D5 = Current Register or Mode being isolated

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
    
        CLR.L   D5
        MOVE.W  D4, D5
        
        MOVE.B      #10,D1
        LSL.W       D1,D5       
        MOVE.B      #13,D1
        LSR.W       D1,D5
        ;   Isolating Source Mode
        
        JSR         EA_JUMP_TABLE
        
        ; Print Out ", "
        
        ; Isolate Destination Mode and Register
        
        ; JSR EA_JUMP_TABLE
        
        ; Final output Format = MOVE.X D##, D##
    
        RTS
    

; Possible modes Dn = 0,An = 1,(An) = 2,(An)+ = 3,-(An) = 4
EA_JUMP_TABLE:

        CMP.B       #0,D5
        BEQ         J_TBL_D
        CMP.B       #2,D5
        BEQ         J_TBL_A
        CMP.B       #3,D5
        BEQ         J_TBL_A
        CMP.B       #4,D5
        BEQ         J_TBL_A_DECR
        
        JSR         J_TO_IMPLEMENT
        ;   deal with errors here
        RTS
J_NUM:
        LEA         NUM_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        RTS
J_TO_IMPLEMENT:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        LEA         TEMP_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        RTS


J_TBL_D:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         MODE_0_MSG, A1 ; D#
        MOVE.B      #14, D0
        TRAP        #15
        ; add code to deal with register
        JSR         J_NUM
        

        RTS

J_TBL_A:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         MODE_A_MSG, A1 ; (A#)
        MOVE.B      #14, D0
        TRAP        #15
        ; add code to deal with register
        JSR         J_NUM
        
        LEA         MODE_A_1_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
    
J_TBL_A_INCR:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         MODE_A_MSG, A1 ; (A#)+
        MOVE.B      #14, D0
        TRAP        #15
        ; add code to deal with register
        JSR         J_NUM
        
        LEA         MODE_A_2_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
        
J_TBL_A_DECR:
        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         MODE_MINUS_MSG, A1 ; -(A#)
        MOVE.B      #14, D0
        TRAP        #15
        ; add code to deal with register
        JSR         J_NUM
        
        LEA         MODE_A_1_MSG, A1
        MOVE.B      #14, D0
        TRAP        #15

        RTS
    
        




MODE_0_MSG:     DC.B        'D',0
MODE_1_MSG:     DC.B        'A',0
MODE_A_MSG:     DC.B        '(A',0
MODE_A_1_MSG:   DC.B        ')',0
MODE_A_2_MSG:   DC.B        ')+',0
MODE_MINUS_MSG: DC.B        '-(A',0

NUM_MSG:        DC.B        '##',0
TEMP_MSG:       DC.B        'TMP',0







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
