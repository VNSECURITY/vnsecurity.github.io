---
title: Interesting Arithmetic Assembly Sequences
author: lamer
excerpt: |
  |
    Microsoft Visual C Compiler generates some interesting assembly instructions for common operations such as multiplication with, taking remainder and quotient by constants, especially powers of 2.
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
tweetbackscheck:
  - 1408359081
shorturls:
  - 'a:4:{s:9:"permalink";s:76:"http://www.vnsecurity.net/2007/05/interesting-arithmetic-assembly-sequences/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydfxd97";s:4:"isgd";s:18:"http://is.gd/aOuec";s:5:"bitly";s:0:"";}'
category:
  - research
---
All examples below use signed integers.

<div class="section" id="multiplication-with-a-power-of-2">
  <h3>
    <a name="multiplication-with-a-power-of-2">Multiplication with a power of 2</a>
  </h3>
  
  <p>
    We all know <tt class="docutils literal"><span class="pre">shl</span></tt> is normally used to multiply a number with a power of 2. This sequence uses <tt class="docutils literal"><span class="pre">lea</span></tt> instruction instead.
  </p>
  
  <div class="section" id="the-asm-code">
    <h4>
      <a name="the-asm-code">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   eax, DWORD PTR _a$[esp+52]  ; eax takes value of a lea   ecx, DWORD PTR [eax*8]      ; ecx takes value of a * 8 </pre></p>
  </div>
  
  <div class="section" id="the-c-code">
    <h4>
      <a name="the-c-code">The C code</a>
    </h4>
    
    <pre class="literal-block"> a * 8; </pre></p>
  </div></p>
</div>

<div class="section" id="multiplication-with-a-constant">
  <h3>
    <a name="multiplication-with-a-constant">Multiplication with a constant</a>
  </h3>
  
  <p>
    The compiler will try to fit the multiplication with <tt class="docutils literal"><span class="pre">lea</span></tt> and <tt class="docutils literal"><span class="pre">add</span></tt> instructions.
  </p>
  
  <div class="section" id="id1">
    <h4>
      <a name="id1">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   eax, DWORD PTR _a$[esp+28]  ; eax takes value of a lea   ecx, DWORD PTR [eax+eax*2]  ; ecx = eax * 3 add   ecx, ecx                    ; ecx = ecx * 2 (or, eax * 6) </pre></p>
  </div>
  
  <div class="section" id="id2">
    <h4>
      <a name="id2">The C code</a>
    </h4>
    
    <pre class="literal-block"> a * 6; </pre></p>
  </div></p>
</div>

<div class="section" id="taking-quotient-of-a-division-by-a-power-of-2">
  <h3>
    <a name="taking-quotient-of-a-division-by-a-power-of-2">Taking quotient of a division by a power of 2</a>
  </h3>
  
  <p>
    This sequence is interesting because there is a conditional jump <tt class="docutils literal"><span class="pre">jns</span></tt> instruction.
  </p>
  
  <div class="section" id="id3">
    <h4>
      <a name="id3">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   edx, DWORD PTR _a$[esp+36] and   edx, -2147483641                        ; 80000007H jns   SHORT $LN3&#064;main dec   edx or    edx, -8                                 ; fffffff8H inc   edx $LN3&#064;main: ; here edx takes the value of the quotient </pre></p>
  </div>
  
  <div class="section" id="id4">
    <h4>
      <a name="id4">The C code</a>
    </h4>
    
    <pre class="literal-block"> a % 8; </pre></p>
  </div></p>
</div>

<div class="section" id="taking-remainder-of-a-division-by-a-power-of-2">
  <h3>
    <a name="taking-remainder-of-a-division-by-a-power-of-2">Taking remainder of a division by a power of 2</a>
  </h3>
  
  <p>
    There is only one shift instruction <tt class="docutils literal"><span class="pre">sar</span></tt> in this sequence.
  </p>
  
  <div class="section" id="id5">
    <h4>
      <a name="id5">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   eax, DWORD PTR _a$[esp+44] cdq and   edx, 7 add   eax, edx sar   eax, 3 ; here eax takes the value of the remainder </pre></p>
  </div>
  
  <div class="section" id="id6">
    <h4>
      <a name="id6">The C code</a>
    </h4>
    
    <pre class="literal-block"> a / 8; </pre></p>
  </div></p>
</div>

<div class="section" id="taking-remainder-of-a-division-by-a-constant">
  <h3>
    <a name="taking-remainder-of-a-division-by-a-constant">Taking remainder of a division by a constant</a>
  </h3>
  
  <p>
    Notice that <tt class="docutils literal"><span class="pre">2aaaaaabH</span></tt> is 2^32 / 6.
  </p>
  
  <div class="section" id="id7">
    <h4>
      <a name="id7">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   ecx, DWORD PTR _c$[esp+20] 
    mov   eax, 715827883                          ; 2aaaaaabH imul  ecx mov   eax, edx shr   eax, 31                                 ; 0000001fH add   eax, edx </pre></p>
  </div>
  
  <div class="section" id="id8">
    <h4>
      <a name="id8">The C code</a>
    </h4>
    
    <pre class="literal-block"> c / 6 </pre></p>
  </div></p>
</div>

<div class="section" id="taking-quotient-of-a-division-by-a-constant">
  <h3>
    <a name="taking-quotient-of-a-division-by-a-constant">Taking quotient of a division by a constant</a>
  </h3>
  
  <p>
    First, take the remainder. Then substract the original value with the multiplication of remainder and constant.
  </p>
  
  <div class="section" id="id9">
    <h4>
      <a name="id9">The ASM code</a>
    </h4>
    
    <pre class="literal-block"> mov   ecx, DWORD PTR _c$[esp+12] mov   eax, 715827883                          ; 2aaaaaabH imul  ecx mov   eax, edx shr   eax, 31                                 ; 0000001fH add   eax, edx lea   edx, DWORD PTR [eax+eax*2] add   edx, edx sub   ecx, edx </pre></p>
  </div>
  
  <div class="section" id="id10">
    <h4>
      <a name="id10">The C code</a>
    </h4>
    
    <pre class="literal-block"> c % 6 </pre></p>
  </div></p>
</div>