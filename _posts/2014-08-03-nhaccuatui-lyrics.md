---
title: Lấy lời nhạc nhaccuatui.com
author: tienpp
layout: post
thumbnail: /assets/2014/08/nhac_cua_tui.png
category: tutorials
---
Nhaccuatui vừa nâng cấp trình chơi nhạc trên web của mình có thể hiển thị lời nhạc theo thời gian khá tốt. Bài viết này sẽ trình bày các bước để lấy lời nhạc đó và cung cấp một công cụ để thực hiện trong 1 cú enter <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_wink.gif" alt=";)" class="wp-smiley" /> (*).

Lấy một bài nhạc làm mẫu như bài [này][1]. Lời nhạc được hiện rất khớp với nhạc:

<div id="attachment_1752" style="width: 405px" class="wp-caption aligncenter">
  <img class="size-full wp-image-1752" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/nctlyricshow.png" alt="nctlyricshow" width="395" height="133" /><p class="wp-caption-text">
    nctlyricshow
  </p>
</div>

Đơn giản, xem mã nguồn của trang thử lời nhạc này lấy từ đâu:

<a href="https://www.vnsecurity.net/2014/08/nhaccuatui-lyrics/htmlsourcecode/" rel="attachment wp-att-1753"><img class="aligncenter size-full wp-image-1753" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/htmlsourcecode.png" alt="htmlsourcecode" width="1352" height="133" /></a>

Đúng là khúc này, đường dẫn <a href="https://www.vnsecurity.net/2014/08/nhaccuatui-lyrics/linkdescription/" rel="attachment wp-att-1754"><img class="alignnone size-full wp-image-1754" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/linkdescription.png" alt="linkdescription" width="548" height="17" /></a> là một mô tả cho bài nhạc ở trên, có chứa các thông tin của bài nhạc, bao gồm cả đường dẫn đến tệp lời nhạc:

<a href="https://www.vnsecurity.net/2014/08/nhaccuatui-lyrics/songdescription/" rel="attachment wp-att-1761"><img class="aligncenter size-full wp-image-1761" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/songdescription.png" alt="songdescription" width="1138" height="399" /></a>

Tải tệp Loi-To-Tinh-Ong-Buom-Vu-Hung.lrc (**) về, nhưng có một vấn đề, nó đã bị mã hóa thành như thế này:

<a href="https://www.vnsecurity.net/2014/08/nhaccuatui-lyrics/lyricencrypted/" rel="attachment wp-att-1762"><img class="aligncenter size-full wp-image-1762" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/lyricencrypted.png" alt="lyricencrypted" width="1901" height="281" /></a>

Làm thế nào đây, rỏ ràng là chương trình nghe nhạc của nhaccuatui hiển thị lời nhạc rất rỏ ràng. Bây giờ, phải tìm hiểu chương trình nghe nhạc này xử lý tệp tin lrc kia như thế nào. Decompile chương trình nghe nhạc của nhaccuatui bằng tiện ích ở đây http://www.showmycode.com/. Duyệt qua một chút mã nguồn thì sẽ thấy đoạn code này:

<a href="https://www.vnsecurity.net/2014/08/nhaccuatui-lyrics/lrcdecrypt/" rel="attachment wp-att-1763"><img class="aligncenter size-full wp-image-1763" src="http://www.vnsecurity.net/wp/storage/uploads/2014/08/lrcdecrypt.png" alt="lrcdecrypt" width="598" height="90" /></a>

Ở dưới là phần xử lý biến local5 để làm lời nhạc, từ đó ta có thể suy ra rằng tệp lrc kia đã được mã hóa bằng RC4, với khóa là đoạn:

<pre class="brush: php; title: ; notranslate" title="">var _local3:ByteArray = Hex.toArray(Hex.fromString(irrcrpt('Mzs2dkvtu5odu', 1)));</pre>

Chương trình chơi nhạc của nhaccuatui sử dụng **irrFuscator **để làm rối mã nguồn action script. Nhưng có một công cụ online để decrypt các chuỗi dùng irrFuscator này tại http://peniscorp.com/boombang/decrypt.php , dán đoạn code trên vào và ta sẽ có:

<pre class="brush: css; title: ; notranslate" title="">var _local3:ByteArray = Hex.toArray(Hex.fromString('Lyr1cjust4nct'));</pre>

Vậy là ta đã có ciphertext là tệp lrc, phương thức mã hóa là **RC4 **với khóa là **Lyr1cjust4nct**, công việc còn lại là giải mã tệp đó. Có thể dùng công cụ có sẵn trên mạng như: http://rc4.online-domain-tools.com/.

Phía dưới là mã nguồn mình viết để đơn giản hóa việc lấy lời nhạc này:

<pre class="brush: css; title: ; notranslate" title="">import re
import httplib
import os
import sys

def rc4crypt(data, key):
    x = 0
    box = range(256)
    for i in range(256):
        x = (x + box[i] + ord(key[i % len(key)])) % 256
        box[i], box[x] = box[x], box[i]
    x = 0
    y = 0
    out = []
    for char in data:
        x = (x + 1) % 256
        y = (y + box[x]) % 256
        box[x], box[y] = box[y], box[x]
        out.append(chr(ord(char) ^ box[(box[x] + box[y]) % 256]))

    return ''.join(out)

if len(sys.argv) &amp;lt;= 2:
    print 'usage: python nctlyricdecryptor.py /bai-hat/loi-to-tinh-ong-buom-vu-hung.d1rchpsGUBfW.html'
    exit()

conn = httplib.HTTPConnection('www.nhaccuatui.com')
conn.request('GET', sys.argv[1])
r1 = conn.getresponse()
data1 = r1.read()
songdescript = 'http://www.nhaccuatui.com/flash/xml?key1=' + re.search('([a-fA-Fd]{32})', data1).group(0)

conn.request('GET', songdescript)
r1 = conn.getresponse()
data1 = r1.read()
m = re.search('http://lrc.nct.nixcdn.com/(.*)]', data1).group(0)[:-2]
print m
os.system('wget ' + m + ' -O lyric')
lyricencrypted = open('lyric').readline()

lyricdecrypted = rc4crypt(lyricencrypted.decode('hex'), 'Lyr1cjust4nct')

f = open('lyric', 'wb')
f.write(lyricdecrypted)
f.close()</pre>

*(*): Các bạn chịu hoàn toàn trách nhiệm trước pháp luật khi dùng chương trình này để lấy dữ liệu từ trang nhaccuatui.*  
*(**) http://en.wikipedia.org/wiki/LRC\_(file\_format)*

 [1]: http://www.nhaccuatui.com/bai-hat/loi-to-tinh-ong-buom-vu-hung.d1rchpsGUBfW.html