---
title: 'How to recover RSA private key in a coredump of ssh-agent &#8211; Sapheads HackJam 2009 Challenge 6'
author: thaidn
excerpt: |
  |
    As the title of this entry suggests, this is the writeup of challenge 6 which is IMHO the coolest CTF challenge ever :-D. I really like its concept and implementation. Thank you whats ^_^!
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:9:"permalink";s:127:"https://www.vnsecurity.net/2009/10/how-to-recover-rsa-private-key-in-a-coredump-of-ssh-agent-sapheads-hackjam-2009-challenge-6/";s:7:"tinyurl";s:26:"http://tinyurl.com/ybjkuag";s:4:"isgd";s:18:"http://is.gd/aOt8v";s:5:"bitly";s:20:"http://bit.ly/7OTwbd";}'
tweetbackscheck:
  - 1408358991
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
Last week or so I joined CLGT to take part in [HackJam 2009][1] by Sapheads. AFAIK this is the first CTF that Sapheads organizes, but they had done a very good job. To most people&#8217;s surprise, the contest attacted quite a lot of teams from around the world, and it had quickly become an international competition.

Did I tell you that [we&#8217;re the winner][2]? Ha ha ha this is our very first win since the name CLGT was born.

BTW, HackJam 2009 was a success because Sapheads had kept their promise which is to &#8220;provide challenges that greatly resemble real world scenarios and environments, at the same time, adding fun and educational ingredients to them&#8221;. We really had fun ^\_^, not disturbing pains \*\_\*, in solving the challenges. Thank you Sapheads! We&#8217;re looking forward to HackJam 2010.

I promised to some people in #sapheads that I would release some writeups about the challenges after the contest ended, and here they are. Sorry for the delay, I have been busy working with vendors on [this][3] which you may want to read too.

I&#8217;ll post writeups of challenge 4, 6, 7, 8, 9 on this blog and [CLGT&#8217;s homepage][4] in the next two weeks. These are the challenges that I solved or helped to solve. I leave out challenge 1 and challenge 2 because they are trivial. I was out or sleeping when the team solved challenge 3 and 5, so I guess I don&#8217;t write nothing about them either. You can download all the binaries in the contest [here][5].

I hope you enjoy reading them as much as I enjoy writing them.

&#8212;&#8212;-

As the title of this entry suggests, this is the writeup of challenge 6 which is IMHO the coolest CTF challenge ever :-D. I really like its concept and implementation. Thank you whats ^_^!

<!--img src="http://hackjam.sapheads.org/cartoons/06_01.jpg">-->

  
<img />

For those who didn&#8217;t take part in HackJam, these two men are the criminals who had stolen and leaked a new album of [SNSD][6] (you should check these girls out ^_^). All teams are in charged of tracking them down.

As you can see in the comic, the criminals got a coredump when they were trying to transfer a MP3 to his server at 67.202.60.164. And that coredump is the only file given in challenge 6.

So first thing first:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ file core.6261

core.6261: ELF 32-bit LSB core file Intel 80386, version 1 (SYSV), SVR4-style, from 'ssh-agent'</pre>

As you can see, this is a coredump of ssh-agent. This is from the manpage of ssh-agent:

> ssh-agent is a program to hold private keys used for public key  
> authentication (RSA, DSA). The idea is that ssh-agent is started in the  
> beginning of an X-session or a login session, and all other windows or  
> programs are started as clients to the ssh-agent program.

The manpage doesn&#8217;t tell where ssh-agent stores private keys, but one can guess that it would store them in its memory. When ssh-agent crashes, all of its memory content would be written to the coredump. So I guess the idea of challenge 6 is to recover the private key of the criminals stored in the coredump, and use that private key to SSH into 67.202.60.164 which may give me the key for challenge 7.

This is why Sapheads challenges are better than other CTFs. They don&#8217;t try to distract us by giving false trails. They give good trails which can be deduced using logical thinking. This challenge also greatly resembles real world scenario which in turn makes it much more interesting than other non-sense challenges somehow created only to show that their authors are smarter than others.

Okie enough bullshit, let&#8217;s get back to challenge 6. As whats from Sapheads suggests, I take a look at static variables of ssh-agent.c which are defined like below:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">typedef struct identity {
 TAILQ_ENTRY(identity) next;
 Key *key;
 char *comment;
 u_int death;
 u_int confirm;
} Identity;

