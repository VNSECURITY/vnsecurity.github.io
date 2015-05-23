---
title: Lỗ hổng nghiêm trọng của TLS/SSL
author: thaidn
excerpt: |
  |
    Tổng quan thì lỗ hổng này nằm ở sự thiếu "ăn rơ" giữa TLS/SSL và các protocol trên nó như HTTP hay SMTP. Khai thác lỗ hổng này thì kẻ tấn công có thể chèn thêm một đoạn plaintext bất kỳ vào TLS/SSL encrypted stream giữa client và server mà cả client và server đều không thể phát hiện được.
layout: post

shorturls:
  - 'a:4:{s:9:"permalink";s:67:"https://www.vnsecurity.net/2009/11/lo-hong-nghiem-trong-cua-tlsssl/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydzd78f";s:4:"isgd";s:18:"http://is.gd/aOt7J";s:5:"bitly";s:20:"http://bit.ly/7NQhNX";}'
tweetbackscheck:
  - 1408358989
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
aktt_notify_twitter:
  - no
category:
  - research
tags:
  - mitm
  - renegotiation
  - ssl
  - tls
---
Một phát hiện hết sức [thú vị][1]:

> The SSL 3.0+ and TLS 1.0+ protocols are vulnerable to a set of related attacks which allow a man-in-the-middle (MITM) operating at or below the TCP layer to inject a chosen plaintext prefix into the encrypted data stream, often without detection by either end of the connection. This is possible because an “authentication gap” exists during the renegotiation process at which the MitM may splice together disparate TLS connections in a completely standards-compliant way. This represents a serious security defect for many or all protocols which run on top of TLS, including HTTPS. 

Thú vị ở chỗ bao nhiêu người, bao nhiêu chuyên gia, bao nhiêu năm qua dòm vô TLS/SSL mà không thấy được lỗ hổng có vẻ như rất hiển nhiên mà các tác giả ở trên phát hiện.

Có lẽ nguyên nhân nhiều người dòm nhưng không thấy là vì họ chỉ dòm TLS/SSL khi nó đứng một mình, mà không nhìn vào bức tranh lớn OSI, trong đó TLS/SSL chỉ là một layer. Chuyện gì sẽ xảy ra nếu TLS/SSL không hiểu rõ cơ chế hoạt động của các protocol bên trên nó, như HTTP, SMTP hay POP3? Nói cách khác, chuyện gì sẽ xảy ra nếu các protocol ở mức Application không hiểu rõ cơ chế vận hành của TLS/SSL để sử dụng cho đúng cách? Đó là lúc lỗ hổng xuất hiện.

Tổng quan thì lỗ hổng này nằm ở sự thiếu &#8220;ăn rơ&#8221; giữa TLS/SSL và các protocol trên nó như HTTP hay SMTP. Khai thác lỗ hổng này thì kẻ tấn công có thể **chèn thêm một đoạn plaintext bất kỳ vào TLS/SSL encrypted stream giữa client và server mà cả client và server đều không thể phát hiện được**.

Đây là một lỗ hổng cực kỳ nghiêm trọng, bởi vì nó phá vỡ hoàn toàn cam kết an toàn của bộ giao thức TLS/SSL. Nói một cách \*hoành tráng\* thì về mặt lý thuyết, nền tảng của thương mại điện tử đang chao đảo. Tôi dùng chữ lý thuyết vì để cho hướng tấn công này nguy hiểm hơn trong thực tế, thì còn có nhiều trở ngại phải vượt qua (và sẽ bị vượt qua).

Để minh họa cho câu chuyện, và để dễ giải thích, tôi đặt ra một ví dụ như sau:

**0. Giả định:**  
> * Ngân hàng A có cung cấp dịch vụ Internet Banking ở địa chỉ <a href="https://www.ebank.com./" target="_blank">https://www.ebank.com.</a> Máy chủ của của họ chạy phần mềm có lỗ hổng mà chúng ta đang bàn ở đây. Chúng ta gọi máy chủ này là server.</p> 
> * Để tăng cường an ninh, ngân hàng A yêu cầu khi khách hàng (giờ cứ gọi là client) sử dụng các tính năng có liên quan đến giao dịch tài chính nằm trong khu vực <a href="https://www.ebank.com/account/," target="_blank">https://www.ebank.com/account/,</a> thì (browser của) họ phải có cài đặt client certificate cho ngân hàng A cung cấp. Lưu ý là nhiều ngân hàng ở VN thực hiện cái này lắm nha.
> 
> * Ngoài ra ngân hàng A còn hỗ trợ khách hàng truy cập bằng (Safari trên) iPhone, lúc đó khách hàng sẽ được chuyển đến <a href="https://www.ebank.com/iphone/" target="_blank">https://www.ebank.com/iphone/.</a> Do iPhone có processor yếu, nên ngân hàng A cấu hình máy chủ web của họ để sử dụng một bộ ciphersuite yếu hơn bộ ciphersuite mà họ sử dụng cho các khách hàng thông thường. Cái này trong thực tế cũng có nhiều công ty triển khai. 

