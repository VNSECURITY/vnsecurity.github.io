---
title: '[Plaid CTF 2015] radhos'
author: vhnvn
layout: post
category: ctf - clgt crew
thumbnail: /assets/2015/04/ppp-web.png
tags:
  - ctf
  - ppp
  - programming
  - web
  - crypto
excerpt: Hash collisions attack on a web application.
---

**Category:** Web

**Points:** 250

**Description:**

> A web scale key value store, for your enjoyment!
>
> Should be working
> Running at 52.6.62.188 port 9009

## 64-bit collision approach

I didn't solve this problem within the contest time, but it's here finally :)

First, let's take a quick look on provided script:

{% gist vhqtvn/0095c863af9098a0394e %}

It's a web service which provide key-value storage functions via JSON requests, keys are stored using its masked hash value using python's built in hash function. So I decided it a collision-finding problem. At first, looking at this line:

{% highlight python %}
assert (hash('PPP') != 2149279368079130035)
{% endhighlight %}

Which made me thought that python is running using version 3.4 with new SIPHASH24 hash algorithm and SPENT A DAY TO CRACK SIPHASH without success... (poor me :(). When i could manage to talk with w~ about this problem, i realized that it's only the old hash function with randomized secret keys.

A quick search on python source code gave me the implementation of its string hashing:

{% highlight cpp %}
static long
string_hash(PyStringObject *a)
{
    register Py_ssize_t len;
    register unsigned char *p;
    register long x;

#ifdef Py_DEBUG
    assert(_Py_HashSecret_Initialized);
#endif
    if (a->ob_shash != -1)
        return a->ob_shash;
    len = Py_SIZE(a);
    /*
      We make the hash of the empty string be 0, rather than using
      (prefix ^ suffix), since this slightly obfuscates the hash secret
    */
    if (len == 0) {
        a->ob_shash = 0;
        return 0;
    }
    p = (unsigned char *) a->ob_sval;
    x = _Py_HashSecret.prefix;
    x ^= *p << 7;
    while (--len >= 0)
        x = (1000003*x) ^ *p++;
    x ^= Py_SIZE(a);
    x ^= _Py_HashSecret.suffix;
    if (x == -1)
        x = -2;
    a->ob_shash = x;
    return x;
}
{% endhighlight %}

Quite simple huh, start with an const, mul and or rounds, and ending by xor with its length and another const. Problem was that we dont know the value of _Py_HashSecret.prefix and _Py_HashSecret.suffix, let's call them A and B from now on. As the calculation is based on simple operations only, we can use tools like z3 to solve the SMT model, but due to laggy internet, I decided to leave that path. Let's calculate some simple hashes:

* Hash value of "\x00" * 1 : (1000003 * A) xor 1 xor B
* Hash value of "\x00" * 2 : (1000003 * 1000003 * A) xor 2 xor B
* Hash value of "\x00" * 3 : (1000003 * 1000003 * 1000003 * A) xor 3 xor B

From above formulas, I can reduce B by xor the hash of 2 strings, make it a formula with only A:

* (Hash value of "\x00" * 1) xor (Hash value of "\x00" * 2) = (1000003 * A) xor 1 xor (1000003 * 1000003 * A) xor 2
* (Hash value of "\x00" * 2) xor (Hash value of "\x00" * 3) = (1000003 * 1000003 * A) xor 2 xor (1000003 * 1000003 * 1000003 * A) xor 3

Now how can we sove that for A? As its type is long on 64 bits machine, we can't do a full bruteforce search.

There's an interesting feature of multiplication and xor is that the suffix of result if equal to operation result of suffixes of its operants. i.e. 0x1213*0x3456 = 0x3B1EE62 while 0x13*0x56 = 0x662, both share the same byte suffix. Using this we can solve for its value byte-byte-byte.

First, let's calculate the hash value of some strings first:

{% highlight cpp %}
/*Hash value of "\x00" * i */
long hashArr[]={0l,
7848190082587965582,
-3458030773997347889,
-4582483746743215612,
4410049638523290193,
6253908765636887514,
7892342918428438971,
4812826225314830288,
-3580448393237491763,
-3802863708583786458,
7877484284146754215,
};
Sample sample[] = {
	 Sample("testing",7,-6690661205054787548),
	 Sample("vanhoa",6,4054411468809426790),
	 Sample("ldfsjl",6,-1154596901575536268),
	 Sample("2cm834mc803c23-",15,-3744132313005259935),
};
{% endhighlight %}

Using these values, we can generate all possible values for A and B using:

{% highlight cpp %}
vector<long> possP;
possP.push_back(0);
for(int b=1;b<=8;b++){
    vector<long> possP2;
    for(long i=0;i<256;i++){
        for(int k=0;k<possP.size();k++){
            long pp = possP[k] + (i<<(8*(b-1)));
            int valid12 = (((M * pp) ^ 1 ^ (M * M * pp) ^ 2 ^ hashArr[1] ^ hashArr[2]) & ((1ll<<(8*b))-1))==0;
            int valid23 = (((M * M * pp) ^ 2 ^ (M * M * M * pp) ^ 3 ^ hashArr[2] ^ hashArr[3]) & ((1ll<<(8*b))-1))==0;
            int valid34 = (((M * M * M * pp) ^ 3 ^ (M * M * M * M * pp) ^ 4 ^ hashArr[3] ^ hashArr[4]) & ((1ll<<(8*b))-1))==0;
            if(valid12 && valid23 && valid34){
                possP2.push_back(pp);
            }
        }
    }
    possP = possP2;
}
{% endhighlight %}

And then verify the results with provided samples:

{% highlight cpp %}
vector<pair<long,long> > r;
for(int k=0;k<possP.size();k++){
    long p = possP[k];
    long q = (p * M) ^ 1 ^ hashArr[1];
    long x = p;
    bool valid = true;
    for(int len=1;valid && len<=hashMax;len++){
        x = (1000003*x);
        if((x^len^q) != hashArr[len]) valid = false;
    }
    for(int i=0;i<sampleLen;i++){
        if(pythonHash(sample[i].inp,sample[i].len,p,q)!=sample[i].hash) valid = false;
    }
    if(valid){
        r.push_back(make_pair(p, q));
    }
}
{% endhighlight %}

Using this method, i can (always) obtain 2 possible values pair for A and B, so i decided to use only the first one.

From this point, A and B are known, so we can simulate the hashing function locally. Now we must find collision for string "you_want_it_LOLOLOL?".

The hashing value is 64 bits, so we have to search on a 64-bit space to obtain the collision, after some simple test on small strings, i think this hashing is nearly unique for them, which lead me to consider only in 8-byte strings. Thinking the hash function as a finity state graph, starting at A, we can go to next hash number using current character of input string. A full BFS rooting from A will require 2^64 nodes to be visited, which is impossible for our normal computer. We can try BFS from both side: the source node and the target node, and check if they can visit a common node, but this approach is for 128GB computer only - as  we have to save hash (8 byte each) of 2^32 values, which require approx. 34GB RAM.

My last step to solve this problem is optimizing this: BFS only 3 bytes from each node, and try to do something for the remain 2 bytes (8-3*2 bytes). The first approach should be 256^2 loop:

    for char1 in range(256):
        for char2 in range(256):
            TWO_WAY_BFS()

which should require some hours to finish. Looking more deeply on the hashing algorithm bring me an idea:

    the assigment x = (1000003*x) ^ *p++; which our controlled p can assign any value to the LSByte of x!

So a byte can be obmitted from the search because it can be calculated using next and previous values, which reduce the searching space to 7 bytes, the obmitted byte will be the glue of 2 BFSs.

Finally making it run 8 processes in parallel and we got the flag *flag{wh0_n3edz22Z22zZ_p3p456}*.

{% gist vhqtvn/e0e545577a518e429d98 %}

        RSIZE = 2
        Found A = 0x1d0e2c73d04d2feb; B= 0xb01eedc54b35180e
        [22] Result 22 : 1
         -7368800807082251008
        SolveLeft 2 256
        SolveLeft 3 65536
        SolveLeft- 4 16777216
        SOLVE LEFT RESULT: 00ba9057 99bcc2b521402d3a ac0276917b41cb3e 426e84fc91cabcb4
        SolveRight 1 1
        SolveRight 2 256
        SolveRight 3 65536
        SOLVE RIGHT RESULT: 009b5da9 99bcc2b521402de5
        Result: \xba\x90\x57\x22\xdf\xa9\x5d\x9b
        Killed: 9

For the session with given A and B, the collision string for "you_want_it_LOLOLOL?" was "\xba\x90\x57\x22\xdf\xa9\x5d\x9b" with the same hash value 0x2fdd3e3f58ce3f70.


## 32-bit collision approach

Here's python collision finding using z3:

{% highlight python%}
#!/usr/bin/python

from z3 import *

x = BitVecs('x1 x2 x3 x4 x5 x6 x7 x8',8)

A = 0x1d0e2c73d04d2feb
B = 0xb01eedc54b35180e

def xhash(a, A, B):
    l = len(a)
    x = A
    x = x ^ (ZeroExt(56,a[0]) << 7)
    l -= 1
    i = 0
    while l >= 0:
        x = (x * 1000003) ^ ZeroExt(56,a[i])
        i += 1
        l -= 1
    x = x ^ len(a)
    x = x ^ B
    return x

s = Solver()
s.add(xhash(x, A, B) & 0xFFFFFFFF == 0x39e0776e)

print s
print 'start!'
print 'sat:',s.check()
m = s.model()
print m
{% endhighlight %}

This program can run under 1 minute on my machine.

        [(((((((((2093659752701439979 ^ ... << ...)*1000003 ^
                 ZeroExt(56, x1))*
                1000003 ^
                ZeroExt(56, x2))*
               1000003 ^
               ZeroExt(56, x3))*
              1000003 ^
              ZeroExt(56, x4))*
             1000003 ^
             ZeroExt(56, x5))*
            1000003 ^
            ZeroExt(56, x6))*
           1000003 ^
           ZeroExt(56, x7))*
          1000003 ^
          ZeroExt(56, x8) ^
          8 ^
          12690842231602747406) &
         4294967295 ==
         971011950]
        start!
        sat: sat
        [x8 = 163,
         x3 = 28,
         x2 = 162,
         x1 = 0,
         x4 = 175,
         x5 = 217,
         x6 = 114,
         x7 = 100]
