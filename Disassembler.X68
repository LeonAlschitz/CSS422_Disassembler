*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000

    
; A3 will store starting address
; A4 will store ending address
; D3 is used to store values that will get compared
    
START:

        ;   Ask user to enter valid starting address, convert from ascii to hex and then store it in A3                 
        LEA         START_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         STA_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15             ; D1 has the length of the address
        
        
        CLR.L       D2
        CLR.L       D3
        CLR.L       D4
        JSR         CONVERT_ASCII
        MOVEA.L     D4,A3
        
        
        
        
        ;   Ask user to enter valid ending address, convert from ascii to hex and then store it in A4 
        
        LEA         END_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        LEA         END_ADDR, A1
        MOVE.B      #2, D0
        TRAP        #15
        
        CLR.L       D2
        CLR.L       D3
        CLR.L       D4
        JSR         CONVERT_ASCII
        MOVEA.L     D4,A4
        
        
        ; add loop later that checks if data entered is valid for both messages
        
        
        JSR         FILE_LOOP
        




CONVERT_ASCII:                  ; Convert Ascii values to Hex. 00011111 00011110 00100001 00101011 = 31 30 33 43. 31 30 33 43 => 0001 0000 0011 1100 = 1 0 3 C

        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
    
        MOVE.B      (A1)+, D2   ; Gives D2 the next Byte from A1
    
        MOVE.B      #$39, D3    ; Moves 39 into D3, Ascii Characters after 39 are not letters
        CMP.B       D3, D2

        BLE         NUM_ASCII   ; data in D2 is less than 39, Most likely a number
        BRA         LET_ASCII   ; If not a number, then it is an ASCII Letter

ASCII_DONE:
        RTS

NUM_ASCII:
        SUBI.B      #$1, D1
        
        MOVE.B      #$30, D3
        SUB.B       D3, D2      ; ASCII numbers start at 30. 30 = 0, 31 = 1, etc
        ADD.B       D2, D4      ; new ASCII number stored at D4
        
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
        
        
        ASL.L       #4, D4
      
        BRA         CONVERT_ASCII
        
        
LET_ASCII:
        SUBI.B      #$1, D1
               

        MOVE.B      #$37, D3
        SUB.B       D3, D2      ; Hex letters we care about are from A-F, we can use math do achieve this
        ADD.B       D2, D4      ; 41 is used to represent A in Hex. Hexadecimal subtraction: 41 - 37 = A
                                ; 46 is used to represent F in Hex. 46 - 37 = F
        
        CMPI.B      #$0, D1     ; check if we have traversed the whole length
        BEQ         ASCII_DONE
        
        ASL.L       #4, D4
        
        
        BRA         CONVERT_ASCII

PRINT_ADDRESS:
        ;SIMHALT 0000 0000
        CLR.L       D1
        MOVE.B      #$9, D1
        MOVE.L      A3, D3
        
        BRA         PRINT_ADDRESS_LOOP

        LEA         SPACE_MSG, A1
        MOVE.B      #14, D0    
        TRAP        #15
        
        RTS

PRINT_ADDRESS_LOOP:
        CMPI.B      #$0, D1
        BEQ         PRINT_ADDRESS_EXIT
        SUBI.B      #$1, D1
        
        MOVE.B      D3, D2
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
        ;       Add branch here that will take the current address in A3
        ;       Turn it into characters and print it to the screen with space
        JSR         PRINT_ADDRESS
        
        
        MOVE.W      (A3)+, D4

        JSR         JUMP_OP_CODE
        
        LEA         NEW_LINE, A1
        MOVE.B      #14, D0
        TRAP        #15


        CMP.L      A3, A4
        ;       If our pointer is at the end, BRA to DONE
        
        
        BEQ         DONE
        
        BRA         FILE_LOOP





DONE:

        
        MOVE.B  #9, D0
        TRAP    #15
        
        
        
* Put variables and constants here
                INCLUDE     'Disassembler_OP_Codes.x68'
START_MSG:      DC.B        'Enter a starting address:',0
END_MSG:        DC.B        'Enter an ending address:',0               
                INCLUDE     'Disassembler_EA_Codes.x68'
                
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
A_MSG:       DC.B        'A',0
B_MSG:       DC.B        'B',0
C_MSG:       DC.B        'C',0
D_MSG:       DC.B        'D',0
E_MSG:       DC.B        'E',0
F_MSG:       DC.B        'F',0
                
ERROR_MSG:      DC.B        'Error',0
SUCCESS_MSG:    DC.B        'Success',0

NEW_LINE:       DC.B        '',CR,LF,0

  
                
                
STA_ADDR        DS.B        40
END_ADDR        DS.B        40



                
                
        END    START    


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
