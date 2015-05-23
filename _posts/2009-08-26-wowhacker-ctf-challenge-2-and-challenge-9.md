---
title: 'WOWHacker CTF &#8211; Challenge 2 and Challenge 9'
author: thaidn
excerpt: |
  |
    Challenge 2 is simple yet interesting. Challenge 9 is a blind remote stack-based buffer overflow exploitation.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:77:"https://www.vnsecurity.net/2009/08/wowhacker-ctf-challenge-2-and-challenge-9/";s:7:"tinyurl";s:26:"http://tinyurl.com/ya5at8c";s:4:"isgd";s:18:"http://is.gd/aOta2";s:5:"bitly";s:20:"http://bit.ly/8QR40X";}'
tweetbackscheck:
  - 1408358994
twittercomments:
  - 'a:1:{i:10715153393;s:7:"retweet";}'
tweetcount:
  - 1
category:
  - 'CTF - CLGT Crew'
---
## Challenge 2

Challenge 2 is simple yet interesting. The initial target is a Python 2.2 byte-compiled file, so the first job is to decompile it to get the source code. Fortunately,* decompyle* just works:</p> 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ decompyle newbie.pyc

Thu Aug 27 02:13:25 2009
# emacs-mode: -*- python-*-
import urllib
def some_cryption(arg):
    pass
a = 'http://'
dummy = 'http://korea'
b = 'uxcpb.xe'
b = b.encode('rot13')
c = 'co.kr'
cs = '.com'
d = '/vfrp/uxuxux'
dt = '/hackers'
d = d.encode('rot13')
dx = 'coolguys'
ff = urllib.urlopen(((a + b) + d))
f_data = ff.read()
file = open('hkhkhk', 'w')
file.write(f_data)
some_cryption(f_data)
file.close()</pre>

You can see that the purpose of this script is to download some data from a fixed URL, and save them to a file named *hkhkhk*. We ran the script, and it indeed downloaded [this file][1]. As the script suggests, the content of *hkhkhk* is encrypted by some cipher. 

Opening *hkhkhk* in a hex editor, one could see that it contains quite a lot of *0&#215;77* characters. A friend of us, [Julianor][2] from [Netifera][3], thought that *hkhkhk *is an executable file, and because excutable file contains a lot of null bytes so *0&#215;77* may be the null byte in the original file. He suggested xoring the content of *hkhkhk* against *0&#215;77*. We did as he suggested, and it worked :-D. *hkhkhk* turns out to be an ELF executable file:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ file hkhkhk
hkhkhk: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV),
for GNU/Linux 2.2.5, dynamically linked (uses shared libs), stripped

$ ./hkhkhk
./hkhkhk [server] [port]

---------------------------
server&gt; 221.143.48.88
port&gt; 1111, 2222, ..., 9999
---------------------------
</pre>

Disassembling *hkhkhk *reveals that this binary is just a simple client that connects to a remote server to get two integers, and send the sum of them back to that server. If the result is correct (which is always), the server will return a congratulation message like below: 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ ./hkhkhk 221.143.48.88 1111
[(867925) + (9792)] = ?
answer is 877717
it's correct. great!, <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":-)" class="wp-smiley" /> </pre>

At first, we thought we should try to exploit the server to force it to return an error or something, but that didn&#8217;t work. Then we thought there&#8217;s something hidden inside *hkhkhk, so ***superkhung** and I spent 1 hour to inspect every single instruction of the binary, but we saw nothing weird.

At this point, a friend suggested us running the binary inside a debugger. He thought that there may be something hidden in the communication between the server and *hkhkhk*.

The communication? I fired up *wireshark*, and to my surprise, I saw the answer right away: **Pandas likes hkpco XD**. It turns out that the congratulation message is something like:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">it's correct. great!, :-)&lt;b&gt;x00&lt;/b&gt;Password is "Pandas likes hkpco XD"</pre>

This message is passed to a *printf* call, and since *printf* expects a null-terminated string, one could never see the characters after the null byte if he doesn&#8217;t run the binary inside a debugger, or sniff the communication like us.

## Challenge 9

Challenge 9 (IP: 221.143.48.88; port :4600) is a remote stack-based buffer overflow exploitation. It&#8217;s interesting because WOWHacker doesn&#8217;t release the binary as other usual exploitation challenges.

While I was banging my head against challenge 8, **gamma95** told me that he could crash challenge 9 with *293* bytes. He thought that this challenge is very obvious, and wondered why none was working on it.

Actually we were very short on manpower in the first day of the premilinary round. So we chose to work only on those challenges that we were interested in or had a larger chance of solving them.

When I first saw challenge 9, I thought this challenge should be hard. Blind remote exploitation is supposed to be hard you know. This wrong assumption plus the fact that I haven&#8217;t practiced software exploitation in the last several months made me decide to leave this challenge for other teamates who might join us in the second day.

But it turns out this challenge is an easy one.

In order to exploit a stack-based buffer overflow vulnerability, one must know which address to return to. Fortunately, WOWHacker gives us a very helpful hint:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">Mr.Her give you something "call me~ call me~" : bfbfeaf2</pre>

So *0xbfbfeaf2* is the return address. Normally this address should point to the beginning of our input buffer which in turn should have this structure:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">&lt;SHELLCODE&gt;&lt;NOP SLED&gt;&lt;xf2xeaxbfxbf&gt;</pre>

The next problem is to determine how many bytes we need to control the EIP. The trick is to use *xebxfe* as the shellcode, and increase the message one byte a time until we see the service hang after it processes our input. If our theory of the structure of the input buffer is correct, this process will succeed eventually because *xebxfe* means &#8220;loop forever&#8221;:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ echo -ne 'xebxfe' | ndisasm -
00000000  EBFE              jmp short 0x0</pre>

Using this technique, we can see that we need totally 302 bytes to control the EIP:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ (python -c 'print "xebxfe" * 149 + "xf2xeaxbfxbf"'; cat) | nc 221.143.48.88 4600</pre>

We use Metasploit to generate a BSD reverse-shell shellcode, and we got the answer: **WOWHACKER without beist.</p> 
</b>Actually this wasn&#8217;t as easy as we write here. We made two stupid mistakes: first off, we assumed that this challenge ran on a Linux box; secondly, our connect back box was behind a firewall :-(. Thanks **Tora** and **biest** for giving us a hand in resolving them.

 [1]: http://hkpco.kr/isec/hkhkhk
 [2]: http://twitter.com/julianor
 [3]: http://netifera.com/