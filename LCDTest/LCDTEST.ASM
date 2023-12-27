; THIS PROGRAM IS FOR THE SOUTHERN CROSS
; Z80 COMPUTER BY CRAIG JONES

; PROGRAM TO DISPLAY DATA ON LCD
;
; LCD IS ADDRESS 50H COMMAND / 51H DATA


; ASSEMBLED USING AZ80 ASSEMBLER
; https://www.retrotechnology.com/
; TO COMPILE IN LINUX (AS PER MARK ABENE)
; ln -s az80.h AZ80.H ; (OR VICE VERSA)
; gcc -I. -o az80 az80.c az80util.c az80eval.c
; THEN CREATE THE FOLLOWING SCRIPT: asmz80 WITH CONTENTS

; -----------------------------------------------------
; #!/bin/bash
; ./az80 $1.asm -l $1.lst -o $1.hex

; -----------------------------------------------------
; THEN chmod +x asmz80 TO MAKE IT EXECUTABLE
;
; IF YOU  USE Z80ASM BY SLR SYSTEMS:
; Z80ASM LCDTEST/H

; -- RICKY BRYCE


    ORG 2000H
;** HEAD **
CPORT:      EQU 50H
DPORT:      EQU 51H
LINE0:      EQU 80H
LINE1:      EQU 0C0H
LINE2:      EQU 94H
LINE3:      EQU 0D4H
;** END HEAD **


;** INITIALIZE **
    LD A,38H           ; 8 BIT 2 LINE 5X7
    OUT (CPORT),A      ; FUNCTION SET
    CALL LCDWAIT
    LD A,0FH           ; TURN ON DISPLAY, CURSOR ON, BLINK
    OUT (CPORT),A      ; DISPLAY ON
    CALL LCDWAIT
    LD A,06H            ; CURSOR MOVE (VS SHIFT DISPLAY)
    OUT (CPORT),A       ; ENTRY MODE
    CALL LCDWAIT
    LD A,01H            ; CLEAR DISPLAY
    OUT (CPORT),A       ; CLEAR DISPLAY
    CALL LCDWAIT

;** END INITIALIZE **


;** MAIN ROUTINE **
MAIN:
    LD HL,FIRSTLINE
    LD A,LINE0
    OUT (CPORT),A ; SET FIRST LINE
    CALL LCDWAIT
    CALL WRCHARS
    

    LD HL,SECONDLINE
    LD A,LINE1
    OUT (CPORT),A ; SET SECOND LINE
    CALL LCDWAIT
    CALL WRCHARS
    
    LD HL,THIRDLINE
    LD A,LINE2
    OUT (CPORT),A ; SET THIRD LINE
    CALL LCDWAIT
    CALL WRCHARS
    
    LD HL,FOURTHLINE
    LD A,LINE3
    OUT (CPORT),A ; SET FOURTH LINE
    CALL LCDWAIT
    CALL WRCHARS
    
    HALT

;** END MAIN ROUTINE **

;** WRITE CHARACTERS ROUTINE **
WRCHARS:
    LD A,(HL)
    CP 24H
    JR Z, CHARRET
    OUT (DPORT),A
    CALL LCDWAIT
    INC HL
    JR WRCHARS
CHARRET:
    RET


;** END WRITE CHARACTERS ROUTINE **


;** LCD WAIT ROUTINE **
LCDWAIT:
    IN A,(CPORT)
    BIT 7,A
    JR NZ,LCDWAIT
    RET
;** END LCDWAIT ROUTINE **


;** FOOT **
FIRSTLINE:
    DB "Southern Cross$"
SECONDLINE:
    DB "   Z80 Computer$"
THIRDLINE:
    DB "      20X4 Display$"
FOURTHLINE:
    DB "!!!!!! ENJOY !!!!!!$"
;** END FOOT **

    END

