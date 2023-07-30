; PROGRAM TO DISPLAY OCTAL AND HEX

; THIS PARTICULAR VERSION DOES NOT USE AN I/O MODULE
; I DISABLED THE OUTPUT FOR AN I/O MODULE IN THIS LINE
;     OUT (80H),A
; I'V ALSO COMMENTED OUT THESE TWO LINES AFTER THE DELAY LOOP:
;    IN A,(81H)          ; LOAD 8 WITH VALUE OF SWITCHES
;    LD (DELAYTIME+1),A


; THIS PROGRAM IS FOR THE SOUTHERN CROSS
; Z80 COMPUTER

; V 1.0 -- USING AZ80 ASSEMBLER
; -- RICKY BRYCE

; BE SURE TO CROSSOVER TX/RX IN CABLE

    ORG 2000H       ; PROGRAM STARTS AT 2000H
    
; DEFINE PRESETS FOR DELAY LOOP
; TO INCREMENT EVERY SECOND (TRIAL AND ERROR)

; ** BEGIN HEAD **
; THESE SETTINGS WILL COARSE ADJUST CLOCK CALIBRATION
; FOR FINER TUNING USE NOPS IN DELAY LOOP
DELAYLOW: EQU 01H    ; DELAY LOW BYTE START 51H
DELAYHIGH: EQU 01; 	; DELAY HIGH BYTE START 01H

; ** END HEAD **


; ** BEGIN INITIALIZE **    
INIT: ; INITIALIZE REGISTERS AND MEMORY
    LD A,0  ; ZERO ACCUMULATOR
    LD IX,OCTAL     ; LOAD IX WITH OCTAL MEMORY LOCATION
    LD (IX+0),A     ; CLEAR LOW OCTAL BYTE
    LD (IX+1),A     ; CLEAR HIGH OCTAL BYTE
    LD (80H),A      ; WRITE 0 TO THE DISPLAY
    LD (COUNTER),A  ; START COUNTER AT ZERO
    LD IX,DELAYTIME ; LOAD IX WITH DELAY TIME MEMORY LOCATION
    LD (IX+0),DELAYLOW  ; HIGH BYTE DELAY LOOP
    LD (IX+1),DELAYHIGH ; LOW BYTE DELAY LOOP
    LD C,CLRBUF         ; CLEAR THE DISPLAY BUFFER BEFORE WE BEGIN
    RST SYSTEM          ; SYSTEM CALL

    
   
; ** BEGIN MAIN ROUTINE **
BEGIN:

    CALL DELAY          ; START BY RUNNING A DELAY LOOP
    LD A,(COUNTER)      ; LOAD A WITH THE COUNTER TO DISPLAY
    INC A               ; INCREMENT A
    LD (COUNTER),A      ; THEN STORE A TO THE COUNTER MEMORY LOCATION
    ;OUT (80H),A         ; SEND THE COUNTER TO THE LEDS

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
    LD A,00H            ; IF VALUE WAS 4, LOAD 00H TO A
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


; ** BEGIN DELAY ROUTINE **
DELAY:
    LD BC,(DELAYTIME)   ; LOAD BC WITH DELAYTIME

FINEDELAY:
    PUSH BC             ; PUSH BC TO STACK (BACKUP)
    LD C,SCAND          ; FUNCTION CODE TO SCAN DISPLAY
    RST SYSTEM          ; CALL THE SYSTEM
    POP BC              ; POP BC FROM STACK (RESTORE)
    DEC BC              ; DECREMENT BC
    LD A,C              ; LOAD A TO C
    OR B                ; SEE IF WE'VE REACHED ZERO YET
    JP NZ,FINEDELAY     ; IF NOT, THEN CONTINUE LOOP

    ; COMMENT OUT THESE TO INSTRUCTIONS IF YOU DO NOT HAVE
    ; AN I/O MODULE
    ;IN A,(81H)          ; LOAD 8 WITH VALUE OF SWITCHES
    ;LD (DELAYTIME+1),A   ; STORE THIS TO HIGH BYTE OF DELAY
                            ; THIS WILL SLOW THE LOOP


    RET                     ; RETURN TO MAIN

; ** END DELAY ROUTINE **




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
				
				
				
; ** END DATA TABLES (ARRAYS) **  

; ** END FOOTER (DEFINE BYTES (DB)) **

; CREATE LABEL (ALIAS) NAMED SYSTEM FOR MONITOR ENTRY POINT
SYSTEM: EQU 30H
BREAK:  EQU 38H

   
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
