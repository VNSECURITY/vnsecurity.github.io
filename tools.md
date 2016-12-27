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
List of tools published by VNSECURITY members. Copyright and all rights therein are maintained by the authors or by other copyright holders.

### Capstone - The Ultimate Disassembler

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


### Keystone - The Ultimate Assembler

Author: Nguyen Anh Quynh 

URL: <http://www.keystone-engine.org/>

Keystone is a lightweight multi-platform, multi-architecture assembler framework.

Highlight features:

* Multi-architecture, with support for Arm, Arm64 (AArch64/Armv8), Hexagon, Mips, PowerPC, Sparc, SystemZ, & X86 (include 16/32/64bit).
* Clean/simple/lightweight/intuitive architecture-neutral API.
* Implemented in C/C++ languages, with bindings for PowerShell, Perl, Python, NodeJS, Ruby, Go, Rust, Haskell & OCaml available.
* Native support for Windows & *nix (with Mac OSX, Linux, *BSD & Solaris confirmed).
* Thread-safe by design.
* Open source.


### Keypatch - The award winning plugin of IDA Pro 

Author: Nguyen Anh Quynh, Thanh Nguyen 

URL: <http://www.keystone-engine.org/keypatch/>

Sometimes we want to patch the binary while analyzing it in IDA, but unfortunately the built-in asssembler of IDA Pro is not adequate.

* Only X86 assembler is available. Support for all other architectures is totally missing.
* The X86 assembler is not in a good shape, either: it cannot understand many modern Intel instructions.
* This tool is not friendly and without many options that would make reverser’s life easier.

Keypatch is the award winning plugin of IDA Pro for Keystone Assembler Engine. Thanks to the power of Keystone, our plugin offers some superior features.

* More friendly & easier to use.
* Cross-architecture: support Arm, Arm64 (AArch64/Armv8), Hexagon, Mips, PowerPC, Sparc, SystemZ & X86 (include 16/32/64bit).
* Cross-platform: work everywhere that IDA works, which is on Windows, MacOS, Linux.
* Based on Python, so it is easy to install as no compilation is needed.
* Open source under GPL v2.

*Keypatch is confirmed to work on IDA Pro version 6.4, 6.5, 6.6, 6.8, 6.9, 6.95 but should work flawlessly on older versions*


### Unicorn - The ultimate CPU emulator

Author: Nguyen Anh Quynh, Dang Hoang Vu 

URL: <http://www.unicorn-engine.org/>

Unicorn is a lightweight multi-platform, multi-architecture CPU emulator framework.

Highlight features:

* Multi-architectures: Arm, Arm64 (Armv8), M68K, Mips, Sparc, & X86 (include X86_64).
* Clean/simple/lightweight/intuitive architecture-neutral API.
* Implemented in pure C language, with bindings for Perl, Rust, Haskell, Ruby, Python, Java, Go, .NET, Delphi/Pascal & MSVC available.
* Native support for Windows & *nix (with Mac OSX, Linux, *BSD & Solaris confirmed).
* High performance by using Just-In-Time compiler technique.
* Support fine-grained instrumentation at various levels.
* Thread-safe by design.
* Distributed under free software license GPLv2.


### PEDA - Python Exploit Development Assistance for GDB

Author: longld aka xichzo  

URL: <https://github.com/longld/peda>

PEDA is a Python Exploit Development Assistance for GDB

Key Features:

* Enhance the display of gdb: colorize and display disassembly codes, registers, memory information during debugging.
* Add commands to support debugging and exploit development (for a full list of commands use `peda help`):
  * `aslr` -- Show/set ASLR setting of GDB
  * `checksec` -- Check for various security options of binary
  * `dumpargs` -- Display arguments passed to a function when stopped at a call instruction
  * `dumprop` -- Dump all ROP gadgets in specific memory range
  * `elfheader` -- Get headers information from debugged ELF file
  * `elfsymbol` -- Get non-debugging symbol information from an ELF file
  * `lookup` -- Search for all addresses/references to addresses which belong to a memory range
  * `patch` -- Patch memory start at an address with string/hexstring/int
  * `pattern` -- Generate, search, or write a cyclic pattern to memory
  * `procinfo` -- Display various info from /proc/pid/
  * `pshow` -- Show various PEDA options and other settings
  * `pset` -- Set various PEDA options and other settings
  * `readelf` -- Get headers information from an ELF file
  * `ropgadget` -- Get common ROP gadgets of binary or library
  * `ropsearch` -- Search for ROP gadgets in memory
  * `searchmem|find` -- Search for a pattern in memory; support regex search
  * `shellcode` -- Generate or download common shellcodes.
  * `skeleton` -- Generate python exploit code template
  * `vmmap` -- Get virtual mapping address ranges of section(s) in debugged process
  * `xormem` -- XOR a memory region with a key
  

### OllyDbg plugin: Catcha! v1.1 – Catcha anywher

Author: [mikado][1]  

URL: <http://www.openrce.org/downloads/details/246/Catcha!>

Sometimes you don&#8217;t know how to start a program correctly from OllyDgb. Catcha! plugin will help you to attach to your program automatically as soon as possible each time your program runs (outside OllyDbg).

It works like Olly De-Attach Helper plugin. Catcha! has more advantages than Olly De-Attach Helper. It helps reversers reach the target program EntryPoint by hooking the EntryPoint to a trap function that raises debug exception by INT3 instruction so we can break into that function before attaching and returning to the EntryPoint.


### ROPEME &#8211; ROP Exploit Made Easy

Author: [longld][2]  

URL: <http://www.vnsecurity.net/2010/08/ropeme-rop-exploit-made-easy/>

ROPEME – ROP Exploit Made Easy – is a PoC tool for ROP exploit automation on Linux x86.

 [1]: /author/mikado/
 [2]: /author/longld/
