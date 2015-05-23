---
title: Hướng dẫn viết bài cho VNSecurity.net
author: admin
layout: default_sidebar
---

### Viết bài cho VNSecurity.net
***
Phiên bản hiện tại của VNSecurity.net được xây dựng trên nền Jekyll, nội dung gốc được lưu trữ ở [https://github.com/VNSECURITY/vnsecurity.github.io](https://github.com/VNSECURITY/vnsecurity.github.io). Để viết bài, bạn cần một tài khoản github có quyền commit đến repository này.

Để gửi bài mới lên VNSecurity.net, bạn cần tạo một *file* trong thư mục `_posts` với định dạng tên  `<năm-tháng-ngày>-tiêu-đề-bài-viết-không-dấu.md`. Ví dụ:

* 2014-08-14-tor-xac-dinh-cac-exit-relay-doc-hai.md
* 2014-05-22-defcon-2014-polyglot.md

Ngôn ngữ định dạng chính cho các bài viết là [Markdown](http://en.wikipedia.org/wiki/Markdown) tuy nhiên HTML vẫn được hỗ trợ ở bất cứ đâu trong bài viết. Nếu chưa quen với Markdown, bạn có thể sử dụng một số công cụ hỗ trợ chỉnh sửa trực tuyến tại [StackEdit](https://stackedit.io/editor), [Markable](http://markable.in/editor/) hoặc [http://jbt.github.io/markdown-editor](http://jbt.github.io/markdown-editor).

##### Luôn phải có YAM Front Matter

Ở đầu mỗi file, bạn cần định nghĩa một khối [YAML Front Matter](http://jekyllrb.com/docs/frontmatter/) chứa các thông tin mô tả bài viết. Nếu thiếu khối này, bài viết của bạn sẽ không được Jekyll xử lý. Ví dụ dưới đây là khối YAML Front Matter cho bài viết **"Tor – Xác định các exit relay độc hại"** của **tienpp**.
    
    ---
    title: 'Tor &#8211; Xác định các exit relay độc hại'
    author: tienpp
    layout: post
    category: tutorials
    excerpt: tóm tắt nội dung bài viết trong một hoặc hai dòng.
    thumbnail: assets/2014/08/Tor_logo1.png
    tags:
      - exit relay
      - read paper
      - tor
    ---

##### Hình ảnh và tập tin tài nguyên

Tất cả tập tin hình của vnsecurity.net được chứa ở thư mục `assets`. Để cho dễ quản lý, chúng ta quy ước các hình ảnh minh họa cho bài viết trong cùng một tháng sẽ được đặt trong cùng một thư mục con tại `assets/<năm>/<tháng>`. Sau khi đã chép tập tin hình ảnh vào đúng thư mục, bạn có tham chiếu đến nó trong bài viết như sau:

<code>
    ![Hình củ hành]( {{"{{"}}site.url}}/assets/2014/08/Tor_logo1.png)
</code>

Với định dạng trên, nội dung HTML được tạo ra sẽ là

    <img alt="Hình củ hành" src="http://vnsecurity.net/assets/2014/08/Tor_logo1.png" />
    
Các quy tắc trên cũng được áp dụng cho các loại tập tin tài nguyên khác như `.txt`, `.pdf`, ...

##### Gửi bài

Việc xuất bản bài viết thực chất là *commit* các thay đổi của bạn lên *github repository*. Dưới đây là một số tác vụ cơ bản khi bạn muốn gửi bài viết của mình:

<table border="1px" cellpadding="5px">
    <tr>
        <td>
            $ git status
        </td>
        <td>
            Kiểm tra xem bạn đã thay đổi hay thêm mới tập tin nào
        </td>
    </tr>
    <tr>
        <td>
            $ git add path/to/file1 path/to/file2
        </td>
        <td>
            Đánh dấu rằng bạn muốn cập nhật các thay đổi trên file1 và file2
        </td>
    </tr>
    <tr>
        <td>
            $ git commit -m "Some message here"
        </td>
        <td>
            Tạo một commit cùng với thông điệp "Some message here"
        </td>
    </tr>
    <tr>
        <td>
            $ git push origin master
        </td>
        <td>
            Gửi tất cả các commit lên github repository
        </td>
    </tr>
</table>

