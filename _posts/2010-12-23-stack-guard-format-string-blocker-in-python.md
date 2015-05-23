---
title: 'Stack Guard &amp; Format String Blocker in Python'
author: lamer
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:78:"http://www.vnsecurity.net/2010/12/stack-guard-format-string-blocker-in-python/";s:7:"tinyurl";s:26:"http://tinyurl.com/cx4y2vm";s:4:"isgd";s:19:"http://is.gd/cSKNX1";}'
tweetbackscheck:
  - 1408358973
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - research
tags:
  - '2010'
  - breakpoint
  - debugger
  - format string
  - function entry
  - function exit
  - python
  - stack guard
---
[Download the tool][1]

`<br />
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%<br />
Stack Guard & Format String Blocker in Python<br />
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%</p>
<p>  :author:     Nam T. Nguyen<br />
  :copyright:  2010, public domain</p>
<p>(Shamefully admitted that this tool was used in the Capture the Flag game at HITB Kuala Lumpur 2010, and it failed)</p>
<p>The Big Picture<br />
===============</p>
<p>Basically, we are running the application under a debugger. When an interesting event occurs, we process it accordingly.</p>
<p>Stack Guard<br />
-----------</p>
<p>The interesting events are function entry and function exit. When we enter into a function, the value at top of stack is XOR'd with a random value. When we exit from a function, the value at TOS is again XOR'd with that same random value.</p>
<p>Format String<br />
-------------</p>
<p>The interesting events are those ``printf`` family functions. When the function is entered, we just have to check if its format string argument contains ``%n`` or ``%hn``. For some functions (e.g. ``printf```), this argument is at TOS + 4 (leave one for saved EBP), for some others (e.g. ``fprintf``) it is at TOS + 8, yet for some (e.g. ``snprintf``) it is at TOS + 12.</p>
<p>The Problems<br />
============</p>
<p>Breakpoints<br />
-----------</p>
<p>The main issue is with multi-process (fork'd code) applications. Basically, when they fork, the soft-breakpoints (0xCC) are retained but the handler does not attach to the new process. Therefore, when a breakpoint hits, the newly forked process simply dies.</p>
<p>To work around this issue, the ``MultiprocessDebugger`` class is written to remember breakpoints in both original and forked processes. It also kills new image (via ``exec``) to protect against successful exploitation that launches ``/bin/sh``, for example.</p>
<p>Function entries/exits<br />
----------------------</p>
<p>Basically, to find all function entries, and exits, we have to walk the code. A recursive iterator (flattened with a simple queue) is used to visit all functions from a starting location (usually ``main`` function). When a ``CALL`` instruction is reached, its destination is deemed a function entry. When a ``RET`` instruction is reached, this current location is deemed an exit of the the current function. This does not work with indirect calls (``CALL EAX``, for e.g.) because we do not know its destination.</p>
<p>Samples<br />
=======</p>
<p>Please peruse ``target.py`` for a sample usage.<br />
`

 [1]: http://force.vnsecurity.net/download/lamer/guard.zip