typedef struct {
 int nentries;
 TAILQ_HEAD(idqueue, identity) idlist;
} Idtab;

/* private key table, one per protocol version */
Idtab idtable[3];
int max_fd = 0;
/* pid of shell == parent of agent */
pid_t parent_pid = -1;
u_int parent_alive_interval = 0;
/* pathname and directory for AUTH_SOCKET */
char socket_name[MAXPATHLEN];
char socket_dir[MAXPATHLEN];</pre></blockquote> 

So right above socket_name are 3 integers, and then comes idtable which contains pointers to Identity structures, which in turn contains pointers to Key structures. This is how a Key structure looks like (it&#8217;s in openssh/key.h):

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">struct Key {
 int     type;
 int     flags;
 RSA    *rsa;
 DSA    *dsa;
};</pre>

Ah RSA structure! This is how it looks like (it&#8217;s in openssl/rsa.h):

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">struct rsa_st
 {
 /* The first parameter is used to pickup errors where
 * this is passed instead of aEVP_PKEY, it is set to 0 */
 int pad;
 long version;
 const RSA_METHOD *meth;
 /* functional reference if 'meth' is ENGINE-provided */
 ENGINE *engine;
 BIGNUM *n;
 BIGNUM *e;
 BIGNUM *d;
 BIGNUM *p;
 BIGNUM *q;
 BIGNUM *dmp1;
 BIGNUM *dmq1;
 BIGNUM *iqmp;
 /* be careful using this if the RSA structure is shared */
 CRYPTO_EX_DATA ex_data;
 int references;
 int flags;
 /* Used to cache montgomery values */
 BN_MONT_CTX *_method_mod_n;
 BN_MONT_CTX *_method_mod_p;
 BN_MONT_CTX *_method_mod_q;
 /* all BIGNUM values are actually in the following data,
  * if it is not NULL */
 char *bignum_data;
 BN_BLINDING *blinding;
 BN_BLINDING *mt_blinding;
 };

typedef bignum_st BIGNUM;
struct bignum_st
 {
 BN_ULONG *d;    /* Pointer to an array of 'BN_BITS2' bit chunks. */
 int top;    /* Index of last used d +1. */
 /* The next are internal book keeping for bn_expand. */
 int dmax;    /* Size of the d array. */
 int neg;    /* one if the number is negative */
 int flags;
 };</pre>

As one can expect, a RSA structure contains n, e, d, p, q and some other data. We need to get these numbers, which are stored in BIGNUM structures, out of the coredump. So the next thing to do is know where idtable is in the coredump. I load the coredump into [bless][7], my favourite hex editor (click on the image to zoom in):

[<img id="BLOGGER_PHOTO_ID_5387580359257709602" style="text-align: center" src="http://2.bp.blogspot.com/_A7OX4bvgkXY/SsSHyshtXCI/AAAAAAAAAC4/vPh2OVvPJA0/s200/Screenshot--home-thaidn-stuff-download-pulltheplug-ctf-hj2009-gate6-core.6261+-+Bless.png" />][8]  
As you can see, at offset 0x13b0 is socket\_name. Based on the analysis of the last paragraph, we can guess that max\_fd, parent\_pid, and parent\_alive_interval are stored in 12 bytes between offset 0x13a4 and 0x13af. Then one can ask, what are those 16 null bytes from offset 0&#215;1394 to 0x13a3? I don&#8217;t know. If you know, please drop me a line. But I know for sure, idtable is stored in 36 bytes from offset 0&#215;1370 to 0&#215;1393, just right before those weird 16 null bytes.

The idtable array has 3 entries, one for each SSH protocol version. Each entry is an structure whose length is 12 bytes (hence 36 bytes for the whole array). When ssh-agent starts, each Idtab is initiated like this:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">TAILQ_INIT(&idtable.idlist);
idtable.nentries = 0;</pre>

where TAILQ_INIT is a macro defined in sys/queue.h as following:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">#define    TAILQ_INIT(head) do {
 (head)-&gt;tqh_first = NULL;
 (head)-&gt;tqh_last = &(head)-&gt;tqh_first;
} while (/*CONSTCOND*/0)</pre>

