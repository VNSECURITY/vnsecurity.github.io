---
title: CodeGate 2010 Challenge 2 – Xbox pwned
author: rd
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:5:{s:9:"permalink";s:70:"http://www.vnsecurity.net/2010/03/codegate-2010-challenge2-xbox-pwned/";s:7:"tinyurl";s:26:"http://tinyurl.com/y98gbjb";s:4:"isgd";s:18:"http://is.gd/aOuhH";s:5:"bitly";s:20:"http://bit.ly/9hweNg";s:6:"google";s:18:"http://goo.gl/KK1Z";}'
tweetbackscheck:
  - 1408358981
twittercomments:
  - 'a:10:{i:10711446023;s:7:"retweet";i:10706087742;s:7:"retweet";i:10705298814;s:7:"retweet";i:10703892923;s:7:"retweet";i:10702999269;s:7:"retweet";i:10700935825;s:7:"retweet";i:10700882633;s:7:"retweet";i:10700271595;s:7:"retweet";i:10698154481;s:7:"retweet";i:10395952627;s:7:"retweet";}'
tweetcount:
  - 10
category:
  - 'CTF - CLGT Crew'
tags:
  - '2010'
  - CLGT
  - codegate
  - TEA
  - Xbox
---
# Summary

This is the most interesting challenge in CodeGate 2010 IMHO. The binary is a VM which loads the *&#8216;codefile&#8217;* and execute it. The VM *codefile* is protected from being tampered with a TEA based hash algorithm. By exploiting the weakness of hash algorithm (similar to Xbox hack) together with a bug inside VM, we could change the execution flow of VM code to get back the secret key content.

# Analysis

Challenge information

> credentials: ssh hugh@ctf4.codegate.org -p 9474 password=takeitaway  
> Exploit /home/hugh/yboy to read secret.key

There are *yboy*, *codefile* and *secret.key* files in the home directory of hugh (you can download these files [here][1] if you want to try it by yourself)

> -rw-r&#8211;r&#8211; 1 codegate codegate 1136 2010-03-12 14:45 codefile  
> -r&#8212;&#8212;&#8211; 1 daryl daryl 140 2010-03-12 15:27 secret.key  
> -rwsr-xr-x 1 daryl root 22307 2010-03-12 16:07 yboy

### a. Reverse Engineering yboy

*yboy* basically does the following things

*   load VM codes from the codefile into memory (code[])
*   load content of secret.key into memory (data[])
*   check for the integrity of codefile using TEA based hash algorithm against a hard-coded hash value. Exit if the hash not matched
*   parse/decode loaded VM codes and execute it accordingly

For the VM code inside codefile

*   ask user to input password
*   compare the input with flag inside secret.key
*   if correct, print out the flag
*   otherwise, print out access denied error and exit

**b. Decompiler for codefile**

Since *yboy* load VM code from *codefile* and execute it, I wrote a decompiler for it

<pre class="brush: cpp; title: ; notranslate" title="">#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;

unsigned char *decode[32] = {
        "halt", "push", "pop", "add", "sub", "or", "xor", "nor", "shl",
        "shr", "not", "nop", "branch", "jumpreg", "callreg", "load",
        "store", "halt", "inputchar", "outputchar", "set_imm", "reload",
        "rrandom", "nop", "nop", "nop", "nop", "nop", "nop", "nop", "nop",
        "nop",
};

unsigned long registers[64];
unsigned long code[32768];
unsigned int PC;

