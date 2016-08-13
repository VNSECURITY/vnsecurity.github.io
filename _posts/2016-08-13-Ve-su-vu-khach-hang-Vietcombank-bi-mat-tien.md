---
title: 'Về sự vụ khách hàng bị tin tặc lấy cắp hơn nửa tỉ đồng và các kĩ thuật liên quan'
author: mrro, superkhung
layout: post
thumbnail: http://vnsecurity.net/assets/2016/08/vcb.jpg
excerpt: Để góp phần làm rỏ hơn về sự vụ này, dưới góc nhìn của người thuần túy làm về an ninh máy tính, chúng tôi có một vài phân tích về quy trình giao dịch bằng ngân hàng điện tử của Vietcombank, cũng như làm thế nào mà tin tặc lại có thể chuyển tiền thành công mà không cần SMS OTP như nạn nhân đề cập.
category: research
published: false
tags:
  - vietcombank
  - smartOTP
  - vietcombank bi hack
---

Mấy ngày qua, trên các phương tiện thông tin truyền thông đăng tải hàng loạt các thông tin về sự vụ một khách hàng của Ngân hàng thương mại cổ phần Ngoại thương Việt Nam (Vietcombank) bị tin tặc đánh cắp hơn nửa tỉ đồng trong tài khoản trong một đêm.[Tài khoản tại Vietcombank bỗng mất 500 triệu trong đêm](http://motthegioi.vn/kinh-te-c-67/thi-truong-kinh-doanh-c-97/tai-khoan-tai-vietcombank-bong-mat-500-trieu-trong-dem-40267.html) Tin tức này thực sự gây hoang mang cho cộng đồng, nhất là các cá nhân và đơn vị sử dụng ngân hàng điện tử để giao dịch hàng ngày. Để xoa dịu người dùng, Vietcombank cũng đã có thông tin về các vấn đề liên quan đến sự vụ này, cụ thể là xác nhận nạn nhân đã bị lừa và cung cấp thông tin quản lý tài khoản của mình cho tin tặc, đồng thời cũng bị lừa để chuyển từ xác thực giao dịch bằng SMS sang smartOTP - *một phương thức xác thực thứ 2 dễ bị phá vỡ của Vietcombank*.

Để góp phần làm rỏ hơn về sự vụ này, dưới góc nhìn của người thuần túy làm về an ninh máy tính, chúng tôi có một vài phân tích về quy trình giao dịch bằng ngân hàng điện tử của Vietcombank, cũng như làm thế nào mà tin tặc lại có thể chuyển tiền thành công mà không cần SMS OTP như nạn nhân đề cập.[Tài khoản tại Vietcombank bỗng mất 500 triệu trong đêm](http://motthegioi.vn/kinh-te-c-67/thi-truong-kinh-doanh-c-97/tai-khoan-tai-vietcombank-bong-mat-500-trieu-trong-dem-40267.html)

Trước hết, chúng tôi xin giới thiệu về các bước cơ bản mà một giao dịch chuyển tiền điện tử phải tuân thủ:
1. Người dùng đăng nhập bằng tên đăng nhập và mật khẩu
2. Tạo giao dịch
3. Nhận và xác thực OTP (trong trường hợp này của VCB là SMS OTP - mã xác thực được nhắn qua tin nhắn SMS)
4. Hoàn tất giao dịch

Bên cạnh SMS OTP, Vietcombank còn cung cấp thêm cho người dùng một kênh giao dịch khác là smartOTP[Từ ngày 30/01/2015, Vietcombank chính thức triển khai ứng dụng Vietcombank Smart OTP - giải pháp mới trong xác thực giao dịch điện tử](https://www.vietcombank.com.vn/News/Vcb_News.aspx?ID=5630) - một ứng dụng sinh mã OTP trên điện thoại thông minh. Theo như đề cập ở trên, nữa đêm ngày 4 rạng sáng ngày 5, nạn nhân bị tin tặc đánh cắp hơn nữa tỉ đồng, mà không hề nhận được SMS OTP. Nghĩa là, tin tặc bằng cách nào đó đã kích hoạt thành công dịch vụ smartOTP của nạn nhân. Trong quá trình phân tích ứng dụng smartOTP này, chúng tôi nhận thấy có 2 cách mà tin tặc có thể kích hoạt smartOTP của một tài khoản bất  kì. Tuy nhiên, trước khi đề cập, ta hãy nhìn qua cách mà người dùng Vietcombank kích hoạt smartOTP cho người dùng đang có SMS OTP:

1. Người dùng cài đặt ứng dụng smartOTP
2. Người dùng nhận mã kích hoạt smartOTP qua SMS OTP
3. Người dùng điền mã nhận được trong SMS OTP trên smartOTP để kích hoạt.

Nhìn vào các bước trên, chúng ta có thể hình dung được cách mà tin tặc có thể đã sử dụng, gần giống như thông tin mà Vietcombank cung cấp:
1. Lừa nạn nhân vào trang web giả mạo
2. Giả mạo để lấy thông tin đăng nhập
3. Tin tặc kích hoạt smartOTP, tiếp tục lừa nạn nhân trên giao diện trang web giả mạo để điền mã SMS OTP vừa nhận được vào trang web đó.
4. Tin tặc kích hoạt thành công smartOTP, nạn nhân không hề biết.

Chúng tôi gọi kịch bàn này là **kịch bản số 1**, kịch bản này rất sát với những gì đã diễn ra thực tế với sự vụ này. Nhưng, sau khi chúng tôi thực hiện việc kiểm tra ứng dụng smartOTP, cũng như quy trình kích hoạt, chúng tôi phát hiện một lỗ hỗng nghiêm trọng nữa trong quy trình đó. Lợi dụng lỗ hổng này, tin tặc có thể kích hoạt bất kì smartOTP nào mà KHÔNG CẦN PHẢI LỪA NGƯỜI DÙNG như kịch bản số 1 ở trên.

***Kịch bản tấn công thứ 2 này sẽ được cập nhật sau.***

Tấn công như thế này là một tấn công quen thuộc. Chúng tôi đã từng đề cập trong bài phân tích ứng dụng btalk của BKAV[Phân tích ứng dụng Btalk trên Android – Phần một: Cơ chế xác thực người dùng](http://www.vnsecurity.net/news/2014/05/06/btalk-part-1.html). Tuy nhiên, không nhiều các lập trình viên và kiểm thử viên bảo mật để ý.

Chúng tôi đã cố gắng thông tin về lỗ hổng này đến Vietcombank. Trong khi đợi khắc phục từ họ, chúng tôi khuyến cáo người dùng tắt chức năng smartOTP, hoặc thông tin với ngân hàng ngay lập tức khi có dấu hiệu nghi ngờ - như là nhận tin nhắn OTP một cách bất thường.

thaidn, superkhung - VnSeccurity
tienpp biên soạn