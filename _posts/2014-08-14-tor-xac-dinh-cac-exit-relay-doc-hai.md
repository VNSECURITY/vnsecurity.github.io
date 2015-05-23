---
title: 'Tor &#8211; Xác định các exit relay độc hại'
author: tienpp
layout: post
category: tutorials
thumbnail: /assets/2014/08/Tor_logo1.png
tags:
  - exit relay
  - read paper
  - tor
---
**1. Mở đầu**  
Bài viết này là phần mô tả sơ lược và bình luận bài báo &#8220;Spoiled Onions: Exposing Malicious Tor Exit Relays&#8221;[1].  
Tor exit relay là nút cuối dùng trong hành trình vận chuyển của các gói tin trọng mạng Tor, gói tin từ đây sẽ đi đến địa chỉ thực sự cần đến. Nó được vận hành bởi các người dùng tình nguyện trọng mạng và có thể nói tổng lưu lượng qua các exit relay này khá lớn (cỡ 1GB/s). Theo thiết kế, thì các người dùng ở các exit relay này có thể quan sát và thay đổi nội dung của các dữ liệu trong mạng.

Trong bài báo này, tác giả đề xuất các phương pháp để nhận ra các exit relay nào đang chơi bẩn và ghi lại những hành động của chúng. Họ xây dựng hai khung chương trình để phát hiện hoạt động bất thường của các exit relay. Một để chủ động phát hiện các hành động như thay đổi nội dung dữ liệu (Man in the middle), một là phần thụ động, để điều tra các exit relay sử dụng phương thức nghe lén (traffic sniff) để ăn cắp dữ liệu. Các giải pháp của tác giả được hiện thực chú trọng đến tính nhanh và hiệu quả trong quá trình quét các exit relay.

**2. Khái quát hoạt động của mạng Tor**

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh5.googleusercontent.com/egeTOj-mT7_qWwI4Xf7KgME_Fj8MQG-ItYOu2MVslR7YV0ewpgIRn0AZzZwTvgvLDJEsN_BUBRAMOXbhIlh4H6pa8J7rQpg8Tlz6g5Efem02QRMHot07Z8BP4GuXuLmaAp1PMklJKjg" alt="" width="307px;" height="201px;" />
</p>

Hình trên là mô hình 3 nút của mạng Tor, dữ liệu từ một tor client bất kì bắt đầu hành trình trong mạng thì nó sẽ đi qua:

1.  Nút đầu (Entry guard): Đây này là nút đầu tiên trong hành trình của dữ liệu trong mạng.
2.  Nút giữa (Middle relay): là các nút trung chuyển dữ liệu trong mạng.
3.  Nút thoát (Exit relay): nút cuối hành trình của dữ liệu trọng mạng, đây là nút bắt cầu mà từ đây dữ liệu sẽ ra khỏi mạng mã hóa của Tor và đi đến đích nằm trong phần còn lại của thế giới &#8211; Internet. Dữ liệu &#8211; nếu có thể- sẽ bị nghe lén hoặc thay đổi ở nút này.

**3. Giám sát các Tor exit relay:**  
Như đã nói ở trên, tác giả đã xây dựng hai khung chương trình nhằm giám sát các exit relay trong toàn bộ mạng Tor. Phần này chúng ta sẽ lần lượt đi qua quá trình thực hiện hai khung chương trình đó. Ngoài ra, tác giả có công bố mã nguồn của chúng ở đây[3].

**3.1 exitmap:**  
Đây là khung chương trình thứ nhất tác giả hiện thực, nó sẽ giám sát chủ động các exit relay trong việc thay đổi nội dụng dữ liệu của người dùng trong mạng.

***Thiết kế:***

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh6.googleusercontent.com/u4TKbpaxg4s49fl5bApAyo2GaPjVFroZMzW9zFlerwcTddFnOM7j6ZR6EHcIAvenrcPhZq6ubTV84zf_NecFOKYNiujLLZM0fS1rhSUc7ZhCeOsRsJAR_F4WQCgUGmLVJMn-LumXD0g" alt="" width="331px;" height="216px;" />
</p>

exitmap chạy trên một máy đơn lẻ, được xây dựng dựa vào thư viện python Stem &#8211; một thư viện hiện thực các giao thức Tor. Tác giả dùng Stem để khởi tạo và đóng các kết nối vào mạng. Bên cạnh đó cần một Tor client đang chạy để lấy các thông tin về các nút để biết đâu là các exit relay đang trực tuyến.