int main(int argc, char **argv)
{
        unsigned int ins;
        unsigned char reg;
        unsigned char imm1, imm2;
        unsigned char opcode;

        unsigned int codesize;
        int set_imm = 1;
        FILE *f;

        f = fopen(argv[1], "r");
        codesize = fread(code, 1, sizeof(code), f);
        fclose(f);
        //check_code();

        PC = 0;
        while (PC &lt; (codesize) / 4) {
                set_imm = 1;
                ins = code[PC];

                opcode = (ins &gt;&gt; 24);   //& 0x1f;
                reg = (ins &gt;&gt; 16) & 0xFF;
                imm1 = (ins &gt;&gt; 8) & 0xFF;
                imm2 = (unsigned char) ins;

                // set_imm
                if (opcode == 20) {
                        printf("%04x: tr%d = %s %x, %x", PC, reg,
                            decode[opcode & 0x1f], imm1, imm2);

                        if (imm2 && !imm1)
                                printf("t; %c", imm2);
                        else if (imm1)
                                printf("t; %04x", imm2 + (imm1 &lt;&lt; 8));

                        printf("n");
                        PC++;
                        continue;
                }

                reg = (ins &gt;&gt; 16) & 0xBF;
                imm1 = (ins &gt;&gt; 8) & 0xBF;
                imm2 = ins & 0xBF;

                printf("%04x: tr%d = %s r%d, r%d", PC, reg,
                    decode[opcode & 0x1f], imm1, imm2);

                if (opcode == 12)       // comment for branch
                        printf("t; if (r%d) goto r%dn", imm1, imm2);
                else
                        printf("n");

                PC++;
        }
        return 0;
}
</pre>

Here is the output of the decompiler (click to open)

