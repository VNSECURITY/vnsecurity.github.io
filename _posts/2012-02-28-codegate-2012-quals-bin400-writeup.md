---
title: CodeGate 2012 Quals bin400 writeup
author: admin
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358967
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - '2012'
  - codegate
  - CTF
---
<span style="color: #222222;font-family: 'Lucida Grande', Arial, Tahoma, Verdana, sans-serif;font-size: 13px;line-height: 18px">Thanks to Deroko and some ARTeam members to play with CLGT. Below is the write up by Deroko posted on <a href="http://www.xchg.info/wiki/index.php?title=CodeGate2012_bin400">http://www.xchg.info/wiki/index.php?title=CodeGate2012_bin400</a></span>

<h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
  <span id="CodeGate2012_bin400">CodeGate2012 bin400</span>
</h3>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Challenge: <strong>The Rewolf in Kaspersky </strong><br /> Link to challenge : <a rel="nofollow" href="http://deroko.phearless.org/codegate2012/bin/bin400.zip">http://deroko.phearless.org/codegate2012/bin/bin400.zip</a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So Rewolf vm, is packed with something called <strong>KasperSky</strong> according to<strong>ProtectionID</strong> (never heard of this packer ). Unpacking is trivial, like with any simple packer. Run to OEP, dump, fix imports:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Here is OEP for ReWolf VM:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Rewolf_oep.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/6/6d/Rewolf_oep.png" alt="Rewolf oep.png" width="398" height="198" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  And here is OEP for original program (note you need to dump at ReWolf VM, but importrec will work only properly if you use this OEP) :
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Real_oep.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/b/b9/Real_oep.png" alt="Real oep.png" width="398" height="225" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Once we have file dumped, we might run it to get idea how it actually looks like:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Appwindow.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/6/6c/Appwindow.png" alt="Appwindow.png" width="266" height="82" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Not much there :( 1st time I pressed some key while program was focused I got an exception:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Exception.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/4/44/Exception.png" alt="Exception.png" width="944" height="115" /></a><br /> <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Exception_code.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/c/c6/Exception_code.png" alt="Exception code.png" width="497" height="23" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  At first I thought that my dump is broken, so I tried with original application, same thing happened. Hmmm so this is common problem, but challenge is definitely not broken, so we need to see what&#8217;s going on, and trace instruction per instruction in ReWolf VM.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  After a little bit of tracing I noticed that exception comes after virtualized jcc is executed, because next instruction size is wrong. (From exception you can see that<strong>ecx</strong> is quite big number which it should not be):
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">0041D000</span>   <span style="color: #0000ff">50</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">EAX</span>            &lt;<span style="color: #339933">-----</span> start of jcc opcode
<span style="color: #adadad;font-style: italic">0041D001</span>   9C               <span style="color: #00007f;font-weight: bold">PUSHFD</span>
<span style="color: #adadad;font-style: italic">0041D002</span>   <span style="color: #0000ff">58</span>               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EAX</span>
<span style="color: #adadad;font-style: italic">0041D003</span>   <span style="color: #0000ff">53</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">EBX</span>
<span style="color: #adadad;font-style: italic">0041D004</span>   E8 <span style="color: #0000ff">00000000</span>      <span style="color: #00007f;font-weight: bold">CALL</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D009
<span style="color: #adadad;font-style: italic">0041D009</span>   5B               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EBX</span>
<span style="color: #adadad;font-style: italic">0041D00A</span>   8D5453 <span style="color: #0000ff">08</span>        <span style="color: #00007f;font-weight: bold">LEA</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="font-weight: bold">DWORD</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EBX</span><span style="color: #339933">+</span><span style="color: #00007f">EDX</span><span style="color: #339933">*</span><span style="color: #0000ff">2</span><span style="color: #339933">+</span><span style="color: #0000ff">8</span><span style="color: #009900;font-weight: bold">]</span>
<span style="color: #adadad;font-style: italic">0041D00E</span>   5B               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EBX</span>
<span style="color: #adadad;font-style: italic">0041D00F</span>   FFE2             <span style="color: #00007f;font-weight: bold">JMP</span> <span style="color: #00007f">EDX</span></pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  If jcc is taked <strong>edx</strong> is set to 1, otherwise <strong>edx</strong> is 0.
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">0041D0DE</span>   33D2             <span style="color: #00007f;font-weight: bold">XOR</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="color: #00007f">EDX</span>                              <span style="color: #666666;font-style: italic">; test.0041D023</span>
<span style="color: #adadad;font-style: italic">0041D0E0</span>   EB <span style="color: #0000ff">04</span>            <span style="color: #00007f;font-weight: bold">JMP</span> <span style="font-weight: bold">SHORT</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D0E6
<span style="color: #adadad;font-style: italic">0041D0E2</span>   33D2             <span style="color: #00007f;font-weight: bold">XOR</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="color: #00007f">EDX</span>
<span style="color: #adadad;font-style: italic">0041D0E4</span>   EB <span style="color: #0000ff">01</span>            <span style="color: #00007f;font-weight: bold">JMP</span> <span style="font-weight: bold">SHORT</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D0E7
<span style="color: #adadad;font-style: italic">0041D0E6</span>   <span style="color: #0000ff">42</span>               <span style="color: #00007f;font-weight: bold">INC</span> <span style="color: #00007f">EDX</span>
<span style="color: #adadad;font-style: italic">0041D0E7</span>   <span style="color: #0000ff">50</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">EAX</span>
<span style="color: #adadad;font-style: italic">0041D0E8</span>   9D               <span style="color: #00007f;font-weight: bold">POPFD</span>
<span style="color: #adadad;font-style: italic">0041D0E9</span>   <span style="color: #0000ff">58</span>               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EAX</span></pre>
  </div>
