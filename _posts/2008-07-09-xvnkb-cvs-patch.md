---
title: xvnkb cvs patch
author: nm
excerpt: |
  |
    Patch for these problem: power consumption and crash w/ xscreensaver.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:51:"https://www.vnsecurity.net/2008/07/xvnkb-cvs-patch/";s:7:"tinyurl";s:26:"http://tinyurl.com/y8hpps3";s:4:"isgd";s:18:"http://is.gd/aOtdv";s:5:"bitly";s:20:"http://bit.ly/7Z6KPQ";}'
tweetbackscheck:
  - 1408359003
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - tutorials
---
Ngồi mân mê cái laptop thấy cpu bị switch khỏi idle mode rất nhiều. Ngó nghiêng một lúc thấy nguyên nhân là tại xvnkb nhà ta.  usleep(10000) được gọi liên tục trong main.c.

bản patch bonus thêm cái vụ crash với xscreensaver khi gõ password.

<pre class="brush: diff; title: ; notranslate" title="">diff -r ./xvnkb_patch/main.c ./xvnkb_org/main.c

92d91
&lt; XEvent peekEvt;
94,95c93,94
&lt; //usleep(1000);
&lt; XPeekEvent(display, &peekEvt);
---
&gt; usleep(1000);
&gt;
105c104
&lt; do {
---
&gt; while( XPending(display) ) {
110c109
&lt; } while( XPending(display) );
---
&gt; }

diff -r ./xvnkb_patch/xvnkb.c ./xvnkb_org/xvnkb.c
276,285c276
&lt;
&lt; /*
&lt; * CHANGES:
&lt; * - SEG FAULT report & fixed by nm &lt;nm@vnoss.org&gt;
&lt; * problem occur when main app call XLookupString w/ keysym arg = NULL.
&lt; * (xscreensaver/lock.c :: size = XLookupString(event, s, 1, 0, compose_status) )
&lt; * pointer keysym must be validate before used.
&lt; */
&lt; if (keysym)
&lt; *keysym = vk_charset==VKC_UTF8 ? *pw|0x01000000 : (*(char *)buffer & 0xFF);
---
&gt; *keysym = vk_charset==VKC_UTF8 ? *pw|0x01000000 : (*(char *)buffer & 0xFF);
</pre>