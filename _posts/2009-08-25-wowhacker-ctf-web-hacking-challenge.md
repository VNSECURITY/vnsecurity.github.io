---
title: 'WOWHacker CTF &#8211; Web Hacking Challenge'
author: thaidn
excerpt: |
  |
    This post is about challenge 8 which made gamma95 and I feel so lost when it comes to web hacking.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:71:"https://www.vnsecurity.net/2009/08/wowhacker-ctf-web-hacking-challenge/";s:7:"tinyurl";s:26:"http://tinyurl.com/ycrxwt6";s:4:"isgd";s:18:"http://is.gd/aOtbC";s:5:"bitly";s:20:"http://bit.ly/6ZZfMF";}'
tweetbackscheck:
  - 1408358997
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
[Challenge 8][1] (not accessible atm) is the only web hacking challenge in WOWHacker&#8217;s CTF. In hindsight it&#8217;s not very difficult, but in fact it took us almost 1 day to solve it.

This is a classic PHP local file inclusion attack. If you set the parameter **ty** and the cookie **71860c77c6745379b0d44304d66b6a13 **to the same file name, the vulnerable PHP script in challenge 8 would try to include that file. Here&#8217;s what the code looks like: 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ty = $_GET["ty"];
$page = $_COOKIE["71860c77c6745379b0d44304d66b6a13"];
if ($ty != $page)
{
    echo "Error!";
}
else
{
    if (include($ty) != 'OK')
    {
        echo "Can't find that page!";
    }
}
</pre>

**Update**: gamma95 has just noticed me this challenge may not be a PHP local file inclusion attack. Maybe it&#8217;s just a vulnerable **readfile** call like this:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">$ty = $_GET["ty"];
$page = $_COOKIE["71860c77c6745379b0d44304d66b6a13"];
if ($ty != $page)
{
    echo "Error!";
}
else
{
    if (file_exists($ty))
    {
        readfile($ty);
    }
    else
    {
        echo "Can't find that page!";
    }
}</pre>

For vulnerable scripts like this, the trick is to include files in known location which may contain important information, i.e. Apache httpd&#8217;s error\_log or access\_log. As we knew this is a Windows machine, we tried to test our theory by including *C:Windowssystem32driversetchosts *which worked as expected. At this point, we thought we were just moments away from the solution of this challenge, but in fact we were totally stuck for the next several hours.

We went on to guess the location of Apache httpd&#8217;s log files. We sent hundreds of requests, but none worked. I even downloaded and installed a copy of Apache httpd to understand its directory structure but still no luck. Why it didn&#8217;t work???

Like [challenge 1][2], it wasn&#8217;t until we almost gave up on this challenge, we realized the simple fact: we always thought that the web server was Apache httpd while it was IIS actually! Years of abandoning Windows has brainwashed us! What a shame!

The next steps are simple. The default IIS installation would store log files in *C:WINDOWSsystem32LogFilesW3SVC1exYYMMDD.log*. As the premilinary round started on 2009.08.14, we guess we should include *C:WINDOWSsystem32LogFilesW3SVC1ex090814.log* which in turn reveals this secret script:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">/tmxhffjsqkdlxmwhaWkddlsemt/answpsorltlagkrpglaemfdjttmqslek/rmfoehrufrnrdpsvntutspdy.php
</pre>

This script asks for a username and password which gamma95 had bypassed it using a trivial SQL injection attack even before I figured out what I should do next. After bypassing the authentication, we obtained the flag which is: **Do you know StolenByte???**

No we don&#8217;t know him, but thanks for a nice challenge!

 [1]: http://221.143.48.78:8080/
 [2]: http://vnhacker.blogspot.com/2009/08/crypto-challenges-wowhacker-ctf.html