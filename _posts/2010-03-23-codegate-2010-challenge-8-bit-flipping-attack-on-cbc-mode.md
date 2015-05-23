---
title: 'CodeGate 2010 &#8211; Challenge 8: Bit-flipping attack on CBC mode'
author: vnsec
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:92:"http://www.vnsecurity.net/2010/03/codegate-2010-challenge-8-bit-flipping-attack-on-cbc-mode/";s:7:"tinyurl";s:26:"http://tinyurl.com/ybxunqw";s:4:"isgd";s:18:"http://is.gd/aVJJX";}'
tweetbackscheck:
  - 1408358978
twittercomments:
  - 'a:1:{i:12866318837;s:7:"retweet";}'
tweetcount:
  - 1
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - bit flipping
  - CLGT
  - codegate
  - Cryptography
  - CTF
---
Writeup for CodeGate 2010 Challenge 8 by <a href="http://namnham.blogspot.com/" target="_blank">namnx</a>

* * *

This is a web-based cryptography challenge. In this challenge, we were provided a URL and a hint &#8220;*the first part is just an IV*&#8220;.

The URL is: <http://ctf1.codegate.org/99b5f49189e5a688492f13b418474e7e/web4.php>.

### Analysis

Go to the challenge URL. It will ask you the username for the first time. After we enter a value, for example &#8216;<span style="font-family: 'Courier New',Courier,monospace">namnx</span>&#8216;, it will return only a single message &#8220;<span style="font-family: 'Courier New',Courier,monospace">Hello, namnx!</span>&#8220;. Examine the HTTP payload, we will see the cookie returned:

> web4_auth=1vf2EJ15hKzkIxqB27w0AA==|5X5A0e3r48gXhUXZHEKBa5dpC+XfdVv4oamlriyi5yM=

The cookie includes 2 parts delimited by character &#8216;|&#8217;. After base64 decode the first part of the cookie, we have a 16-byte value. According to the hint, this is the IV of the cipher. And because it has 16-byte length, I guess that this challenge used AES cipher, and the block size is 16 bytes. Moreover, the cipher has an IV, so it can&#8217;t be in ECB mode. I guessed it in CBC mode. The last part is the base64 of a 32-byte value. This is a cipher text. We will exploit this value later.

Browse the URL again, we will receive another message: &#8220;*Welcome back, namnx! Your role is: user. You need admin role.*&#8221; Take a look into this message, we can guess the operation of this app: it will receive the cookie from the client, decrypt it to get the user and role information and return the message to the client based on the user and role information. So, in order to get further information, we must have the admin role. This is our goal in this challenge.**<span style="font-family: Georgia,'Times New Roman',serif"> </span>**

### Exploit

I wrote some Python to work on this challenge easier:

<pre class="brush: python; title: ; notranslate" title="">import urllib, urllib2
    import base64, re

    url = 'http://ctf1.codegate.org/99b5f49189e5a688492f13b418474e7e/web4.php'
    user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'

    def get_cookie(user):
        headers = { 'User-Agent' : user_agent}
        values = {'username' : user, 'submit' : "Submit"}
        data = urllib.urlencode(values)
        request = urllib2.Request(url, data, headers)
        response = urllib2.urlopen(request)
        cookie = response.info().get('Set-Cookie')
        groups = re.match("web4_auth=(.+)|(.+);.+", cookie).groups()
        iv = base64.b64decode(groups[0])
        cipher = base64.b64decode(groups[1])
        return iv, cipher

    def get_message(iv, cipher):
        cookie = base64.b64encode(iv) + '|' + base64.b64encode(cipher)
        cookie = urllib.quote(cookie)
        cookie = 'web4_auth=' + cookie
        headers = { 'User-Agent' : user_agent, 'Cookie': cookie}
        request = urllib2.Request(url, None, headers)
        response = urllib2.urlopen(request)
        data = response.read()
        print repr(data)
        groups = re.match(".+, (.*)! .+: (.*). You.+", data).groups()
        return groups[0], groups[1]
