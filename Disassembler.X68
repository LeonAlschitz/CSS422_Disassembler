*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
        MOVEA   #SRC, A0    ; This gets the start of the space
        MOVEA   #DST, A1    ; This gets the start of the next space. ie (The end of the last space)
        MOVEA   #DST, A2
* Put program code here

    ADDRESS_LOOP:
        CMP   A0, A1
        BEQ     DONE
        MOVE.B  (A0)+, D0
        MOVE.B  D0, (A2)+
        
        BRA ADDRESS_LOOP
        


    DONE:
        LEA     DST, A1
        MOVE.B  #13, D0
        TRAP    #15
        
        MOVE.B  #9, D0
        TRAP    #15
* Put variables and constants here

SRC:
    DC.B    'This is',0
    
DST:
    DS.B    64

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
