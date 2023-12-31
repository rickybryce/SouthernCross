; THIS PROGRAM IS FOR THE SOUTHERN CROSS
; Z80 COMPUTER BY CRAIG JONES

; PROGRAM TO DISPLAY OCTAL, HEX AND BINARY
; YOU WILL NEED  AN OUTPUT MODULE AT 80H
; FOR LEDS. V2.0

; USE THIS VERSION WITH SCNEO ONLY
; IF YOU HAVE ACIA FIRMWARE, THEN YOU CAN CHANGE
; THE OUTPUT PORT TO 83 (HARDWARE AND IN THIS PROGRAM)
; 
; IF YOU HAVE ACIA OR SCMON 1.8, THEN ALSO, CHANGE THE 
; BREAK: EQU 28H TO BREAK: EQU 38H
;
; If you do not have an I/O display, you simply won't
; see the LED Outputs.

; OCTAL WILL DISPLAY ON THE FIRST 4 DIGITS, AND HEX ON 
; THE LAST 2.  LEDS WILL SHOW BINARY.



; KEYPAD BUTTONS 2-3 SET DELAY (E HIGHEST, 2 LOWEST)
; BUTTON 1 IS FOR SINGLE STEP, 0 WILL RESET
; F WILL BREAK TO 28H 

; ASSEMBLED USING AZ80 ASSEMBLER
; https://www.retrotechnology.com/restore/az80.html
; TO COMPILE IN LINUX (AS PER MARK ABENE)
; ln -s az80.h AZ80.H ; (OR VICE VERSA)
; gcc -I. -o az80 az80.c az80util.c az80eval.c
; THEN CREATE THE FOLLOWING SCRIPT: assemble WITH CONTENTS

; -----------------------------------------------------
; #!/bin/bash
; ./az80 $1.asm -l $1.lst -o $1.hex

; -----------------------------------------------------
; THEN chmod +x assemble TO MAKE IT EXECUTABLE
; THEN ./assemble filename  should create your hex file

; IN SCNEO, PRESS I, THEN PASTE HEX FILE INTO TERMINAL WITH
; 1MS LINE DELAY.
; PRESS G2000 AFTER IT'S LOADED TO RUN THE PROGRAM

; -- RICKY BRYCE



    ORG 2000H       ; PROGRAM STARTS AT 2000H
    
; DEFINE PRESETS FOR DELAY LOOP
; TO INCREMENT EVERY SECOND (TRIAL AND ERROR)

; ** BEGIN HEAD **
; THESE SETTINGS WILL COARSE ADJUST CLOCK CALIBRATION
; FOR FINER TUNING USE NOPS IN DELAY LOOP
DELAYLOW:   EQU 00H     ; DELAY LOW BYTE START 00H
DELAYHIGH:  EQU 01H     ; DELAY HIGH BYTE START 01H
SYSTEM:     EQU 30H     ; FOR SYSTEM CALLS
BREAK:      EQU 28H     ; BREAK POINT
LEDPORT:    EQU 80H     ; PORT FOR LEDS

; ** END HEAD **

PREINIT:
    LD IX,DELAYTIME ; LOAD IX WITH DELAY TIME MEMORY LOCATION
    LD (IX+0),DELAYLOW  ; HIGH BYTE DELAY LOOP
    LD (IX+1),DELAYHIGH ; LOW BYTE DELAY LOOP
    XOR A               ; ZERO ACCUMULATOR
    LD (ONESHOT),A      ; CLEAR ONESHOT FLAG
    LD (SINGLESTEP),A   ; CLEAR SINGLESTEP FLAG

