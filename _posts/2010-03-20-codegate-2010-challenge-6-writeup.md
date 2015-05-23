---
title: 'CodeGate 2010 &#8211; Challenge 6 writeup'
author: longld
layout: post

aktt_notify_twitter:
  - no
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:68:"http://www.vnsecurity.net/2010/03/codegate-2010-challenge-6-writeup/";s:7:"tinyurl";s:26:"http://tinyurl.com/yd9hlug";s:4:"isgd";s:18:"http://is.gd/aPLeG";}'
tweetbackscheck:
  - 1408358980
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - CTF
  - forensics
  - network forensics
---
# Summary

Challenge 6 is a forensics problem with a mountain of data, a packet capture file and a FAT32 filesystem image. In order to find the secret you have to watch for the &#8220;key&#8221; exchanged via MSN conversation in a packet capture file, then use it to find the secret file name. With forensics problems, luck is more important than techniques and you should only do it if you don&#8217;t have anything to play during the game.

# Analysis

Challenge information:

> credentials:
> 
> http://ctf.codegate.org/thisiswhereiuploadmyfiles/CC2A8B4FA2E1FA6BD7FE9B8EFC86BCB7
> 
> Substitute for those who are not in Korea : http://www.mediafire.com/?wyhexdmzzdm
> 
> You should convert the flag into lower case letters and try to auth with it.
> 
> Hint: The packet of messenger is important. You don&#8217;t need to care the ftp stuff.
> 
> Hint2: Please put your flag without any extension to the auth page.

## File info

> <pre>$ file CC2A8B4FA2E1FA6BD7FE9B8EFC86BCB7
CC2A8B4FA2E1FA6BD7FE9B8EFC86BCB7: gzip compressed data, from Unix, last modified: Fri Mar 12 17:20:19 2010

$ zcat CC2A8B4FA2E1FA6BD7FE9B8EFC86BCB7 &gt; challenge6
$ file challenge6
challenge6: POSIX tar archive (GNU)

$ tar xvf challenge6
352FCD8BDEC8244CDED00CA866CA24B9
B400CBEA39EA52126E2478E9A951CDE8

$ file 352FCD8BDEC8244CDED00CA866CA24B9 B400CBEA39EA52126E2478E9A951CDE8
352FCD8BDEC8244CDED00CA866CA24B9: tcpdump capture file (little-endian) - version 2.4 (Ethernet, capture length 65535)
B400CBEA39EA52126E2478E9A951CDE8: x86 boot sector, code offset 0x58, OEM-ID "MSDOS5.0",
sectors/cluster 8, reserved sectors 4334, Media descriptor 0xf8, heads 255, sectors 1982464 (volumes &gt; 32 MB) ,
FAT (32 bit), sectors/FAT 1929, reserved3 0x800000, serial number 0x7886931a, unlabeled</pre>

