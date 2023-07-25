# SouthernCross
Programs for the Southern Cross Z80 Computer

<h2>SCCStopWatchV1:</h2>

SCCStopWatchV1 is a stop watch program for the Southern Cross Computer, which is designed by Craig Jones.  This program is based on the scan of the Z80 processor at 4Mhz.  After sending your program to the Southern Cross, type G 2000 on your Serial Terminal, or simply press Fn-0 on the keypad.  + will start the Stop Watch, and - will pause.  0 resets.

<b>Known Issues:</b><p>
In order to allow time for the "click" every second, the hundredths will run from 0 to 99 in approximately 950 ms.  This does affect the accuracy of the hundredths.

<b>Stop Watch Accuracy:</b><p>
I've tested this stop watch for an accuracy of 10 minutes.  To calibrate the time, simply add or remove NOP instructions in the delay loop.