</pre>

The first function, get\_cookie will submit a value as a username in the first visit to the page, get the returned cookie, and then parse it to get the IV and cipher. The second function, get\_message, do the task like when you visit the page in later times, it parses the response message to get the returned username and role.

<pre class="brush: python; title: ; notranslate" title="">&gt;&gt;&gt; iv, cipher = get_cookie('123456789012')
    &gt;&gt;&gt; len(cipher)
    32
    &gt;&gt;&gt; iv, cipher = get_cookie('1234567890123')
    &gt;&gt;&gt; len(cipher)
    48
</pre>

When you input the user with a 12-byte value, the returned cipher will have 32 bytes (2 blocks). And when you enter a 13-byte value, the cipher will have 48 bytes (3 blocks). This means that beside the username value, the plain text of the cipher will be added more 20 bytes.

Try altering the cipher text to see how it is decrypted:

<pre class="brush: python; title: ; notranslate" title="">&gt;&gt;&gt; iv, cipher = get_cookie('1234567890')
    &gt;&gt;&gt; cipher1 = cipher[:-1] + '&#092;&#048;0'
    &gt;&gt;&gt; username, role = get_message(iv, cipher1)
    'Welcome back, 1234567xa2xc2xcaxfeixdbxee_cxa7xd7x0cxa9jxe0xbb! Your role is: . You need admin role.'
</pre>

As you can see, the last block of the decrypted role is the first block of the plain text. So, the format of the plain text may be: &#8216;username=&#8217; + username + [11 bytes].

To here, we can guess that the format of the plain text can be something like:

> &#8216;username=&#8217; + username + [delimiter] + [param] + &#8216;=&#8217; + [value]

The last 11 bytes of the plain text can be determined by the code below:

<pre class="brush: python; title: ; notranslate" title="">&gt;&gt;&gt; iv, cipher = get_cookie('x00')
    &gt;&gt;&gt; username, role = get_message(iv, cipher)
    'Welcome back, x00##role=userx00x00x00x00x00x00x00x00x00x00x00! Your role is: . You need admin role.'
</pre>

You can see the last 11 bytes of the plain text in the returned message. So, at this time, we can conclude format of the plain text is:

> &#8216;username=&#8217; + username + &#8216;##role=&#8217; + role

Now, the last thing we have to do is altering the role value to &#8216;admin&#8217;. Because we&#8217;ve already known the format of the plain text, we can choose to input the username close to the target plain text and try to alter the cipher text in the way that the decrypted value is what we want.

Let remind the operation of CBC mode in cryptographic ciphers. In encryption process:

> y[1] = C(IV xor x[1])  
> y[n] = C(y[n-1] xor x[n])

and in the decryption:

> x[1] = D(y[1]) xor IV  
> x[n] = D(y[n]) xor y[n-1]

Notice that if we flip one bit in the (n-1)th block of cipher text, the respective bit in the n-th block of plain text will be also flipped. So, we will you this fact to exploit the challenge:

<pre class="brush: python; title: ; notranslate" title="">&gt;&gt;&gt; iv, cipher = get_cookie('012345678901234567890123#role=admin')
    &gt;&gt;&gt; s = cipher[:16] + chr(ord(cipher[16]) ^ 0x10) + cipher[17:]
    &gt;&gt;&gt; username, role = get_message(iv, s)
    'Welcome back, 0123456Lxaax17mxe9x91xdcxe2`#z)xd8mxd8x18! Your role is: admin. You need admin role. Congratulations! Here is your flag: the_magic_words_are_squeamish_ossifrage_^-^!!!!!'
</pre>

Successful! Such an interesting challenge, isn&#8217;t it?

### References

*   <a href="http://en.wikipedia.org/wiki/Block_cipher_modes_of_operation" target="_blank">Block cipher modes of operation</a>
*   <a href="http://en.wikipedia.org/wiki/Bit-flipping_attack" target="_blank">Bit-flipping attack</a>