<pre class="brush: cpp; collapse: true; light: false; title: ; toolbar: true; notranslate" title="">rd@jps(~/working/ctf/codegate2010/2/)$ ./yboy-decompile codefile
0000:   r1 = set_imm 0, 45      ; E
0001:   r0 = outputchar r1, r0
0002:   r1 = set_imm 0, 6e      ; n
0003:   r0 = outputchar r1, r0
0004:   r1 = set_imm 0, 74      ; t
0005:   r0 = outputchar r1, r0
0006:   r1 = set_imm 0, 65      ; e
0007:   r0 = outputchar r1, r0
0008:   r1 = set_imm 0, 72      ; r
0009:   r0 = outputchar r1, r0
000a:   r1 = set_imm 0, 20      ;
000b:   r0 = outputchar r1, r0
000c:   r1 = set_imm 0, 70      ; p
000d:   r0 = outputchar r1, r0
000e:   r1 = set_imm 0, 61      ; a
000f:   r0 = outputchar r1, r0
0010:   r1 = set_imm 0, 73      ; s
0011:   r0 = outputchar r1, r0
0012:   r1 = set_imm 0, 73      ; s
0013:   r0 = outputchar r1, r0
0014:   r1 = set_imm 0, 77      ; w
0015:   r0 = outputchar r1, r0
0016:   r1 = set_imm 0, 6f      ; o
0017:   r0 = outputchar r1, r0
0018:   r1 = set_imm 0, 72      ; r
0019:   r0 = outputchar r1, r0
001a:   r1 = set_imm 0, 64      ; d
001b:   r0 = outputchar r1, r0
001c:   r1 = set_imm 0, 3e      ; &gt;
001d:   r0 = outputchar r1, r0
001e:   r1 = set_imm 0, 3e      ; &gt;
001f:   r0 = outputchar r1, r0
0020:   r60 = set_imm 0, ff     ; �
0021:   r61 = set_imm 0, 1      ;
0022:   r4 = set_imm 5, 39      ; 0539
0023:   r3 = inputchar r0, r0
0024:   r50 = set_imm 0, a      ;
0025:   r0 = store r4, r3
0026:   r0 = nop r0, r0
0027:   r10 = sub r3, r50
0028:   r10 = not r10, r0
0029:   r11 = set_imm 0, 2f     ; /
002a:   r0 = branch r10, r11    ; if (r10) goto r11
002b:   r4 = add r61, r4
002c:   r10 = sub r60, r3
002d:   r11 = set_imm 0, 23     ; #
002e:   r0 = branch r10, r11    ; if (r10) goto r11
002f:   r19 = set_imm 5, 39     ; 0539
0030:   r20 = set_imm 0, 0
0031:   r21 = set_imm 0, 23     ; #
0032:   r21 = sub r21, r20
0033:   r21 = not r21, r0
0034:   r22 = set_imm 0, 5e     ; ^
0035:   r0 = branch r21, r22    ; if (r21) goto r22
0036:   r21 = load r20, r0
0037:   r25 = add r19, r20
0038:   r0 = nop r0, r0
0039:   r26 = load r25, r0
003a:   r26 = sub r21, r26
003b:   r22 = set_imm 0, 41     ; A
003c:   r0 = branch r26, r22    ; if (r26) goto r22
003d:   r23 = set_imm 0, 1      ;
003e:   r20 = add r20, r23
003f:   r22 = set_imm 0, 31     ; 1
0040:   r0 = branch r22, r22    ; if (r22) goto r22
0041:   r1 = set_imm 0, 41      ; A
0042:   r0 = outputchar r1, r0
0043:   r1 = set_imm 0, 63      ; c
0044:   r0 = outputchar r1, r0
0045:   r1 = set_imm 0, 63      ; c
0046:   r0 = outputchar r1, r0
0047:   r1 = set_imm 0, 65      ; e
0048:   r0 = outputchar r1, r0
0049:   r1 = set_imm 0, 73      ; s
004a:   r0 = outputchar r1, r0
004b:   r1 = set_imm 0, 73      ; s
004c:   r0 = outputchar r1, r0
004d:   r1 = set_imm 0, 20      ;
004e:   r0 = outputchar r1, r0
004f:   r1 = set_imm 0, 44      ; D
0050:   r0 = outputchar r1, r0
0051:   r1 = set_imm 0, 65      ; e
0052:   r0 = outputchar r1, r0
0053:   r1 = set_imm 0, 6e      ; n
0054:   r0 = outputchar r1, r0
0055:   r1 = set_imm 0, 69      ; i
0056:   r0 = outputchar r1, r0
0057:   r1 = set_imm 0, 65      ; e
0058:   r0 = outputchar r1, r0
0059:   r1 = set_imm 0, 64      ; d
005a:   r0 = outputchar r1, r0
005b:   r1 = set_imm 0, a       ;
005c:   r0 = outputchar r1, r0
005d:   r0 = halt r0, r0
005e:   r1 = set_imm 0, 47      ; G
005f:   r0 = outputchar r1, r0
0060:   r1 = set_imm 0, 72      ; r
0061:   r0 = outputchar r1, r0
0062:   r1 = set_imm 0, 65      ; e
0063:   r0 = outputchar r1, r0
0064:   r1 = set_imm 0, 65      ; e
0065:   r0 = outputchar r1, r0
0066:   r1 = set_imm 0, 74      ; t
0067:   r0 = outputchar r1, r0
0068:   r1 = set_imm 0, 7a      ; z
0069:   r0 = outputchar r1, r0
006a:   r1 = set_imm 0, 20      ;
006b:   r0 = outputchar r1, r0
006c:   r1 = set_imm 0, 68      ; h
006d:   r0 = outputchar r1, r0
006e:   r1 = set_imm 0, 61      ; a
006f:   r0 = outputchar r1, r0
0070:   r1 = set_imm 0, 63      ; c
0071:   r0 = outputchar r1, r0
0072:   r1 = set_imm 0, 6b      ; k
0073:   r0 = outputchar r1, r0
0074:   r1 = set_imm 0, 65      ; e
0075:   r0 = outputchar r1, r0
0076:   r1 = set_imm 0, 72      ; r
0077:   r0 = outputchar r1, r0
0078:   r1 = set_imm 0, 73      ; s
0079:   r0 = outputchar r1, r0
007a:   r1 = set_imm 0, 2e      ; .
007b:   r0 = outputchar r1, r0
007c:   r1 = set_imm 0, 20      ;
007d:   r0 = outputchar r1, r0
007e:   r1 = set_imm 0, 4b      ; K
007f:   r0 = outputchar r1, r0
0080:   r1 = set_imm 0, 65      ; e
0081:   r0 = outputchar r1, r0
0082:   r1 = set_imm 0, 65      ; e
0083:   r0 = outputchar r1, r0
0084:   r1 = set_imm 0, 70      ; p
0085:   r0 = outputchar r1, r0
0086:   r1 = set_imm 0, 20      ;
0087:   r0 = outputchar r1, r0
0088:   r1 = set_imm 0, 75      ; u
0089:   r0 = outputchar r1, r0
008a:   r1 = set_imm 0, 70      ; p
008b:   r0 = outputchar r1, r0
008c:   r1 = set_imm 0, 20      ;
008d:   r0 = outputchar r1, r0
008e:   r1 = set_imm 0, 74      ; t
008f:   r0 = outputchar r1, r0
0090:   r1 = set_imm 0, 68      ; h
0091:   r0 = outputchar r1, r0
0092:   r1 = set_imm 0, 65      ; e
0093:   r0 = outputchar r1, r0
0094:   r1 = set_imm 0, 20      ;
0095:   r0 = outputchar r1, r0
0096:   r1 = set_imm 0, 67      ; g
0097:   r0 = outputchar r1, r0
0098:   r1 = set_imm 0, 6f      ; o
0099:   r0 = outputchar r1, r0
009a:   r1 = set_imm 0, 6f      ; o
009b:   r0 = outputchar r1, r0
009c:   r1 = set_imm 0, 64      ; d
009d:   r0 = outputchar r1, r0
009e:   r1 = set_imm 0, 20      ;
009f:   r0 = outputchar r1, r0
00a0:   r1 = set_imm 0, 77      ; w
00a1:   r0 = outputchar r1, r0
00a2:   r1 = set_imm 0, 6f      ; o
00a3:   r0 = outputchar r1, r0
00a4:   r1 = set_imm 0, 72      ; r
00a5:   r0 = outputchar r1, r0
00a6:   r1 = set_imm 0, 6b      ; k
00a7:   r0 = outputchar r1, r0
00a8:   r1 = set_imm 0, 2e      ; .
00a9:   r0 = outputchar r1, r0
00aa:   r1 = set_imm 0, 20      ;
00ab:   r0 = outputchar r1, r0
00ac:   r1 = set_imm 0, 53      ; S
00ad:   r0 = outputchar r1, r0
00ae:   r1 = set_imm 0, 74      ; t
00af:   r0 = outputchar r1, r0
00b0:   r1 = set_imm 0, 61      ; a
00b1:   r0 = outputchar r1, r0
00b2:   r1 = set_imm 0, 79      ; y
00b3:   r0 = outputchar r1, r0
00b4:   r1 = set_imm 0, 20      ;
00b5:   r0 = outputchar r1, r0
00b6:   r1 = set_imm 0, 73      ; s
00b7:   r0 = outputchar r1, r0
00b8:   r1 = set_imm 0, 68      ; h
00b9:   r0 = outputchar r1, r0
00ba:   r1 = set_imm 0, 61      ; a
00bb:   r0 = outputchar r1, r0
00bc:   r1 = set_imm 0, 72      ; r
00bd:   r0 = outputchar r1, r0
00be:   r1 = set_imm 0, 70      ; p
00bf:   r0 = outputchar r1, r0
00c0:   r1 = set_imm 0, 2e      ; .
00c1:   r0 = outputchar r1, r0
00c2:   r1 = set_imm 0, 20      ;
00c3:   r0 = outputchar r1, r0
00c4:   r1 = set_imm 0, 44      ; D
00c5:   r0 = outputchar r1, r0
00c6:   r1 = set_imm 0, 69      ; i
00c7:   r0 = outputchar r1, r0
00c8:   r1 = set_imm 0, 73      ; s
00c9:   r0 = outputchar r1, r0
00ca:   r1 = set_imm 0, 6f      ; o
00cb:   r0 = outputchar r1, r0
00cc:   r1 = set_imm 0, 62      ; b
00cd:   r0 = outputchar r1, r0
00ce:   r1 = set_imm 0, 65      ; e
00cf:   r0 = outputchar r1, r0
00d0:   r1 = set_imm 0, 79      ; y
00d1:   r0 = outputchar r1, r0
00d2:   r1 = set_imm 0, 20      ;
00d3:   r0 = outputchar r1, r0
00d4:   r1 = set_imm 0, 6d      ; m
00d5:   r0 = outputchar r1, r0
00d6:   r1 = set_imm 0, 69      ; i
00d7:   r0 = outputchar r1, r0
00d8:   r1 = set_imm 0, 73      ; s
00d9:   r0 = outputchar r1, r0
00da:   r1 = set_imm 0, 69      ; i
00db:   r0 = outputchar r1, r0
00dc:   r1 = set_imm 0, 6e      ; n
00dd:   r0 = outputchar r1, r0
00de:   r1 = set_imm 0, 66      ; f
00df:   r0 = outputchar r1, r0
00e0:   r1 = set_imm 0, 6f      ; o
00e1:   r0 = outputchar r1, r0
00e2:   r1 = set_imm 0, 72      ; r
00e3:   r0 = outputchar r1, r0
00e4:   r1 = set_imm 0, 6d      ; m
00e5:   r0 = outputchar r1, r0
00e6:   r1 = set_imm 0, 61      ; a
00e7:   r0 = outputchar r1, r0
00e8:   r1 = set_imm 0, 74      ; t
00e9:   r0 = outputchar r1, r0
00ea:   r1 = set_imm 0, 69      ; i
00ec:   r1 = set_imm 0, 6f      ; o
00ed:   r0 = outputchar r1, r0
00ee:   r1 = set_imm 0, 6e      ; n
00ef:   r0 = outputchar r1, r0
00f0:   r1 = set_imm 0, 2e      ; .
00f1:   r0 = outputchar r1, r0
00f2:   r1 = set_imm 0, a       ;
00f3:   r0 = outputchar r1, r0
00f4:   r1 = set_imm 0, 59      ; Y
00f5:   r0 = outputchar r1, r0
00f6:   r1 = set_imm 0, 6f      ; o
00f7:   r0 = outputchar r1, r0
00f8:   r1 = set_imm 0, 75      ; u
00f9:   r0 = outputchar r1, r0
00fa:   r1 = set_imm 0, 72      ; r
00fb:   r0 = outputchar r1, r0
00fc:   r1 = set_imm 0, 20      ;
00fd:   r0 = outputchar r1, r0
00fe:   r1 = set_imm 0, 66      ; f
00ff:   r0 = outputchar r1, r0
0100:   r1 = set_imm 0, 6c      ; l
0101:   r0 = outputchar r1, r0
0102:   r1 = set_imm 0, 61      ; a
0103:   r0 = outputchar r1, r0
0104:   r1 = set_imm 0, 67      ; g
0105:   r0 = outputchar r1, r0
0106:   r1 = set_imm 0, 20      ;
0107:   r0 = outputchar r1, r0
0108:   r1 = set_imm 0, 69      ; i
0109:   r0 = outputchar r1, r0
010a:   r1 = set_imm 0, 73      ; s
010b:   r0 = outputchar r1, r0
010c:   r1 = set_imm 0, 3a      ; :
010d:   r0 = outputchar r1, r0
010e:   r1 = set_imm 0, 20      ;
010f:   r0 = outputchar r1, r0
0110:   r29 = set_imm 0, 1      ;
0111:   r30 = xor r30, r30
0112:   r1 = load r30, r0
0113:   r0 = outputchar r1, r0
0114:   r30 = add r29, r30
0115:   r31 = set_imm 0, 26     ; &
0116:   r31 = sub r30, r31
0117:   r32 = set_imm 1, 12     ; 0112
0118:   r0 = branch r31, r32    ; if (r31) goto r32
0119:   r1 = set_imm 0, a       ;
011a:   r0 = outputchar r1, r0
011b:   r0 = halt r0, r0
</pre>