We have 2 files: a tcpdump packet capture and a FAT32 filesystem image. From the hints (yes, without it we don&#8217;t know what to search for), we focus our search to:

*   Final secret key must be a file and it may rely on FAT32 image
*   Keyword to find out that secret file must be exchanged via MSN conversation(s) in tcpdump file

## MSN conversation

Using chaosreader (you can use other tools to have the same result) to analyse pcap file, we will have a list of sessions like below:

<img class="alignnone size-full wp-image-733" title="Chaosreader Report - msnp" src="http://vnsecurity.net/wp/storage/uploads/2010/03/Chaosreader-Report-352FCD8BDEC8244CDED00CA866CA24B9.pcap_1269063206104.png" alt="Chaosreader Report - msnp" width="953" height="173" />

The session number 263 & 264 is MSN chat. Following the conversion by looking in to raw file we find some interesting things:

> <span style="color: #0000ff">forensic-proof@live.com> i;d like to get a file that i asked you before&#8230;&#8230;<br /> forensic-proof@live.com> now availabel?</span>
> 
> <span style="color: #ff0000">securityholic@hotmail.com> ah<br /> securityholic@hotmail.com> ok wait a min <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":)" class="wp-smiley" /><br /> </span>  
> [... MSN P2P file transfer session ...]
> 
> <span style="color: #0000ff">forensic-proof@live.com> thanks&#8230;.<br /> </span>  
> <span style="color: #ff0000">securityholic@hotmail.com> this is between you and me :-/</span>

It looks like they exchange some &#8220;secret&#8221; via MSN P2P file transfer. Looking at file transfer session (refer to References for MSN protocol) :

> To: <msnmsgr:securityholic@hotmail.com;{95178158-37b6-45ce-b332-2042a4d27563}>  
> From: <msnmsgr:forensic-proof@live.com;{281f2818-580b-46f0-909f-c009de526642}>  
> Via: MSNSLP/1.0/TLP ;branch={51D93360-BFBD-40CB-AD0A-2D7FB5C28031}  
> CSeq: 1  
> Call-ID: {71021C00-FE1C-4E91-B415-D2145D7C1C24}  
> Max-Forwards: 0  
> Content-Type: application/x-msnmsgr-transrespbody  
> Content-Length: 482
> 
> Listening: true  
> NeedConnectingEndpointInfo: false  
> Conn-Type: Direct-Connect  
> TCP-Conn-Type: Direct-Connect  
> IPv6-global: 2001:0:cf2e:3096:2036:1131:5c67:c1c5  
> UPnPNat: false  
> Capabilities-Flags: 1  
> **srddA-lanretnI4vPI: 85.26.251.361  
> troP-lanretnI4vPI: 2133**  
> IPv6-Addrs: 2001:0:cf2e:3096:2036:1131:5c67:c1c5 2002:a398:3e3a::a398:3e3a  
> IPv6-Port: 3313  
> Nat-Trav-Msg-Type: WLX-Nat-Trav-Msg-Direct-Connect-Resp  
> Bridge: TCPv1  
> Hashed-Nonce: {E3759BB3-EED9-04F3-3B1A-56044619D59F}

What the hell is this: **srddA-lanretnI4vPI: 85.26.251.361? **It&#8217;s reversed! So, file transfer session has this information: **IPv4Internal-Addrs: 163.152.62.58, IPv4Internal-Port: 3312. **It&#8217;s confirmed by looking at chaosreader output:

<img class="alignnone size-full wp-image-734" title="Chaosreader Report- 3312" src="http://vnsecurity.net/wp/storage/uploads/2010/03/Chaosreader-Report-352FCD8BDEC8244CDED00CA866CA24B9.pcap_1269063302409.png" alt="Chaosreader Report- 3312" width="914" height="21" />

Let dump that session and use tcpxtract to extract files from the pcap:

> <pre>$ tcpdump -nn -r 352FCD8BDEC8244CDED00CA866CA24B9 'port 3312' -w 3312.pcap</pre>
> 
> <pre>$ tcpxtract -f 3312.pcap
 Found file of type "pdf" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000001.pdf
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000008.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000009.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000010.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000011.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000012.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000013.jpg
 Found file of type "jpg" in session [163.152.62.59:37390 -&gt; 163.152.62.58:61452], exporting to 00000014.jpg</pre>

During the game, we opened PDF file but it&#8217;s just blank then we focused on JPG files, but no luck. Re-examined the blank PDF, by &#8220;Select All&#8221; we found there&#8217;s hidden text at the bottom of  the page: **CC105EE2A139A631175571452968D637. **Looks like a &#8220;key&#8221; &#8211; checksum of the secret file.

Searching on FA32 filesystem image for that checksum:

> <pre>$ sudo mount -o loop,ro B400CBEA39EA52126E2478E9A951CDE8 /mnt/loop

$ find /mnt/loop -type f -exec md5sum {} ; &gt;&gt; md5sum.txt

$ grep -i CC105EE2A139A631175571452968D637 md5sum.txt
cc105ee2a139a631175571452968d637  /mnt/loop/hqksksk/iologmsg.dat</pre>

Matched! Finally, the secret key is: **iologmsg. **We&#8217;re just lucky!

Now, look back to the hint &#8220;You should convert the flag into lower case letters and try to auth with it.&#8221;, it sounds irrelevant or the md5sum was the correct key at first?

# References

*   <a href="http://msnpiki.msnfanatic.com/index.php/MSNC:MSNSLP" target="_blank">http://msnpiki.msnfanatic.com/index.php/MSNC:MSNSLP</a>
*   <a href="http://www.hypothetic.org/docs/msn/client/file_transfer.php" target="_blank">http://www.hypothetic.org/docs/msn/client/file_transfer.php</a>
*   <a href="http://chaosreader.sourceforge.net/" target="_blank">http://chaosreader.sourceforge.net/</a>
*   <a href="http://tcpxtract.sourceforge.net/" target="_blank">http://tcpxtract.sourceforge.net/</a>

Keywords: network forensics, msn protocol, codegate 2010