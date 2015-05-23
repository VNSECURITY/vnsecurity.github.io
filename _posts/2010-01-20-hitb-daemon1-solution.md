---
title: HITB Daemon1 Solution
author: suto
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:9:"permalink";s:56:"http://www.vnsecurity.net/2010/01/hitb-daemon1-solution/";s:7:"tinyurl";s:26:"http://tinyurl.com/yahnmyk";s:4:"isgd";s:18:"http://is.gd/aOufL";s:5:"bitly";s:0:"";}'
tweetbackscheck:
  - 1408358985
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
tags:
  - '2009'
  - 'CTF - CLGT Crew'
  - hitb
---
Here is my next solution for HITB CTF 2009 Daemon1. Similar to [daemon 6][1], the flag is the content of errorcode.txt file located in the same directory with daemon&#8217;s binary.

<pre class="brush: bash; gutter: false; title: ; notranslate" title="">home suto # netstat -tulpan
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:4444            0.0.0.0:*               LISTEN   6174/daemon1
</pre>

So you can see it listens on port 4444. Next I tried to find where the daemon processes my input.

<pre class="brush: python; highlight: [13,24]; title: ; notranslate" title="">.text:080494F1                 push    eax
.text:080494F2                 call    _recv
.text:080494F7                 add     esp, 10h
.text:080494FA                 cmp     eax, 0
.text:080494FD                 jle     loc_80495D2
.text:08049503                 push    esi
.text:08049504                 push    eax
.text:08049505                 lea     esi, [ebp-538h]
.text:0804950B                 push    esi
.text:0804950C                 mov     ecx, [ebp-548h]
.text:08049512                 push    ecx
.text:08049513                 call    sub_804A2B0
.text:08049518                 mov     eax, offset aIcvykbmukcrwdp ; &quot;iCvYkBMuKcrwDPkAqmCFgOKVeV34&quot;
.text:0804951D                 mov     ecx, 1Ch
.text:08049522                 cld
.text:08049523                 mov     esi, [ebp-560h]
.text:08049529                 mov     edi, eax
.text:0804952B                 repe cmpsb
.text:0804952D                 setnbe  dl
.text:08049530                 setb    al
.text:08049533                 add     esp, 10h
.text:08049536                 cmp     dl, al
.text:08049538                 jnz     loc_80495FF
.text:0804953E                 call    sub_8048F10
.text:08049543                 push    0
.text:08049545                 sub     esp, 8
.text:08049548                 push    offset s
.text:0804954D                 call    _strlen
.text:08049552                 add     esp, 0Ch
.text:08049555                 push    eax
.text:08049556                 push    offset s
.text:0804955B
.text:0804955B loc_804955B:                            ; CODE XREF: .text:08049608j
.text:0804955B                 mov     edx, [ebp-548h]
.text:08049561                 push    edx
.text:08049562                 call    _send

</pre>

And here is what sub_8048F10 does:

<pre class="brush: python; title: ; notranslate" title="">lea     edi, [ebp+var_40]
mov     esi, offset unk_80553D2
mov     ecx, edx
rep movsd
mov     ax, ds:word_80553EA
mov     [edi], ax
push    (offset aSocketError+0Bh) ; modes
push    offset filename ; &quot;/home/d1/errorcode.txt&quot;
call    _fopen
&lt;snip&gt;
</pre>

The code compares &#8220;**iCvYkBMuKcrwDPkAqmCFgOKVeV34**&#8221; with the input string. If it&#8217;s matched, the encrypted content of errorcode.txt will be returned.

<pre class="brush: bash; gutter: false; title: ; notranslate" title="">home suto #nc localhost 4444

iCvYkBMuKcrwDPkAqmCFgOKVeV34

ddddddddddPfddddfdssqpfdddddddddhfh
</pre>

&#8220;ddddddddddPfddddfdssqpfdddddddddhfh&#8221; is the return data. It&#8217;s the encrypted content of errorcode.txt (which is &#8220;1&#8243; in this case).

After few hours trying to reverse the binary, I got stuck with the encoding algorithm so I tried to analysis the output data instead.

Input: 1  
Ouput: ddddddddddPfddddfdssqpfdddddddddhfh

Input: 2  
Output: ddddddddddPfdddddfdssqpfhfh

Input: 3  
Output: ddddddddddPfdddddfdssqpfdhfh

Input: 4  
Output: ddddddddddPfdddddfdssqpfddhfh

==>Output string begins with ddddddddddPfdddddfdssqpf and ends with hfh, number 1 is the special case.

9  
ddddddddddPfdddddfdssqpfdddddddhfh

Next, we test with 2 numbers:

24  
<span style="color: #ff0000">ddddddddddPfdddddfdssqpfhddhfh</span>

3 numbers:

247  
<span style="color: #ff0000">ddddddddddPfdddddfdssqpfhdd</span><span style="color: #00FF00">hddd</span>hfh

We can see that the string with red color is the same as the output for 24, and the green part is addition part for 7, so I guess h is character to begin a new number, let&#8217;s see with 6 numbers:

247398  
ddddddddddPfdddddfdssqpf**h**dd**h**ddd**h**qqqq**h**dddddd**h**qhfh

Now the algorithm is more clear :), the length of input number is the number of &#8216;h&#8217; in the encoded data + 1 (we don&#8217;t count the last &#8216;hfh&#8217;). But how about q and d?

