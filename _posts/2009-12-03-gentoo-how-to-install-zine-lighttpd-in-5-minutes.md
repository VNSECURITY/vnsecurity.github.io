---
title: 'Gentoo: How to install Zine+lighttpd in 5 minutes'
author: vnsec
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:9:"permalink";s:84:"https://www.vnsecurity.net/2009/12/gentoo-how-to-install-zine-lighttpd-in-5-minutes/";s:7:"tinyurl";s:26:"http://tinyurl.com/y8wlb8q";s:4:"isgd";s:18:"http://is.gd/aOt6P";s:5:"bitly";s:20:"http://bit.ly/8AoIsb";}'
tweetbackscheck:
  - 1408358988
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - tutorials
tags:
  - gentoo
  - lighttpd
  - zine
---
This is how you can get <a title="Zine" href="http://zine.pocoo.org/" target="_blank">Zine </a>+ <a title="Lighttpd" href="http://www.lighttpd.net/" target="_blank">lighty</a> running under <a title="Gentoo" href="http://www.gentoo.org" target="_blank">Gentoo</a> in 5 minutes

**1. Install the required python packages for Zine**
{% highlight bash %}
(root) # cat /etc/portage/package.keywords
 dev-python/werkzeug
 dev-python/Babel
 dev-python/html5lib
 dev-python/flup
 dev-python/sqlalchemy

(root) # emerge -av sqlalchemy jinja2 werkzeug simplejson html5lib pytz Babel lxml flup
{% endhighlight %}

**2. Download and Install Zine**
{% highlight bash %}
(download) $ wget http://zine.pocoo.org/releases/Zine-0.1.2.tar.gz
(download) $ tar zxvf Zine-0.1.2.tar.gz
(download) $ cd Zine-0.1.2

# Use --prefix to install zine to a different location than default (/usr)
(Zine-0.1.2) $ ./configure --prefix=/srv/usr && make install

# Create a working directory for your Zine fastcgi and configuration files
(Zine-0.1.2) $ mkdir -p /var/www/zine
(Zine-0.1.2) $ cp servers/zine.fcgi /var/www/zine

# Edit zine.fcgi to update INSTANCE_FOLDER and ZINE_LIB
(Zine-0.1.2) $ nano /var/www/zine/servers/zine.fcgi
{% endhighlight %}

    INSTANCE_FOLDER = '/var/www/zine';  
    ZINE_LIB = '/srv/usr/lib/zine';


<pre class="brush: bash; light: true; title: ; notranslate" title="">(Zine-0.1.2) $ chown lighttpd /var/www/zine
(Zine-0.1.2) $ chmod 755 /var/www/zine/zine.fcgi
</pre>

**3. Update lighttpd configuration**
{% highlight bash %}# Edit /etc/lighttpd/mod_fastcgi.conf for global fcgi handler setup or
# add fastcgi.server to your VHOST config
(root) # nano /etc/lighttpd/mod_fastcgi.conf
{% endhighlight %}

    fastcgi.server = ('' =>  
    ((  
    'bin-path' => '/var/www/zine/zine.fcgi',  
    'socket' => '/tmp/fcgi-zine.socket',  
    'check-local' => 'disable'  
    )))

**4. Restart your lighttpd!**
