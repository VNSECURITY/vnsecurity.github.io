---
title: Vá lỗi cho gói openssl
author: lukas
excerpt: |
  |
    Lỗi nghiêm trọng trong phần sinh số ngẫu nhiên trong gói ssl của Debian: https://vnsecurity.net/Members/rd/archive/2008/05/13/debian-openssl-package-fix-predictable-random-number-generator đã kéo theo sự ảnh hưởng nghiêm trọng đến hệ thống mã hoá khoá của các distro dựa trên nền Debian. Lỗi này hiện có trong các release mới nhất của Debian và Ubuntu.
layout: post
shorturls:
  - 'a:4:{s:9:"permalink";s:58:"https://www.vnsecurity.net/2008/05/va-loi-cho-goi-openssl/";s:7:"tinyurl";s:26:"http://tinyurl.com/ybb5tpp";s:4:"isgd";s:18:"http://is.gd/aOteo";s:5:"bitly";s:20:"http://bit.ly/5dyyr3";}'
tweetbackscheck:
  - 1408359006
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
aktt_notify_twitter:
  - no
category:
  - news
---
Các phiên bản có chứa lỗi:

* Ubuntu 7.04 (Feisty)  
* Ubuntu 7.10 (Gutsy)  
* Ubuntu 8.04 LTS (Hardy)  
* Ubuntu &#8220;Intrepid Ibex&#8221; (development): libssl <= 0.9.8g-8  
* Debian 4.0 (etch) (see corresponding Debian security advisory)

Debian có cung cấp một script kiểm tra key, nếu status trả về weak tức là hệ thống của bạn có lỗi. Bạn nên update hệ thống ngay lập tức.

<http://security.debian.org/project/extra/dowkd/dowkd.pl.gz>  
<http://security.debian.org/project/extra/dowkd/dowkd.pl.gz.asc>

Việc kiểm tra này cần phải tính toán lại nên có thể khá lâu, bạn có thể bỏ qua bước này và chỉ cần apt-get update/upgrade mà thôi, hiện các repo đã có đầy đủ các gói cập nhật.

Có người đã gọi sự cố này là ngày &#8220;Thảm họa Debian&#8221; sau sự kiện năm 2003.

**Links:**  
[Linux security][1]  
[Planet Debian][2]

 [1]: http://www.linuxsecurity.com/content/view/136870?rdf
 [2]: http://planet.debian.org