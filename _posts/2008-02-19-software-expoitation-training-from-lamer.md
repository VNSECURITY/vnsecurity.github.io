---
title: Software expoitation training from lamer
author: hieu le
excerpt: |
  |
    This is a general review of the Software Exploitation course taught by Nam T. Nguyen (lamer at vnsecurity dot net) [1][2]. All reviews and comments were written by a neophyle in this field.
layout: post
tweetcount:
  - 1
twittercomments:
  - 'a:1:{i:10730874947;s:7:"retweet";}'
shorturls:
  - 'a:4:{s:9:"permalink";s:76:"https://www.vnsecurity.net/2008/02/software-expoitation-training-from-lamer/";s:7:"tinyurl";s:26:"http://tinyurl.com/ybjatar";s:4:"isgd";s:18:"http://is.gd/aOtjO";s:5:"bitly";s:20:"http://bit.ly/6VoJFG";}'
tweetbackscheck:
  - 1408359068
category:
  - news
---
The course lasted 2 days (Feb 16th and 17th, 2008), and, in my opinion, was very interesting. That&#8217;s the motivation for me to write these from a learner&#8217;s point of view.

** Content of the course:**  
 - Stack/Heap overflow, focusing on stack overflow because of difficulty of Heap overflow with these techniques:  
   + Return to libc (ret2libc)  
   + Return to pop (ret2pop)  
   + Overwrite .got, .dtors &#8230; if the program was compiled with ASLR (Address Space Layout Randomization) support.  
 - Format string  
 - Race condition (TOC/TOU &#8211; Time of Check/Time of Use)

** Requirements:**  
 - 01 laptop with DVD drive  
 - VMWare player [3] installed  
 - Basic knowledge of Linux and typical commands  
 - Basic knowledge of programing  
 - Basic knowledge of Assembly

The knowledge of Linux and Assembly is not required but learners can learn faster with them.

The learners will also gain the knowledge of using:  
 - IDA [4]  
 - gdb [5]  
 - python [6]

This is the most practical and beneficial course that I have ever attended. I was naturally sucked into the flow of solving problems. These are what I have noticed:  
 - The course flows from extremely basic information to very advanced knowledge.  
 - The learners will develop their skills based on these basic techniques.  
 - Studying and practicing simultaneously  
 - Interative learning, the learners must answer many questions throughout the course. This is very useful because the instructor can know whether they &#8220;get it&#8221;.  
 - The learners must think and solve problems themselves in a logical way based on the knowledge they have just had.  
 - Analyzing and predicting are two skills used throughout the course.  
 - The instructor has prepared the course carefully so that every sentence, or idea is valuable.  
 - The course is the experience of the instructor so it is very short but it fully covers all information that would require hundreds of pages to explain.  
 - This is the first time I could read and understand the flow chart of one program based entirely on its ASM code; then, exploit it.

** Conclusion**  
I highly appreciate this course because of its outstanding quality. The experience and skill of the instructor make me believe in what I have learned. If there&#8217;s any advanced course from lamer, I&#8217;ll attend.

** References **  
[1] VNSecurity &#8211; a non-profit research organization dedicated to network and system security. Their team has won the CTF2007’s first prize at HITB2007 Malaysia. VNSec was found and led by Thanh Nguyen (rd at vnsecurify dot net).

[2] Nam T. Nguyễn (Security+, CISSP) – a member of vnsecurity.net  
[3] VMWare Player – a software to run a virtual machine. See more at www.vmware.com/products/player/  
[4] IDA – a powerful disassembler. See more at www.hex-rays.com/idapro  
[5] GDB – GNU debugger. See more at www.sourceware.org/gdb/  
[6] Python – a powerful programming language. See more at www.python.org. There’s a website for Vietnamese who loves Python at [www.vithon.org][1]. This site was found and led by Nam T. Nguyễn.

 [1]: http://www.vithon.org/