; ** BEGIN INITIALIZE **    
INIT: ; INITIALIZE REGISTERS AND MEMORY
    XOR A               ; ZERO ACCUMULATOR
    LD (RESETFLAG),A    ; CLEAR RESET FLAG
    LD IX,OCTAL         ; LOAD IX WITH OCTAL MEMORY LOCATION
    LD (IX+0),A         ; CLEAR LOW OCTAL BYTE
    LD (IX+1),A         ; CLEAR HIGH OCTAL BYTE
    LD (COUNTER),A      ; START COUNTER AT ZERO
    OUT (LEDPORT),A     ;SEND COUNTER TO LEDS
    LD C,CLRBUF         ; CLEAR THE DISPLAY BUFFER BEFORE WE BEGIN
    RST SYSTEM          ; SYSTEM CALL

    LD C,DISBYT         ; DISPLAY 00 ON THE RIGHTMOST DIGITS
    RST SYSTEM          ; CALL SYSTEM
    LD HL,00H           ; LOAD 00 TO HL TO DISPLAY ON LEFT 4 DIGITS
    LD C,DISADD         ; ADD 00 TO THE DISPLAY BUFFER
    RST SYSTEM          ; SYSTEM CALL
    OUT (LEDPORT),A     ; SEND COUNTER TO LEDS

; ** BEGIN MAIN ROUTINE **
BEGIN:
    LD A,(RESETFLAG)    ; CHECK THE RESET FLAG
    OR A                ; CHECK FOR ZERO (LD DOES NOT ALTER FLAGS)
    JR NZ,INIT          ; RE-INITIALIZE IF RESET FLAG SET
    LD A,(SINGLESTEP)   ; LOAD SINGLESTEP FLAG
    OR A                ; CHECK FOR ZERO (LD DOES NOT ALTER FLAGS)
    JP NZ,SST           ; GO TO SINGLE STEP ROUTINE
RSST:                   ; RETURN FROM SINGLESTEP
    CALL DELAY          ; START BY RUNNING A DELAY LOOP
    LD A,(COUNTER)      ; LOAD A WITH THE COUNTER TO DISPLAY
    INC A               ; INCREMENT A
    LD (COUNTER),A      ; THEN STORE A TO THE COUNTER MEMORY LOCATION
    OUT (LEDPORT),A     ; SEND THE COUNTER TO THE LEDS

    ; CONVERT OCTAL
FIRSTCHAR:              ; IF THE FIRST CHARACTER IS 8, WE NEED TO ADD 8
    LD HL,(OCTAL)       ; LOAD HL WITH THE LAST OCTAL VALUE
    INC HL              ; INCREMENT THIS VALUE
    LD (OCTAL),HL       ; THEN STORE HL BACK TO OCTAL MEMORY LOCATION
    LD A,L              ; LOAD THE LOW BYTE TO A
    AND 0FH             ; MASK OUT THE UPPER NYBBLE
    CP 08H              ; COMPARE TO 8
    JR NZ,CONT          ; IF NOT 8, THEN WE ARE OK... CONTINUE
    LD HL,(OCTAL)       ; IF 8, THEN RELOAD OCTAL MEMORY LOCATION TO HL
    LD A,L              ; TRANSFER L TO A
    ADD A,08H           ; ADD 8H
    LD L,A              ; THEN STORE BACK TO L
    LD (OCTAL),HL       ; NOW STORE HL BACK TO THE OCTAL MEMORY LOCATION
SECCHAR:                ; NEXT, DEAL WITH THE UPPER NYBBLE
    LD HL,(OCTAL)       ; LOAD THE VALUE OF OCTAL TO HL
    LD A,L              ; LOAD L TO A
    AND 0F0H            ; MASK OUT THE LOWER NYBBLE
    CP 80H              ; SEE IF WE'VE REACHED 80H
    JR NZ,CONT          ; IF NOT THEN CONTINUE
    LD L,00H            ; BUT IF SO, LOAD L WITH 00H
    INC H               ; THEN INCREMENT H
    LD (OCTAL),HL       ; STORE THE VALUE OF HL BACK TO OCTAL
THIRCHAR:               ; NEXT, DEAL WITH THE HIGH BYTE, SINCE WE CAN GO TO 377
    LD HL,(OCTAL)       ; LOAD HL WITH OCTAL
    LD A,H              ; TRANSFER H TO A
    CP 04H              ; IF IT'S 4, THEN IT'S TOO HIGH
    JP NZ,CONT          ; IF NOT THEN WE ARE OK TO CONTINUE
    XOR A               ; IF VALUE WAS 4, LOAD 00H TO A
    LD H,A              ; THEN SET H TO ZERO
    LD (OCTAL),HL       ; HL IS THE NEW OCTAL NUMBER, STORE THIS VALUE TO OCTAL
