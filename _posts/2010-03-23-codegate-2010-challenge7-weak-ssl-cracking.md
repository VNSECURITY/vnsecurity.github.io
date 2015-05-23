---
title: 'CodeGate 2010 &#8211; Challenge 7: Weak SSL Cracking'
author: vnsec
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:32:"http://www.vnsecurity.net/?p=780";s:7:"tinyurl";s:26:"http://tinyurl.com/yfrfoz7";s:4:"isgd";s:18:"http://is.gd/aTV8k";}'
tweetbackscheck:
  - 1408358979
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
kopa_newsmixlight_total_view:
  - 1
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - Cryptography
  - CTF
  - ssl
---
Writeup for CodeGate 2010 &#8211; Challenge 7 by <a href="http://namnham.blogspot.com/" target="_blank">namnx</a>

* * *

<div style="text-align: justify">
  Last weekend, I had a great hacking time with team <a href="http://www.vnsecurity.net/about-us/clgt-ctf-team/">CLGT</a> in the <a href="http://ctf.codegate.org/">CodeGate 2010 CTF</a> Preliminary Round. It lasted 36 consecutive hours from 7:00AM March 13 to 7:00PM March 14. There were a lot of teams around the world participating in this hacking contest. And excellently, CLGT proved it as one of the best teams when got the 2nd place in this round. See <a href="http://beist.org/CG2010_rank.png">final ranking</a>.
</div>

<div style="text-align: justify">
  This entry is my writeup for challenge 7. I think this is an interesting challenge from which you can learn more deeply about SSL protocol and public key cryptography. In this challenge, we were provided a tcpdump file of a SSL traffic and a hint &#8220;<em>does the modulus look familiar?</em>&#8220;. So our goal is to analyze and decrypt this captured traffic to get the flag.
</div>

**<span style="font-family: Georgia,'Times New Roman',serif">Analysis</span>**  
Firstly, I used Wireshark to load this file and start to analyze it:

<div style="clear: both;text-align: center">
  <a style="margin-left: 1em;margin-right: 1em" href="http://lh3.ggpht.com/_BaefoYBtOwQ/S59Mv6OohsI/AAAAAAAAAW4/z7INUja_DtE/challenge7-1.png"><img src="http://lh3.ggpht.com/_BaefoYBtOwQ/S59Mv6OohsI/AAAAAAAAAW4/z7INUja_DtE/challenge7-1.png" border="0" alt="" width="500" height="271" /></a>
</div>

<div style="text-align: justify">
  There are 26 packets captured. Packet #4 is a <strong><em>SSL Client Hello</em></strong> packet, but after it, packet #8 and packet #9 have FIN flag. This mean that the session was termininated. So we just ignore them.
</div>

<div style="text-align: justify">
  Packet #14 is another <strong><em>SSL Client Hello</em></strong> packet. This is where the real session began. Take a look into it:
</div>

<div style="clear: both;text-align: center">
  <a style="margin-left: 1em;margin-right: 1em" href="http://lh4.ggpht.com/_BaefoYBtOwQ/S59PftmaEmI/AAAAAAAAAXA/yxCqiOSmyHA/challenge7-2.png"><img src="http://lh4.ggpht.com/_BaefoYBtOwQ/S59PftmaEmI/AAAAAAAAAXA/yxCqiOSmyHA/challenge7-2.png" border="0" alt="" width="500" height="274" /></a>
</div>

<div style="text-align: justify">
  There is nothing special. It is just a normal <strong><em>SSL Client Hello</em></strong> packet. It happens when a client want to connect to a SSL service. We continue look into the packet #16, the <strong><em>SSL Server Hello</em></strong> packet:
</div>

<div style="clear: both;text-align: center">
  <a style="margin-left: 1em;margin-right: 1em" href="http://lh6.ggpht.com/_BaefoYBtOwQ/S59SI8VjnhI/AAAAAAAAAXI/LGU0BQZP4x0/s1600/challenge7-3.png"><img src="http://lh6.ggpht.com/_BaefoYBtOwQ/S59SI8VjnhI/AAAAAAAAAXI/LGU0BQZP4x0/s400/challenge7-3.png" border="0" alt="" width="501" height="324" /></a>
</div>

<div style="clear: both;text-align: left">
  This is the response for SSL Client Hello packet. We can see some useful information here:
</div>

<div style="clear: both;text-align: left">
  - The cipher suite will be used: <strong>RSA_WITH_AES_256_CBC_SHA</strong>
</div>

<div style="clear: both;text-align: left">
  - The X509 certificate of the server
</div>

