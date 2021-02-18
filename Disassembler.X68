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
    
    
    
    
    ; can determine OP code from first 4 bits
    
START:                  ; first instruction of program
        LEA         START_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         STA_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15             ; D1 has the length of the address
        
        
        ; LEA         END_MSG, A1
        ; MOVE.B      #14, D0    
        ; TRAP        #15
        
        ; LEA         END_ADDR, A1
        ; MOVE.B      #2, D0
        ; TRAP        #15
        




CONVERT_TO_ASCII:

        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        ; BEQ         
    
        MOVE.B      (A1)+, D2   ; Gives D2 the next Byte from A1
    
        MOVE.B      #$39, D3    ; Moves 39 into D3, Ascii Characters after 39 are not letters
        CMP.B       D3, D2

        BLE         NUM_ASCII   ; data in D2 is less than 39, Most likely a number
        BRA         LET_ASCII   ; If not a number, then it is an ASCII Letter


NUM_ASCII:
        MOVE.B      #$30, D3
        SUB.B       D3, D2      ; ASCII numbers start at 30. 30 = 0, 31 = 1, etc
        ADD.B       D2, D4      ; new ASCII number stored at D4
        
        SUBI.B      #$1, D1
        
        BRA         CONVERT_TO_ASCII
        
        
LET_ASCII:

        MOVE.B      #$37, D3
        SUB.B       D3, D2      ; Hex letters we care about are from A-F, we can use math do achieve this
        ADD.B       D2, D4      ; 41 is used to represent A in Hex. Hexadecimal subtraction: 41 - 37 = A
                                ; 46 is used to represent F in Hex. 46 - 37 = F
        
        SUBI.B      #$1, D1
        
        BRA         CONVERT_TO_ASCII





        






        
* Put program code here

ADDRESS_LOOP:
        CMP   A0, A2
        BEQ     DONE
        MOVE.B  (A0)+, D1
        MOVE.B  D1, (A3)+
        MOVE.B  #' ',(A3)+
        
        ; LEA     D1, A1
        
        ; MOVE.B  #14, D0
        ; TRAP    #15
        
        BRA ADDRESS_LOOP


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
                
STA_ADDR        DS.B        40
END_ADDR        DS.B        40
                
                
        END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
