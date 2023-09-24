Z80ASM SuperFast Relocating Macro Assembler     	    Z80ASM 1.32 Page   1
LCDTEST Z80

    1                   ; THIS PROGRAM IS FOR THE SOUTHERN CROSS
    2                   ; Z80 COMPUTER BY CRAIG JONES
    3                   
    4                   ; PROGRAM TO DISPLAY DATA ON LCD
    5                   ;
    6                   ; LCD IS ADDRESS 50H COMMAND / 51H DATA
    7                   
    8                   
    9                   ; ASSEMBLED USING A80 ASSEMBLER
   10                   ; https://www.retrotechnology.com/
   11                   ; TO COMPILE IN LINUX (AS PER MARK ABENE)
   12                   ; ln -s a65.h A80.H ; (OR VICE VERSA)
   13                   ; gcc -I. -o a65 a80.c a80util.c a80eval.c
   14                   ; THEN CREATE THE FOLLOWING SCRIPT: ASM18 WITH CONTENTS
   15                   
   16                   ; -----------------------------------------------------
   17                   ; #!/bin/bash
   18                   ; ./a80 $1.asm -l $1.lst -o $1.hex
   19                   
   20                   ; -----------------------------------------------------
   21                   ; THEN chmod +x ASM80 TO MAKE IT EXECUTABLE
   22                   ; -- RICKY BRYCE
   23                   
   24                   
   25         2000          ORG 2000H
   26                   ;** HEAD **
   27         0050      CPORT:      EQU 50H
   28         0051      DPORT:      EQU 51H
   29         0080      LINE0:      EQU 80H
   30         00C0      LINE1:      EQU 0C0H
   31         0094      LINE2:      EQU 94H
   32         00D4      LINE3:      EQU 0D4H
   33                   ;** END HEAD **
   34                   
   35                   
   36                   ;** INITIALIZE **
   37 2000  3E 38           LD A,38H           ; 8 BIT 2 LINE 5X7
   38 2002  D3 50           OUT (CPORT),A      ; FUNCTION SET
   39 2004  CD 205F         CALL LCDWAIT
   40 2007  3E 0F           LD A,0FH           ; TURN ON DISPLAY, CURSOR ON, BLINK
   41 2009  D3 50           OUT (CPORT),A      ; DISPLAY ON
   42 200B  CD 205F         CALL LCDWAIT
   43 200E  3E 06           LD A,06H            ; CURSOR MOVE (VS SHIFT DISPLAY)
   44 2010  D3 50           OUT (CPORT),A       ; ENTRY MODE
   45 2012  CD 205F         CALL LCDWAIT
   46 2015  3E 01           LD A,01H            ; CLEAR DISPLAY
   47 2017  D3 50           OUT (CPORT),A       ; CLEAR DISPLAY
   48 2019  CD 205F         CALL LCDWAIT
   49                   
   50                   ;** END INITIALIZE **
   51                   
   52                   
   53                   ;** MAIN ROUTINE **
   54 201C              MAIN:
   55 201C  21 2066         LD HL,FIRSTLINE
   56 201F  3E 80           LD A,LINE0
   57 2021  D3 50           OUT (CPORT),A ; SET FIRST LINE
   58 2023  CD 205F         CALL LCDWAIT
Z80ASM SuperFast Relocating Macro Assembler     	    Z80ASM 1.32 Page   2
LCDTEST Z80

   59 2026  CD 2051         CALL WRCHARS
   60                       
   61                   
   62 2029  21 2075         LD HL,SECONDLINE
   63 202C  3E C0           LD A,LINE1
   64 202E  D3 50           OUT (CPORT),A ; SET SECOND LINE
   65 2030  CD 205F         CALL LCDWAIT
   66 2033  CD 2051         CALL WRCHARS
   67                       
   68 2036  21 2085         LD HL,THIRDLINE
   69 2039  3E 94           LD A,LINE2
   70 203B  D3 50           OUT (CPORT),A ; SET THIRD LINE
   71 203D  CD 205F         CALL LCDWAIT
   72 2040  CD 2051         CALL WRCHARS
   73                       
   74 2043  21 2097         LD HL,FOURTHLINE
   75 2046  3E D4           LD A,LINE3
   76 2048  D3 50           OUT (CPORT),A ; SET FOURTH LINE
   77 204A  CD 205F         CALL LCDWAIT
   78 204D  CD 2051         CALL WRCHARS
   79                       
   80 2050  76              HALT
   81                   
   82                   ;** END MAIN ROUTINE **
   83                   
   84                   ;** WRITE CHARACTERS ROUTINE **
   85 2051              WRCHARS:
   86 2051  7E              LD A,(HL)
   87 2052  FE 24           CP 24H
   88 2054  28 08           JR Z, CHARRET
   89 2056  D3 51           OUT (DPORT),A
   90 2058  CD 205F         CALL LCDWAIT
   91 205B  23              INC HL
   92 205C  18 F3           JR WRCHARS
   93 205E              CHARRET:
   94 205E  C9              RET
   95                   
   96                   
   97                   ;** END WRITE CHARACTERS ROUTINE **
   98                   
   99                   
  100                   ;** LCD WAIT ROUTINE **
  101 205F              LCDWAIT:
  102 205F  DB 50           IN A,(CPORT)
  103 2061  CB 7F           BIT 7,A
  104 2063  20 FA           JR NZ,LCDWAIT
  105 2065  C9              RET
  106                   ;** END LCDWAIT ROUTINE **
  107                   
  108                   
  109                   ;** FOOT **
  110 2066              FIRSTLINE:
  111 2066  53 6F 75 74     DB "Southern Cross$"
  112 2075              SECONDLINE:
  113 2075  20 20 20 5A     DB "   Z80 Computer$"
  114 2085              THIRDLINE:
  115 2085  20 20 20 20     DB "      64k RAM/ROM$"
  116 2097              FOURTHLINE:
Z80ASM SuperFast Relocating Macro Assembler     	    Z80ASM 1.32 Page   3
LCDTEST Z80

  117 2097  52 69 63 6B     DB "Ricky Bryce$"
  118                   ;** END FOOT **
  119                   
  120                       END
 0 Error(s) Detected.
 163 Absolute Bytes. 14 Symbols Detected.
TINE **
   98                