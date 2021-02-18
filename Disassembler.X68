*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    ; Testing MOVE.B
    ; MOVE.B = 10 3C =  0001 0000 0011 1100
    ; Byte Operation   00(01) 0000 0011 1100
    ; Destination      0001 (0000 00)11 1100
    ; Source           0001 0000 00(11 1100)
    
    ; 1 byte is represented by 2 hex digits
    
    
    ; can determine OP code from first 4 bits
    
START:                  ; first instruction of program
        LEA         START_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         STA_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15             ; D1 has the length of the address
        
        
        BRA         CONVERT_TO_ASCII
        
        
        ; LEA         END_MSG, A1
        ; MOVE.B      #14, D0    
        ; TRAP        #15
        
        ; LEA         END_ADDR, A1
        ; MOVE.B      #2, D0
        ; TRAP        #15
        




CONVERT_TO_ASCII:

        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         OP_CODE
    
        MOVE.B      (A1)+, D2   ; Gives D2 the next Byte from A1
    
        MOVE.B      #$39, D3    ; Moves 39 into D3, Ascii Characters after 39 are not letters
        CMP.B       D3, D2

        BLE         NUM_ASCII   ; data in D2 is less than 39, Most likely a number
        BRA         LET_ASCII   ; If not a number, then it is an ASCII Letter


NUM_ASCII:
        SUBI.B      #$1, D1
        
        MOVE.B      #$30, D3
        SUB.B       D3, D2      ; ASCII numbers start at 30. 30 = 0, 31 = 1, etc
        ADD.B       D2, D4      ; new ASCII number stored at D4
        
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         OP_CODE
        
        
        ASL.L       #4, D4
      
        BRA         CONVERT_TO_ASCII
        
        
LET_ASCII:
        SUBI.B      #$1, D1
               

        MOVE.B      #$37, D3
        SUB.B       D3, D2      ; Hex letters we care about are from A-F, we can use math do achieve this
        ADD.B       D2, D4      ; 41 is used to represent A in Hex. Hexadecimal subtraction: 41 - 37 = A
                                ; 46 is used to represent F in Hex. 46 - 37 = F
        
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         OP_CODE
        
        ASL.L       #4, D4
        
        
        BRA         CONVERT_TO_ASCII





OP_CODE:
        MOVEA.L     D4, A3
        CLR.L       D1
        MOVE.B      #12, D1
        LSR.W       D1, D4

        
        
        
        
        ; List of compare and BRA statements

        
        CMP.B       #$1, D4
        BRA         OP_CODE_MOVE
        
        LEA         ERROR_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15



OP_CODE_MOVE:

        




        
* Put program code here


DONE:

        
        MOVE.B  #9, D0
        TRAP    #15
        
        
        
* Put variables and constants here
        INCLUDE     'Disassembler_EA_Codes.x68'
        INCLUDE     'Disassembler_OP_Codes.x68'




START_MSG:
                DC.B        'Enter a starting address:',0
END_MSG:
                DC.B        'Enter an ending address:',0
                
ERROR_MSG:
                DC.B        'Error',0
                
SUCCESS_MSG:    DC.B        'Success',0
                
                
                
STA_ADDR        DS.B        40
END_ADDR        DS.B        40
                
                
        END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
