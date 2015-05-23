---
title: HITB 2007 CTF report
author: longld
excerpt: |
  |
    This is what we did to win the HITB 2007 CTF in Kualar Lumpur - Malaysia.
layout: post
tweetcount:
  - 1
tweetbackscheck:
  - 1408359074
shorturls:
  - 'a:4:{s:9:"permalink";s:55:"http://www.vnsecurity.net/2007/09/hitb-2007-ctf-report/";s:7:"tinyurl";s:26:"http://tinyurl.com/ya4h74x";s:4:"isgd";s:18:"http://is.gd/aOub5";s:5:"bitly";s:0:"";}'
twittercomments:
  - 'a:1:{i:10730343033;s:7:"retweet";}'
category:
  - 'CTF - CLGT Crew'
---
We decided to join [HITB 2007 CTF][1] in Kualar Lumpur just after the [VNSECON &#8217;07][2] in August. Our team, [Sao Vang][3] from vnSecurity, is the last (10th) team registered, and we had only 1 month to prepare for the competition. It&#8217;s unbelievable that we win the game!

## Day 1 &#8211; 05/09

The game, which had been planned to start at 10:30 AM, was delayed because the organizer had not completed setting it up. Teams had to find something fun to do while waiting. We sat on the ground playing bzflag. Other guys checked email, or set up the hardware. We felt a bit nervous because there was only one network cable on each team&#8217;s table and other teams brought their own switch.

Finally, CTF crew announced the game would start at 2:00 PM. At 2:45pm, it really started. While the crew setting up vmware images (Gentoo 2007 hardened) for teams&#8217; servers, some guys looked over their shoulders and captured (guessed) the root&#8217;s password. It&#8217;s a bad password (qwe123). We got it too ;).

The organizer sent out `crackme1` for Windows and the main switch would only be plumbed after it had been cracked. I changed our root&#8217;s password, copied the vmware image for backup, tried to upload the tools to server with USB HDD, and ran the defense script while [lamer][4] and sieukhung were cracking the binary on their laptop. They took it down only within 20 minutes!

Then the game really started. The organizer announced the root password to all teams. Before that, one team (perhaps Qb1t?) had used it to accessed other servers, installed backdoor user (lalala?) and unwisely changed their root passwords. The organizer identified and removed it easily. We had also prepared a script just for this situation. Had we run `install_backdoor` script (silently, without changing root password), we could have owned most of the boxes. But then, where is the fun?

All teams started looking at the vulnerability daemons (01 to 08) and defending their servers. Some teams `chown`&#8216;d all the flags so that no other team could get it, even the score server ;-). There was glitches in the score server. Only Sao Vang got positive defensive score while the rest got negative. After `crackme1` was done, the organizer sent out `crackme2` binary. By the end of day 1, no daemon was exploited and we earned 350 bonus points for `crackme1`.

There was not much to say about day 1 because it just happened in less than 3 hours. We managed to crack `crackme1` and identified the vulnerabilities in some daemons. Our dreaded vmware host running on WinXP hang 2 times and continued to hang 3 or 4 times on day 2.

## Day 1.5

We got back to our place and continued the job overnight. `crackme2` (md5 crack) was solved first by sieukhung. Then, we found the vuln in `daemon05` (trivial buffer overflow; shamelessly, we weren&#8217;t successful in exploiting it remotely) and `daemon07` (trivial format string) but there were &#8220;bugs&#8221; that made them un-exploitable. After few hours, we could exploit `daemon02` (vtable overwrite) and `daemon04` (buffer overflow with multithreaded complication). We went to bed (and sofa ;)) at 4:30 AM and woke up at 7:30 AM. Crazyyy!

The next morning, while waiting for taxi, lamer managed to exploit `daemon01` (reverse crc32 and buffer overflow). All of our exploits were coded by lamer with his excellent Python framework.

## Day 2 &#8211; 06/09

The game started at 11:00 AM and ran smoothly.

It was more exciting on day 2. We continued to lead from the beginning by submitting `crackme2` and getting flags from other servers. The organizer also sent out fixed binaries for `daemon05` and `daemon07`.

After 2 hours, we raked in lots of points for captured flags from daemon 1, 2, 4, and 7. According to the [detail score log][5], we should have gained breakthrough points for 5 daemons (`daemon08` later) instead of 4 as displayed on the official score board and [Padocon][6] (from Korea) would have had no breakthrough. We guessed they just replayed our exploits. And maybe other teams did the same too. We raked in more than 3000 points while the next closest team 700.

After that, we settled down to work on daemon 3, 6 and 8. At 2:00 PM, the organizer sent out `crackme3` and source code of `daemon08`. sieukhung cracked `crackme3` in half an hour and we earned many bonus points (800). Right after that, lamer finished his work on `daemon08` and we got breakthrough for it. We decided to take a break and have lunch with McDonald hamburgers (thanks BlueMood, and Valmont for your support). We intended to give up daemon 3 and 6 to play bzflag (hey, they had a crowded bzflag server there) till the game ended.

But [WsLabi][7] (from Switzerland) managed to decode `daemon03` and got breakthrough for it. They also ran exploits for other daemons and earned many offensive points. We felt their hot breath when their offensive score was just one flag behind us. I thought there was something wrong with our exploits and reviewed them. We found out that exploit for `daemon04` was stuck by blocking socket behavior. We changed it and got more points.

Team Army Strong had best defensive score at that time and it seemed like we could not get valid flags from them. When trying to run exploit for `daemon08` against Army Strong, I found that the first byte of the flag changed from time to time. It inspired us to write a brute force script to submit score to the server and with just a few Python loops we successfully captured their flag (thank you Army Strong for this inspration ;)).

Some of our exploits were not really stable (e.g. `daemon07`), flag data sometimes were 40 bytes or more instead of 20 bytes (fixed flag&#8217;s length). We modified the above brute force script to submit flag in any size and raked in more points. By 4:30 PM the organizer set new flags for some daemons (they set new flags only 1 time on day 2) and we easily gained more offensive points with our scripts.

When there was only 30 minutes left, the organizer announced bonus points for crackmes&#8217; and daemons&#8217; exploits write-ups (brief). It was quite rush. We decided to shutdown the server because score server did not check for defensive things anymore and focus on write-ups. We submitted write-ups for all challenges we solved and got more than 1000 bonus points.

Finally, we won the 1st place with a total of 8900 points, with best offensive (5280), second-best defensive (510) and highest bonus (3110). WsLabi won the 2nd place with a total of 5540 points and Padocon came next with 3165.

## Conclusion

*   The CTF this year was very interesting and attracted a lot of people (though it started late as normal)
*   Some teams had more than 3 players (4 to 6) and played in turn. It is more fun this way.
*   Best defensive strategy is to keep the daemons running and modify nothing.
*   Because defensive score is far lower than offensive score, &#8220;good&#8221; defensive strategy is to remove read permission from flags so that no other team can get it. &#8220;Best&#8221; defensive strategy is to follow Army Strong.
*   Capturing then replaying is a good offensive strategy and can help team win if they do it effectively.
*   [python][8] rox!
*   Team must plan and prepare well to have good result.

## References

*   [spoo  
    nfork&#8217;s write up][9]
*   [xwings&#8217; report][10]
*   [WsLabi&#8217;s write up for daemon03][11]
*   lamer&#8217;s write up for [daemon01][12], [daemon05][13], and [daemon07][14]
*   <http://ctf2007.security.org.my/>

## Credits

To all vnSecurity members

More detailed write ups will be posted at [http://www.vnsecurity.net][15].

 [1]: http://conference.hitb.org/hitbsecconf2007kl/?page_id=61
 [2]: http://conf.vnsecurity.net/
 [3]: http://ctf2007.security.org.my/score/list/team_id/10
 [4]: /Members/lamer
 [5]: http://ctf2007.security.org.my/score/list
 [6]: http://ctf2007.security.org.my/score/list/team_id/1
 [7]: http://ctf2007.security.org.my/score/list/team_id/7
 [8]: http://www.vithon.org/
 [9]: http://www.security.org.my/index.php?/archives/HITBSecConf2007-Capture-the-Flag-Game<br />
-Considered-Fun.html
 [10]: http://blog.xwings.net/?p=76#more-76
 [11]: http://wabisabilabi.blogspot.com/2007/09/hitb-2007-ctf-daemon-03-writeup.html
 [12]: /Members/lamer/archive/2007/09/11/hitb07kl-ctf-daemon01
 [13]: /Members/lamer/archive/2007/09/14/hitb07kl-ctf-daemon05
 [14]: /Members/lamer/archive/2007/09/16/hitb07kl-ctf-daemon07/
 [15]: ../..