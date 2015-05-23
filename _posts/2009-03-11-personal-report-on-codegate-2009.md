---
title: Personal report on CodeGate 2009
author: lamer
excerpt: |
  |
    Team CLGT took part in the CodeGate 2009 organized by BeistLab. We came in 9th. And this post is about what happened then.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:68:"https://www.vnsecurity.net/2009/03/personal-report-on-codegate-2009/";s:7:"tinyurl";s:26:"http://tinyurl.com/y8lhq2w";s:4:"isgd";s:18:"http://is.gd/aOtcy";s:5:"bitly";s:20:"http://bit.ly/4qHTei";}'
tweetbackscheck:
  - 1408359000
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
kopa_newsmixlight_total_view:
  - 17
category:
  - 'CTF - CLGT Crew'
---
The contest started at 20:00 GMT+7 on March 06 and ended at 22:00 GMT+7 on March 08 (sorry to the ladies, we ignored yall). There were about 500 registered teams for the preliminary round. I reckon more than half of them were by-products of hacking attempts at the registration site.

On the first night, we played from home. Six challenges were released in the first wave, then through out the whole contest, more challenges came up eventually. I could only remember picking up challenge 07 and worked on it in one or two hours, then continued with challenge 03. The rest of the team were less lucky though. They hit on 09, 11, and 13 which are crazily difficult. Not because they are analytically difficult but they are, well, like those &#8220;aha questions&#8221; that you encounter in job interviews. In fact, many top teams had the same difficulties in solving them because, I guess, we just aren&#8217;t exposed to the same teaching as the quiz maker. Take challenge 09 for example. It was a short Matahari cipher as what the hint suggested. But after hours of googling, the only usable link was an old scanned image at <a class="reference" href="http://math88.com.ne.kr/crypto/picture/matahari-cipher.jpg">http://math88.com.ne.kr/crypto/picture/matahari-cipher.jpg</a>. Nonetheless, we managed to climb to the top spot that night.

The next morning, some of us gathered at a coffee shop, some worked from home. I hit myself hard on the head for not taking the #03 breakthrough the previous night. Cuz I was kinda tired so I went to bed early. At around 07:30 we solved #03. Then 04 took away a lot of our time. A few of us passed 04 around trying to find where we could exploit the EBP overwrite bug. None of us could tell. So we left #04 and looked at other challenges. I picked up #10. At first look, it seemed unbreakable to me. After a few hours thinking on it, a shamefully dumb idea came. I wrote a utility similar to the Rainbow Table generator and hoped it could complete the task within a reasonable time so that we could solve the challenge on the next day. And by then, my brain shut down, I couldn&#8217;t think of anything else, probably due to the lack of sleep. The team, though, still solved some more problems, especially we got pass the insensible challenge #13.

The last day some of us still gathered at a coffee shop (including me), and some still worked from home. This was the most productive day for myself. At first, we solved challenge 08. Then we nailed #17. And while I was thinking of #21, the solution for #04 came. Leaving 04 in the good hand of rd, I got back to 10. Our hope collapsed when we found out that the generator was still way behind. So I scraped that dumb idea and tried to find another way. At the same time, the team made some good progress on 18, and 21. It was unfortunate that minutes of brilliance did not come sooner. We all came to feasible solutions for 10, 18, and 21 after the contest ended a few minutes. In fact, we shared with other teams the disappointment. Some team solved a challenge just seconds after the score system closed. That is true pity. In the end, we arrived at 9th.

All in all, we love this contest. There were many new stuffs for us to learn from this. Most importantly, we found that we were too far behind in Web technologies.

Kudos to BeistLab for organizing such entertaining and educating contest!

Our write-ups could be downloaded [here][1]. Enjoy.

 [1]: /wp/storage/uploads/2009/12/codegate2009.pdf