</div>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">0041D4AA</span>   5A               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EDX</span>                &lt;<span style="color: #339933">----</span> <span style="color: #00007f;font-weight: bold">pop</span> EIP <span style="color: #009900;font-weight: bold">(</span>jcc <span style="color: #00007f;font-weight: bold">not</span> taken<span style="color: #009900;font-weight: bold">)</span>
<span style="color: #adadad;font-style: italic">0041D4AB</span>   <span style="color: #0000ff">58</span>               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EAX</span>
<span style="color: #adadad;font-style: italic">0041D4AC</span>  ^E9 2CFFFFFF      <span style="color: #00007f;font-weight: bold">JMP</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D3DD
<span style="color: #adadad;font-style: italic">0041D4B1</span>   0FB657 <span style="color: #0000ff">03</span>        <span style="color: #00007f;font-weight: bold">MOVZX</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="font-weight: bold">BYTE</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EDI</span><span style="color: #339933">+</span><span style="color: #0000ff">3</span><span style="color: #009900;font-weight: bold">]</span>
<span style="color: #adadad;font-style: italic">0041D4B5</span>   FF7424 <span style="color: #0000ff">08</span>        <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="font-weight: bold">DWORD</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">SS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">ESP</span><span style="color: #339933">+</span><span style="color: #0000ff">8</span><span style="color: #009900;font-weight: bold">]</span>
<span style="color: #adadad;font-style: italic">0041D4B9</span>   9D               <span style="color: #00007f;font-weight: bold">POPFD</span>
<span style="color: #adadad;font-style: italic">0041D4BA</span>   E8 41FBFFFF      <span style="color: #00007f;font-weight: bold">CALL</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D000
<span style="color: #adadad;font-style: italic">0041D4BF</span>   85D2             <span style="color: #00007f;font-weight: bold">TEST</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="color: #00007f">EDX</span>
<span style="color: #adadad;font-style: italic">0041D4C1</span>  ^<span style="color: #0000ff">74</span> E7            <span style="color: #00007f;font-weight: bold">JE</span> <span style="font-weight: bold">SHORT</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D4AA
<span style="color: #adadad;font-style: italic">0041D4C3</span>   5A               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EDX</span>
<span style="color: #adadad;font-style: italic">0041D4C4</span>   <span style="color: #0000ff">0357</span> <span style="color: #0000ff">04</span>          <span style="color: #00007f;font-weight: bold">ADD</span> <span style="color: #00007f">EDX</span><span style="color: #339933">,</span><span style="font-weight: bold">DWORD</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EDI</span><span style="color: #339933">+</span><span style="color: #0000ff">4</span><span style="color: #009900;font-weight: bold">]</span> &lt;<span style="color: #339933">---</span> increment EIP <span style="color: #009900;font-weight: bold">(</span>jcc taken<span style="color: #009900;font-weight: bold">)</span>
<span style="color: #adadad;font-style: italic">0041D4C7</span>   <span style="color: #0000ff">034F</span> <span style="color: #0000ff">04</span>          <span style="color: #00007f;font-weight: bold">ADD</span> <span style="color: #00007f">ECX</span><span style="color: #339933">,</span><span style="font-weight: bold">DWORD</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EDI</span><span style="color: #339933">+</span><span style="color: #0000ff">4</span><span style="color: #009900;font-weight: bold">]</span>
<span style="color: #adadad;font-style: italic">0041D4CA</span>   <span style="color: #0000ff">58</span>               <span style="color: #00007f;font-weight: bold">POP</span> <span style="color: #00007f">EAX</span>
<span style="color: #adadad;font-style: italic">0041D4CB</span>  ^E9 5AFEFFFF      <span style="color: #00007f;font-weight: bold">JMP</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D32A</pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <strong>[edi+4] = 00000104</strong>
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">0041D32A</span>   8BF2             <span style="color: #00007f;font-weight: bold">MOV</span> <span style="color: #00007f">ESI</span><span style="color: #339933">,</span><span style="color: #00007f">EDX</span>
<span style="color: #adadad;font-style: italic">0041D32C</span>   <span style="color: #0000ff">46</span>               <span style="color: #00007f;font-weight: bold">INC</span> <span style="color: #00007f">ESI</span>
<span style="color: #adadad;font-style: italic">0041D32D</span>   8A02             <span style="color: #00007f;font-weight: bold">MOV</span> <span style="color: #00007f">AL</span><span style="color: #339933">,</span><span style="font-weight: bold">BYTE</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EDX</span><span style="color: #009900;font-weight: bold">]</span>           &lt;<span style="color: #339933">---</span> <span style="font-weight: bold">size</span> of next instruction
<span style="color: #adadad;font-style: italic">0041D32F</span>   <span style="color: #0000ff">3242</span> <span style="color: #0000ff">01</span>          <span style="color: #00007f;font-weight: bold">XOR</span> <span style="color: #00007f">AL</span><span style="color: #339933">,</span><span style="font-weight: bold">BYTE</span> <span style="font-weight: bold">PTR</span> <span style="color: #00007f">DS</span><span style="color: #339933">:</span><span style="color: #009900;font-weight: bold">[</span><span style="color: #00007f">EDX</span><span style="color: #339933">+</span><span style="color: #0000ff">1</span><span style="color: #009900;font-weight: bold">]</span>         &lt;<span style="color: #339933">---</span> <span style="color: #00007f;font-weight: bold">xor</span> 1st <span style="color: #0000ff">2</span> bytes to get proper sie
<span style="color: #adadad;font-style: italic">0041D332</span>   0FB6C0           <span style="color: #00007f;font-weight: bold">MOVZX</span> <span style="color: #00007f">EAX</span><span style="color: #339933">,</span><span style="color: #00007f">AL</span>
<span style="color: #adadad;font-style: italic">0041D335</span>   <span style="color: #0000ff">50</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">EAX</span>                           &lt;<span style="color: #339933">---</span> <span style="font-weight: bold">size</span> of instruction passed to memcpy
<span style="color: #adadad;font-style: italic">0041D336</span>   <span style="color: #0000ff">56</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">ESI</span>
<span style="color: #adadad;font-style: italic">0041D337</span>   <span style="color: #0000ff">57</span>               <span style="color: #00007f;font-weight: bold">PUSH</span> <span style="color: #00007f">EDI</span>
<span style="color: #adadad;font-style: italic">0041D338</span>   E8 D8050000      <span style="color: #00007f;font-weight: bold">CALL</span> <span style="color: #00007f;font-weight: bold">test</span><span style="color: #339933">.</span>0041D915                 &lt;<span style="color: #339933">---</span> memcpy</pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <strong>BOOM Exception</strong>
</p>

