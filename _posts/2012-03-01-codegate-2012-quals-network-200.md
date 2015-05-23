---
title: 'Codegate 2012 Quals &#8211; Network 200'
author: pdah
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358967
category: ctf - clgt crew
tags:
  - '2012'
  - codegate
  - network
---
**Challenge**

> To whom it may concern to DoS attack.  
> What is the different between attack and normal traffic?  
> Attached PCAP file is from suspicious client PC which may be infected.  
> If you find TOP 4 targeting address, let me know exactly information such as below.  
> Answer:  
> COUNTRY\_NAME\_TOP1(3)COUNTRY\_NAME\_TOP2(13)COUNTRY\_NAME\_TOP3(2)COUNTRY\_NAME\_TOP4(5)\_1.1.1.1\_2.2.2.2\_3.3.3.3\_4.4.4.4 

<http://repo.shell-storm.org/CTF/CodeGate-2012/Network200/A565CF2670A7D77603136B69BF93EA45>

**Summary**  
Given a pcap file, our task is to find top 4 targeting addresses of a DoS attack. This challenge requires network analysis skill with some experiences of DoS attack.

**Solution**

We wrote a small python script to generate the statistics of packets:

<pre class="brush: python; title: ; notranslate" title="">from scapy.all import *
import operator
packets = rdpcap("network200")
stats = {}
for packet in packets:
    try:
        dst = packet.payload.dst
        if dst not in stats: stats[dst] = 0
        stats[dst] += 1
    except:
        pass
for k,v in sorted(stats.iteritems(), key=operator.itemgetter(1))[::-1]:
    print k,v
</pre>

Here’s a part of output:

> 111.221.70.11 52620  
> 1.2.3.4 12670  
> 109.123.118.42 2960  
> 174.35.40.44 637  
> 220.73.139.203 452  
> 123.214.170.56 375  
> 199.7.48.190 311  
> 220.73.139.201 280  
> 8.8.8.8 248  
> 74.125.71.94 208  
> 208.46.163.42 186  
> 175.158.10.55 146  
> 174.35.40.43 145  
> 74.125.71.120 120  
> 74.125.71.104 116  
> 69.171.234.16 103  
> 66.150.14.48 99  
> 61.110.213.19 94  
> 184.28.147.55 84  
> 174.35.40.45 82  
> 110.45.229.135 82  
> 199.59.149.232 79  
> 61.106.27.72 77  
> 184.169.76.33 68  
> 74.125.71.157 62  
> 211.174.53.236 56  
> 174.35.40.6 55  
> 208.94.0.38 54  
> &#8230; 

Then we checked one by one from the top of our list using WireShark:

*   111.221.70.11 is obviously under SYN flood attack.
*   109.123.118.42 is flooded by HTTP GET requests.
*   199.7.48.190 is under RUDY attack (POST requests with very large Content-Length).
*   66.150.14.48 has some abnormal HTTP Requests.

Using ip2location.com, we got the country names in respective order:

*   Singapore
*   United Kingdom
*   United States
*   United States

FLAG: **none\_111.221.70.11\_109.123.118.42\_199.7.48.190\_66.150.14.48**