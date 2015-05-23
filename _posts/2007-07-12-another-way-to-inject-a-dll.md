---
title: Another way to inject a DLL
author: mikado
excerpt: |
  |
    There's nothing new. This method is based on method CreateRemoteThread() and CEngine::EngineTrap() in my previous blog entry.
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
shorturls:
  - 'a:4:{s:9:"permalink";s:62:"http://www.vnsecurity.net/2007/07/another-way-to-inject-a-dll/";s:7:"tinyurl";s:26:"http://tinyurl.com/y8zlc5g";s:4:"isgd";s:18:"http://is.gd/aOucv";s:5:"bitly";s:0:"";}'
tweetbackscheck:
  - 1408359062
category:
  - tutorials
---
Read this first: <a class="generated" href="archive/2007/07/10/ollydbg-plugin-catcha-v1-1-catcha-anywhere">OllyDbg plugin: Catcha! v1.1 &#8211; Catcha anywhere</a> 

Nothing special <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_biggrin.gif" alt=":D" class="wp-smiley" /> Just write a trap function that call LoadLibrary() function&#8230; 

Pros:  
- We have an advantage that we don&#8217;t have to call CreateRemoteThread() function. 

Cons:  
- Must pause target process to hook its EntryPoint :D.