***Hoạt động:***

1.  Đầu tiên, exitmap lấy toàn bộ các exit relay từ Tor client đang chạy. Thực hiện chọn ra một exit relay ngẫu nhiên để kiểm tra.
2.  Khởi tạo một vòng (circuit) dữ liệu trong mạng Tor với exit relay là nút được lấy ngẫu nhiên từ 1.
3.  Giao tiếp với Tor client để vận chuyển dữ liệu.

***Nâng cao hiệu năng của thiết kế:***  
Với mô hình và hoạt động của hệ thống ở trên, dữ liệu từ exitmap vào mạng Tor và đi lòng vòng qua rất nhiều nút khác rồi mới đến exit relay chọn sẵn, nên hiệu năng không cao. Trong khi mục đích của việc kiểm tra này hoàn toàn không đòi hỏi tính ẩn danh của Tor mang lại, nên tác giả đã cải tiến thêm hệ thống như sau.

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh4.googleusercontent.com/KTsL1X9oYrbghyBPrjO-2k6CL2gf8eG8C9Lbbj_5GwdwQYJR5iJK0hDOPYeivadYFMCr_PL6rAjhbDHJ06H3H4kvf4i8EYpBDa35pqcBcU-RHcmplOfbPgtuKe-5d0r_XT5ccEOhGEw" alt="" width="302px;" height="190px;" />
</p>

Thay vì chạy lòng vòng trong mạng dẫn đến ảnh hưởng hiệu năng của việc kiểm tra, tác giả đề xuất mô hình: dữ liệu chỉ chạy qua một nút cố định rồi đi ngay đến exit relay.

***Phần quét:***  
Dựa vào exitmap được xây dựng như trên, tác giả viết thêm các phần kiểm tra cho các giao thức như HTTPs, XMPP, IMAPs, SSH, phát hiện sslstrip và phân giải DNS giả tạo.  
*Các phần quét kiểm tra dựa trên các giao thức HTTPs, XMPP, IMAPs và SSH:* đều được thực hiện thông qua việc kiểm tra chứng chỉ hợp lệ trả về khi dữ liệu đi qua mạng Tor. Một exit relay thực hiện MitM sẽ khiến cho chứng chỉ trả về không đúng như ý và từ đó phát hiện được hành vi MitM của exit relay đó.  
Hình dưới tác giả cung cấp một đoạn mã giả mô tả phần đã nói ở trên:

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh5.googleusercontent.com/cAlohQ54Mm_7Xb-cHeI6SqXDZnFE9bnl_0dTbUv1j9Ikq94QQ9owdv9xNwVTESFEvze5pStzE406oXzMwAKWGRSAp5N0-pecfpYAIbNM7UbcPmHK18MXuhCwqpRclqtQD_RW" alt="" width="621px;" height="224px;" />
</p>

*Sslstrip:* Thay vì cố gắng quan sát dữ liệu đã được bảo vệ với kết nối TLS, kẻ tấn công sẽ cố gắng chuyển các đường dẫn từ https về http, từ đó dữ liệu được chuyển dưới dạng hoàn toàn minh bạch, và kẻ tấn công dễ dàng lấy cắp các dữ liệu chúng muốn. Để phát hiện việc &#8220;downgraded&#8221; này, phần quét sslstrip cố gắng phát hiện trong dữ liệu HTML các đường dẫn bị thay đổi từ HTTPS thành HTTP.

*Phân giải DNS giả mạo*: Địa chỉ DNS cũng có thể được các client gửi đến exit relay để phân giải, việc này dẫn đến phía exit relay có thể giả mạo việc phân giải đó. Một mặt, các exit relay trong quá khứ có thể bị thiết lập sai khi dùng các DNS bị cản lọc &#8211; ví dụ như ở một số ISP ở Trung Quốc, Việt Nam, và một số nước châu âu. exitmap cũng sẽ phát hiện các phân giải DNS giả tạo này.

**3.2 HoneyConnector:**  
Khung chương trình này được xây dựng để phát hiện thụ động một vài exit relay đang cố gắng quan sát dữ liệu (sniffing) của người dùng Tor. Việc quan sát các dữ liệu này hầu hết là trên các giao thức không được mã hóa như là FTP, IMAP.

***Mô hình:***

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh3.googleusercontent.com/NEuvLRGQZi6NpPeR8VEFxIhyd10MEGjEKnkBlQPjXma6n3rzOI1H-siwNvK2WDN_BJuVnKVy_KvXbDwfPvJzL-01COmODQLcuz7yoctqdkDDjdLA4OMkjwyaw5R1PlUCiGOt" alt="" width="576px;" height="296px;" />
</p>

