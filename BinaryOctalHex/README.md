<h1>Binary, Octal, and Hex Counter</h1>
This program will display Octal on the first 4 digits of the Southern Cross display.  Hexadecimal will be displayed on the rightmost two digits of the display.  
<p>OctalHex -- Requires no I/O Module, but you will not have a binary output.</p> 
<p>BinaryOctalHex -- This file uses the switches for your delay.</p>
<p>BinaryOctalHex2 -- Uses keypad buttons instead of switches, and described below</p>
If you have an I/O module built, set the output address to 80h.  This is for SCNEO firmware, so if you have the ACIA firmware, you will need to change this to an unused port.  Additionally, the F key will perofrm a system break, which is RST 28H in SCNEO.  In other versions, this would be 38h.  The port settings are in the head of the asm file.  After a change, you will have to re-assemble to generate a new hex file with your changes.</p>
<p>This program uses the keypad on the Southern Cross. </p>
<ul>
  <li>Button 0 -- Resets</li>
  <li>Button 1 -- Single Step</li>
  <li>Buttons 2-E -- Speed adjust.  2 is fastest, and E is slowest.</li>
  <li>Button F -- Break</li>
</ul>

<pre>
; THIS PROGRAM IS FOR THE SOUTHERN CROSS
; Z80 COMPUTER BY CRAIG JONES

; PROGRAM TO DISPLAY OCTAL, HEX AND BINARY
; YOU WILL NEED  AN OUTPUT MODULE AT 80H
; FOR LEDS. V2.0

; USE THIS VERSION WITH SCNEO ONLY
; IF YOU HAVE ACIA FIRMWARE, THEN YOU CAN CHANGE
; THE OUTPUT TO AN UNUSED PORT (HARDWARE AND IN THIS PROGRAM)
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

  
</pre>
