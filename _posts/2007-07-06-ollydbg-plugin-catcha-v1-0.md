---
title: 'OllyDbg plugin: Catcha! v1.0'
author: mikado
excerpt: |
  |
    Sometimes you don't know how to start a program correctly
    from OllyDgb. Catcha! plugin will help you to attach to your
    program automatically as soon as possible each time your
    program runs (outside OllyDbg).
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359064
shorturls:
  - 'a:4:{s:9:"permalink";s:61:"http://www.vnsecurity.net/2007/07/ollydbg-plugin-catcha-v1-0/";s:7:"tinyurl";s:26:"http://tinyurl.com/yexr2lt";s:4:"isgd";s:18:"http://is.gd/aOucW";s:5:"bitly";s:0:"";}'
category:
  - tutorials
---
<a title="OllyDbg plugin: Catcha! v1.0" class="generated" href="/vnsec/Members/internal/public/ollydbg-plugin-catcha/Catcha-1.0.rar">OllyDbg plugin: Catcha! v1.0</a>

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">Catcha! v1.0
Coded by mikado @ vnsecurity, 4vn
Website: http://www.vnsecurity.net - http://www.4vn.org
Email: mikado[at]4vn[dot]org

[ About ]
Sometimes you don't know how to start a program correctly
from OllyDgb. Catcha! plugin will help you to attach to your
program automatically as soon as possible each time your
program runs (outside OllyDbg).

It works like Olly De-Attach Helper plugin:

http://www.openrce.org/downloads/details/185/Olly%20De-Attach%20Helper

Catcha! has more advantages than Olly De-Attach Helper.
It helps reversers not to miss many opcodes before attaching
target program.

Check it out! Have fun and feel free to contact me.

[ Instructions ]
- Copy Catcha!.dll and Catcha!.sys to OllyDbg plugin directory.
- First, select target program by chosing menu:
  Plugins -&gt; Catcha! -&gt; Select Catcha! target.
- Run target program outside OllyDbg.
  It will be attached in OllyDbg automatically as soon as possible.
- Press F9 to continue running program or,
  right click on Disassembler window and chose Thread -&gt; Main
  on Popup menu to switch to program's main thread and continue
  your debug session.

[ History ]
2007.07.06:
- Version 1.0 released.

[ Known bugs ]
1. Target program can only be attached automatically one time.
   You have to restart OllyDbg in order for Catcha! to work correctly.
2. Only tested on Windows XP SP2. The kernel driver was built
   on WinDDK with Windows XP Build Environment.

[ TODO ]
- Fix bug (1).
- Implement de-attach function without closing target program.

mikado.
</pre>