<div style="clear: both;text-align: justify">
  In the SSL protocol, the server send its certificate to the client in the handshaking process. This certificate will be used for supporting the key exchange afterward. The certificate contains the server&#8217;s public key and other data. By extracting the public key and recovering the private key from it, we can decrypt the SSL traffic.
</div>

<div style="clear: both;text-align: justify">
  <strong><span style="font-family: Georgia,'Times New Roman',serif">Exploit</span></strong>
</div>

<div style="clear: both;text-align: justify">
  I wrote some Python code to exploit this challange:
</div>

<pre class="brush: python; title: ; notranslate" title="">from scapy.all import *
    from M2Crypto import X509

    def decode_serverhello(packet):
    payload = packet.load
    cert = payload[94:1141]
    cert = X509.load_cert_string(cert, 0)
    return cert

    def get_pubkey(cert):
    pubkey = cert.get_pubkey().get_rsa()
    n = long(pubkey.n.encode('hex')[8:], 16)
    e = long(pubkey.e.encode('hex')[9:], 16)
    return n, e

    packets = rdpcap('ssl.pcap')
    cert = decode_serverhello(packets[15])
    n,e = get_pubkey(cert)
</pre>

Because this traffic used RSA as public key algorithm, the public key contains 2 components: **n** and **e**. We get their values from the above code:

<pre class="brush: python; title: ; notranslate" title="">n = 1230186684530117755130494958384962720772853569595334792197322452151726400507263657518745202199786469389956474942774063845925192557326303453731548268507917026122142913461670429214311602221240479274737794080665351419597459856902143413
    e = 65537
</pre>

<div style="text-align: justify">
  In RSA, <strong>n</strong> is the product of 2 big prime numbers <strong>p</strong> and <strong>q</strong>. So, in order to recover the RSA private key from the public key, we must factorize <strong>n</strong> into <strong>p</strong> and <strong>q</strong>. This is the key point of the challenge. In this situation, n is a very big number (232 decimal digits). How can we do that? In the beginning, I didn&#8217;t know how to solve it. But I remembered the hint &#8220;<em>does the modulus look familiar?</em>&#8220;. So I tried <a href="http://bit.ly/azg7Vh">googling it</a> <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_biggrin.gif" alt=":-D" class="wp-smiley" /> (actually just its last digits). And&#8230; oh my god, I was lucky! It is <a href="http://en.wikipedia.org/wiki/RSA_numbers#RSA-768">RSA-768</a>. It&#8217;s factorized just few months ago.
</div>

<pre class="brush: python; title: ; notranslate" title="">RSA-768 = 33478071698956898786044169848212690817704794983713768568912431388982883793878002287614711652531743087737814467999489
    × 36746043666799590428244633799627952632279158164343087642676032283815739666511279233373417143396810270092798736308917
</pre>

So now, we have all components of the RSA keys.

<pre class="brush: python; title: ; notranslate" title="">n = 1230186684530117755130494958384962720772853569595334792197322452151726400507263657518745202199786469389956474942774063845925192557326303453731548268507917026122142913461670429214311602221240479274737794080665351419597459856902143413
    e = 65537
    p = 33478071698956898786044169848212690817704794983713768568912431388982883793878002287614711652531743087737814467999489
    q = 36746043666799590428244633799627952632279158164343087642676032283815739666511279233373417143396810270092798736308917
    d = 703813872109751212728960868893055483396831478279095442779477323396386489876250832944220079595968592852532432488202250497425262918616760886811596907743384527001944888359578241816763079495533278518938372814827410628647251148091159553
</pre>

<div style="text-align: justify">
  The last thing we have to do is generating the RSA private key in PEM format from these components. But how can we do that? As far as I know, popular cryptographic libraries like OpenSSL do not support this. So in this case, I wrote my own tool to do this task. It is based on ASN1. It is a little long to post here. But if you want to write your own one, I recommend <a href="http://pyasn1.sourceforge.net/">pyasn1</a>.
</div>

After having the private key, just import it to Wireshark to decrypt the SSL traffic:

<div style="clear: both;text-align: center">
  <a style="margin-left: 1em;margin-right: 1em" href="http://lh6.ggpht.com/_BaefoYBtOwQ/S59zDsyIwPI/AAAAAAAAAXQ/dMd2XsmITRo/s1600/challenge7-4.png"><img src="http://lh6.ggpht.com/_BaefoYBtOwQ/S59zDsyIwPI/AAAAAAAAAXQ/dMd2XsmITRo/s400/challenge7-4.png" border="0" alt="" width="501" height="178" /></a>
</div>

**References**  
- SSL/TLS: http://en.wikipedia.org/wiki/Transport\_Layer\_Security  
- RSA: http://en.wikipedia.org/wiki/RSA