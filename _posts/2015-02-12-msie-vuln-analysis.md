---
title: 'Microsoft Internet Explorer 9-11 Windows 7-8.1 Vulnerability (patched in late 2014) '
author: suto
layout: post
thumbnail: /assets/2015/02/ie.png
excerpt: In late 2014, Microsoft patched a bug related to unitialized memory corruption that leads to code execution. Here's my attempt to reproduce the bug.
category: research
tags:
  - Reverse Engineering
  - bug
  - Exploitation
---
**I. Vunerability Description:**

Uninitialized Memory Corruption Lead to Code Execution.

**II.Analysis:**
I crafted an HTML file called `1.html` and opened it with IE11/Windows 8.1, the following crash happened:

<img alt="Crash" src="http://vnsecurity.net/assets/2015/02/1.png"  width="600px" />

The call tree lead to there :

<img alt="Call Tree" src="http://vnsecurity.net/assets/2015/02/2.png"  width="400px" />


The root cause of problem is wrong assumtion and memory not clearly reset.
When execute javascript line:

     document.getElementsByTagName('tr')[0].insertCell();
   
The function CTableRowLayout::EnsureCells will be called:

<img alt="IDA" src="http://vnsecurity.net/assets/2015/02/3.png"  width="500px" />

Because adding a cell to row, it need to expand the memory to hold new row.
First it will reAlloc memory in CimplAry::EnsureSizeWorker to enough for new tableRowLayout. The function success alloc memory as below:

<img alt="Ensure Mem" src="http://vnsecurity.net/assets/2015/02/4.png"  width="500px" />

But it never reset memory to zero:

The line:

    while ( v2 > v4 )
      {
        --v2;
        *(_DWORD *)(*(_DWORD *)(v3 + 76) + 4 * v2) = 1;
      }

Will mark if it exist a cell in that row. And the memory at the moment will be likely:

0xheap: 0x1 0x1 0x1 ....... 0xc0c0c0c0

The value 0xc0c0c0c0 is from uninitialized memory. So if we parepare some holes in memory by our string fit with that size, freed before it reallocate our value will be in that location like below ( when our string is 0x40404040 )

<img alt="Controlled " src="http://vnsecurity.net/assets/2015/02/5.png" width="800px" />


That happend because when javascript trying to add a new Row to Table:

  document.getElementsByTagName('table')[0].insertRow();



But that piece of above memory will never be reset to 1 to indicate that has a cell in there. So after all, IE will trying to access that address,It saw our value as a Pointer to a Table's Cell Object in Heap. From there it will calculation and Change some memory, with can be lead to
Write to controlled memory and highly possible lead to bypass ASLR ( if the address 
overwrote is Array Lenght ) and Code execution.


For full PoC code please email to suto@vnsecurity.net
Happy hunting :)