CONT:
    LD C,DISADD         ; FUNCTION CODE TO ADD VALUE TO DISPLAY
    LD HL,(OCTAL)       ; LOAD HL WITH OCTAL AS REQUIRED BY DISADD
    RST SYSTEM          ; SYSTEM CALL
    LD A,(COUNTER)      ; LOAD A WITH THE COUNTER
    LD C,DISBYT         ; THEN PERFORM A FUNCTION CALL TO DISPLAY THE COUNTER
    RST SYSTEM          ; SYSTEM CALL TO DISPLAY RIGHTMOST DIGITS
    JP BEGIN            ; START OVER
    
; ** END MAIN ROUTINE **

; ** SINGLE STEP ROUTINE **
SST:                    ; SIGNLE STEP ROUTINE
                        ; WE WON'T DO ONE SHOTS HERE TO ALLOW REPEATS
    
    LD A,01H            ; LOAD 1 TO A
    LD (DELAYTIME+1),A  ; SET DELAYTIME HIGH
    XOR A               ; CLEAR ACCUMULATOR
    LD (DELAYTIME),A    ; SET DELAYTIME LOW
    ;RST BREAK
    NOP
SSTH:                   ; SINGLESTEP HOLD
                        ; WE'LL ALLOW ANY KEY HERE AS DELAY WILL
                        ; CHANGE MODE IF ANOTHER KEY IS PRESSED
    LD C,SCAND
    RST SYSTEM
    IN A,(86H)          ; LOAD KEYPAD BUFFER
    BIT 5,A             ; CHECK BIT 5 (STAUS)
    JR Z, SSTH           ; HOLD
    JP RSST             ; RETURN TO MAIN
; ** END SINGLESTEP ROUTINE **


; ** BEGIN DELAY ROUTINE **
DELAY:
    ; COMMENT OUT THE NEXT TWO INSTRUCTIONS IF YOU DO NOT HAVE
    ; AN I/O MODULE
    ;IN A,(81H)          ; LOAD 8 WITH VALUE OF SWITCHES
    
    LD BC,(DELAYTIME)   ; LOAD BC WITH DELAYTIME
    LD (DLYLOOP),BC     ; SET LOOP AT CURRENT TIME


DELAY1:
    CALL CHKKEY          ; CHECK FOR KEYPAD VALUE
    
    PUSH BC             ; PUSH BC TO STACK (BACKUP)
    LD C,SCAND          ; FUNCTION CODE TO SCAN DISPLAY
    RST SYSTEM          ; CALL THE SYSTEM
    POP BC              ; POP BC FROM STACK (RESTORE)
    LD BC,(DLYLOOP)     ; LOAD BC FROM CURRENT DELAY VALUE
    DEC BC              ; DECREMENT BC
    LD (DLYLOOP),BC     ; STORE THE NEW VALUE TO MEMORY
    LD A,C              ; LOAD A FROM C
    OR B                ; SEE IF WE'VE REACHED ZERO YET
    JP NZ,DELAY1        ; IF NOT, THEN CONTINUE LOOP
    RET                 ; RETURN TO MAIN
; ** END DELAY ROUTINE **