Pseudo C code of the decompiled *codefile*

<pre class="brush: cpp; title: ; notranslate" title="">// data is an int array - int data[0x2000/4]
// the first 140 bytes of data store the content of "secret.key" file
printf("Enter password&gt;&gt;");
r4 = 1337;
while (!EOF) {
        r3 = getc();
        data[r4] = r3;
        if (r3 == 'n') break;
        r4++;
}
r19 = 1337;
r20 = 0;
while (1) {
        if (r20 == 0x23) goto correctpass;
        if (data[r20] != data[r19+r20]) goto wrongpass;
        r20++;
}

wrongpass:
printf("Access Deniedn");
exit(0);

correctpass:
printf("Greetz hackers. Keep up the good work. Stay sharp. Disobey misinformation.n");
printf("Your flag is: ");
for(i=0; i&lt;0x26; i++)
        print("%c", data[i]);
printf("n");
</pre>

### c. Xbox&#8217;s TEA hash collision

From the decompiled VM code above, if we could modify the content of *codefile*, it would be possible to print out the flag inside secret.key stored at *data[0]*. However, the *codefile* is protected from being tampered with a hash algorithm.

<pre class="brush: cpp; title: ; notranslate" title="">int
check_code()
{
        int result;
        unsigned int v1;
        unsigned int v2;
        unsigned int i;

        hash_block(0x99999999, 0xBBBBBBBB, 0x44444444, 0x55555555, code[0],
            code[1], &v2, &v1);

        for (i = 2; i &lt;= 32766; i += 2)
                hash_block(v2, v1, v2, v1, code[i], code[i + 1], (int *) &v2,
                    (int *) &v1);

        if (v2 != 0x1EC0A9F0 || (result = v1, v1 != 0x9217F034)) {
                puts("Tampering detected. Prepare for imminent arrest.");
                exit(0);
        }
        return result;
}
</pre>

