---
title: SMM rootkit PoC demo at Black Hat 08
author: rd
excerpt: |
  |
    Sherri Sparks và Embleton sẽ demo bản SMM  (System Management Mode) rootkit tại Black Hat 2008 sắp tới. Đây là loại rootkit sẽ rất khó phát hiện do AV không truy cập được vùng nhớ SMRAM này.
layout: post
tweetcount:
  - 0
shorturls:
  - 'a:4:{s:9:"permalink";s:72:"https://www.vnsecurity.net/2008/05/smm-rootkit-poc-demo-at-black-hat-08/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydxatd9";s:4:"isgd";s:18:"http://is.gd/aOtgm";s:5:"bitly";s:20:"http://bit.ly/5oDJMX";}'
tweetbackscheck:
  - 1408359007
twittercomments:
  - 'a:0:{}'
aktt_notify_twitter:
  - no
category:
  - news
---
Với kiến trúc IA32/64, để thay đổi SMI handler (cho rootkit) có thể patch BIOS code hoặc thay đổi trực tiếp từ SMRAM nếu D_LCK bit không được set hoặc tận dụng lỗi của CPU/Chipset/BIOS cho phép truy cập vùng nhớ SMRAM. ITP (In-Target Probe) cũng có thể được dùng để thay đổi SMRAM hay debug SMI handler.  Theo thông tin được biết từ tác giả của SMM rookit sẽ trình bày tại [BlackHat 08][1] sắp tới thì họ tận dụng lỗi cũ được công bố năm 2006 khi BIOS không khóa vùng nhớ SMRAM. Duflot đã trình bày việc tận dụng lỗi này để phá lớp bảo vệ của *OpenBSD secure levels* tại CanSecWest 2006. BSDaemon cũng đã đề cập một phần về chủ đề này tại [VNSECON 07][2] và viết một bài nghiên cứu về việc này trên Phrack Magazine.

Yuriy của Intel cũng sẽ trình bày tại BlackHat 08 sắp tới [một giải pháp][3] để phát hiện virtualization rookit sử dụng bộ vi xử lý riêng nhúng trong MCH. Giải pháp này cũng có thể được sử dụng để phát hiện SMM rootkit.

**Links:**

*   [Hackers Find a New Place to Hide Rootkits][4]
*   [BlackHat USA 08][1]
*   [Security Issues Related to Pentium System Management Mode][5]
*   [VNSECON 07][2]
*   [System Management Mode Hack &#8211; Using SMM for &#8220;Other Purposes&#8221;][6]

 [1]: http://www.blackhat.com/html/bh-usa-08/bh-usa-08-schedule.html
 [2]: http://conf.vnsecurity.net/program/frontpage?pageIndex=1
 [3]: http://www.blackhat.com/html/bh-usa-08/bh-usa-08-speakers.html#Bulygin
 [4]: http://www.pcworld.com/businesscenter/article/145703/hackers_find_a_new_place_to_hide_rootkits.html
 [5]: http://www.cansecwest.com/slides06/csw06-duflot.ppt
 [6]: http://www.phrack.com/issues.html?issue=65&id=7