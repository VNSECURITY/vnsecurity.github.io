---
title: '[writeup] Hacklu 2012 &#8211; Challenge #10 (500)'
author: pdah
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358965
category: ctf - clgt crew
tags:
  - '2012'
  - CTF
  - Hacklu
---
> 10 &#8211; zlotpy  
> Gambling time. Play against the Internet Zlot Machine at ctf.fluxfingers.net tcp/2053 This challenge has two stages.
> 
> 1) Medium: Investigate the contents of a saved game.
> 
> 2) Hard: Get 8 (EIGHT) bonus points. Good luck! Hint: We have some sourcecode for you! https://ctf.fluxfingers.net/challenges/zlot.py

At the first sight, we thought this challenge was about Padding Oracle, but it turned out that Bit Flipping attack should be enough to solve.  
First step is to send &#8216;S&#8217; and get back the ciphertext representing current game state

> Welcome to the Internet ZlotMachine. Enter &#8216;T&#8217; for the Tutorial.  
> Your current balance is 5 credits and 1 bonus  
> S  
> Your games has been saved! Please write down the following save game code.  
> WVIagr4eWOGCHi/CSQg1oKEgZneHnJJIm5LJjJeacngsTG1hm9jfygT6ZpBrsFihNKoef165OP2pb+tacn+9FlV+CfKjelFHS4MykxpJcYk=  
> This game may later be loaded with L

If we send this cipher back to the server, it will return **&#8220;Your current balance is 5 credits and 1 bonus&#8221;**

The code below will loop throuth each byte of the cipher text, increase the value by one and ask the server to load that newly created gamestate.

<pre class="brush: python; title: ; notranslate" title="">s = socket(AF_INET, SOCK_STREAM)
s.connect(("ctf.fluxfingers.net",2053))
s.recv(1024)&lt;/code&gt;

responses = set()

def send_request(data):
    try:
        s.send("L"+data+"n")
    except:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(("ctf.fluxfingers.net",2053))
        s.recv(1024)
        s.send("L"+data+"n")&lt;/code&gt;

    r = s.recv(1024)

    if r not in responses:
        responses.add(r)
        print r

orig_cipher = base64.b64decode("mzIbwjPTw6hMVcp5DsRZGJykuaWXYaukFOEvUT5xVFLfjqQahbCTNsjXYYUawNEc+XFBV689Y/LPD8YYqKy+Z4DqS1uh9yva1ICjyphYbC8=")
fake_cipher = orig_cipher
l = len(orig_cipher)
for i in range(l):
    print "Try with character #%d"%i
    fake_cipher = set_byte(orig_cipher, i, chr((ord(fake_cipher[i])+1)%256) )
    send_request(base64.b64encode(fake_cipher))
</pre>

The response will look like this:

> Try with character #9  
> Try with character #10  
> Restored state.  
> Your current balance is 5 credits and 0 bonus
> 
> Try with character #11  
> Error loading game: Expecting , delimiter: line 1 column 11 (char 11)

Looking at the result, we notice that changing value of byte #10 will cause the bonus value changed.  
Now we simply brute the value of this byte until getting the flag:

<pre class="brush: python; title: ; notranslate" title="">orig_cipher = base64.b64decode("mzIbwjPTw6hMVcp5DsRZGJykuaWXYaukFOEvUT5xVFLfjqQahbCTNsjXYYUawNEc+XFBV689Y/LPD8YYqKy+Z4DqS1uh9yva1ICjyphYbC8=")
fake_cipher = orig_cipher
l = len(orig_cipher)
for i in range(256):
    index = 10
    fake_cipher = set_byte(fake_cipher, index, chr((ord(fake_cipher[index])+i)%256) )
    send_request(base64.b64encode(fake_cipher))
</pre>

We will see the flag after a few minutes:

> Restored state.  
> Your current balance is 5 credits and 5 bonus
> 
> Restored state.  
> Your current balance is 5 credits and 8 bonus  
> Nice one. Here&#8217;s your flag: 9eef8f17d07c4f11febcac1052469ab9