From 247398:  
ddddddddddPfdddddfdssqpf<span style="color: #ff0000">hdd</span><span style="color: #00ff00">hddd</span><span style="color: #ff0000">hqqqq</span><span style="color: #00ff00">hdddddd</span><span style="color: #ff0000">hq</span>hfh  
4 is hdd  
7 is hddd  
3 is hqqqq  
9 is hdddddd  
8 is hq

Yeah! when the next number is increased, it uses a d for +1 (7 = 4 + 3 = hddd).  
q is used for decrease (-1).

35896742  
ddddddddddPfdddddfdssqp<span style="text-decoration: underline"> <span style="color: #ff0000"><strong>fd[<span style="color: #333300">3</span>]</strong></span></span><span style="color: #ff0000"><strong> </strong></span> **<span style="color: #ff0000">hdd</span>**[5] <span style="color: #ff0000"><strong>hddd</strong></span>[8] **<span style="color: #ff0000">hd[<span style="color: #333300">9</span>]</span>** **<span style="color: #ff0000">hqqq[<span style="color: #333300">6</span>]</span>** **<span style="color: #ff0000">hd[<span style="color: #333300">7</span>]</span>** **<span style="color: #ff0000">hqqq[<span style="color: #333300">4</span>]</span><span style="color: #ff0000"> hqq[<span style="color: #333300">2</span>]</span>**hfh

Why 3? You answer yourself !

Now we come back to special cases for number 1 and 0

358967421  
ddddddddddPfdddddfd<span style="color: #ff0000"><strong>d</strong><strong>ddfds</strong></span>ssqpfdhddhdddhdhqqqhdhqqqhqq<span style="color: #ff0000"><strong>h</strong><strong>fddddddddd</strong></span>hfh

Here is output for 35896742  
ddddddddddPfdddddfdssqpfdhddhdddhdhqqqhdhqqqhqqhfh

The different parts are marked with Red color.

Put 1 in the middle:  
3589617421  
ddddddddddPfdddddfd<span style="color: #ff0000"><strong>d</strong><strong>ddfds</strong></span>ssqpfdhddhdddhdhqqq**<span style="color: #ff0000">hfddddddddd</span><span style="color: #00ff00">hsd</span>**hqqqhqq**<span style="color: #ff0000">hf</span>**hfh

358967421  
ddddddddddPfdddddfd<span style="color: #ff0000"><strong>dddfds</strong></span>ssqpfdhddhdddhdhqqqhdhqqqhqq**<span style="color: #ff0000">hfddddddddd</span>**hfh

35896742

ddddddddddPfdddddfdssqpfdhddhdddhdhqqqhdhqqqhqqhfh

So the output will be fdddddddddh for number 1. If 1 is in the middle, it will be dddfds.  
And another notes is hsd , one &#8220;d&#8221; character because it is calculated from the number before &#8220;1&#8243; &#8211; 6- and increases it to -7-.

Another test:

4668981445134  
ddddddddddPfdddddf<span style="color: #ff0000"><strong>d</strong><strong>dddfds</strong></span>ssqpfdd<span style="color: #ff0000">(<strong>4)</strong></span>hdd**<span style="color: #ff0000">(6)</span>**h**<span style="color: #ff0000">(6)</span>**hdd**<span style="color: #ff0000">(8)</span>**hd<span style="color: #ff0000"><strong>(9)</strong></span>hq**<span style="color: #ff0000">(8)</span>**hfddddddddd**<span style="color: #ff0000">(1)</span>**hsqqqq**<span style="color: #ff0000">(4)</span>**h<span style="color: #ff0000">(4)</span>

hd<span style="color: #ff0000"><strong>(5) </strong></span>hf**<span style="color: #ff0000">(1</span>**)hs qq**<span style="color: #ff0000">(3)</span>** hd**<span style="color:#ff0000">(4)</span>** hffh

Now replace the number 1 with 0 from previous input:

ddddddddddPfdddddfd<span style="color: #ff0000"><strong>dddfds</strong></span>ssqpfdd<span style="color: #0000ff"><strong>(4)</strong></span>hdd**<span style="color: #0000ff">(6)</span>**h**<span style="color: #0000ff">(6)</span>**hdd<span style="color: #0000ff"><strong>(8)</strong></span>hd**<span style="color: #0000ff">(9)</span>**hq**<span style="color: #0000ff">(8)</span><span style="color: #ff0000">hfdddddddd</span><span style="color: #0000ff">(0)</span>**hsqqqq**<span style="color: #0000ff">(4)</span>**h**<span style="color: #0000ff">(4)</span>**hd<span style="color: #0000ff"><strong>(5)</strong></span>

hf<span style="color: #0000ff"><strong>(0)</strong></span>hsqq**<span style="color: #0000ff">(3) </span>**hd<span style="color: #0000ff"><strong>(4)</strong></span>hffh

We see 0 is quite similar to 1 with one &#8216;d&#8217; less.

Now it&#8217;s just a simple task to decode the return content of errorcode.txt (flag) from the daemon.

And it&#8217;s all about daemon1 in HITB CTF 2009!

 [1]: http://www.vnsecurity.net/2009/12/hitb-2009-daemon6-write-up/