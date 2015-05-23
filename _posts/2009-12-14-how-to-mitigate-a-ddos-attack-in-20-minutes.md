---
title: 'Giám sát an ninh mạng &#8211; hay là làm thế nào để ngăn chặn một cuộc tấn công DDoS trong 20&#039;'
author: thaidn
layout: post

tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
shorturls:
  - 'a:4:{s:9:"permalink";s:78:"http://www.vnsecurity.net/2009/12/how-to-mitigate-a-ddos-attack-in-20-minutes/";s:7:"tinyurl";s:26:"http://tinyurl.com/yc98qxq";s:4:"isgd";s:18:"http://is.gd/aOueU";s:5:"bitly";s:0:"";}'
tweetbackscheck:
  - 1408358987
aktt_notify_twitter:
  - no
category:
  - research
tags:
  - DDoS
  - mitigate DDoS
  - NSM
---
<span style="font-style: italic">(rút ra từ bài nói chuyện tại BarcampSaigon 2009)</span>  
[Network Security Monitoring or How to mitigate a DDoS attack in 20&#8242;][1]

View more [presentations][2] from [thaidn][3].

Để bắt đầu thì tôi xin chia sẻ một câu chuyện. Cách đây không lâu, web site của một khách hàng bị tấn công từ chối dịch vụ DDoS. Vào lúc cao trào của vụ tấn công, có hơn 10.000 IP đến từ khắp nơi trên thế giới liên tục gửi hàng ngàn yêu cầu mỗi giây đến hệ thống của khách hàng này. Hình ảnh (slide số 4) mà quý vị đang thấy trên màn hình gồm có 2 phần nhỏ. Phần ở trên là lưu lượng dữ liệu ra vào hệ thống lúc bình thường, không bị tấn công. Phần ở dưới là lưu lượng dữ liệu ra vào hệ thống của ngay tại thời điểm đang bị tấn công dữ dội.

Như quý vị cũng thấy, chỉ trong vòng 10&#8242;, từ lúc 16h10 đến 16h20, lượng dữ liệu ra vào đã tăng đột biến lên gấp gần 10 lần lúc bình thường. Nhưng đồng thời, chỉ trong vòng chưa tới 20&#8242;, chúng tôi đã kiểm soát được vụ tấn công này, và đưa toàn bộ hệ thống trở lại tình trạng bình thường. Chúng tôi làm được như vậy tất cả là nhờ vào việc đã áp dụng tốt các công nghệ và nguyên tắc của giám sát an ninh mạng.

Nếu quý vị từng phải xử lý một vụ tấn công DDoS, tôi tin chắc có một câu hỏi mà quý vị đã phải tự hỏi nhiều lần: <span style="font-weight: bold">chuyện gì đang diễn ra vậy?</span> Tại sao hệ thống của tôi đang chạy ngon lành tự dưng lại cứng đơ, khách hàng không sử dụng được nữa?

Bản thân tôi cho rằng đây là câu hỏi tối quan trọng mà bất kỳ ai làm việc trong lĩnh vực an ninh mạng đều phải tự hỏi và phải có câu trả lời xác đáng. Ngay tại thời điểm này đây, ngay khi quý vị đang ngồi ở đây nghe tôi trình bày, quý vị có biết ai đang làm gì ở đâu như thế nào trên hệ thống của quý vị hay không?

Tại sao câu hỏi đó quan trọng? Tại sao quý vị cần phải biết được ai đang làm gì ở đâu như thế nào trên hệ thống của quý vị? Đơn giản vì chúng ta không thể bảo vệ một hệ thống nếu chúng ta không biết được trạng thái của hệ thống đó. Và chúng ta chỉ có thể biết được trạng thái của một hệ thống bằng cách theo dõi nó thường xuyên. Nói cách khác, chúng ta phải biết được tất cả các hoạt động đã và đang diễn ra trên hệ thống.

Thử nhìn vào hoạt động của một khách sạn. Để đảm bảo an ninh, người ta phải đặt camera theo dõi ở khắp nơi. Các camera này chắc hẳn sẽ đưa hình ảnh về một địa điểm tập trung, nơi có các chuyên viên theo dõi 24/7 để kịp thời phát hiện và đối phó với các sự cố an ninh.

Tương tự như thế, muốn đảm bảo an ninh thông tin chúng ta cũng phải tiến hành theo dõi 24/7. Nhưng trong thực tế, theo quan sát của tôi, rất ít tổ chức ở VN có một hệ thống giám sát an ninh như thế. Để bảo vệ hệ thống mạng của mình, các doanh nghiệp và các tổ chức công thường triển khai các thiết bị như tường lửa, phần mềm chống và diệt virus, thiết bị phát hiện xâm nhập, thiết bị ngăn chặn xâm nhập. Rõ ràng họ nghĩ rằng, các thiết bị này đảm bảo an ninh mạng cho họ nên họ mới đầu từ nhiều tiền của để triển khai chúng.

Thật tế hầu hết những người giữ quyền quyết định đầu tư cho an toàn thông tin thường hay hành động theo thị trường. Ví dụ như cách đây vài năm, tường lửa là mốt. Ai cũng đầu tư làm hệ thống tường lửa nên chúng ta cũng phải làm tường lửa. Sau đó, các giải pháp phát hiện xâm nhập lên ngôi. Bây giờ cái gì đang là trào lưu quý vị biết không? ISO 27001.

Lãnh đạo doanh nghiệp thấy các các doanh nghiệp khác triển khai ISO 27001 nên họ cũng muốn doanh nghiệp của họ phải đạt được chuẩn này. Tôi không nói rằng tường lửa, thiết bị phát hiện xâm nhập hay đạt được các chuẩn như ISO 27001 và ITIL là không có tác dụng, nhưng câu hỏi chúng ta cần phải tự hỏi là: tại sao sau khi triển khai quá trời thứ đắt tiền và tốn thời gian như thế, chúng ta vẫn bị xâm nhập, chúng ta vẫn bị tấn công? Liệu ISO 27001 hay tường lửa có giúp bạn khắc phục được một vụ tấn công từ chối dịch vụ trong vòng 20&#8242;? Rồi khi đã bị xâm nhập, có thiết bị đắt tiền hay tiêu chuẩn nào giúp quý vị biết được hệ thống của quý vị bị xâm nhập khi nào, tại sao và như thế nào hay không?

Chỉ có con người mới có khả năng làm việc đó. Đây là điều tôi muốn nhấn mạnh, các thiết bị hay các tiêu chuẩn sẽ trở nên vô tác dụng nếu chúng ta không có con người thường xuyên theo dõi, giám sát hệ thống. Nghĩa là, <span style="font-weight: bold">chúng ta cần các chuyên gia giám sát hệ thống có chuyên môn cao.</span>

Tại sao chúng ta cần phải có chuyên gia, tại sao tự bản thân các thiết bị hay các tiêu chuẩn không thể bảo vệ hệ thống mạng? Bởi vì những kẻ tấn công rất thông minh, không thể dự đoán và rất có thể có động lực cao nhất là khi thương mại điện tử phát triển như bây giờ. Máy móc và quy trình không thể ngăn chặn được họ, chắc chắn là như thế. Máy móc chắc chắn sẽ thua khi chiến đấu với não người. Đó là lý do chúng ta cần con người, cần những chuyên gia, để biến an ninh mạng thành một cuộc chiến cân sức hơn giữa người và người, thay vì giữa máy và người.

Câu hỏi đặt ra là các chuyên gia an ninh mạng cần gì để có thể phát hiện và xử lý các sự cố an ninh mạng cũng như xây dựng các kế hoạch phòng thủ? Câu trả lời chỉ có một: <span style="font-weight: bold">tất cả dữ liệu mà chúng ta có thể thu thập được trên hệ thống mạng trong khi sự cố xảy ra!</span>

Quý vị còn nhớ ví dụ của tôi v/v làm sao để bảo vệ an ninh cho một khách sạn? Người quản lý cố gắng thu thập tất cả các dữ liệu, ở đây là hình ảnh và âm thanh, bằng các camera đặt khắp nơi trong khách sạn, và họ cần có các chuyên gia lành nghề để phân tích các hình ảnh này để kịp thời xử lý các sự cố. Họ có hệ thống chống và phát hiện cháy, họ có hệ thống chống trộm, nhưng những máy móc đó chỉ là công cụ, phần việc chính vẫn phải do con người, là các chuyên gia thực hiện.

Tóm lại, để đảm bảo an ninh, chúng ta cần phải theo dõi giám sát hệ thống mạng 24/7, và để làm chuyện đó chúng ta cần có các chuyên gia và các chuyên gia cần dữ liệu để thực hiện công việc của họ. Giám sát an ninh mạng chính là phương thức giúp chúng ta có thể thực hiện việc này một cách tối ưu nhất. Vậy giám sát an ninh mạng là gì?

Thuật ngữ giám sát an ninh mạng được chính thức định nghĩa vào năm 2002 và về cơ bản nó gồm 3 bước: <span style="font-weight: bold">thu thập dữ liệu, phân tích dữ liệu và leo thang thông tin.</span>

Để thu thập dữ liệu, chúng ta sẽ sử dụng các phần mềm hay giải pháp có sẵn trên thị trường để thu thập dữ liệu ghi dấu hoạt động của các máy chủ, thiết bị mạng, phần mềm ứng dụng, cơ sở dữ liệu&#8230;Nguyên tắc của thu thập dữ liệu là thu thập càng nhiều càng tốt, với mục tiêu là chúng ta phải có đầy đủ thông tin về trạng thái, log file của tất cả các thành phần trong hệ thống cần phải bảo vệ. Bởi vì có muôn hình vạn trạng các loại tấn công và sự cố ATTT, chúng ta không thể biết trước dữ liệu nào là cần thiết để có thể phát hiện và ngăn chặn loại tấn công nào. Nên kinh nghiệm của tôi là nếu mà luật pháp và công nghệ cho phép, cứ thu thập hết tất cả dữ liệu mà quý vị có thể. Nguyên tắc “thà giết lầm còn hơn bỏ sót” có thể áp dụng ở đây.

Nếu phần mềm có thể giúp chúng ta làm công việc thu thập dữ liệu, thì để phân tích dữ liệu và ra quyết định, như đã nói ở trên, chúng ta cần có chuyên gia, bởi chỉ có chuyên gia mới có thể hiểu rõ ngữ cảnh của dữ liệu mà phần mềm đã thu thập được. Ngữ cảnh là tối quan trọng. Một dữ liệu được thu thập trong ngữ cảnh A có thể sẽ có ý nghĩa rất khác với cùng dữ liệu đó nếu nó thuộc về ngữ cảnh B. Ví dụ như một ngày đẹp trời hệ thống thu thập dữ liệu cảnh báo rằng một số file chương trình trên một máy chủ quan trọng đã bị thay đổi. Nếu như xét ngữ cảnh A là máy chủ đó đang được nâng cấp phần mềm, thì thông tin này không có nhiều ý nghĩa. Nhưng nếu như ở ngoài ngữ cảnh A đó, nói cách khác, không có một yêu cầu thay đổi phần mềm nào đang được áp dụng cho máy chủ đó cả, thì rõ ràng rất có thể máy chủ đó đã bị xâm nhập. Và chỉ có những chuyên gia mới có thể cung cấp được những ngữ cảnh như thế.

Quy trình giúp cho chúng ta leo thang thông tin. Leo thang thông tin là việc các chuyên gia báo cáo lên trên cho những người có quyền quyết định những vấn đề mà họ cho là quan trọng, cần phải điều tra thêm. Những người có quyền quyết định là những người có đủ thẩm quyền, trách nhiệm và năng lực để quyết định cách đối phó với các sự cố ANTT tiềm tàng. Không có leo thang thông tin, công việc của các chuyên gia sẽ trở thành vô ích. Tại sao phải phân tích để phát hiện các sự cố ANTT tiềm tàng nếu như chẳng có ai chịu trách nhiệm cho việc xử lý chúng?

Quay trở lại với câu chuyện vụ tấn công từ chối dịch vụ mà tôi chia sẻ ban đầu. Hệ thống giám sát an ninh mạng của chúng tôi thu thập tất cả dữ liệu liên quan đến hoạt động của các thiết bị như tường lửa, máy chủ proxy, máy chủ web, các ứng dụng web chạy trên các máy chủ web. Dựa vào nguồn dữ liệu phong phú này, các chuyên gia của chúng tôi đã không mất quá nhiều thời gian để phân tích và nhận ra các dấu hiệu bất thường trên hệ thống. Họ leo thang thông tin bằng cách thông báo cho tôi, và tôi quyết định kích hoạt quá trình đối phó với sự cố ANTT, ở đây là đối phó khi bị tấn công từ chối dịch vụ.

Về mặt kỹ thuật, chúng tôi đã cài đặt sẵn các biện pháp kiểm soát tự động trên hệ thống giám sát an ninh mạng, nên các chuyên gia của tôi chỉ phải theo dõi vụ tấn công xem có diễn tiến gì bất thường hay không mà không phải thực hiện thêm bất kỳ thao tác nào. Về mặt hành chính, tôi thông báo cho lãnh đạo doanh nghiệp và các đơn vị như Trung Tâm Chăm Sóc Khách hàng, Trung tâm Vận hành Data Center cũng như mở kênh liên lạc với các ISP để nhờ họ trợ giúp nếu như đường truyền bị quá tải. Như quý vị đã thấy trong một slide ở phía trước, chỉ chưa tới 20&#8242;, vừa ngay sau lần kích hoạt hệ thống phòng thủ đầu tiên, vụ tấn công đã được kiểm soát thành công. Hệ thống giám sát an ninh mạng cũng giúp chúng tôi làm các báo cáo để gửi lãnh đạo cũng như gửi các cơ quan điều tra nhờ hỗ trợ truy tìm thủ phạm.

Toàn bộ phương thức giám sát an ninh mạng chỉ đơn giản như thế. Đến đây là chúng ta xong phần 1 của bài trình bày này. Tiếp theo tôi sẽ chia sẻ một số thông tin về hệ thống cũng như công tác giám sát an ninh mạng.

Về mặt kỹ thuật, chúng tôi không mất quá nhiều thời gian cho việc thiết kế hệ thống và lựa chọn giải pháp, bởi vì ngay từ đầu chúng tôi đã xác định đây là một lĩnh vực tương đối mới mẻ, thành ra một giải pháp hoàn chỉnh sẽ không có trên thị trường. Thay vào đó, giống như phát triển phần mềm theo nguyên lý agile, chúng tôi làm vừa làm vừa điều chỉnh.

Chúng tôi khởi đầu bằng việc xây dựng một hệ thống log tập trung. Như đã nói ở trên, đây là công đoạn thu thập dữ liệu. Trong quá trình làm, chúng tôi nhận thấy hầu hết các ứng dụng chạy trên nền UNIX hay các thiết bị mạng đều hỗ trợ sẵn chuẩn syslog, thành ra chúng tôi quyết định chọn phần mềm mã nguồn mở syslog-ng làm công cụ chính để thu thập log.

Tuy nhiên có hai vấn đề: các máy chủ Windows mặc định không hỗ trợ syslog; và một số ứng dụng do chúng tôi tự phát triển hay mua ngoài cũng không hỗ trợ syslog. Đối với vấn đề thứ nhất, chúng tôi cài đặt thêm một phần mềm cho các máy chủ Windows, để đẩy các sự trên trên đó về hệ thống log của chúng tôi. Đối với vấn đề thứ hai, việc đầu tiên chúng tôi làm là xây dựng một quy định về log của các ứng dụng. Trong quy định này chúng tôi yêu cầu tất cả các ứng dụng muốn được cấp quyền chạy trên hệ thống của chúng tôi thì phải thỏa mãn các tiêu chí về log các sự kiện. Chúng tôi cũng hướng dẫn và cung cấp thư viện phần mềm mẫu để các lập trình viên có thể tích hợp vào phần mềm có sẵn của họ.

Syslog-ng là một phần mềm mã nguồn mở tuyệt vời. Nó hoạt động cực kỳ ổn định, bền vững. Trong suốt hơn 3 năm triển khai hệ thống này, chúng tôi chưa bao giờ gặp sự cố ở phần mềm này. Nhưng syslog-ng cũng chỉ làm tốt nhiệm vụ thu thập dữ liệu, làm sao phân tích dữ liệu đó? Trên thị trường lúc bấy giờ có khá nhiều công cụ giúp giải quyết vấn đề này. Chúng tôi lần lượt thử nghiệm các công cụ này, và rồi chúng tôi phát hiện ra Splunk. Chúng tôi hay gọi phần mềm này là “Splunk toàn năng”. Một công cụ phân tích dữ liệu trên cả tuyệt vời!

Splunk rất hay, nhưng nếu không có các chuyên gia có kỹ năng phân tích dữ liệu để khai thác Splunk thì hệ thống cũng sẽ không đem lại nhiều ích lợi. Cái hay của Splunk là ở chỗ nó đã làm cho công việc phân tích log tưởng như nhàm chán trở nên cực kỳ thú vị. Chỉ trong một thời gian ngắn, nhân viên của tôi đã bị Splunk mê hoặc. Cái tên “Splunk toàn năng” cũng là do anh ấy đặt cho Splunk. Thành ra chúng tôi cũng không mất quá nhiều thời gian để huấn luyện, bởi vì tự bản thân giải pháp nó đã đủ thú vị để cuốn hút con người chủ động tìm hiểu nó.

Điều tối quan trọng nhất đối với một hệ thống giám sát an ninh là khả năng phân tích một lượng dữ liệu lớn một cách nhanh chóng. Splunk làm rất tốt việc này. Tuy vậy trên thị trường vẫn có các giải pháp khác hoàn toàn miễn phí như tôi liệt kê ở trên. Bản thân tôi cho rằng Hadoop + Scribe + Hive là một hướng nghiên cứu nhiều tiềm năng.

Với hệ thống này, bây giờ chúng tôi có thể an tâm rằng tôi có thể biết được chuyện gì đang diễn ra trên hệ thống mạng của các khách hàng của chúng tôi ngay tại thời điểm tôi đang viết những dòng này.

Về phía lãnh đạo doanh nghiệp, họ cũng an tâm khi biết rằng, chúng tôi có thể phát hiện, truy vết và đối phó lại với bất kỳ sự cố ANTT nào diễn ra trên hệ thống của họ. Thực tế là từ khi triển khai giải pháp này, chúng tôi giải quyết được 100% các sự cố an toàn thông tin trên hệ thống của các khách hàng của chúng tôi.

Ngoài ra hệ thống này còn giúp chúng tôi phát hiện và xử lý hơn phân nửa các sự cố an toàn thông tin. Có rất nhiều tình huống, nếu không có sự hỗ trợ của hệ thống này, chúng tôi sẽ không thể giải quyết được vấn đề. Lại quay lại với câu chuyện bị tấn công DDoS ở trên.

Nhắc lại, một khách hàng của chúng tôi từng bị tấn công DDoS trên diện rộng vào hệ thống máy chủ Internet Banking. Ở thời điểm cao trào, có hơn 10000 IP gửi hàng ngàn request/s đến máy chủ của họ. Làm thế nào để nhanh chóng lấy ra được danh sách 10000 IP này, ngăn chặn chúng trên hệ thống firewall, mà không chặn nhầm khách hàng? Làm thế nào để có thể tự động hóa quá trình trên, chẳng hạn như cứ mỗi 15&#8242; sẽ lấy ra danh sách các IP đang tấn công, cập nhật bộ lọc của tường lửa?

Với hệ thống này, chúng tôi chỉ cần soạn thảo một đoạn script ngắn để lấy ra danh sách IP đang gửi hơn 100 request/s rồi cài đặt chương trình để tự động cập nhật bộ lọc của firewall mỗi 15&#8242;. Một vấn đề tưởng như nan giải có thể giải quyết nhanh gọn lẹ và rất rẻ.

Các giải pháp chống DDoS sẽ có 2 thành phần chính: phát hiện và đánh chặn. Các giải pháp có sẵn trên thị trường như các thiết bị của các hãng lớn hay các giải pháp mở như Iptables + Snort inline thường cố gắng phân tích các packet/request để phân loại chúng theo thời gian thực. Nghĩa là khi có một packet/request đi vào, các giải pháp này sẽ cố gắng xác định xem packet đó có phải là một phần của vụ tấn công hay không, nếu phải thì thực hiện đánh chặn.

Sự khác biệt của giải pháp của chúng tôi so với các giải pháp chống DDoS đang có trên thị trường là chúng tôi không cố gắng phân loại và ngăn chặn các packet/request theo thời gian thực. Thay vào đó, <span style="font-weight: bold">chúng tôi tách phần phát hiện ra khỏi hệ thống phòng thủ</span>, và thực hiện phần phát hiện hoàn toàn offline bằng cách sử dụng thông tin từ hệ thống NSM.

Cụ thể, thông tin từ hệ thống đánh chặn cũng như các nguồn khác như web server, proxy hay firewall sẽ được đưa vào hệ thống phân tích để chạy offline, rồi kết quả phân tích này sẽ được cập nhật ngược trở lại cho hệ thống đánh chặn. Với cách làm này, giải pháp của chúng tôi có thể đáp ứng được lượng tải rất lớn vì chúng tôi không phải tốn quá nhiều resource để phân tích on-the-fly một packet hay request như các giải pháp khác.

Về các hướng phát triển trong thời gian tới, tôi thấy một ứng dụng hay ho khác của hệ thống giám sát an ninh mạng là nó giúp chúng tôi có thể đo lường được mức độ an toàn của hệ thống. Có một nguyên tắc lâu đời của quản lý là: chúng ta không thể quản lý những gì chúng ta không thể đo đạc. Do đó để quản lý được an toàn thông tin, chúng ta phải biến an toàn thông tin thành những thông số có thể đo đạc và so sánh được. Đây là một hướng tiếp cận an toàn thông tin từ góc nhìn của người quản lý mà chúng tôi muốn áp dụng cho các khách hàng trong thời gian sắp tới.

**Tài liệu tham khảo:**

*   Ký sự các vụ DDoS vào HVAOnline
*   <a href="http://taosecurity.blogspot.com" target="_blank"> http://taosecurity.blogspot.com</a>

 [1]: http://www.slideshare.net/thaidn/network-security-monitoring-or-how-to-mitigate-a-ddos-attack-in-20 "Network Security Monitoring or How to mitigate a DDoS attack in 20'"
 [2]: http://www.slideshare.net/
 [3]: http://www.slideshare.net/thaidn