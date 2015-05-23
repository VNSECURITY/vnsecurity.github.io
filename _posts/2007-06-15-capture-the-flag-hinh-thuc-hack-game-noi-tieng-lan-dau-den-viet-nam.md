---
title: 'Capture-the-Flag: hình thức hack game nổi tiếng lần đầu đến Việt Nam'
author: longld
excerpt: |
  |
    Trong khuôn khổ hội thảo bảo mật VNSECON '07 sẽ tổ chức tại TpHCM tháng 8 tới, hình thức hack game nổi tiếng Capture the Flag (CTF) sẽ lần đầu được tổ chức tại Việt Nam. VNSECON CTF lần này hy vọng sẽ là một sân chơi mở, cạnh tranh và hấp dẫn cho các nhóm bảo mật trong nước và nước ngoài so tài.
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359034
shorturls:
  - 'a:4:{s:9:"permalink";s:102:"http://www.vnsecurity.net/2007/06/capture-the-flag-hinh-thuc-hack-game-noi-tieng-lan-dau-den-viet-nam/";s:7:"tinyurl";s:26:"http://tinyurl.com/yznshwz";s:4:"isgd";s:18:"http://is.gd/aOudW";s:5:"bitly";s:0:"";}'
aktt_notify_twitter:
  - no
category:
  - 'CTF - CLGT Crew'