Rồi bây giờ tôi sẽ sử dụng cái kỹ thuật vừa mới phát hiện để tấn công các khách hàng của ngân hàng A theo 3 hướng tấn công mà các tác giả nêu ra. Àh lưu ý là đây là loại tấn công MITM, nghĩa là attacker phải có quyền theo dõi, điều chỉnh dữ liệu truyền qua lại giữa client và server nha. Attacker có thể làm việc này thông qua các tấn công vào các giao thức ARP hay DNS.

**1. Hướng tấn công số 1**

Đối với hướng tấn công số 1, tôi sẽ lợi dụng việc khi truy cập vào <a href="https://www.ebank.com/account/" target="_blank">https://www.ebank.com/account/</a> thì server sẽ yêu cầu client phải trình certificate.

Sơ đồ bên dưới là tôi lấy từ paper của các tác giả phát hiện ra lỗ hổng này. Tôi thấy cái sơ đồ này giải thích rất rõ lỗ hổng này và cách thức tấn công theo hướng thứ 1. Thật ra thì hướng thứ 2 và hướng thứ 3 cũng khá giống hướng thứ 1, nên tôi nghĩ nắm rõ hướng thứ 1 thì sẽ thấy các hướng kia cũng đơn giản.

<div align="center" class="limitview">
  <a href="http://farm3.static.flickr.com/2534/4078446262_1a478302c1_o.png"><img src="http://farm3.static.flickr.com/2534/4078446262_1a478302c1_o.png" /></a>
</div>

Có 4 bước khi triển khai tấn công này:

* Bước 1: client truy cập vào <a href="https://www.ebank.com./" target="_blank">https://www.ebank.com.</a> Lúc này client sẽ kết nối đến attacker, và gửi CLIENT\_HELLO để bắt đầu giao thức TLS/SSL. Attacker sẽ tạm dừng cái kết nối này và lưu msg CLIENT\_HELLO lại để dùng trong bước 3.

* Bước 2: attacker mở kết nối đến server thật. Hai bên sẽ bắt tay theo giao thức TLS/SSL để tạo thành một session. Sau khi hoàn tất bắt tay, attacker gửi một HTTP request, đại loại như:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">POST /account/transfer?amount=1000&amp;receiver=attacker HTTP/1.1rn</pre>

<div class="coded">
</div>

\* Bước 3: server thấy có một request đến khu vực /account/ nên nó tạm thời dừng xử lý request này lại và như đã nói ở trên, nó yêu cầu attacker phải đưa client certificate cho nó xem. Cái hay ở đây, mặc dầu attacker không có (private key của) certificate của client, nhưng hắn vẫn có thể \*proxy* cái certificate đó từ client lên server, mà không bị bên nào phát hiện cả.

Server bắt đầu quá trình xác thực bằng việc gửi một msg HELLO\_REQUEST ngược lại cho attacker. Attacker nhận được msg này thì hắn gửi CLIENT\_HELLO mà hắn đã lưu ở bước 1 ngược lại cho server. Rồi cứ thế, attacker đứng giữa, chuyển msg qua lại giữa client và server cho đến khi quá trình xác thực bằng client certificate kết thúc thành công.

Lưu ý là có 2 loại msg mà attacker sẽ gửi. Loại thứ nhất (trên sơ đồ là những msg kết thúc hoặc bắt đầu từ cột m) là những msg mà hắn phải giải mã/mã hóa trước khi gửi đi. Ví dụ như hắn nhận &#8220;Certificate&#8221; từ phía client thì hắn sẽ mã hóa cái msg này lại, rồi mới gửi cho server. Loại thứ hai (trên sơ đồ là những msg màu hồng và đỏ) là những msg mà hắn không đọc được (vì không có key), hắn chỉ làm mỗi việc là nhận từ client thì gửi qua server và ngược lại.

* Bước 4: quá trình xác thực client certificate đã kết thúc thành công, server tiếp tục xử lý cái request của attacker ở trên, và trả kết quả lại cho attacker (lưu ý là attacker sẽ không đọc được kết quả này).

Điểm yếu là ở đây. Như chúng ta thấy, khi attacker gửi request ở bước 3, lúc đó hắn chưa được xác thực. Nói cách khác, lúc này request của hắn là unauthenticated request. Việc xác thực diễn ra sau đó, và sau khi xác thực rồi thì server lại quay lại xử lý tiếp cái unauthenticated request của attacker.

Lưu ý, ở bước này, để tránh bị tình nghi, attacker có thể tiếp tục trả kết quả về cho client để đóng kết nối lại một cách êm đẹp.

**2. Hướng tấn công số 2**