Google the constant **0x61C88647** and searching around, I found that it&#8217;s a TEA based hash algorithm. Using TEA hash is bad and there is a weakness in the algorithm in which by flipping the 32nd and 64th bit of a 64 bits block, the hash value will remain the same. <a href="http://www.xbox-linux.org/wiki/17_Mistakes_Microsoft_Made_in_the_Xbox_Security_System#The_TEA_Hash" target="_blank">Xbox was hacked</a> because of this one. (*Actually I didn&#8217;t know about Xbox&#8217;s TEA bits flipping attack. I found this collision by writing a tool doing the brute force on bits flipping of 64 bits block to find the collision. Later, I realized that Yboy is Xbox with two bits flipped*)

Now, the next problem is to find how *codefile* should be patched to print out the flag.

### d. Branch instruction handing bug

The 32nd and 64th bit of a 64 bits block are MSB bits of the opcode field of two consequence instructions. Since the code only uses the least 05 bits in opcode for instruction decode, changing the MSB of the opcode won&#8217;t affect the instruction decode part. However, there is a problem with branch instruction handling code which will help us to modify the behavior of branch.

If we look at the VM parsing code, an instruction (4 byes) structure is as the following

\[ opcode \] \[ output register \] \[ imm1 \] \[ imm2 \]

