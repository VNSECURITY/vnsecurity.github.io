---
title: 'CodeGate 2010 Challenge 15 &#8211; SHA1 padding attack'
author: rd
layout: post

aktt_notify_twitter:
  - no
tweetbackscheck:
  - 1408358983
shorturls:
  - 'a:4:{s:9:"permalink";s:75:"http://www.vnsecurity.net/2010/03/codegate_challenge15_sha1_padding_attack/";s:7:"tinyurl";s:26:"http://tinyurl.com/ygdl77a";s:4:"isgd";s:18:"http://is.gd/aOugF";s:5:"bitly";s:20:"http://bit.ly/aKE893";}'
twittercomments:
  - 'a:6:{i:10568006622;s:7:"retweet";i:10576507412;s:7:"retweet";i:10574263387;s:7:"retweet";i:10569701394;s:7:"retweet";i:10567861679;s:7:"retweet";i:10567299486;s:7:"retweet";}'
tweetcount:
  - 6
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - CTF
  - length extension attack
  - padding
  - sha1
---
## Summary

This is a web based crypto challenge vulnerable to padding/length extension attack in its sha1 based authentication scheme.

## Analysis

Challenge URL: <a href="http://ctf1.codegate.org/03c1e338b6445c0f127319f5cb69920a/web1.php" target="_blank">http://ctf1.codegate.org/03c1e338b6445c0f127319f5cb69920a/web1.php</a>

This page will ask for submitting a username for the first time. Once a username is submited ( &#8216;aaaa&#8217; for example), the script will set a cookie as the following:

> web1_auth = YWFhYXwx**|**8f5c14cc7c1cd461f35b190af57927d1c377997e

The first part **YWFhYXwx** is the base64 encoded string of *&#8216;aaaa|1&#8242;* (username|role). The second part **8f5c14cc7c1cd461f35b190af57927d1c377997e** is the *sha1(unknown_secretkey + username + role)*.

In the next visit, the web1.php script will check for the cookie and return the following message

> &#8220;Welcome back, aaaa! You are not the administrator.&#8221;

We can guest that 1 is the role value for normal user and 0 for administrator.

## Solution

If we try to modify to first part of the web1\_auth cookie to something like base64\_encode(&#8216;aaaa|0&#8242;), the script will return an error message saying that the data has been tampered due to the wrong signature.

As we know that popular hash functions including sha1 are vulnerable to length extension (or padding) attacks. This can be used to break naive authentication schemes based on hash functions.

I will not write the detail on how to do sha1 length extension attack, you can read papers in the References section below for more information. Basically, with padding attack, we can append arbitrary data to the cookie and generate a valid signature for it without knowing the secret key. In this challenge, we want to have &#8216;|0&#8242; (administrator role) at the end of the first part of the cookie.

> $ python sha-padding.py  
> usage: sha-padding.py <keylen> <original\_message> <original\_signature> <text\_to\_append>
> 
> $ python sha-padding.py 25 &#8216;aaaa|1&#8242; 8f5c14cc7c1cd461f35b190af57927d1c377997e &#8216;|0&#8242;  
> new msg: &#8216;aaaa|1x80x00x00x00x00x00x00x00x00x00x00x00x00x00x00x00  
> x00x00x00x00x00x00x00x00x00x00x00x00x00x00x00x00xf8|0&#8242;  
> base64: YWFhYXwxgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4fDA=  
> new sig: 70f8bf57aa6d7faaa70ef17e763ef2578cb8d839

And here is what we got with the web1_auth cookie using **YWFhYXwxgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4fDA=** and signature **70f8bf57aa6d7faaa70ef17e763ef2578cb8d839**

> Welcome back, aaaa! Congratulations! You did it! Here is your flag: CryptoNinjaCertified!!!!!

## Source Codes

*   <http://force.vnsecurity.net/download/rd/shaext.py>
*   <http://force.vnsecurity.net/download/rd/sha-padding.py>
*   <http://force.vnsecurity.net/download/rd/sha.py> (this one  taken from pypy lib)

## References

*   [http://en.wikipedia.org/wiki/Cryptographic\_hash\_function][1]
*   [Flickr&#8217;s API Signature Forgery Vulnerability][2]
*   G. Tsudik, “Message authentication with one-way hash functions,” Proceedings of Info-com 92.

Keywords: sha1, padding, length extension attack, codegate 2010

 [1]: http://en.wikipedia.org/wiki/Cryptographic_hash_function
 [2]: http://netifera.com/research/flickr_api_signature_forgery.pdf