; SIMPLE CYLONG PROGRAM
; YOU WILL NEED AN INPUT MODULE AT 81H, AND AN
; OUTPUT MODULE AT 80H FOR LEDS AND TIME DELAY
;
; CHECK BRYCEAUTOMAITON.COM TO BUILD THE I/O MODULE
;https://bryceautomation.com/index.php/2023/07/31/i-o-module-for-the-southern-cross/
;
; SWITCHES AT 81H DETERMINE THE HIGH BYTE OF
; THE DELAY LOOP

; THIS PROGRAM IS FOR THE SOUTHERN CROSS
; Z80 COMPUTER

; V 1.0 -- USING AZ80 ASSEMBLER
; -- RICKY BRYCE

; ** BEGIN HEAD **
; THESE SETTINGS WILL COARSE ADJUST CLOCK CALIBRATION
; FOR FINER TUNING USE NOPS IN DELAY LOOP
DELAYLOW: EQU 0FFH   ; DELAY LOW BYTE START 51H
DELAYHIGH: EQU 00; 	; DELAY HIGH BYTE START 01H
                    ; THIS WILL BE REPLACED LATER IN THE PROGRAM
                    ; BY THE SWITCH SETTINGS

; ** END HEAD **

    ORG 2000H       ; PROGRAM STARTS AT 2000H
    
; ** BEGIN INITIALIZE **    
INIT: ; INITIALIZE REGISTERS AND MEMORY
    LD A,0  ; ZERO ACCUMULATOR
    LD (80H),A      ; WRITE 0 TO THE DISPLAY
    LD IX,DELAYTIME ; LOAD IX WITH DELAY TIME MEMORY LOCATION
    LD (IX+0),DELAYLOW  ; HIGH BYTE DELAY LOOP
    LD (IX+1),DELAYHIGH ; LOW BYTE DELAY LOOP
    LD A,80H
    LD (ROTMEM),A
    OUT (80H),A
; ** END INITIALIZE ***
       
; ** BEGIN MAIN ROUTINE **
BEGIN:

RROT:
    OR A                ; CLEAR CARRY
    CALL DELAY          ; START BY RUNNING A DELAY LOOP
    LD A,(ROTMEM)       ; LOAD A FROM MEMORY
    RRA                 ; ROTATE A
    LD (ROTMEM),A       ; STORE A TO MEMORY
    OUT (80H),A         ; SEND A TO THE LEDS
    CP 01H
    JP NZ,RROT
LROT:
    OR A                ; CLEAR CARRY
    CALL DELAY          ; DELAY ONCE AGAIN
    LD A,(ROTMEM)       ; LOAD A FROM MEMORY
    RLA                 ; ROTATE A
    LD (ROTMEM),A       ; STORE A TO MEMORY
    OUT (80H),A         ; SEND A TO THE LEDS
    CP 80H
    JP NZ,LROT
    JR BEGIN
    
; ** BEGIN DELAY ROUTINE **
DELAY:
    ; THIS IS SIMPLY A DELAY ROUTINE.  IT IS DESTRUCTIVE TO 
    ; A AND BC.  THE HIGH BYTE OF THE DELAY LOOP IS RETRIEVED
    ; FROM THE SWITCHES AT PORT 81H
    IN A,(81H)          ; LOAD 8 WITH VALUE OF SWITCHES
    LD (DELAYTIME+1),A   ; STORE THIS TO HIGH BYTE OF DELAY
    LD BC,(DELAYTIME)   ; LOAD BC WITH DELAYTIME
; NEST DELAY LOOPS
DELAY1:
    LD D,0BH            ; LOAD A STARTING VALUE TO D... WITHOUT THIS
                        ; THE LIGHT WILL BLINK TO FAST FOR LOWER VALUES
                        ; OF SWITCHES.
DELAY2:
    DEC D               ; DECREMENT DE FOR INNER LOOP
    JP NZ,DELAY2        ; IF SO, THEN JUMP TO DELAY2
    
    DEC BC              ; DECREMENT BC
    LD A,C              ; LOAD A FROM C
    OR B                ; SEE IF WE'VE REACHED ZERO YET
    JP NZ,DELAY1     ; IF NOT, THEN CONTINUE LOOP
    RET                     ; RETURN TO MAIN
; ** END DELAY ROUTINE **
    
; ** BEGIN FOOTER (DEFINE BYTES (DB)) **
    ORG 2100H	; AVOID CROSSING PAGE BOUNDARY
    
; ** BEGIN DATA TABLES (ARRAYS) **
DELAYTIME: 		; FOR DELAY LOOPS
    DB 00H,00H 	; THESE WILL BE OVERWRITTEN WITH
				;CONSTANTS DEFINED IN HEADER
ROTMEM:
    DB 00H
; ** END FOOTER (DEFINE BYTES (DB)) ***


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

				