<pre class="brush: cpp; title: ; notranslate" title="">opcode = (ins &gt;&gt; 24);   //& 0x1f;
                reg = (ins &gt;&gt; 16) & 0xFF;
                imm1 = (ins &gt;&gt; 8) & 0xFF;
                imm2 = (unsigned char) ins;
</pre>

The least 05 bits of opcode are being used as an index to lookup for the corresponding function from the *decode* function table (*decode[opcode & 0x1f]*)

Lets look deeper at the code handling &#8216;branch&#8217; instruction:

<pre class="brush: cpp; title: ; notranslate" title="">int branch(int imm1, int imm2)
{
        if (imm1)
                PC = imm2;
        else
                PC++;
        return 0;
}
</pre>

**Inside main()**

**[<img class="alignnone size-full wp-image-650" title="codegatechal2" src="http://www.vnsecurity.net/wp/storage/uploads/2010/03/codegatechal2.png" alt="codegatechal2" width="500" height="365" />][2]**

As we can see, it only uses the least five bits of opcode* ((ins >> 24) & 0x1f)* for decode while the full byte *(ins >> 24) *is used for comparing later (opcode value for branch is **oxC**).

If we set the MSB of opcode, the opcode would become 0x8c. In this case, the *branch() *function is still being called, however, the *(opcode == 0xC)* check in *main*() will be false and **PC will be increased by 1 unexpectedly**.

### e. Subvert the code flow to print out the flag

Look back at the decompiled VM code

