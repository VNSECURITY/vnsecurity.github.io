---

title: 'Phương pháp vật lý giúp kéo dài tuổi thọ pin pithium'
author: knight9
layout: post
category: misc
thumbnail: /assets/2014/12/li-battery.jpg
tags:
  - lithium
  - battery
  - li-ion
  - li-polymer
---
*Bài viết phản ánh ý kiến chủ quan của tác giả sau khi tham khảo các bài viết từ [BatteryUniversity.com](http://batteryuniversity.com)*

Pin Lithium-ion là công nghệ chủ yếu để lưu trữ năng lượng điện trong các thiết bị công nghệ cao hiện nay, nhờ vào các đặc tính vượt trội hơn các công nghệ pin trước (Nickel-metal, Lead-acid) như nhẹ hơn, trữ điện lâu hơn, không có hiệu ứng nhớ.<sup>1</sup> Hầu hết pin trong các smartphone mà chúng ta đang sử dụng hàng ngày đều là ứng dụng của pin Li-ion (bao gồm cả pin Li-polymer<sup>2</sup>). Tác giả hy vọng bài viết này sẽ cung cấp cho bạn đọc một cái nhìn khoa học cũng như cách sử dụng pin Li-ion sao cho hiệu quả.

Năm 2010, phòng thí nghiệm CADEX ở Canada tiến hành một thử nghiệm về số chu kỳ sạc-xả của 11 loại pin Li-polymer 1500mAh phổ biến trên thị trường. Kết quả cho thấy sau khoảng 250 chu kỳ, dung lượng pin giảm xuống còn 73-84%.

![Dung lượng pin sau 250 chu kỳ sạc-xả](http://vnsecurity.net/assets/2014/12/lithium1.jpg)

Đọc đến đây có lẽ bạn cảm thấy hơi thất vọng vì với cường độ sử dụng thông thường, smartphone cần khoảng 1 lần sạc mỗi ngày. Điều đó có nghĩa sau khoảng 1 năm thì pin smartphone của bạn sẽ suy hao đi 1/4. Nhưng mà ... mời bạn đọc tiếp.

Thí nghiệm trên được thực hiện bằng cách sạc pin đến mức điện áp 4.2V (đầy 100%) và xả đều với cường độ dòng điện 1.5A liên tục tới khi điện áp dừng ở mức 3V (0% - xài cạn trong khoảng 1 giờ). Điều này làm tăng tải lên viên pin.

Nếu như dòng điện được xả chỉ một phần rồi sạc lại (50%, 25%, 10%) thay vì xả một hơi từ 100%-0% thì tuổi thọ sẽ được tăng lên đáng kể. Bảng thống kê dưới đây cho thấy điều đó (nguồn BatteryUniversity):

![xả một phần](http://vnsecurity.net/assets/2014/12/lithium2.jpg)

Trong khi xả một hơi hết 100% thì sau 300 chy kỳ dung lượng pin giảm còn 70%, thì xả mỗi đợt 50% sẽ cần 1200 chy kỳ (mỗi chu kỳ 50%, tương đương 600 chu kỳ 100%), hay nói cách khác là pin sẽ bền bỉ hơn, tương tự với trường hợp 25% và 10%.

Một yếu tố quan trọng khác dẫn đến suy giảm tuổi thọ là điện áp sạc đầy (điện áp mà bạn ngắt nguồn ra không cho sạc tiếp nữa), Thông thường pin Li-ion được sạc tới mức 4.2V thì ngừng. Nếu bạn chịu khó để ý sẽ nhận ra càng gần đến 100% thì pin sạc càng lâu, nguyên nhân là do càng gần mức điện áp bão hòa (khoảng 4.3V) thì khả năng tiếp nhận dòng điện của pin càng thấp. Đây cũng là lí do vì sao công nghệ sạc nhanh của các hãng điện thoại (TurboCharge/QuickCharge/ChargeBooster/...) luôn quảng cáo sạc x phút đến 50%, chứ không phải sạc y phút đầy (do y luôn lớn hơn x khá nhiều lần).

Khi sạc ở giai đoạn điện áp cao sẽ tạo nhiều sức ép lên pin. BatteryUniversity và một nghiên cứu vào năm 2002 (Choi et al, mình không tìm được tài liệu gốc) chỉ ra rằng cứ mỗi 0.1V điện áp sạc đầy được giảm đi, thì tuổi thọ của pin sẽ được tăng lên gấp đôi.

![Điện áp sạc đầy 1](http://vnsecurity.net/assets/2014/12/lithium4.jpg)

![Điện áp sạc đầy 2](http://vnsecurity.net/assets/2014/12/lithium5.jpg)

Bảng 4 cho thấy sự tương quan giữa điện áp và dung lượng của pin, theo đó là số chu kỳ sạc-xả cho tới khi dung lượng giảm còn 70%. Mức điện lí tưởng và được xem như loại bỏ hẳn sự ảnh hưởng của điện áp lên tuổi thọ pin là 3.92V, tương ứng 75%. Một số nhà sản xuất điều chỉnh thang đo % xuống mức điện áp thấp, tức là thông báo 100% khi pin chỉ mới sạc tới 80%-90% dung lượng thực (<4.2V), điều này làm tăng độ bền của pin nhưng lại khiến cho người dùng không vui vẻ lắm khi thời lượng pin bị cắt giảm, một sự đánh đổi theo chiến lược của nhà sản xuất.

Bên cạnh điện áp và cường độ dòng điện, thì nhiệt độ cũng ảnh hưởng đến vòng đời của pin Li-ion, nhiệt độ càng cao thì quá trình "lão hóa" của pin càng nhanh.

![Nhiệt độ ảnh hưởng đến quá trình thoái hóa pin](http://vnsecurity.net/assets/2014/12/lithium3.jpg)

Tóm tắt:
--------
Những điều bạn nên làm để tăng tuổi thọ cho pin là:

 - Hạn chế sử dụng pin cường độ cao liên tục trong thời gian dài.
 - Sạc trong thời gian ngắn nhưng thường xuyên, pin Li-ion không có hiệu ứng nhớ, việc sạc ngắt quãng khi chưa hết 100% chỉ làm cho thiết bị đo dung lượng sai lệch (cần điều chỉnh bằng cách sạc-xả hết 100% dung lượng sau vài tháng sử dụng) chứ không có hiệu ứng phụ nào khác.<sup>3</sup> 
 - Nên sạc pin tới mức 75-85% (khoảng 4V) rồi ngừng, duy trì mức điện áp >4V sẽ ảnh hưởng đến tuổi thọ pin.
 - Tránh lưu trữ và sử dụng pin ở nhiệt độ cao.

Lời kết:
--------
Suy cho cùng, pin cũng chỉ là một thiết bị vô tri phục vụ con người, việc thay pin mới sau một thời gian sử dụng là điều không thể tránh khỏi. Đừng bận tâm quá nhiều về nó mà hãy thoải mái sử dụng pin theo cách của bạn. (nhưng tính tiền theo cách người bán)

*Bài viết đã xin phép và nhận được sự đồng ý của website BatteryUniversity để dịch thuật và truyền tải lại nội dung các bài viết gốc*

Nguồn tham khảo từ BatteryUniversity của tác giả *Isidor Buchmann* và nhà tài trợ *Cadex Electronics Inc*

 1. <a href="http://batteryuniversity.com/learn/article/lithium_based_batteries">http://batteryuniversity.com/learn/article/lithium_based_batteries</a> <br>
 2. <a href="http://batteryuniversity.com/learn/article/the_li_polymer_battery_substance_or_hype">http://batteryuniversity.com/learn/article/the_li_polymer_battery_substance_or_hype</a> <br>
 3. <a href="http://batteryuniversity.com/learn/article/battery_calibration">http://batteryuniversity.com/learn/article/battery_calibration</a> <br>
 4. <a href="http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries">http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries</a>
