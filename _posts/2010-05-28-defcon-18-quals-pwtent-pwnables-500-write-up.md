---
title: 'DEFCON 18 Quals: Pwtent Pwnables 500 write up'
author: rd
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:79:"http://www.vnsecurity.net/2010/05/defcon-18-quals-pwtent-pwnables-500-write-up/";s:7:"tinyurl";s:26:"http://tinyurl.com/2ud7a44";s:4:"isgd";s:18:"http://is.gd/eBZFN";}'
tweetbackscheck:
  - 1408358974
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - CTF
  - DEFCON
---
This is a short write up since I&#8217;m a bit lazy. We didn&#8217;t solved it during the quals as it was too late (we exhausted and most of member including myself went to sleep so I only started looking into this in the morning of Monday. Didn&#8217;t have enough of time to finish it).

For pp500, ddtek gave us a pcap network dump of a remote exploit to a daemon on host 192.41.96.63, port 6913 and password to login is &#8216;antagonist&#8217;. Playing around with the daemon, I found out that &#8216;b&#8217; command returns you back a block of 512 bytes from the binary.

<pre>Password: antagonist
? to see the menu
&gt; ?
x - quit
d - donate entropy
r - report
b - /dev/hrnd
? - help
&gt; b
Seed: 0
ELF     4�$4 (444�������&& l � ��/libexec/ld-elf.so.FreeBSDk5%20   .1!
                                                                      "
/)(-*&gt;</pre>

Seed value from 0 to 19 returned the same data, 20 returned different data, 21-39 same as 20, &#8230; So I wrote a script to extract out all the blocks from the binary with seed values 0, 20, 40, 60, 80, &#8230;.. After filtered out all the duplicated blocks, there were totally 21 unique blocks.

<pre class="brush: python; title: ; notranslate" title="">#!/usr/bin/env python
import sys
import socket

class humpty:
        def  __init__(self, host, port):
                self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.s.connect((host, port))
                ret = self.s.recv(1024)
                print ret

        def login(self, passwd):
                self.s.send(passwd + "n")
                ret = self.s.recv(1024)
                print ret

        def getdata(self, seed):
                print seed
                cmd = "bn"
                self.s.send(cmd)
                ret = self.s.recv(1024)
                print ret
                ret = self.s.recv(1024)
                print ret

                self.s.send("%dn" % seed)
                ret = ret + self.s.recv(1024)
                ret = ret
                #print len(ret), repr(ret)
                return ret[6:518]

        def close(self):
                self.s.close()

def log(file, data):
        f = open(file, "w")
        f.write(data)
        f.close()

host = '192.41.96.63'
port = 6913

c = humpty(host, port)
a = raw_input("Enter to continue");
c.login("antagonist")

data = []
for i in range(0, 100):
        data.append(c.getdata(20*i));

data = list(set(data))
print "Total %d unique blocks" % len(data)
for i in range(0, len(data)):
        log("%d"%i, data[i])

print "Done"
c.close()
</pre>

From the pcap dump session, we can find out that the size of humpty binary is 10392, which is 21 blocks of 512 bytes

<pre>-rwxr-x---  1 root  humpty  10392 May 22 19:06 humpty
-rw-r-----  1 root  humpty     21 May 22 19:01 key</pre>

The task now is to merge all the blocks in a the right order to rebuild the ELF binary. What I did was to get a sample freebsd binary which has similar size as humpty, then used \`split -b512\` to split it to 21 chunks of 512 bytes and then compared side by side with the 21 extracted blocks from ddtek&#8217;s pp500 server, merged it manually and used readelf to verify the merged binary. [Here][1] (or [here][2]) is the binary for pp500&#8242;s humpty.

After getting the binary, the rest of the tasks are easy since ddtek gave us out the exploit from the pcap dump. The exploit is similar to [the exploit of esd2][3]. FYI, esd2 is the original binary for pp500 which was leaked out via pp200 shell. After ddtek guys realized of this problem, they modified the esd2, changed password, strings, commands, read elf block functions, xor input, .. and named it humpty.

 [1]: http://force.vnsecurity.net/download/humpty
 [2]: http://ddtek.biz/pp500
 [3]: /2010/05/defcon-18-quals-pwtent-pwnables-500-exploit/