So after initiation, an Idtab structure would contain 1 zero integer for nentries, 1 null pointer for idlist.tqh\_first, and 1 pointer for idlist.tqh\_last which points back to idlist.tqh_first. Looking at the coredump, one can see that the first two Idtab entries of idtable don&#8217;t contain any key information because their nentries is 0. This is as expected, since SSH protocol 1 and 1.1 are long deprecated. The last entry of idtable is the Idtab of SSH protocol version 2. As one can see, its nenetries is 1, and we can guess that the pointer 0x0806E3B8 is pointing to an identity structure which contains 4 pointers and 2 integers. Let&#8217;s see if this is the case:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">$ gdb /usr/bin/ssh-agent core.6261
Core was generated by `/usr/bin/ssh-agent'.
[New process 6261]
#0  0xb7f55424 in __kernel_vsyscall ()

(gdb) x/6x 0x0806E3B8
0x806e3b8:    0x00000000    0x0806297c    0x0806e158    0x0806e3a8
0x806e3c8:    0x00000000    0x00000000

(gdb) x/s 0x0806e3a8
0x806e3a8:     "id_rsa"</pre>

As you can see, the 4th pointer is comment. So the 3rd pointer should be key, i.e. it should point to a Key structure which contains 2 integers and 2 pointerss:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">(gdb) x/4x 0x0806e158
0x806e158:    0x00000001    0x00000000    0x0806e170    0x00000000</pre>

If everything is correct, the pointer 0x0806e170 should point to a RSA structure:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">(gdb) x/22x 0x0806e170
0x806e170:    0x00000000    0x00000000    0xb7ed5840    0x00000000
0x806e180:    0x0806e210    0x0806e228    0x0806e240    0x0806e288
0x806e190:    0x0806e270    0x0806e2b8    0x0806e2a0    0x0806e258
0x806e1a0:    0x00000000    0x00000000    0x00000001    0x0000000e
0x806e1b0:    0x00000000    0x00000000    0x00000000    0x00000000
0x806e1c0:    0x0806e950    0x00000000</pre>

How to be sure this is a RSA structure? Is there any known value to test? Fortunately, the answer is yes. If this is a RSA structure, the 6th pointer 0x0806e228 should point to a BIGNUM structure containing the value of the e parameter which should be 0&#215;23, the default value that ssh-keygen uses for e. Let&#8217;s see:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">(gdb) x/5x 0x0806e228
0x806e228:    0x0806e2e0    0x00000001    0x00000001    0x00000000
0x806e238:    0x00000001

(gdb) x/2x 0x0806e2e0
0x806e2e0:    0x00000023  0xb7d39150</pre>

Yay! We got it!

The next step is to extract all the parameters. It was not as easy as it sounds though. I spent quite a lot of time to read out the value of these parameters due to my ignorant of big-edian and little-edian storage. But I managed to get them out eventually. I generated the RSA private key from p and q, and used it to SSH into 67.202.60.164 which indeed gave me the key for challenge 7. I got my first breakthrough he he he.

That&#8217;s it. Thanks for reading.

Err&#8230;but how to generate RSA private key from n, d, e, p and q? I&#8217;m glad that you ask. Tools like openssl can not help in this case. You must write your own tool. I suggest you taking a look at ASN.1. There&#8217;s a very good tutorial [here][9].

If you understand ASN.1, I&#8217;m pretty sure you&#8217;d know how to generate RSA private key from its parameters. You can use [pyasn1][10] which is a very good ASN.1 library for Python. I can&#8217;t release my tool because it&#8217;s part of the upcoming CTF that I&#8217;m organizing. After that CTF, I&#8217;ll update this post with the tool.

 [1]: http://hackjam.sapheads.org/
 [2]: http://hackjam.sapheads.org/?p=rank
 [3]: http://vnhacker.blogspot.com/2009/09/flickrs-api-signature-forgery.html
 [4]: ../../../
 [5]: http://www.wekk.net/files/hackjam.tar.gz
 [6]: http://snsdkorean.wordpress.com/
 [7]: http://home.gna.org/bless/
 [8]: http://2.bp.blogspot.com/_A7OX4bvgkXY/SsSHyshtXCI/AAAAAAAAAC4/vPh2OVvPJA0/s1600-h/Screenshot--home-thaidn-stuff-download-pulltheplug-ctf-hj2009-gate6-core.6261+-+Bless.png
 [9]: http://luca.ntop.org/Teaching/Appunti/asn1.html
 [10]: http://pyasn1.sourceforge.net/