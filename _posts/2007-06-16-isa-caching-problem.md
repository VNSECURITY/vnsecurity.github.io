---
title: ISA caching problem
author: hieu le
excerpt: |
  |
    ISA có cơ chế cache cả dynamic content, làm sao để bỏ qua cache của ISA đây?
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359024
shorturls:
  - 'a:4:{s:9:"permalink";s:54:"http://www.vnsecurity.net/2007/06/isa-caching-problem/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydaqwbk";s:4:"isgd";s:18:"http://is.gd/aOudL";s:5:"bitly";s:0:"";}'
category:
  - tutorials
---
Mấy hôm rồi vật lộn với cái vụ cache của ISA. Đề bài rất đơn giản: 2 tài khoản của 2 người ở trong cùng LAN, sử dụng chung ISA2004 làm proxy. Họ login và &#8230; nhìn thấy nội dung tài khoản của nhau. Làm sao giải quyết?

Giải pháp được đưa ra là ép proxy không được cache bằng các tham số:

Pragma: no-cache

Cache-control: no-cache

Cache-control: private

Expires: 0

must-revalidate

Kết quả: vẫn bị cache.

Nghi ngờ: proxy bỏ qua các tham số được gửi trong header và cố tình cache.

Giải pháp 2: thay đổi URL ngẫu nhiên là khỏi cache

URL hiện nay sẽ như sau: www.xxx.com/java-script?_id=random-id-gen-time-by-time

Kết quả: vẫn bị cache như thường, kiểm tra tại proxy thì thấy proxy nhận được request từ client với môt cái URL quái đản và &#8230; ngay lập tức móc trong cache ra trả lời mà không thèm đả động gì đến web-server. Vấn đề chỉ bị khi enable tùy chọn &#8220;cache dynamic content&#8221; lên. 

Nghi ngờ: dynamic content caching quá nguy hiểm.

Giải pháp 3: chơi URL kiểu khác, bây giờ sẽ là:

www.xxx.com/java**random-string-gen-time-by-time**script

Kết quả: có vẻ như đã ổn, nhưng cứ click loạn lên một hồi thì lại nhìn thấy thông tin tài khoản của thằng kia mặc dù xác suất rất ít. Sao thế nhỉ? Hình như sửa chưa toàn diện thì phải? 

Kệ, chơi tuyệt chiêu cuối cho chắc ăn (mà đáng lẽ ra phải chơi ngay từ đầu nhưng không ai thèm nghe mình).

Giải pháp cuối: đưa SSL vào.

Kêt quả: ISA mà cache nữa là thua luôn. Có điều nó lại cache SSL response thành một cục chả biết để làm gì.

**Kết luận: **cứ công nghệ có sẵn mà chơi, mải miết sáng tác mất nhiều thời gian.