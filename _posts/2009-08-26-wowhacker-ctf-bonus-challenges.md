---
title: 'WOWHacker CTF &#8211; Bonus Challenges'
author: superkhung
excerpt: |
  |
    When the preliminary round approached the stop time, WOWHacker added two more bonus challenges. And here is how superkhung solved them.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:66:"https://www.vnsecurity.net/2009/08/wowhacker-ctf-bonus-challenges/";s:7:"tinyurl";s:26:"http://tinyurl.com/ycw5jkz";s:4:"isgd";s:18:"http://is.gd/aOtaC";s:5:"bitly";s:20:"http://bit.ly/6Tgpi6";}'
tweetbackscheck:
  - 1408358996
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
kopa_newsmixlight_total_view:
  - 1
category:
  - 'CTF - CLGT Crew'
---
## **Challenge 15**

**2009ISEC.apm** is actually an Android Package file. Rename **2009ISEC.apm** to **2009ISEC.apk**, install it on an Android phone, then run it, tap on the **About** button, and you&#8217;ll see the answer which is **Wowhacker$%hinehong(ISEC)#$boann**.

## **Challenge 16 **

Challenge 16 is a Windows reversing challenge. The binary **fishing.exe** has a hidden form named **TForm2**. To see this form, one can replace the parameter of the first **Createform()** call at **00475EDC** by the parameter of **TForm2**.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">Original asm code:

00475ED6   MOV EDX,DWORD PTR DS:[4754D8] ;  00475524 &lt;&lt; value of TForm1
00475EDC   CALL 00453694

Patched asm code:

00475ED6   MOV EDX,DWORD PTR DS:[475134] ;  00475180 &lt;&lt; value of TForm2
00475EDC   CALL 00453694</pre>

**TForm2** asks for a password, then it does some calculations and compares the result with **MTRJTWQI7dUwnijTkMnLEWf**.

The password processing routine starts at the loop at **004753B2**:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">004753B2  MOV EAX,DWORD PTR SS:[EBP-8]
004753B5  MOV BL,BYTE PTR DS:[EAX+EDI-1]
004753B9  CMP BL,20
004753BC  JE SHORT 004753DB
004753BE  LEA EAX,DWORD PTR SS:[EBP-8]
004753C1  CALL 00404384
004753C6  MOV EDX,EDI
004753C8  DEC EDX
004753C9  SAR EDX,1
004753CB  JNS SHORT 004753D0
004753CD  ADC EDX,0
004753D0  ADD EDX,EDX
004753D2  SUB BL,DL
004753D4  ADD BL,0A
004753D7  MOV BYTE PTR DS:[EAX+EDI-1],BL
004753DB  INC EDI
004753DC  CMP EDI,1A
004753DF  JNZ SHORT 004753B2</pre>

Notice that this routine is very simple, the most important are 2 operations at

**004753D2** and **004753D4**:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">004753D2  SUB BL,DL
004753D4  ADD BL,0A</pre>

To reverse this routine, we just change subtract to add and add to subtract,  then input the encrypted password string to find out the original password.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">Patched asm code:

004753D2  ADD BL,DL
004753D4  SUB BL,0A</pre>

After patching the asm code like that, we enter the encrypted password string **MTRJTWQI7dUwnijTkMnLEWf** into **TForm2**, and set a break point at the first argument of** LStrCmp()** function at **004753E1** to sniff out the decrypted password.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">004753E1  MOV EAX,DWORD PTR SS:[EBP-8] ; EBP-8 will store the decrypted password
004753E4  MOV EDX,DWORD PTR DS:[479C8C]
004753EA  CALL 00404278 ; call LStrCmp()
</pre>

We will see that encrypted string **MTRJTWQI7dUwnijTkMnLEWf** will be decrypted to **CJJBVNSMG5dUypmnZqUvVOcr**. Use this password on the original app, and we get the final answer: **HOMEWORLD2_PrideOfHiG@Ra**.