<h1>SCMulti</h1>
<p>This project is for educational use, and performs multiple functions on the Southern Cross computer by Craig Jones.  To use this project, 
you will need to build an I/O Module running on port 80H (outputs) and 81H (Inputs).  For information on how to buld an I/O module, check out 
  <a href="https://bryceautomation.com/index.php/2023/07/31/i-o-module-for-the-southern-cross/">this link:</a>.</p>  

<p>I used Z80ASM to compile this by SLR systems.  Just rename the .asm file to a .z80 file to assemble.  
  Other compilers may require some minor coding changes, such as TASM.  TASM tends to use a "." before assembler 
  directives such as .ORG, and .DB.  I wrote this code under WordStar 4.0 as a non-document file.</p>  

<ul>
  <li>Switch 0 -- Port Reflector -- Displays the values of switches on the LED's as long as switch 0 is high.</li>
  <li>Switch 1 -- Binary Counter -- Counts in Binary.  Switch 6 pauses the counter, and switch 7 resets the counter.  
    
  <li>Switch 2 -- Cylon Effect -- Lights will move back and forth.   You can set a separate delay for the cylon than what you use for the binary counter in the source file.</li>
  <li>Switch 3 -- Simple Counter -- The lights will count by 1 each time you turn on switch 7.  Shut Switch 3 off, then on again to reset the Simple Counter</li>
  <li>Switch 4 -- Exit to CP/M --  This is will execute a JP to 00H</li>
  <li>Switch 5 -- Not used</li>
  <li>Switch 6 -- When in Binary Counter Mode with Switch 1, this will pause the counter.</li>
  <li>Switch 7 -- When in Binary Counter Mode with Switch 1, this will reset the counter  When in Simple Counter mode with Switch 3, Switch 7 increments the counter.</li>
</ul>
<p> Be sure to shut all switches off for about 1 second before choosing a different function.</p>
<p>If you use Z80ASM by SLR systems, simply rename the SCMULTI.ASM file to SCMULTI.Z80.  To assemble:  Z80ASM SCMULTI/H (Assuming all files are on the same drive as Z80ASM)</p>

<p>--Ricky Bryce</p>