<pre class="brush: cpp; title: ; notranslate" title="">0020:   r60 = set_imm 0, ff     ; r60 = 255
0021:   r61 = set_imm 0, 1      ; r61 = 1
0022:   r4 = set_imm 5, 39      ; r4 = 0x539  (1337)
0023:   r3 = inputchar r0, r0   ; r3 = getc()
0024:   r50 = set_imm 0, a      ; r50 = 'n'
0025:   r0 = store r4, r3          ; data[r4] = r3
0026:   r0 = nop r0, r0
0027:   r10 = sub r3, r50        ; r10 = r3 - 'n'
0028:   r10 = not r10, r0         ; !r10
0029:   r11 = set_imm 0, 2f     ; r11 = 0x002f
002a:   r0 = branch r10, r11    ; if (r3 == 'n') goto 002f
002b:   r4 = add r61, r4           ; r4++
002c:   r10 = sub r60, r3         ; r10 = 255 - r3
002d:   r11 = set_imm 0, 23    ; 0x0023
002e:   r0 = branch r10, r11    ; if (r3 != EOF) goto 0023
002f:   r19 = set_imm 5, 39     ; r19 = 0x539 (1337)
0030:   r20 = set_imm 0, 0      ; r20 = 0
0031:   r21 = set_imm 0, 23    ; r21 = 0x23 (35)
0032:   r21 = sub r21, r20      ; r21 = r21 - r20
0033:   r21 = not r21, r0        ; !r21
0034:   r22 = set_imm 0, 5e     ; 0x005e
0035:   r0 = branch r21, r22    ; if (r20 == 35) goto 005e //goodpassword
0036:   r21 = load r20, r0        ; r21 = data[r20]
0037:   r25 = add r19, r20       ; r25 = 0x539 + r20
0038:   r0 = nop r0, r0
0039:   r26 = load r25, r0        ; r26 = data[0x539 + r20]
003a:   r26 = sub r21, r26        ; r26 = r26 - r21
003b:   r22 = set_imm 0, 41     ; 0x0041
003c:   r0 = branch r26, r22    ; if (data[r20] != data[0x539+r20) goto 0041 //badpassword
003d:   r23 = set_imm 0, 1      ; r23 = 1
003e:   r20 = add r20, r23       ; r20++
003f:   r22 = set_imm 0, 31     ; 0x0032
0040:   r0 = branch r22, r22    ; goto 0032 //loop
</pre>

The code above read password from stdin, stores it inside *data* array starting at *data[0x539] *then compares the input with the content of *secret.key* stored at the beginning of *data[0]* (35 DWORDS = 140 bytes).

*What if we modify the MSB bit of branch instruction at 002a?*

> //modify *code[2a]* from 0x0c000a0b to 0x8c000a0b  
> 002a: r0 = branch r10, r11 ; if (r3 == 'n') goto 002f

When 'n' is read, the branch() instruction will set PC to the password check code at 002f (*002f: r19 = set_imm 5, 39 ; r19 = 0x539*). However, because the opcode now is 0x8c instead of 0x0c, PC will be also increased by 1 unexpectedly due to the bug at main loop code mentioned above. Hence, the PC will point to instruction at 0030 (0*030: r20 = set_imm 0, 0 ; r20 = 0*) instead of 002f.

Since the instruction at 002f is skipped, r19 register will be 0 (default value) instead of 0x539. The VM code becomes

<pre class="brush: cpp; title: ; notranslate" title="">//r19 register value is 0 while it's expected to be 0x539
r20 = 0;
while (1) {
        if (r20 == 0x23) goto correctpass;
        if (data[r20] != data[r19+r20]) goto wrongpass;
        r20++;
}
</pre>

It's comparing identical data. Yboy Pwned!

## Exploit

*   Copy the *codefile*, edit it to set the 32nd and 64th bits at offset 0x2a

> code[2a] 0x0c000a0b -> 0x8c000a0b  
> code[2b] 0x03043d04 -> 0x83043d04

*   Run the yboy with the new codefile
*   Press enter and get the flag

> hugh@codegate-desktop:/tmp/rd$ ./yboy newcodefile  
> ...  
> Enter password>>  
> Greetz hackers. Keep up the good work. Stay sharp. Disobey misinformation.  
> Your flag is: TEA - Toiletpaper Esque Aspirations

## References

*   <a href="http://www.xbox-linux.org/wiki/17_Mistakes_Microsoft_Made_in_the_Xbox_Security_System#The_TEA_Hash" target="_blank">17 Mistakes Microsoft Made in the Xbox Security System</a>

Keywords: TEA, VM, Xbox, codegate 2010

 [1]: http://force.vnsecurity.net/download/rd/yboy.tgz
 [2]: http://www.vnsecurity.net/wp/storage/uploads/2010/03/codegatechal2.png