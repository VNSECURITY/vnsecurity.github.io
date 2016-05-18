---
title: 'Hacker Việt Nam tìm ra lỗ hổng, Apple cập nhật bản vá bảo mật'
author: pdah
layout: post
thumbnail: http://vnsecurity.net/assets/2016/05/elcapitan.png
excerpt: Ngày 18/5, Apple đã cập nhật bản vá bảo mật thứ ba trong năm 2016 cho hệ điều hành El Capitan. Có rất nhiều lỗi được vá trong các bản cập nhật như thế này được phát hiện và thông báo bởi các hacker mũ trắng hoạt động độc lập. Tuy nhiên điểm đáng chú ý trong lần cập nhật này là ngoài các tên tuổi quen thuộc như Ian Beer (Google), Stefan Esser, hay lokihardt, có hai lỗi bảo mật được phát hiện bởi Nguyễn Mạnh Luật, một chuyên gia bảo mật đến từ Việt Nam.
category: research
published: true
tags:
  - facebook
  - android
  - tor
  - censorship
  - vietnam
---

Ngày 18/5, Apple đã cập nhật bản vá bảo mật thứ ba trong năm 2016 cho hệ điều hành El Capitan. Có rất nhiều lỗi được vá trong các bản cập nhật như thế này được phát hiện và thông báo bởi các hacker mũ trắng hoạt động độc lập. Tuy nhiên điểm đáng chú ý trong lần cập nhật này là ngoài các tên tuổi quen thuộc như Ian Beer (Google), Stefan Esser, hay lokihardt, có hai lỗi bảo mật được phát hiện bởi Nguyễn Mạnh Luật, một chuyên gia bảo mật đến từ Việt Nam.

Các lỗi này xoay quanh việc quản lý vùng nhớ không tốt trong mã nguồn của các thư viện PHP mặc định, mức độ nguy hiểm tuy không cao nhưng vẫn có thể gây "crash" tiến trình. Mạnh Luật cho biết sẽ có các bài viết chi tiết về kỹ thuật xung quanh các phát hiện này, hiện tại bạn đọc có thể xem qua thông báo lỗi mà bạn đã gửi đến nhóm phát triển PHP:

* [CVE-2016-3141](https://bugs.php.net/bug.php?id=71587)
* [CVE-2016-3142](https://bugs.php.net/bug.php?id=71498)

Ngoài ra, Luật cũng công bố thêm 6 lỗi khác và đã được gán mã CVE (chỉ những lỗi được công nhận là lỗ hổng bảo mật mới được gán mã này): 

* [CVE-2016-3185](https://bugs.php.net/bug.php?id=71610)
* [CVE-2016-4344, CVE-2016-4345, CVE-2016-4346](https://bugs.php.net/bug.php?id=71637)
* [CVE-2016-4342](https://bugs.php.net/bug.php?id=71354)
* [CVE-2016-4343](https://bugs.php.net/bug.php?id=71331)

Cũng phải nói thêm rằng Mạnh Luật không phải là hacker mũ trắng đầu tiên tìm ra lỗi trong các phần mềm nổi tiếng trên thế giới, các công ty Microsoft, Adobe đã từng phải gấp rút cập nhật bản vá cho các lỗ hổng phát hiện bởi người Việt Nam như thaidn, suto, caonguyen ... Đây là một tín hiệu đáng mừng cho giới an toàn thông tin Việt Nam khi các bạn trẻ yêu thích bảo mật đang theo đuổi con đường hacker mũ trắng: tham gia tìm lỗ hổng và thông báo lỗi đến nhà phát triển thay vì tận dụng
khai thác chúng với mục đích xấu. 



