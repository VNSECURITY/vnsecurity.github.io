---
title: CodeGate 2012 Quals bin500 writeup
author: admin
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358968
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - '2012'
  - codegate
  - CTF
---
Thanks to Deroko and some ARTeam members to play with CLGT. Below is the write up by Deroko posted on <http://www.xchg.info/wiki/index.php?title=CodeGate2012_bin500>

<h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
  <span id="CodeGate2012_bin500">CodeGate2012 bin500</span>
</h3>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Challenge: <strong>Seeing that it is not all. </strong><br /> Link to challenge: <a rel="nofollow" href="http://deroko.phearless.org/codegate2012/bin/bin500.zip">http://deroko.phearless.org/codegate2012/bin/bin500.zip</a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  This binary is double ReWolf vm, and python script for modified Olly by Immunity.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Script which comes with binary uses <strong>marshal.loads</strong> to load already compiled pyc code which was produced with <strong>marshal.dump</strong>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  To get .pyc back we need to make some modification to our script:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Modifiedscript.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/1/14/Modifiedscript.png" alt="Modifiedscript.png" width="766" height="300" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Now <strong>C:test.pyc</strong> will have dump of python bytecode.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  If you look carefully through script, some strings might look like a clue:
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white">readMemory
getRegs
EIP
Nice work<span style="color: #339933">,</span> Key1 <span style="color: #339933">:</span>
But<span style="color: #339933">,</span> Find Next Key!
Nice work<span style="color: #339933">,</span> Key2 <span style="color: #339933">:</span>
Input Key <span style="color: #339933">:</span> Key1 <span style="color: #339933">+</span> Key2
<span style="font-weight: bold">Nothing</span> Found <span style="color: #339933">...</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So this script will probably try to read from current EIP some bytes (readMemory + EIP are good hint), and make key out of it. After modifying <strong>test.pyc</strong> to have proper layout:
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">00000000</span>  <span style="color: #0000ff">03</span> f3 0d 0a dc <span style="font-weight: bold">dd</span> e2 4c  <span style="color: #0000ff">63</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span>  |<span style="color: #339933">.......</span>Lc<span style="color: #339933">.......</span>|
<span style="color: #adadad;font-style: italic">00000010</span>  <span style="color: #0000ff">00</span> <span style="color: #0000ff">02</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">40</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span>  <span style="color: #0000ff">00</span> <span style="color: #0000ff">73</span> <span style="color: #0000ff">22</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">00</span> <span style="color: #0000ff">64</span> <span style="color: #0000ff">00</span>  |<span style="color: #339933">.....</span>@<span style="color: #339933">...</span>s<span style="color: #7f007f">"...d.|
00000020  00 64 01 00 6c 00 00 5a  00 00 64 02 00 84 00 00  |.d..l..Z..d.....|</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Which is actually <strong>4 bytes for python signature</strong> + <strong>4 bytes for timestamp</strong> +<strong>marshal.dump()</strong> data we get .pyc file which we can decompile.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  For sake of this solution, we will use some simple program to dump python byte-code, and one I found here:<a rel="nofollow" href="http://nedbatchelder.com/blog/200804/the_structure_of_pyc_files.html">http://nedbatchelder.com/blog/200804/the_structure_of_pyc_files.html</a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  After disassembling binary with this python script we get (I cut not important parts):
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white">             <span style="color: #0000ff">15</span> LOAD_ATTR                <span style="color: #0000ff">2</span> <span style="color: #009900;font-weight: bold">(</span>readMemory<span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">18</span> LOAD_CONST               <span style="color: #0000ff">1</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #0000ff">4237456</span><span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">21</span> LOAD_CONST               <span style="color: #0000ff">2</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #0000ff">80</span><span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">24</span> CALL_FUNCTION            <span style="color: #0000ff">2</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So from address <strong>40A890</strong> it will read <strong>80</strong> bytes and keep it in internal buffer.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Now comes interesting part when it actually gets keys:
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"> <span style="color: #0000ff">19</span>          <span style="color: #0000ff">54</span> LOAD_FAST                <span style="color: #0000ff">4</span> <span style="color: #009900;font-weight: bold">(</span>regs<span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">57</span> LOAD_CONST               <span style="color: #0000ff">3</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #7f007f">'EIP'</span><span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">60</span> BINARY_SUBSCR
             <span style="color: #0000ff">61</span> LOAD_CONST               <span style="color: #0000ff">4</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #0000ff">4273157</span><span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">64</span> COMPARE_OP               <span style="color: #0000ff">2</span> <span style="color: #009900;font-weight: bold">(</span>==<span style="color: #009900;font-weight: bold">)</span>
             <span style="color: #0000ff">67</span> POP_JUMP_IF_FALSE      <span style="color: #0000ff">161</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  and
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"> <span style="color: #0000ff">23</span>     &gt;&gt;  <span style="color: #0000ff">161</span> LOAD_FAST                <span style="color: #0000ff">4</span> <span style="color: #009900;font-weight: bold">(</span>regs<span style="color: #009900;font-weight: bold">)</span>
            <span style="color: #0000ff">164</span> LOAD_CONST               <span style="color: #0000ff">3</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #7f007f">'EIP'</span><span style="color: #009900;font-weight: bold">)</span>
            <span style="color: #0000ff">167</span> BINARY_SUBSCR
            <span style="color: #0000ff">168</span> LOAD_CONST              <span style="color: #0000ff">15</span> <span style="color: #009900;font-weight: bold">(</span><span style="color: #0000ff">4278021</span><span style="color: #009900;font-weight: bold">)</span>
            <span style="color: #0000ff">171</span> COMPARE_OP               <span style="color: #0000ff">2</span> <span style="color: #009900;font-weight: bold">(</span>==<span style="color: #009900;font-weight: bold">)</span>
            <span style="color: #0000ff">174</span> POP_JUMP_IF_FALSE      <span style="color: #0000ff">276</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  If you look at <strong>out.txt</strong> (in attachment) you may also see what&#8217;s read from where as this python script is not complicated, and python byte code is quite easy to understand.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So just set EIP to be <strong>413405</strong> and run script, and you will get 1st key. Then set EIP to be <strong>414705</strong> and run scrip again. If you did, everything correct you should see in Log of Immunity Debugger this:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Key.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/5/52/Key.png" alt="Key.png" width="291" height="51" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So final key is <strong>Never_up_N3v3r_1n</strong>
</p>

<h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
  <span id="Greetings">Greetings</span>
</h3>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  I would like to say tnx to my <strong>ARTeam</strong> mates, <strong>vnsecurity</strong> guys, and <strong>rd</strong> , and of course to <strong>superkhung</strong> for listening to my random blabing on skype during CTF :)
</p>

<h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
  <span id="Author">Author</span>
</h3>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <strong>deroko of ARTeam</strong>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
    <p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">