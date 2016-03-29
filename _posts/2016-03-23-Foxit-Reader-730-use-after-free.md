---
title: 'Foxit Reader 7.3.0  Use-After-Free (patched in 7.3.4 recently)'
author: suto
layout: post
thumbnail: 
excerpt: The poc for Foxit Reader 7.3.0 UAF vulnerability.
category: research
tags:
  - poc
  - bug
  - exploit
---

When opening the x.pdf file (at the end of this post) in Foxit Reader, it will show a popup indicating PDF file is corrupted.

<img alt="IDA" src="http://vnsecurity.net/assets/2016/03/foxit-popup.png"  width="800px" />

Clicking on the OK button will lead to the following crash
<img alt="IDA" src="http://vnsecurity.net/assets/2016/03/foxit-crash.png"  width="700px" />

The problem occurs because after the button is clicked, some structure allocated on the heap has been Freed, but the pointer is not cleared and reused later then led to crash.

If attacker can manage to reallocate the heap before reused, he can execute arbitrary code under the context of Foxit Reader. (Currently, I have managed to double free the heap address so you can try :) This is just a 1day bug so I'm not digging more)

{% gist loianhtuan/cabe4f075e4447ff7c75 %}
