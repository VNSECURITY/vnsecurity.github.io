---
title: '[CodeGate CTF 2015 - Quals] good-crypto'
author: vhnvn
layout: post
category: ctf - clgt crew
excerpt: Cracking a WEP passphrase given its SHA1 prefix, charset and corresponding WEP key.
thumbnail: /assets/2015/03/wep.png
tags:
  - ctf
  - wep
  - codegate
  - programming
  - crypto
---

**Category:** Programming

**Points:** 500

**Description:**

> Binary : [http://binary.grayhash.com/bd24de5d345c0d1da274fcd7d9a2b244/file.xz](file.xz)
> We recently intercepted some kind of encrypted traffic, can you help us recover the password?
>
> Update: Due to a crappy javascript programmer there's one line of code missing, but I'm sure you can figure out which one

## Write-up

The provided file is a compressed pcap file on a WEP-encrypted wireless network.

    14:52:22.194582 WEP Encrypted 44us CF +QoS Data IV:ed006c Pad 0 KeyID 0

Let's crack the key using aircrack-ng:

    > aircrack-ng file.pcap
    Opening file.pcap
    Read 45169 packets.

       #  BSSID              ESSID                     Encryption

       1  00:26:66:55:97:D6  cgnetwork                 WEP (15477 IVs)

    Choosing first network as target.

    Opening file.pcap
    Attack will be restarted every 5000 captured ivs.
    Starting PTW attack with 15477 ivs.

                                                                                    Aircrack-ng 1.2 rc1


                                                                    [00:00:00] Tested 103 keys (got 15477 IVs)

       KB    depth   byte(vote)
        0    0/  1   A4(22784) 62(20992) A8(19968) B6(19968) 42(19456) 6E(19456) 91(19200) B7(19200) 26(18944) 9E(18944) 68(18944) E4(18688) 0E(18688) 74(18688)
        1    0/  1   3D(23040) 51(20736) 07(20480) 62(19968) 7B(19968) 1F(19712) B0(19712) BD(19456) 85(19200) 9D(19200) 80(19200) EC(18944) 13(18944) 98(18688)
        2    0/  1   F6(23808) E4(20992) D0(20736) 68(20224) 95(19712) 38(19456) 0C(19200) F7(18944) 45(18944) A8(18944) 4F(18944) C5(18688) CB(18688) BB(18688)
        3    1/ 10   F3(20480) D0(19968) C5(19968) 3E(19712) 52(19456) B2(19456) 09(19456) 20(19456) 43(19456) A0(19200) 8F(19200) B0(19200) 04(18944) 8D(18944)
        4    8/ 11   67(19456) 52(19456) F9(19456) 5C(19456) 20(19456) 45(18944) D3(18944) 95(18944) 85(18944) 9D(18688) 3A(18688) C8(18688) 40(18688) 1E(18432)

                             KEY FOUND! [ A4:3D:F6:F3:74 ]
        Decrypted correctly: 100%

Yes, that was easy, now we can decrypt the traffic:

    > airdecap-ng -w A4:3D:F6:F3:74 file.pcap
    Total number of packets read         45169
    Total number of WEP data packets     15477
    Total number of WPA data packets         0
    Number of plaintext data packets         0
    Number of decrypted WEP  packets     15477
    Number of corrupted WEP  packets         0
    Number of decrypted WPA  packets         0

Still don't need wireshark, use foremost to extract the files:

    > foremost -v file-dec.pcap

    Foremost version 1.5.7 by Jesse Kornblum, Kris Kendall, and Nick Mikus
    Audit File

    Foremost started at Mon Mar 16 16:24:49 2015
    Invocation: foremost -v file-dec.pcap
    Output directory: /Users/Shared/dev/ctf/codegat/p500/output
    Configuration file: /usr/local/etc
    Processing: file-dec.pcap
    |------------------------------------------------------------------
    File: file-dec.pcap
    Start: Mon Mar 16 16:24:49 2015
    Length: Unknown

    Num  Name (bs=512)         Size  File Offset     Comment

    0:  00000104.jpg         258 KB           53549
    1:  00004538.jpg          87 KB         2323670
    2:  00000406.gif           35 B          208185       (1 x 1)
    3:  00001260.gif           35 B          645564       (1 x 1)
    4:  00002450.gif           42 B         1254588       (1 x 1)
    5:  00003653.gif           35 B         1870635       (1 x 1)
    6:  00003719.gif           35 B         1904213       (1 x 1)
    7:  00010456.gif           49 B         5353479       (1 x 1)
    8:  00010876.gif           35 B         5568641       (1 x 1)
    9:  00001639.htm           67 B          839396
    10: 00024427.htm           1 KB        12506741
    11: 00001765.png          283 B          904100       (44 x 44)
    12: 00001831.png          166 B          937711       (12 x 12)
    13: 00010214.png           67 B         5229704       (1 x 1)
    14: 00010671.png          110 B         5464006       (1 x 400)
    15: 00020736.png          425 B        10616910       (19 x 19)
    16: 00024242.png          589 B        12412171       (19 x 19)
    *|
    Finish: Mon Mar 16 16:24:49 2015

    17 FILES EXTRACTED

    jpg:= 2
    gif:= 7
    htm:= 2
    png:= 6
    ------------------------------------------------------------------

The secret is in this html:

{% highlight html %}
    <html>
    <head>
        <title>Router - index</title>
        <link href="static/css/bootstrap.min.css" rel="stylesheet" media="screen">
        <link href="static/css/bootstrap-responsive.min.css" rel="stylesheet" media="screen">
        <link href="static/css/blah.css" rel="stylesheet">

        <script src="static/js/sha1.js"></script>

        <script>
            function validate() {
                var x = document.forms["formxx"]["pwz"].value;
                if (x == null || x == "") {
                    alert("Password must be filled out");
                    return false;
                }

                if (!x.match("/^[A-Za-z]+$/")) {
                    alert("Bad charset");
                    return false;
                }

                if (!sha1(x).match("^ff7b948953ac"))
                {

                }

                alert("Flag: " + x);
                return true;
            }
        </script>

    </head>
    <body>
        <div class="box">
            <center>
                <h1>Router - Please log in</h1>
            </center>
            <br/>
            <br/>




            <form class="box" method="post" onSubmit="validate()" name="formxx" action="/login">
                <h2 class="box-heading">Login</h2>
                <input type="text" class="input-block-level" placeholder="Username" name="user" value="admin">
                <input type="password" name="pwz" class="input-block-level" placeholder="WEP passhrase" name="pw">
                <input type="submit" name="submit" value="Submit" />
            </form>
        </div>

        <script src="static/js/jquery-1.10.2.min.js"></script>
        <script src="static/js/bootstrap.min.js"></script>
    </body>
    </html>

{% endhighlight %}

Well, now let's sum up all the information:

* We need to find a password with charset [a-zA-Z]+, having sha1 value starting with "ff7b948953ac" (from javascript code).
* The password is WEP's Passphrase (indicated in placeholder of the input box).
* WEP's key corresponding to the Passphrase is A4:3D:F6:F3:74.

Using the first hint only, I wrote a brute force script for it and had it run up to 6 characters without success.

WEP's key generator is mostly using simple xor and PRNG:

![WEP key generation algorithm](/assets/2015/03/wep.png "WEP key generation algorithm")

The seed's efficient value space is only 24 bits, so we can find the original hash easily:
{% gist vhqtvn/ed163c30000405149a4e %}

Output:

    ('Found it: ', '0x12766b')
    Verify:
    ('0xa4', '0xa4a782')
    ('0x3d', '0x3d303d')
    ('0xf6', '0xf6420c')
    ('0xf3', '0xf3089f')
    ('0x74', '0x74c0e6')

So we have the seed value now, and:

* sumxor(p[4k])=0x6b
* sumxor(p[4k+1])=0x76
* sumxor(p[4k+2])=0x12

The passphrase length is longer than 6, so from this i can guess the passphrase length is 10 (as passhrase is ascii, we just need to look at msb of the result to guess). I was feeling stupid to see how long can my original bruteforce script need to brute these 10 characters.

Let's rewrite the relations in more readable form:

* p[0] xor p[4] xor p[8] = 0x6b
* p[1] xor p[5] xor p[9] = 0x76
* p[2] xor p[6]          = 0x12

Using these relations, the key space is still 7 characters, cracking that for charset of 52 values should take hours, so i tried to install cuda toolkit to use gpu, but my crappy internet dont allow me to do so. From the relation, in both set {p[0], p[4], p[8]}, {p[1], p[5], p[9]}, there must be 2 uppercase letters or no letter at all for each set, so I guessed that all characters are lowercase. Now let's run a bruteforce script for lowercase charset:

{% gist vhqtvn/4ff6fe679f313be3a8ea %}

Wait some tens of seconds and we have the key: **cgwepkeyxz**.

Thanks CodeGate for this interesting "programming" problem :)