Trước khi bắt đầu giải thích hướng số 2, tôi muốn nhấn mạnh ý này: **tất cả 3 hướng tấn công này đều hướng đến chôm credential của client để gửi các authenticated request đến server. Credential ở đây có thể là certificate (như ở hướng số 1) hay cookie/session (như ở hướng số 2 và số 3).** Nếu chỉ áp dụng cho HTTPS, nhìn ở một góc độ nào đó, các hướng tấn công này rất giống với tấn công CSRF. Nên nếu ứng dụng của bạn đã có các phương thức phòng chống CSRF rồi hay nếu ứng dụng của bạn không chấp nhận thay đổi state bằng GET, thì tạm thời cũng không phải có gì lo lắng.

Đối với hướng số 1, tôi lợi dụng client certificate để gửi một authenticated request. Ở trường hợp các server không xác thực bằng certificate, tôi sẽ sử dụng hướng tấn cống số 2.

Hướng tấn công này cũng có 4 bước:

* Bước số 1: tương tự như hướng tấn công số 1.

* Bước 2: attacker mở kết nối đến server thật. Hai bên sẽ bắt tay theo giao thức TLS/SSL để tạo thành một session.

Sau khi hoàn tất bắt tay, attacker gửi một HTTP request, đại loại như:

<div class="coded">
</div>

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">GET /iphone/login HTTP/1.1rn
Host: ebank.comrn
Connection: keep-alivern
rn
GET /account/transfer?amount=1000&amp;receiver=attacker HTTP/1.1rn
Host: ebank.comrn
Connection: closern
X-ignore-this:</pre>

* Bước số 3: server thấy có request đến /iphone/ nên nó tạm thời dừng xử lý request này lại và, như đã nói ở phần giả định, server sẽ bắt đầu quá trình renegotiate lại để chọn một bộ ciphersuite yếu hơn. Vấn đề ở đây là server sẽ buffer lại toàn bộ nhóm unauthenticated request này, khi mà renegotiate xong thì lại quay lại xử lý hết tất cả.

Trong quá trình renogotiation, vai trò của attacker cũng tương tự như ở bước số 3 của hướng tấn công số 1, nghĩa là hắn cũng chỉ \*proxy\* msg qua lại giữa client và server, cho đến khi quá trình renegotiate kết thúc thành công.

* Bước số 4: lúc này, client thấy đã handshake xong rồi, nên bản thân nó sẽ gửi tiếp cái HTTP request của nó ở dạng:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">GET /index HTTP/1.1rn
Cookie: AuthMe=Nowrn
rn</pre>

<div class="coded">
</div>

Chuyện bất ngờ diễn ra ở đây. Server nó sẽ gom nhóm unauthenticated request ở bước 2 (do attacker gửi) và cái authenticated request này (do client gửi) rồi xử lý chung một lần. Nguyên nhân server xử lý như thế là do cái cờ keep-alive ở request đầu tiên. Thành ra lúc này nhóm request trở thành như sau (màu cam là attacker gửi, màu xanh là client gửi):

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">GET /iphone/login HTTP/1.1rn
Host: ebank.comrn
Connection: keep-alivern
rn
GET /account/transfer?amount=1000&amp;receiver=attacker HTTP/1.1rn
Host: ebank.comrn
Connection: closern
X-ignore-this:GET /index HTTP/1.1rn
Cookie: AuthMe=Nowrn
rn</pre>

Ở đây cái header X-ignore-this đã vô hiệu hóa cái request **GET /index HTTP/1.1** của client, đồng thời chôm luôn cookie của client để gắn vào cái unauthenticated request **GET /account/transfer?amount=1000&receiver=attacker**. Rất hay!

**3. Hướng tấn công số 3**

Đây là hướng tấn công mạnh nhất, không cần server phải có cấu hình đặc biệt gì để thực hiện. Sự khác biệt cơ bản giữa tấn công này với hai hướng tấn công vừa rồi là trong trường hợp này, client bắt đầu quy trình renegotiation.

Ý tưởng thực hiện tấn công rất giống với hướng 2, chỉ khác nhau ở bước số 2, attacker sẽ không gửi **GET /iphone/login** nữa mà gửi trực tiếp luôn request của hắn, kèm theo một cái &#8220;X-ignore-this&#8221; header.

Ngay sau khi gửi cái request đó, attacker sẽ forward cái CLIENT_HELLO thu được ở bước 1 sang cho phía server để bắt đầu quy trình renegotiation. Khi đã renegotiate xong, client sẽ gửi request ban đầu của mình đến server, lúc này toàn bộ request sẽ trông như sau (phần màu cam của attacker gửi, phần màu xanh của client gửi):

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">GET /account/transfer?amount=1000&amp;receiver=attacker HTTP/1.1rn
Host: ebank.comrn
Connection: closern
X-ignore-this: GET /index HTTP/1.1rn
Cookie: AuthMe=Nowrn
rn</pre>

Tương tự ở trên, X-ignore-this đã vô hiệu hóa request của client và chôm cookie để biến request của attacker thành authenticated. Không cần keep-alive, không cần server phải có cấu hình đặc biệt gì cả!

 [1]: http://extendedsubset.com/