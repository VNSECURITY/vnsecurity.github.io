---
title: Software based disk encryption not secure enough!
author: rd
excerpt: |
  |
    Researchers at Princeton University has released a white paper named
     "Lest We Remember: Cold Boot Attacks on Encryption Keys" [1] about gaining access to the contents of a computer's RAM after power off and/or reboot and used it to defeat various popular disk encryption systems such as Microsoft's BitLocker, Apple's FileVault, TrueCrypt, dm-crypt.
layout: post
tweetcount:
  - 0
shorturls:
  - 'a:4:{s:9:"permalink";s:84:"https://www.vnsecurity.net/2008/02/software-based-disk-encryption-not-secure-enough/";s:7:"tinyurl";s:26:"http://tinyurl.com/yazlckp";s:4:"isgd";s:18:"http://is.gd/aOtjl";s:5:"bitly";s:20:"http://bit.ly/8tVLwg";}'
tweetbackscheck:
  - 1408359015
twittercomments:
  - 'a:0:{}'
aktt_notify_twitter:
  - no
category:
  - news
---
Contrary to conventional wisdom, &#8220;volatile&#8221; semiconductor memory does not entirely lose its contents when power is removed. Both static (SRAM) and dynamic (DRAM) memory retains some information on the data stored in it while power was still applied and they still hold values for a long intervals without power or refresh. This is a known [2] problem for a long long time. However, no one has ever tried (or published) any practical attack on this problem like what Princeton University researchers did.

This DRAM threat goes beyond disk encryption. Any kind of sensitive data such as password, encryption key, credit card information,&#8230; in you RAM could be stolen in just a few minutes. Due to the nature of this problem, it&#8217;s hard for software based hard disk encryption solution to protect against this attack. Software based solution would be able to try to encrypt/clear the disk key whenever PC goes into inactive state (i.e screen saver, standby, hibernate) but it&#8217;s not really practical and/or applicable in some cases. The white paper [1] also offers interesting algorithms & methods to find crypto keys in memory images.

If you&#8217;re really care about your information, you should better to change your behavior to unmount encrypted disk and/or power-off your machine (for a while to give the memory enough time to decay) whenever you&#8217;re away from your computer if you&#8217;re using software based disk encryption and/or to use a hardware based disk encryption solution. FYI, Seagate also has a hardware based hard disk encryption solution ready to use.

Links:

1.  <a href="http://citp.princeton.edu.nyud.net/pub/coldboot.pdf" target="_blank">Lest We Remember: Cold Boot Attacks on Encryption Keys</a>
2.  <a href="http://www.cs.auckland.ac.nz/~pgut001/pubs/secure_del.html" target="_blank">Secure Deletion of Data from Magnetic and Solid-State Memory</a>