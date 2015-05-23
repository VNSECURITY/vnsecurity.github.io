---
title: 'ISEC 2009 CTF Prequal &#8211; Challenge 03'
author: olalalili
excerpt: |
  |
    My solution for challenge 3 in ISEC 2009  CTF Prequal last two week
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:70:"https://www.vnsecurity.net/2009/08/isec-2009-ctf-prequal-challenge-03/";s:7:"tinyurl";s:26:"http://tinyurl.com/ycelgzp";s:4:"isgd";s:18:"http://is.gd/aOtaX";s:5:"bitly";s:20:"http://bit.ly/7BV89s";}'
tweetbackscheck:
  - 1408358996
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
---
Solution for Challenge 3 is bruteforce. The trick is to check every characters of the plaintext to figure out which nibbles it affect in encoded string. The rule is each nibble of encoded string is only affected by one char of plaintext and the character at higher position get higher priority if there&#8217;s a collision.

Then I declare struct and arrays like this :

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">typedef struct
{
    int nibble_1;
    int nibble_2;
} affect;

// string used for bruteforce
char s[20] = "1111111111111111111";

// encoded string got from plaintext s
char result[51]="";

// encoded string we need to get from plaintext s
char final[51]="A1 FD 7E F6 F0 70 98 D6 E5 F8 FF F8 78 B8 DE ED 0D";

affect a[20] = \{\{1,-1},{0,4},{3,7},{6,10},{9,-1},{12,13},{15,16},
                {18,19},{22,-1},{21,25},{24,28},{27,31},{30,-1},
                {33,34},{36,37},{39,40},{43,-1},{42,46},{45,48\}\};
</pre>

And here is the bruteforce function:

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">int Brut(int index)
{
    if (index==19) {
        if (result[strlen(result)-1]==final[strlen(final)-1])
            return 1;
        return 0;
    }
    for (int j=32;j&lt;127;j++)
    {
        s[index]=j;
        ::SendDlgItemMessageA(hwndEncoder,1000,WM_SETTEXT,0,(LPARAM)s);
        ::SendMessage(hwndEncoder, WM_COMMAND, MAKEWPARAM(1002, BN_CLICKED),
                     (LPARAM)hwndEncodingButton);
        Sleep(50);
        ::SendDlgItemMessageA(hwndEncoder,1001,WM_GETTEXT,51,(LPARAM)result);
        if (((result[a[index].nibble_1]==final[a[index].nibble_1])
           &amp;&amp;(((a[index].nibble_2==-1)||(a[index].nibble_2!=-1)
           &amp;&amp;(result[a[index].nibble_2]==final[a[index].nibble_2]))) )
            &amp;&amp; (strlen(result)==strlen(final)))
        {
            if (Brut(index+1))
                return 1;
        }
    }
    return 0;
}
</pre>

Main

<pre class="brush: cpp; gutter: false; title: ; notranslate" title="">hwndEncoder = FindWindowA(NULL,"Encoder");
        hwndEncodingButton = FindWindowA(NULL,"Encoding");
        Brut(0);
</pre>