---
title: Debian openssl package fix predictable random number generator
author: rd
excerpt: |
  |
    Debian đã công bố khuyến nghị bảo mật và cung cấp bản vá lỗi cho gói openssl của Debian cho lỗi trong phần sinh số ngẫu nhiên (random number generator). Lỗi được vá trong OpenSSL PRNG (pseudo random number generator) là lỗi do một Debian developer chỉnh sửa lại code của OpenSSL khiến cho bộ sinh số ngẫu nhiên này chỉ được "seed" bởi process pid.
layout: post
shorturls:
  - 'a:4:{s:9:"permalink";s:98:"https://www.vnsecurity.net/2008/05/debian-openssl-package-fix-predictable-random-number-generator/";s:7:"tinyurl";s:26:"http://tinyurl.com/ycoyh5f";s:4:"isgd";s:18:"http://is.gd/aOtgN";s:5:"bitly";s:20:"http://bit.ly/7XyOzG";}'
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359008
category:
  - news
---
Debian developer vào 05/2006 đã <a href="http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=363516" target="_blank">chỉnh sửa lại code của OpenSSL</a> sau khi sửa lỗi &#8220;uninitialized variable&#8221; do <a href="http://valgrind.org/" target="_blank">valgrind</a> cảnh báo. Tuy nhiên do không hiểu đây là sự cố tình sử dụng biến không được khởi tạo như một yếu tố &#8220;ngẫu nhiễn&#8221; của OpenSSL developer, Debian developer <a href="http://svn.debian.org/viewsvn/pkg-openssl/openssl/trunk/rand/md_rand.c?rev=141&view=diff&r1=141&r2=140&p1=openssl/trunk/rand/md_rand.c&p2=/openssl/trunk/rand/md_rand.c" target="_blank">đã loại bỏ một số đoạn mã trong hàm PRNG</a> khiến cho cho bộ sinh số ngẫu nhiên này chỉ được &#8220;seed&#8221; bởi process pid từ hệ thống. Điều này dẫn đến thư viện OpenSSL do Debian cung cấp này chỉ sinh ra 32,768 cặp khóa duy nhất từ PRNG, đồng nghĩa với việc độ an toàn của các khóa RSA, DSA, &#8230; chỉ còn là 15 bits.

Các mã khóa được sinh ra từ các gói có sử dụng thư viện OpenSSL bị lỗi này như SSH, OpenVPN, DNSSEC, X.509 certificates đều cần phải được sinh (generate) lại khóa từ đầu.

Đây là một ví dụ điển hình cho việc vì sao các nhà đóng gói phần mềm không nên tự ý chỉnh sửa code của các thư viện, phần mềm nếu không hiểu rõ về nó và nếu có chỉnh sửa thì nên gửi lại bản patch cho nhà phát triển của gói phần mềm đó để kiểm tra và cập nhật.

**Links:**

*   <a href="http://lists.debian.org/debian-security-announce/2008/msg00152.html" target="_blank">[SECURITY] [DSA 1571-1] New openssl packages fix predictable random number generator </a>
*   <a href="http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=363516" target="_blank">Debian Bug report logs &#8211; #363516 &#8211; valgrind-clean the RNG</a>
*   <a href="http://svn.debian.org/viewsvn/pkg-openssl/openssl/trunk/rand/md_rand.c?rev=141&view=diff&r1=141&r2=140&p1=openssl/trunk/rand/md_rand.c&p2=/openssl/trunk/rand/md_rand.c" target="_blank">Diff for /openssl/trunk/rand/md_rand.c between version 140 and 141</a>