<div style="font-family: sans-serif;font-size: 13px;text-align: left" dir="ltr">
  <div style="line-height: normal;font-family: monospace">
    <pre style="font-family: monospace, 'Courier New';background-color: initial;font: normal normal normal 1em/1.2em monospace;margin-top: 0px;margin-bottom: 0px;vertical-align: top;padding: 0px;border: 0px none white"><span style="color: #adadad;font-style: italic">0041DB10</span>  <span style="color: #0000ff">25</span> <span style="color: #0000ff">93</span> <span style="color: #0000ff">97</span> B6 C4 C5 <span style="color: #0000ff">89</span> 8A                          <span style="color: #339933">%</span>“—¶ÄÅ‰Š</pre>
  </div>
</div>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Instruction size is calculated as <strong>25 ^ 93 = B6</strong> which is wrong for instruction size in this case.
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  At this point I decided to try and patch jcc vm handler so jcc will not be taken:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Patch.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/6/63/Patch.png" alt="Patch.png" width="399" height="189" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  and then I typed something:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Firstcharacter.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/7/7c/Firstcharacter.png" alt="Firstcharacter.png" width="270" height="81" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  And then I just kept pressing keys:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Okunlocked.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/8/85/Okunlocked.png" alt="Okunlocked.png" width="270" height="83" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  Press <strong>OK</strong> and you get the key:
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <a style="text-decoration: none;color: #0b0080;background-color: initial" href="http://www.xchg.info/wiki/index.php?title=File:Finalkey.png"><img style="vertical-align: middle;margin: 0px;border: initial none initial" src="http://www.xchg.info/wiki/images/2/21/Finalkey.png" alt="Finalkey.png" width="269" height="83" /></a>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  So correct key for bin400 is : <strong>WonderFul_lollol_!</strong>
</p>

<p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
  <h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
    <span id="Greetings">Greetings</span>
  </h3>
  
  <p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
    I would like to say tnx to my <strong>ARTeam</strong> mates, <strong>vnsecurity</strong> guys, and of course<strong>superkhung</strong> for listening to my random blabing on skype during CTF :)
  </p>
  
  <h3 style="margin-top: 0px;margin-right: 0px;margin-bottom: 0.3em;margin-left: 0px;padding-top: 0.5em;padding-bottom: 0.17em;border-bottom-width: initial;border-bottom-style: none;border-bottom-color: initial;width: auto;font-size: 17px;font-family: sans-serif">
    <span id="Author">Author</span>
  </h3>
  
  <p style="margin-top: 0.4em;margin-right: 0px;margin-bottom: 0.5em;margin-left: 0px;font-family: sans-serif;font-size: 13px">
    <strong>deroko of ARTeam</strong>
  </p>
  
  <div>
    <strong><br /> </strong>
  </div>