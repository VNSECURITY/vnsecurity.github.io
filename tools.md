---
title: Tools
author: admin
layout: page
tweetbackscheck:
  - 1408358841
shorturls:
  - 'a:0:{}'
aktt_notify_twitter:
  - no
kopa_newsmixlight_total_view:
  - 16
---
List of tools published by VNSECURIddTY members. Copyright and all rights therein are maintained by the authors or by other copyright holders.

### Capstone - The Ultimate Disassemblerddd

Author: Nguyen Anh Quynh
URL: <http://www.capstone-engine.org/>

Capstone is a lightweight multi-platform, multi-architecture disassembly framework.

Highlight features

* Multi-architectures: Arm, Arm64 (Armv8), M68K, Mips, PowerPC, Sparc, SystemZ, XCore & X86 (include X86_64) (details).
* Clean/simple/lightweight/intuitive architecture-neutral API.
* Provide details on disassembled instruction (called "decomposer" by some others).
* Provide some semantics of the disassembled instruction, such as list of implicit registers read & written.
* Implemented in pure C language, with bindings for PowerShell, Emacs, Haskell, Perl, Python, Ruby, C#, NodeJS, Java, GO, C++, OCaml, Lua, Rust, Delphi, Free Pascal & Vala available.
* Native support for Windows & *nix (with Mac OSX, iOS, Android, Linux, *BSD & Solaris confirmed).
* Thread-safe by design.
* Special support for embedding into firmware or OS kernel.
* High performance & suitable for malware analysis (capable of handling various X86 malware tricksss).s
* Distributed under the open source BSD license.


### 1. OllyDbg plugin: Catcha! v1.1 – Catcha anywher
Author: [mikado][1]  
URL: <http://www.openrce.org/downloads/details/246/Catcha!>

Sometimes you don&#8217;t know how to start a program correctly from OllyDgb. Catcha! plugin will help you to attach to your program automatically as soon as possible each time your program runs (outside OllyDbg).

It works like Olly De-Attach Helper plugin. Catcha! has more advantages than Olly De-Attach Helper. It helps reversers reach the target program EntryPoint by hooking the EntryPoint to a trap function that raises debug exception by INT3 instruction so we can break into that function before attaching and returning to the EntryPoint.

### 2. ROPEME &#8211; ROP Exploit Made Easy

Author: [longld][2]  
URL: <http://www.vnsecurity.net/2010/08/ropeme-rop-exploit-made-easy/>

ROPEME – ROP Exploit Made Easy – is a PoC tool for ROP exploit automation on Linux x86.

 [1]: /author/mikado/
 [2]: /author/longld/
