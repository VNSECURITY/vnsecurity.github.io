---
title: Fun code snippet
author: lamer
excerpt: \n
layout: post
shorturls:
  - 'a:4:{s:9:"permalink";s:52:"https://www.vnsecurity.net/2008/05/fun-code-snippet/";s:7:"tinyurl";s:26:"http://tinyurl.com/yemjhcm";s:4:"isgd";s:18:"http://is.gd/aOtha";s:5:"bitly";s:20:"http://bit.ly/74Ni8z";}'
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359009
category:
  - tutorials
---
This small snippet is copied from a much popular application.

`.text:1000EBE0 push ecx ; some_string<br />
.text:1000EBE1 push '%'<br />
.text:1000EBE3 push '%'<br />
.text:1000EBE5 push offset aCsystemdriveCS ; "%cSystemDrive%c%s"<br />
.text:1000EBEA push edx ; buffer<br />
.text:1000EBEB call ds:swprintf`

Translated to C:

`swprintf(buffer, "%cSystemDrive%c%s", '%', '%', some_string);`

Of course you&#8217;d be scratching your head to explain why the writer wrote it this way, instead of simply `swprintf(buffer, "%%SystemDrive%%%s", some_string);`. To show off great C-kungfu? Or the lack thereof? Anyway, I just thought it was funny enough to post.