---
title: 'FIDO U2F: Công nghệ xác minh hai bước chống phishing'
author: thaidn
layout: post
thumbnail: http://vnsecurity.net/assets/2016/08/u2f.png
excerpt: U2F là chữ viết tắt của Universal 2nd Factor, hiểu nôm na đây là công nghệ xác minh hai bước có thể sử dụng ở mọi nơi. Công nghệ U2F do Google Security Team cùng với Yubico và NXP sáng chế và sau đó bàn giao lại cho FIDO Alliance. Tôi không tham gia sáng chế ra công nghệ này, nhưng tôi có hỗ trợ đánh giá bộ giao thức U2F. So với các công nghệ tương đương như SMS OTP hay RSA SecurID, U2F có những sáng tạo độc đáo làm cho nó an toàn và dễ sử dụng hơn.
category: tutorial
published: true
tags:
  - u2f
  - phishing
---

U2F là chữ viết tắt của Universal 2nd Factor, hiểu nôm na đây là công nghệ xác minh hai bước có thể sử dụng ở mọi nơi. Công nghệ U2F do Google Security Team cùng với Yubico và NXP sáng chế và sau đó bàn giao lại cho [FIDO Alliance.](https://fidoalliance.org/) Tôi không tham gia sáng chế ra công nghệ này, nhưng tôi có hỗ trợ đánh giá bộ giao thức U2F. **So với các công nghệ tương đương như SMS OTP hay RSA SecurID, U2F có những sáng tạo độc đáo làm cho nó an toàn và dễ sử dụng hơn.**

![fido u2f](http://vnsecurity.net/assets/2016/08/fido-u2f.png)

### Lợi thế

So sánh với các giải pháp phổ biến trên thị trường như SMS OTP, Smart OTP, Google Authenticator, hay RSA SecurID, FIDO U2F có nhiều lợi thế.

* An toàn
   * FIDO U2F chống được tấn công phishing. Bất kỳ giải pháp nào yêu cầu người sử dụng chép mã OTP đều không thể chống lại tấn công phishing.
   * FIDO U2F là một chuẩn mở, các doanh nghiệp cần độ bảo mật cao có thể tự đánh giá và triển khai giải pháp này mà không cần nhờ vào bên thứ ba. Các giải pháp như RSA SecurID hoàn toàn đóng, không ai biết bên trong chúng hoạt động như thế nào.
  
* Dễ sử dụng.
   * Để xác minh, người sử dụng chỉ cần sờ hoặc nhấn vào một nút duy nhất trên thiết bị FIDO U2F ([xem thêm demo đăng nhập vào Google sử dụng thiết bị U2F của hãng Yubico](https://www.youtube.com/watch?annotation_id=annotation_1845157061&feature=iv&src_vid=BXN7-Wn1Hy4&v=LeTkw6kmlzg)). Các giải pháp khác đều yêu cầu người dùng phải chép một mã số (thường được gọi là OTP) từ thiết bị sinh mã.
   
* Tiêu chuẩn mở.
   * Người dùng mua một thiết bị FIDO U2F có thể sử dụng cho nhiều dịch vụ khác nhau, từ Internet Banking cho đến Gmail, YouTube, Dropbox, v.v. Người dùng chuyên nghiệp còn có thể sử dụng FIDO U2F để đăng nhập vào các máy chủ thông qua SSH hay VPN. Thiết bị RSA SecurID vừa đắt tiền vừa lại chỉ sử dụng được ở một nơi duy nhất.
   * Các doanh nghiệp triển khai công nghệ FIDO U2F có thể tận dụng số lượng khách hàng đã có sẵn thiết bị FIDO U2F, mà không cần phải đầu tư hay yêu cầu khách hàng mua thêm thiết bị mới. Việc phải mua thiết bị đắt tiền như RSA SecurID thường khiến người sử dụng không muốn đăng ký xác minh hai bước, khiến cho tài khoản của họ kém an toàn.
   * Vì các sản phẩm FIDO U2F có cách thức hoạt động như nhau, các doanh nghiệp triển khai công nghệ FIDO U2F tránh được tình trạng bị “locked in" vào một nhà sản xuất độc quyền. Đây là vấn đề thường gặp khi triển khai các giải pháp xác thực hai lớp như RSA SecurID, vì một khi đã triển khai rồi thì khó chuyển sang nhà cung cấp giải pháp khác được nữa.
    
* Giá cả hợp lý.
   * Tùy thuộc vào yêu cầu của người dùng mà thiết bị FIDO U2F có giá dao động từ 10 USD đến 40 USD. Trong tương lai giá cả của các thiết bị này sẽ đi xuống vì càng lúc sẽ có càng nhiều nhà sản xuất.

### Góc kỹ thuật: U2F chống phishing như thế nào?

Tấn công phishing trên web lợi dụng điểm yếu là người sử dụng không biết trang web mà họ đang xem có phải là trang web mà họ muốn truy cập hay không. Các hướng dẫn phòng chống phishing thường yêu cầu người sử dụng kiểm tra địa chỉ trang web, nhưng trên thực tế đa số người sử dụng không hiểu “địa chỉ trang web" là gì, yêu cầu họ tự kiểm tra là một đòi hỏi duy ý chí.

Việc kiểm tra địa chỉ trang web cũng không có tác dụng là mấy, vì có rất nhiều mẹo ([ví](https://sites.google.com/site/bughunteruniversity/nonvuln/phishing-with-window-opener) [dụ](http://lcamtuf.coredump.cx/switch/)) mà kẻ tấn công có thể sử dụng để đánh lừa ngay cả những kỹ sư máy tính chuyên nghiệp. Ngoài kiểm tra địa chỉ trang web, một lời khuyên thường gặp nữa là kiểm tra chứng chỉ SSL. Đa số các ngân hàng sử dụng chứng chỉ EV, với loại chứng chỉ này tên ngân hàng sẽ hiển thị trên thanh địa chỉ. Tuy nhiên các nhà nghiên cứu ở đại học Stanford chỉ ra rằng kẻ tấn công dễ dàng lừa người dùng bằng cách tạo một thanh địa chỉ giả mạo ([tấn công "hình trong hình"](http://www.adambarth.com/papers/2007/jackson-simon-tan-barth.pdf)).

Thông thường có hai hướng khắc phục một rủi ro: bằng quy trình và bằng kỹ thuật. Yêu cầu người sử dụng kiểm tra địa chỉ trang web hay chứng chỉ SSL là một cách khắc phục rủi ro bị phishing bằng quy trình. Như đã nói ở trên, giải pháp quy trình không hiệu quả vì hay đặt kỳ vọng quá cao vào người sử dụng, vốn thường là mắt xích yếu nhất trong hệ thống. **Một nguyên tắc quan trọng trong thiết kế an toàn thông tin là chỉ khi nào không thể sử dụng giải pháp kỹ thuật thì mới tính đến giải pháp quy trình. Công nghệ U2F giải quyết rủi ro phishing bằng một giải pháp kỹ thuật.**

**Giao thức U2F loại bỏ người dùng ra khỏi quá trình kiểm tra địa chỉ trang web.** Chỉ với thay đổi nhỏ này, tấn công phishing bị vô hiệu hóa hoàn toàn. Cụ thể, trình duyệt web của người dùng sẽ trực tiếp gửi địa chỉ trang web đến cho thiết bị U2F và thiết bị U2F sẽ thay người dùng kiểm tra địa chỉ có đúng hay không. Có thể hiểu hôm na với mỗi địa chỉ khác nhau thiết bị U2F sẽ trả về một mã xác thực khác nhau, do đó nếu người dùng bị lừa vào http://phishing.com, trang web này không thể lấy cấp mã xác thực của https://banking.com vì địa chỉ https://banking.com khác với http://phishing.com. Nếu Vietcombank sử dụng công nghệ U2F, kẻ tấn công đã không thể nào lấy được mã xác thực của khách hàng, vì địa chỉ trang web giả mạo khác với địa chỉ trang web Vietcombank.

### Giải pháp

Tổ chức phi lợi nhuận FIDO Alliance đã chuẩn hóa U2F thành một tiêu chuẩn Internet mở. Hiện tại FIDO Alliance có hơn 150 công ty thành viên. Bất kỳ công ty nào cũng có thể đăng ký trở thành thành viên của FIDO Alliance và được quyền chế tạo các sản phẩm tuân theo chuẩn U2F mà không sợ các thành viên khác kiện vi phạm quyền sáng chế. Các doanh nghiệp, tổ chức và người sử dụng cá nhân có thể thoải mái sử dụng các sản phẩm theo công nghệ U2F không cần phải tham gia vào FIDO Alliance.

Một giải pháp U2F bao gồm ba thành phần:

* **Thiết bị FIDO U2F cho người dùng cuối**. Thiết bị FIDO U2F phổ biến nhất trên thị trường là [Yubikey](https://www.yubico.com/products/yubikey-hardware/) của hãng Yubico. Thiết bị rẻ nhất có giá khoảng 10 USD, hỗ trợ giao tiếp qua cổng USB, cần phải có máy tính cá nhân mới sử dụng được. Thiết bị hỗ trợ giao tiếp thông qua Bluetooth hoặc NFC, có thể sử dụng với điện thoại thông minh, được bán với giá 40 USD. Chuẩn FIDO 2.0 hứa hẹn sẽ cho phép người sử dụng dùng chính điện thoại của họ như là một thiết bị U2F.
* **Phần mềm FIDO U2F trên máy chủ**. Nếu một ngân hàng muốn triển khai công nghệ U2F, máy chủ Internet Banking của họ phải hiện thực hóa giao thức U2F. Google có cung cấp một thư viện phần mềm nguồn mở mẫu ở địa chỉ https://github.com/google/u2f-ref-code.
* **Trình duyệt web của người dùng cuối**. Hiện tại trong số các trình duyệt phổ biến chỉ có Google Chrome hỗ trợ U2F. Mozilla Firefox sẽ hỗ trợ công nghệ U2F trong thời gian sắp tới. Microsoft và Apple chưa có động thái gì cho thấy họ sẽ hỗ trợ U2F trên trình duyệt của họ.

Để triển khai giải pháp U2F, các doanh nghiệp cần phải có chuyên gia am hiểu về công nghệ này. Những người này sẽ giúp đánh giá các giải pháp trên thị trường, nhu cầu của doanh nghiệp và từ đó chọn ra một một chiến lược đầu tư hợp lý.

Đối với người sử dụng cá nhân, mỗi người nên sắm một thiết bị FIDO U2F ([thiết bị rẻ nhất có giá chưa đầy 10 USD](https://www.amazon.com/HyperFido-K5-FIDO-U2F-Security/dp/B00WIX4JMC/ref=pd_sim_147_1?ie=UTF8&psc=1&refRID=F26A5E605T83YXKQ3WYR), hoặc [tự làm ở nhà, dành cho những ai rành điện tử](https://github.com/conorpp/u2f-zero)). Món đầu tư nhỏ này sẽ giúp [bảo vệ tài khoản](https://vnhacker.blogspot.com/2015/08/7-buoc-bao-ve-tai-khoan-google.html) Google, Dropbox, v.v. tránh khỏi tấn công phishing và các hiểm họa khác.
