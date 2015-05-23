---
title: 'WOWHacker CTF &#8211; Crypto Challenges'
author: thaidn
excerpt: |
  |
    Last week team CLGT took part in the WOWHacker CTF. I was in charged of crypto challenges, so I decide to write something about challenge 1 and challenge 10.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:67:"https://www.vnsecurity.net/2009/08/wowhacker-ctf-crypto-challenges/";s:7:"tinyurl";s:26:"http://tinyurl.com/yasfwlw";s:4:"isgd";s:18:"http://is.gd/aOtbT";s:5:"bitly";s:20:"http://bit.ly/4WXnPw";}'
tweetbackscheck:
  - 1408358998
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
## Challenge 1

[Challenge 1][1] is&#8230;crazy hahaha. Only one or two teams could solve it until the author (hello hinehong :-D) gave out a list of 7 hints. I have designed some web-related crypto challenges (which you will see soon ^^) so I think the difficulty of challenge 1 relies on how fast people can guess the meaning of the cookie. It would be easier for the teams if the author sets the cookie as cookie = cipher + &#8220;|&#8221; + key. BTW, here&#8217;s my solution.

When you access the link above, you&#8217;ll see a bunch of javascripts. After decoding those javascripts (which I leave as exercise for readers), you&#8217;ll see a form whose target is [http://221.143.48.96:8080/you\_are\_the\_man\_but\_try\_again.jsp][2]. This form accepts a parameter named &#8220;hong&#8221; which is either true or false. If you set **hong=true**, the server sends back a cookie like below:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">id=&lt;code&gt;pKCdQgyJb4dziUESVUv+5qBIoGwQgL2WB@ae506e&lt;/code&gt;</pre>

This looks like a base64 encoded string, but it&#8217;s not. In fact you need to modify it a little bit before you can base64 decode it. This is, as I said previously, why this challenge is hard.

One trick I learn from this challenge is to guess the boundary between key and cipher text, one should try to truncate one character a time and base64 decode the string until he gets an output whose length in bytes is a multiple of 8 or 16, which are common block cipher&#8217;s block length.

The cookie can be either &#8220;cipher + key&#8221; or &#8220;key + cipher&#8221;, so one should try the above process in both cases. If you can&#8217;t find any such output, then you know your theory is wrong, i.e. the cookie is in some other form. Fortunately, my theory is right in this case.

It turns out that the first 32 bytes of the cookie is the cipher text, and the rest 8 bytes is the key. It&#8217;s a 8-bytes key, so this cookie should be encrypted by DES which is a popular 8-bytes key block cipher. I wrote a small python script to decrypt the it: 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">&gt;&gt;&gt;from Crypto.Cipher import DES
&gt;&gt;&gt;cookie = 'pKCdQgyJb4dziUESVUv+5qBIoGwQgL2WB@ae506e'
&gt;&gt;&gt; key = cookie[32:]
&gt;&gt;&gt; data = base64.b64decode(cookie[0:32])
&gt;&gt;&gt; des = DES.new(key, DES.MODE_CBC)
&gt;&gt;&gt; des.decrypt(data)
'wowhackexd6xe0xbc*exe7nxc7x1axf92w6Hxfdxe5'</pre>

Hmm. I remembered I tried to submit &#8216;wowhacke&#8217; to the scoring server, but, of course, it&#8217;s not the correct answer. Then I wasted the next hour to test various stupid theories to understand what the last 16 bytes of the output are.

It was not until I nearly gave up on this challenge, I realized the obvious: this is mode ECB stupid!!! Why on earth I always thought it&#8217;s CBC? I changed the mode, and the result is: 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">&gt;&gt;&gt; des = DES.new(key)
&gt;&gt;&gt; des.decrypt(data)
'wowhacker@!hine@ipsecx03x03x03'
</pre>

Remember those *&#8216;x03x03x03&#8242;*. You&#8217;ll see them again in my crypto challenges ;-).</p> 

## Challenge 10

[Challenge 10][3] is cool. In summary, the author sets a RSA private key as a property of a Java object, then he gives out the serialization stream of that object, and asks teams to recover the private key to decrypt a ciphertext.

So the first thing we must do is to understand [how Java does serialization][4]. I was never a fan of Java, so this is something completely new to me. But that&#8217;s why I really enjoy playing capture the flag games. It forces me to learn new thing fast in a very short time.

I spent nearly 1 hour reading the spec, mostly on the [object serialization stream protocol][5]. Then I spent one and a half hour starring at my hex editor screen and acting as a binary parser which was, I don&#8217;t know why I feel that, really fun (later on Tora of SexyPwndas fame showed me a much less painful way to recover the object. Thanks Tora!)

I recovered the RSA private key eventually. How to use it to decrypt the ciphertext in key.txt? While de-serializing the object, you would see that there&#8217;s a field named tripleDesKey containing a 24-bit string which you can get by base64-decoding the last 32 bytes of the serialized object.

At first I thought I should use the RSA key to decrypt this 24-bit string to get the real tripleDesKey, and uses that key in turn to decrypt key.txt. This hybrid approach is the standard way to do encryption using public key cryptosystem. But you shouldn&#8217;t expect anything standard in CTF, rite?

It turns out all that tripleDes key and ciphertext are just there to distract me. I have to admit that I don&#8217;t like challenges giving false trails. You can either give good trails or no trail at all. Giving false trail is a sin :-P.

Anyway, if you look at key.txt, you&#8217;ll see that its content is a 128-bytes string. 128-bytes = 1024-bit = the size of the modulus in the recovered RSA private key. So this string should be the ciphertext encrypted directly using the RSA private key. Indeed it is! 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">&gt;&gt;&gt; from M2Crypto.RSA import *
&gt;&gt;&gt; rsa = load_key('my_rsa_key')
&gt;&gt;&gt; data = open('key.bin').read()
&gt;&gt;&gt; rsa.private_decrypt(data, 3)
'x00x02#padding#x00isec@#$wowhacker!!'
</pre>

There&#8217;s a small minor issue that I intentionally left out. Can you find out what it is and resolve it yourself?

I hope you enjoy reading this. Happy hacking!

 [1]: http://221.143.48.96:8080/level1.jsp
 [2]: http://221.143.48.96:8080/you_are_the_man_but_try_again.jsp
 [3]: http://mega.1280.com/file/VA9JDUSD/
 [4]: http://java.sun.com/j2se/1.5.0/docs/guide/serialization/spec/serialTOC.html
 [5]: http://java.sun.com/j2se/1.5.0/docs/guide/serialization/spec/protocol.html#8101