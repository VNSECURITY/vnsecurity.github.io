---
title: Clickjacking revealed
author: lamer
excerpt: |
  |
    Robert "RSnake" Hansen from SecTheory gave me a preview of his talk at OWASP AppSec Asia 2008.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:57:"https://www.vnsecurity.net/2008/10/clickjacking-revealed/";s:7:"tinyurl";s:26:"http://tinyurl.com/y9saqmb";s:4:"isgd";s:18:"http://is.gd/aOtdd";s:5:"bitly";s:20:"http://bit.ly/7egOIp";}'
tweetbackscheck:
  - 1408359002
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - tutorials
---
I just came back from the first day of OWASP AppSec Asia 2008 in Taipei. Beside two t-shirts, I got to be among the first privilege group to preview Robert Hansen&#8217;s presentation on Clickjacking. The show is scheduled for the second day, tomorrow, but I have to fly to Kuala Lumpur. How lucky am I!

Getting back to the issue, clickjacking basically borrows the user&#8217;s mouse click to click on another unintended object such as a link, or a button. For example, the website shows you a link, you click on it thinking that you will be taken to the intended location. But hey, the browser sends a request to another location!

But that&#8217;s doable with plain JavaScript too. What&#8217;s new here is the click you made could be placed on a button of an ActiveX. Scary, no? The demo showed me that, with clickjacking, bad guys could force Flash player to turn on the microphone. When you visit a HTML page, some JavaScript activates a Flash component. This component asks the Flash player to turn on the microphone and starts recording. Normally, Flash player will pop up a dialog with an OK button to ask for your permission before doing so. Now, your mouse click, that you made on the HTML page, is borrowed and used to click on that OK button. And Flash player turns on the microphone. Or maybe the webcam. Or, wait, maybe something more than that. Whatever you can do with a mouse click, clickjacking allows the attacker to &#8220;help&#8221; you do that, silently.

Thank you Robert for the preview. It was way cool!

For the HITB 2008 KL goers, Jeremiah Grossman will be presenting the keynote &#8220;The art of Click Jacking&#8221; on the first day. And I will see you there too.