; ** CHECKKEYS ROUTINE **
; CHECK THE STATUS OF THE BUTTONS TO GET THE DELAYTIME,
; SINGLE STEP MODE (1), OR RESET (0).
CHKKEY:
    LD  A,(ONESHOT)      ; SEE IF A KEY IS STILL PRESSED
    OR A
    JR  NZ,CHKONS       ; CHECK FOR KEY RELEASE TO CLEAR ONS
    IN A,(86H)          ; GET THE KEYPAD BUFFER
    BIT 5,A             ; SEE IF A KEY WAS PRESSED
    JR Z,NOKEY          ; RETURN IF NO KEYPRESS
    AND 0FH             ; CLEAR UPPER BITS
    OR A                ; CHECK A FOR ZERO
    JR Z,ZEROKEY        ; SET RESET FLAG
    CP 01H              ; CHECK A FOR ONEKEY
    JR Z, ONEKEY        ; SET SINGLESTEP FLAG
    CP 0FH
    JR Z,SYSBREAK
    
    ; THE FOLLOWING STATEMENTS ADJUST THE DELAY VALUE FOR 
    ; TIMES THAT ARE MORE USEFUL

    LD (DELAYTIME+1),A  ; SET UPPER BYTE OF DELAY
    XOR A               ; SET A TO 0
    LD (DELAYTIME),A    ; STORE ZERO TO LOW BYTE OF DELAYTIME
                        ; THIS WILL SLOW THE LOOP WITH MORE OF A TIME SPREAD
    LD HL,(DELAYTIME)   ; LOAD DELAYTIME VALUE TO HL
    SRL H               ; SHIFT RIGHT H
    RR L                ; ROTATE RIGHT L
    SRL H               ; SHIFT RIGHT H
    RR L                ; ROTATE RIGHT L
    LD (DELAYTIME),HL   ; UPDATE DELAYTIME

    ; UPDATE CURRENT LOOP TIME
    LD BC,(DELAYTIME)   ; START OVER WITH NEW DELAYTIME
    LD (DLYLOOP),BC     ; UPDATE CURRENT DLY LOOP TIME
    
    
    ; SET BITS
    LD A,01H            ; LOAD 1 TO ACCUMULATOR
    LD (ONESHOT),A      ; SET THE ONE SHOT FLAG
    XOR A               ; CLEAR ACCUMULATOR
    LD (SINGLESTEP),A   ; CLEAR SINGLESTEP FLAG 
        ;(DIFFERENT KEY PRESSED IF WE GOT HERE)

    JR CHKKEYRET        ; RETURN FROM SUBROUTINE

NOKEY:                  ; NO KEY PRESSED
    XOR A               ; ZERO ACCUMULATOR
    LD (ONESHOT),A      ; CLEAR ONESHOT
    JP CHKKEYRET        ; RETURN

ZEROKEY:
    LD A,01H            ; LOAD ACCUMULATOR WITH 1
    LD (RESETFLAG),A  ; SET RESET FLAG
    JR CHKKEYRET
ONEKEY:
    LD A,01H
    LD (SINGLESTEP),A   ; SET SINGLESTEP MODE
    
    JR CHKKEYRET
CHKONS:
    IN A,(86H)          ; CHECK FOR INPUTS
    BIT 5,A             ; CHECK FOR STATUS BIT
    JR NZ, CHKKEYRET    ; IF KEY STILL PRESSED, RETURN
    XOR A               ; OTHERWISE, ZERO ACCUMULATOR
    LD (ONESHOT),A      ; AND CLEAR ONE SHOT
    

CHKKEYRET:
    RET
    
SYSBREAK:
    RST BREAK



; ** END CHECKKEYS ROUTINE


; ** BEGIN FOOTER (DEFINE BYTES (DB)) **
    ORG 2200H		; AVOID CROSSING PAGE BOUNDARY
    
; ** BEGIN DATA TABLES (ARRAYS) **
DELAYTIME: 		; FOR DELAY LOOPS
    DB 00H,00H 	; THESE WILL BE OVERWRITTEN WITH
				;CONSTANTS DEFINED IN HEADER
COUNTER:        ; VALUE TO BE DISPLAYED ON LEDS AND RIGHTMOST 2 DIGITS
    DB 00H
OCTAL:          ; VALUE TO BE DISPLAYED ON LEFTMOST 4 DIGITS
    DB 00H,00H
SINGLESTEP:     ; SINGLE STEP FLAG
    DB 00H
ONESHOT:        ; ONE SHOT FLAG FOR BUTTONS
    DB 00H
RESETFLAG:      ; RESET FLAG
    DB 00H
DLYLOOP:        ; CURRENT DELAY VALUE
    DB 00H, 00H
				
				
				
; ** END DATA TABLES (ARRAYS) **  

; ** END FOOTER (DEFINE BYTES (DB)) **

