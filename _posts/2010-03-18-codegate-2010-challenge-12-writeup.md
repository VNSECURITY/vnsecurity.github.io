---
title: Codegate 2010 Challenge 12 writeup
author: hieu le
layout: post

aktt_notify_twitter:
  - no
tweetbackscheck:
  - 1408358982
shorturls:
  - 'a:4:{s:9:"permalink";s:69:"http://www.vnsecurity.net/2010/03/codegate-2010-challenge-12-writeup/";s:7:"tinyurl";s:26:"http://tinyurl.com/ye8rm3x";s:4:"isgd";s:18:"http://is.gd/aOugW";s:5:"bitly";s:0:"";}'
twittercomments:
  - 'a:4:{i:10722481876;s:3:"222";i:10758208402;s:7:"retweet";i:10758173294;s:7:"retweet";i:10726012348;s:7:"retweet";}'
tweetcount:
  - 5
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - CTF
  - file forensic
---
<h2 id="Summary" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  Summary<a title="Link to this section" href="#Summary"></a>
</h2>

*   Problem: Finding the key in one raw-data-file &#8211; forensic challenge
*   Techniques: Using foremost to extract data
*   Solution: Just extract data and it&#8217;s done

<h2 id="Analysis" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  Analysis<a title="Link to this section" href="#Analysis"></a>
</h2>

After downloading the file, let&#8217;s skim over.

<p style="text-indent: 0.5em">
  $ file 514985D4E9D80D8BF227859C679BFB32 514985D4E9D80D8BF227859C679BFB32: CDF V2 Document, Little Endian, Os: Windows, Version 6.1, Code page: 949, Title: Chzcxva Pneivat Znqr Rnfl, Author: Flfnqzva, Template: Normal.dotm, Last Saved By: FRETR INHQRANL, Revision Number: 12, Name of Creating Application: Microsoft Office Word, Total Editing Time: 21:00, Create Time/Date: Mon Feb 22 12:48:00 2010, Last Saved Time/Date: Thu Mar 4 13:54:00 2010, Number of Pages: 7, Number of Words: 1381, Number of Characters: 7876, Security: 0
</p>

<p style="text-indent: 0.5em">
  $ ls -l 514985D4E9D80D8BF227859C679BFB32
</p>

<p style="text-indent: 0.5em">
  -rw-r&#8211;r&#8211; 1 hieuln hieuln 867328 2010-03-13 21:18 514985D4E9D80D8BF227859C679BFB32
</p>

<p style="text-indent: 0.5em">
  Of course, it&#8217;s not CDF document. So, the general step is using foremost to extract inside-data.
</p>

<p style="text-indent: 0.5em">
  $ foremost -c /etc/foremost.conf -v -o out 14985D4E9D80D8BF227859C679BFB32
</p>

<p style="text-indent: 0.5em">
  It got a lot of stuffs. Let&#8217;s browsing images file first. I noticed there&#8217;s a small image named &#8220;00000041.tif&#8221; looks like a captcha. Try with that phrase and it is the right key &#8220;E5R69267&#8243;.
</p>

<p style="text-indent: 0.5em">
  Sad, really upset. That&#8217;s such a bad challenge with 300 points. And I can&#8217;t imagine that CLGT is the 3rd team submit this flag, it&#8217;s the end of first day.
</p>

<h2 id="References" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  References<a title="Link to this section" href="#References"></a>
</h2>

*   Tools: [<span> </span>http://foremost.sourceforge.net/][1]
*   Keywords: files recovery, forensic

 [1]: http://foremost.sourceforge.net/