***Khung chương trình này hoạt động như sau:***  
Từ Tor client liên tục gửi đi các yêu cầu login đến &#8220;Destination Server&#8221; là các FTP/IMAP server với các thông tin đăng nhập user/pass được tạo sẵn, đồng thời gửi các thông tin đó đến server đích.  
Các thông tin đăng nhập trên được lưu trong database, bao gồm đã được gửi qua exit relay nào. Trong thời gian theo dõi (hàng tháng), nếu một thông tin đăng nhập nào đó được dùng để đăng nhập vào các FTP/IMAP server trên thì sẽ bị lưu lại và đối chiếu với thông tin trong cơ sở dữ liệu, tìm ra được exit relay nào đã tiến hành lấy cắp dữ liệu.

Phần còn lại của bài báo là các thông tin rút ra được từ kết quả kiểm tra của tác giả trong nhiều tháng liền. Trong phần đúc kết thông tin này, có nhiều thông tin rất thú vị, ví dụ như về một số nhóm chuyên đi lợi dụng các exit relay để sniffing, chèn thêm mã độc vào trang html, … Hình dưới liệt kê 40 exit relay mà tác giả đã kiểm tra được có hành vi nguy hiểm:

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh5.googleusercontent.com/PN1ExhdM9z2CpzWbXfuSniUs_JV_fyvazqjQmyh5vXCsvlrEa1tS0XQ-4Fu20TIVjhRudYbmpLxI6Yh3Qa9PP67W06ypZYNlBupIHA7eOkNIsUJ_6v81cuwMsAT2WUYgY38U" alt="C:A31D5665347F1D4E-A7C2-4647-96EF-468158E00942_filesimage006.png" width="551px;" height="671px;" />
</p>

Và các exit relay đã nghe lén để ăn cắp thông tin (đăng nhập) của người dùng Tor:

<p style="text-align: center;">
  <img class="aligncenter" src="https://lh6.googleusercontent.com/TyO3KqIdmwZHVSp4e3lfpf570_CXC1z552vgEJFDgl-y6aJQ8UEwkoIKlO964hR5UzAkumblEDPBtN-L4kMQA_zrYv4WZQr6eys8ST3kT-QDPD1C5lmyePRIppFnmxcaZpbo" alt="C:A31D5665347F1D4E-A7C2-4647-96EF-468158E00942_filesimage007.png" width="584px;" height="466px;" />
</p>

Các bạn đọc thêm ở tài liệu trong phần 4, các phần phân tích kết quả còn lại.

Phần còn lại trong bài báo là các phát triển thêm của tác giả cho trình duyệt Tor browser, để có thể phòng ngừa nếu một exit relay nào đó đang MitM, mà không hiểu gì về trang cảnh báo của trình duyệt. Thay vì để trình duyệt hiện cảnh báo thì Tor sẽ tự xác minh và từ bỏ ngay exit relay đang MitM đó. Các bạn đọc thêm trong phần 6 của bài báo.

**4. Tổng kết**  
Vậy dùng tor có an toàn không? Dù rằng bài báo đã cho thấy rằng có khả năng bị tấn công khi sử dụng Tor, tuy nhiên các tấn công này hoàn toàn là phòng ngừa được nếu như người dùng tôn trọng các nguyên tắc bảo mật (trong trường hợp bị MitM), và không dùng các giao thức cũ để đăng nhập (FTP/IMAP) để có thể dễ dàng bị đánh cắp dữ liệu.  
Gần đây cũng có một nghiên cứu về Tor nữa, nhưng đã bị hủy bỏ trước khi trình bày ở hội nghị Blackhat USA. Nghiên cứu này về vấn đề nặc danh của Tor. [2]  
Quay lại với bài báo, có cách nào có thể qua mặt được các kiểm tra như bài báo đã làm hay không. Và có cách nào để có thể ứng dụng vào Tor để phát hiện ngay tức thì các hành động gây hại ở exit relay và loại bỏ nó ra khỏi mạng. Mong các bạn thảo luận thêm <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":)" class="wp-smiley" /> 

Tham khảo:

[1] https://petsymposium.org/2014/papers/Winter.pdf  
[2] http://freedomhacker.net/tor-project-fixing-vulnerability-that-could-expose-users/  
[3] http://www.cs.kau.se/philwint/spoiled_onions/