; CREATE LABEL (ALIAS) NAMED SYSTEM FOR MONITOR ENTRY POINT


   
; Pasted some code out of the monitor definitions file.
; This is not the whole file.
; to obtain the file, visit:
; https://github.com/crsjones/Southern-Cross-Computer-z80/tree/main/SouthernCrossSBC_Monitor/SCMonitorV18
;--------------------------------------------
; S O U T H E R N   C R O S S   M O N I T O R
;--------------------------------------------
;
;  MONITOR DEFINITIONS FILE 
;  Version 1.8
;
; WRITTEN BY CRAIG R. S. JONES
; MELBOURNE, AUSTRALIA.
;
;--------------------
; SYSTEM CALL NUMBERS
;--------------------
;
;  LD   C,SYSTEM CALL NUMBER
;  RST  30H
;

MAIN:	EQU	0	;RESTART MONITOR
VERS:	EQU	1	;RETURNS MONITOR VERSION
DISADD:	EQU	2	;ADDRESS -> DISPLAY BUFFER
DISBYT:	EQU	3	;DATA -> DISPLAY BUFFER
CLRBUF:	EQU	4	;CLEAR DISPLAY BUFFER
SCAND:  EQU	5	;SCAN DISPLAY
CONBYT:	EQU	6	;BYTE -> DISPLAY CODE
CONVHI:	EQU	7	;HI NYBBLE -> DISPLAY CODE
CONVLO:	EQU	8	;LO NYBBLE - > DISPLAY CODE
SKEYIN:	EQU	9	;SCAN DISPLAY UNTIL KEY PRESS
SKEYRL:	EQU	10	;SCAN DISPLAY UNTIL KEY RELEASE
KEYIN:	EQU	11	;WAIT FOR KEY PRESS
KEYREL:	EQU	12	;WAIT FOR KEY RELEASE
MENU:	EQU	13	;SELECT ENTRY FROM MENU
CHKSUM:	EQU	14	;CALCULATE CHECKSUM
MUL16:	EQU	15	;16 BIT MULTIPLY
RAND:	EQU	16	;GENERATE RANDOM NUMBER
INDEXB:	EQU	17	;INDEX INTO BYTE TABLE
INDEXW:	EQU	18	;INDEX INTO WORD TABLE
MUSIC:	EQU	19	;PLAY MUSIC TABLE
TONE:	EQU	20	;PLAY A NOTE
BEEP:	EQU	21	;KEY ENTRY BEEP
SKATE:	EQU	22	;SCAN 8X8 DISPLAY
TXDATA:	EQU	23	;TRANSMIT SERIAL BYTE
RXDATA:	EQU	24	;RECEIVE SERIAL BYTE
ASCHEX:	EQU	25	;ASCII CODE -> HEX
WWATCH:	EQU	26	;WRITE TO SMART WATCH
RWATCH:	EQU	27	;READ FROM SMART WATCH
ONESEC:	EQU	28	;ONE SECOND DELAY USING SMARTWATCH
RLSTEP:	EQU	29	;RELAY SEQUENCER
DELONE:	EQU	30	;ONE SECOND DELAY LOOP
SCANKEY: EQU	31	;SCAN THE KEYBOARD
INTELH:	EQU	32	;RECEIVE INTEL HEX FILE
SPLIT:	EQU	33	;SEPARATE A BYTE INTO NYBBLES
SNDMSG:	EQU	34	;SND ZERO TERMINATED STRING TO SERIAL PORT
BITASC:	EQU	35	;CONVERT A BYTE INTO AN ASCII STRING OF ONES AND ZEROES
WRDASC:	EQU	36	;CONVERT A WORD TO ASCII
BYTASC:	EQU	37	;CONVERT A BYTE TO ASCII
NYBASC:	EQU	38	;CONVERT A NYBBLE TO ASCII
PCBTYP:	EQU	39	;RETURNS BOARD TYPE, SC OR TEC-1F
PRNTSZ:	EQU	40	;INLINE SERIAL PRINT STRING
KBDTYP:	EQU	41	;RETURNS KEYBOARD TYPE
UPDATE:	EQU	42  ;UPDATE DISPLAY AND MODE DECIMAL POINT SEGMENTS
VARRAM:	EQU	43	;RETURN BASE VARIABLE ADDRESS
SERINI:	EQU	44	;INITIALISE BIT BANG SERIAL PORT
SCBUG:	EQU	45	;SCBUG SERIAL MONITOR

;END OF PARTIAL INCLUDE FILE
    END