---
Trong khuôn khổ hội thảo bảo mật [VNSECON &#8217;07][1] sẽ tổ chức tại TpHCM tháng 8 tới, hình thức hack game nổi tiếng [Capture the Flag][2] (CTF) sẽ lần đầu được tổ chức tại Việt Nam. VNSECON CTF lần này hy vọng sẽ là một sân chơi mở, cạnh tranh và hấp dẫn cho các nhóm bảo mật trong nước và nước ngoài so tài.

CTF lần đầu tiên được tổ chức tại hội thảo bảo mật nổi tiếng DefCon (Mỹ) lần thứ 5 năm 1997. CTF đã được cải tiến, nâng dần độ khó trong các lần sau đó để hấp dẫn và mang tính cạnh tranh hơn với sự đóng góp của các nhóm tổ chức như GhettoHackers, Kenshoto và được tổ chức ngày càng chuyên nghiệp hơn. Các lần DefCon CTF gần đây được tổ chức bởi Kenshoto, một nhóm những người từng tham gia tranh tài và tổ chức CTF qua các kỳ DefCon. Được xem như một hack game &#8220;chuẩn&#8221;, CTF đã được nhân rộng ở một số hội thảo bảo mật khác như [Hack.Lu][3], [HITBSecConf][4], tất nhiên về quy mô hoặc cách thức có thể khác nhau.

CTF là thể loại hack game &#8220;tấn công và phòng thủ&#8221; (attack and defense), qua đó không chỉ thử thách người chơi các kỹ năng phát hiện lỗ hổng bảo mật, khai thác chúng mà còn các kỹ năng bịt các lỗ hổng đó, xây dựng phòng tuyến để bảo vệ. Do chỉ diễn ra trong thời gian ngắn (2-3 ngày) nên &#8220;cuộc chiến&#8221; sẽ rất căng thẳng với cường độ và áp lực cao, mặc dù thể lệ cho phép cá nhân tham gia nhưng chiến thắng thường thuộc về các đội có trình độ &#8220;cứng&#8221; và được tổ chức tốt. Các kỳ CTF gần đây được tổ chức như sau: các đội tham gia sẽ được cấp một máy chủ chạy hệ điều hành được công bố trước (như Gentoo Linux, FreeBSD, Windows 2000), trên máy chủ đã cài đặt sẵn nhiều dịch vụ mạng chứa &#8220;lỗ hổng&#8221;. Nhiệm vụ của đội chơi là tìm ra các lỗ hổng đó, khai thác chúng và tấn công máy chủ của các đội khác để ghi điểm, đồng thời phải tìm cách bịt các lỗ hổng đó trước sự tấn công của các đội khác. Các dịch vụ có thể là thông thường như http, mysql, ftp với các lỗ hổng đã được công bố hoặc được các nhóm tổ chức tạo ra với lỗ hổng được &#8220;cố tình&#8221; tạo ra rất tinh vi (loại này khó hơn).

Có hai loại điểm được tính: điểm tấn công (offensive) và điểm phòng thủ (defensive). Ví dụ có 4 đội chơi, đội 1 khai thác được lỗ hổng trong daemon1 và dùng chúng để tấn công máy chủ của đội 2-4, lấy các flag (hay token) cho daemon1 trên các máy chủ đó và ghi được 3 điểm tấn công. Các flag được thay đổi định kỳ (ví dụ mỗi 2 giờ), do đó với cùng một lỗ hổng khai thác được, một đội có thể kiếm được nhiều điểm tấn công theo thời gian. Ngược lại, điểm phòng thủ có được bằng cách đảm bảo các dịch vụ cần bảo vệ chạy liên tục (máy chủ tính điểm kiểm tra định kỳ) với các quy định như không được làm thay đổi file chương trình, không được tắt, không được đặt firewall chặn các đối thủ,&#8230; Ngoài ra một đội còn có thể có điểm thưởng thêm nếu viết chi tiết về lỗ hổng phát hiện được, cách khai thác và vá chúng. Một đội cũng có thể giành giải chỉ với điểm phòng thủ. CTF được xem là game rất &#8220;đời thực&#8221; (real world) do lẽ giống như công việc của các nhà quản trị mạng hoặc chuyên gia bảo mật, họ phải bảo vệ các máy chủ của công ty trước sự tấn công từ bên ngoài trong khi vẫn phải duy trì sự liên tục của các dịch vụ mạng. Luật chơi chỉ cấm các hình thức tấn công DoS (đội vi phạm có thể bị loại lập tức), còn lại các đội có thể dùng bất cứ &#8220;thủ đoạn&#8221; nào để đạt được mục tiêu kiếm điểm, kể cả các biện pháp phi kỹ thuật như &#8230; lừa gạt đội khác (social engineering).

Là một hack game hấp dẫn, tất nhiên đối tượng tham gia CTF là các hacker, nhưng thành phần cũng rất đa dạng. Có thể là nhóm các hacker, nhóm các chuyên gia bảo mật hoặc nhóm nghiên cứu ở trường đại học. Đội giành chiến thắng DefCon CTF 2005, [ShellPhish][5] đến từ trường đại học UCSB (University of California, Santa Barbara) và được dẫn đầu bởi Associate Professor [Giovanni Vigna][6]. Giải thưởng CTF thường không lớn về vật chất nhưng rất có giá trị bởi uy tín của nó. Đội đoạt giải thường được cộng đồng bảo mật trân trọng bởi họ là &#8220;vàng thật &#8221; và đã chứng tỏ được những kỹ năng thực sự của mình. Để được tham dự vòng chơi trực tiếp DefCon CTF các đội còn phải trải qua vòng sơ loại để đảm bảo các đội là đủ năng lực và trình độ khá tương đồng.

Ở châu Á, CTF được tổ chức lần đầu tiên tại Malaysia trong trong hội thảo HITBSecConf 2002. Năm nay, [HITB CTF 2007 Dubai][7] đã diễn ra tại Dubai, UAE từ ngày 3 đến 5 tháng 4 và &#8230; không có đội nào thắng cuộc. [HITB CTF 2006 Kuala Lumpur][8] được tổ chức tại Malaysia với 9 đội tham dự đến từ Italia, Singapore, Malaysia và Hàn Quốc. Các đội tham dự phải giải quyết [6 thử thách][9] hóc búa có mức độ khó khác nhau của các nhà tổ chức là các chương trình được viết có lỗi một cách tinh vi. Đội thắng cuộc DOKDO-KOR (PADOCON) Hàn Quốc cũng chỉ vượt qua được một thử thách. Nhóm tổ chức HITB CTF cũng là nhóm tổ chức VNSECON CTF 2007 tháng 8 tới tại Việt Nam với hình thức tương tự nhưng chỉ khó trung bình do đây là lần đầu tiên. HITB CTF 2007 Dubai dự kiến cũng được sử dụng để làm bài thử cho VNSECON CTF 2007.

[VNSECON CTF 2007][10] lần đầu tiên tại Việt Nam này sẽ gồm tối đa 10 đội, mỗi đội tối đa 3 thành viên. Ban tổ chức hy vọng sẽ thu hút được từ 3 đến 5 đội trong nước và các đội trong khu vực Đông Nam Á như Signapore, Malaysia đã không có điều kiện tham dự HITB CTF 2007 tại Dubai do Việt Nam hiện là một điểm đến hấp dẫn, khá gần và không cần Visa. Để tham dự VNSECON CTF 2007, các đội tham gia cần chuẩn bị các kỹ năng như dịch ngược (reverse engineering), kiểm lỗi mã nguồn (code auditing, trong trường hợp được cung cấp mã nguồn) và kỹ năng quan trọng nhất là viết chương trình khai thác lỗ hổng. Nếu muốn có hy vọng đoạt giải các đội cần phải lên kế họach và chuẩn bị thật kỹ, đây là lời khuyên nghiêm túc của ban tổ chức. Nếu các bạn muốn tham gia, hãy thành lập đội của mình và chuẩn bị ngay từ bây giờ. Liệu các hacker nội có chứng tỏ được mình trước các đối thủ nước ngoài? Hẹn gặp ở VNSECON CTF 2007!

&#8211;  
Nguồn tham khảo  
1. [http://en.wikipedia.org/wiki/Capture\_the\_flag#Computer_security][2]  
2. <http://defcon.org/>  
3. <http://midnightresearch.com/hacking-contest-scoreboard/>  
4. <http://conference.hackinthebox.org/>  
5. <http://mel.icious.net/ctf_writeup.html>  
6. <http://www.vnsecurity.net/download/rd/ctf/>  
7. <http://conf.vnsecurity.net/contest-vi>

 [1]: http://conf.vnsecurity.net/
 [2]: http://en.wikipedia.org/wiki/Capture_the_flag#Computer_security
 [3]: http://www.hack.lu/
 [4]: http://conference.hackinthebox.org/
 [5]: http://midnightresearch.com/hacking-contest-scoreboard/
 [6]: http://www.cs.ucsb.edu/%7Evigna/
 [7]: http://conference.hackinthebox.org/hitbsecconf2007dubai/?page_id=61
 [8]: http://conference.hitb.org/hitbsecconf2006kl/?page_id=61
 [9]: http://www.vnsecurity.net/download/rd/ctf/
 [10]: http://conf.vnsecurity.net/contest