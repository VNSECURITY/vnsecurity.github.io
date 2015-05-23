---
title: '[writeup] Hacklu 2012 – Challenge #12 – Donn Beach – (500)'
author: olalalili
layout: post

aktt_notify_twitter:
  - no
shorturls:
  - 'a:0:{}'
tweetbackscheck:
  - 1408358962
category: ctf - clgt crew
---
> The famous zombie researcher “Donn Beach” almost created an immunization  
> against the dipsomanie virus. This severe disease leads to the inability to  
> defend against Zombies, later causes a complete loss of memory and finally  
> turns you into one of them. Inexplicably Donn forgot where he put the  
> license key for his centrifuge. Provide him a new one and humanity will owe  
> you a debt of gratitude for fighting one of the most wicked illnesses  
> today.
> 
> https://ctf.fluxfingers.net/challenges/donn_beach.exe
> 
> ctf.fluxfingers.net tcp/2055

First, the executable requires you to enter a name to identify which equals to 0x4B17E245 after being hashed. You can easily bypass this step by patching, but in case you want to know the correct answer, it is **DonnBeach**.

Second, the executable asks for a key with format 11111111-22222222-33333333. The key and the correct name hash are passed to VM-obfuscated functions, transformed and then must equal to four constant values in order to get the flag.

After hours reversing the VM, I rebuilt the code :

<pre class="brush: plain; title: ; notranslate" title="">unsigned char table[] =
"x63x7Cx77x7BxF2x6Bx6FxC5x30x01x67x2BxFExD7xABx76
xCAx82xC9x7DxFAx59x47xF0xADxD4xA2xAFx9CxA4x72xC0
xB7xFDx93x26x36x3FxF7xCCx34xA5xE5xF1x71xD8x31x15
x04xC7x23xC3x18x96x05x9Ax07x12x80xE2xEBx27xB2x75
x09x83x2Cx1Ax1Bx6Ex5AxA0x52x3BxD6xB3x29xE3x2Fx84
x53xD1x00xEDx20xFCxB1x5Bx6AxCBxBEx39x4Ax4Cx58xCF
xD0xEFxAAxFBx43x4Dx33x85x45xF9x02x7Fx50x3Cx9FxA8
x51xA3x40x8Fx92x9Dx38xF5xBCxB6xDAx21x10xFFxF3xD2
xCDx0Cx13xECx5Fx97x17x44xC4xA7x7Ex3Dx64x5Dx19x73
x60x81x4FxDCx22x2Ax90x88x46xEExB8x14xDEx5Ex0BxDB
xE0x32x3Ax0Ax49x06x24x5CxC2xD3xACx62x91x95xE4x79
xE7xC8x37x6Dx8DxD5x4ExA9x6Cx56xF4xEAx65x7AxAEx08
xBAx78x25x2Ex1CxA6xB4xC6xE8xDDx74x1Fx4BxBDx8Bx8A
x70x3ExB5x66x48x03xF6x0Ex61x35x57xB9x86xC1x1Dx9E
xE1xF8x98x11x69xD9x8Ex94x9Bx1Ex87xE9xCEx55x28xDF
x8CxA1x89x0DxBFxE6x42x68x41x99x2Dx0FxB0x54xBBx16";

unsigned int domap( unsigned int number )
{
  unsigned char* buffer = table;

  unsigned int pos;
  unsigned int x = 0;

  for (int i=0; i&lt;4; i++)
  {
    unsigned int tmp = number;
    for (int j=0; j&lt;i; j++)
      tmp = tmp &gt;&gt; 8;
    pos = tmp & 0xFF;
    int y = buffer[pos];
    for (int j=0; j&lt;i; j++)
      y = y &lt;&lt; 8;
    x = x ^ y;
  }

  return x;
}

// Name hash : t ( = 0x4B17E245 )
// Key : x-y-z
void transform(unsigned int& t, unsigned int& x, unsigned int& y, unsigned int& z)
{
  unsigned int tmp;

  for (int i=0 ; i &lt; 2; i++)
  {
    t = domap(t);
    x = domap(x);
    y = domap(y);
    z = domap(z);

    x = (x &lt;&lt; 8) ^ (x &gt;&gt; 24);
    y = (y &lt;&lt; 16) ^ (y &gt;&gt; 16);
    z = (z &lt;&lt; 24) ^ (z &gt;&gt; 8);

    tmp = t;
    t = t ^ x;
    x = x ^ y;
    y = y ^ z;
    z = z ^ tmp;
  }

// Require : t-x-y-z == 01020304-05060708-09101112-0D14151E
}
</pre>

Looking at the code, I happily thought that the easiest option is using Z3py to solve ^0^&#8230; Unfortunately, after hours, i failed to implement the algorithm ( ok, shame on me -_- ) . Then LSE got breakthrough, i started to find another way&#8230; Doing some maths, finally I found a solution :  
- Let&#8217;s call the t,x,y,z before the last xors step as t1, x1, y1, z1 and the fresh t,x,y,z as t0, x0, y0, z0.  
- Assign to t1 ( or x1, y1, z1 ) a random interger, then we can compute t0, x0, y0, z0.  
- There will be a conflict in our way if we assigned a wrong value, so we need to bruteforce t1 ( or x1, t1, z1 ) value.

<pre class="brush: plain; title: ; notranslate" title="">unsigned char findchar(unsigned char x)
{
  for (int i=0; i&lt;256; i++)
    if (table[i] == x)
    {
      return i;
    }
}

unsigned int remap(unsigned int number)
{
  unsigned int x = 0;
  unsigned char pos;
  for (int i=0; i&lt;4; i++)
  {
    unsigned int tmp = number;
    for (int j=0; j&lt;i; j++)
      tmp = tmp &gt;&gt; 8;
    pos = tmp & 0xFF;
    int y = findchar(pos);
    for (int j=0; j&lt;i; j++)
      y = y &lt;&lt; 8;
    x = x ^ y;
  }
  return x;
}

void solve()
{
  unsigned int x1,y1,z1,t1,x0,y0,z0,t0;

  t0 = 0xb3f0986e;

  for (unsigned int tmp = 0; tmp &lt; 0xFFFFFFFF; tmp++)
  {
    x1 = tmp;
    y1 = 0x05060708 ^ x1;
    z1 = 0x09101112 ^ y1;
    t1 = 0x0D14151E ^ z1;

    x1 = (x1 &gt;&gt; 8) ^ (x1 &lt;&lt; 24);
    y1 = (y1 &gt;&gt; 16) ^ (y1 &lt;&lt; 16);
    z1 = (z1 &gt;&gt; 24) ^ (z1 &lt;&lt; 8);

    x1 = remap(x1);
    y1 = remap(y1);
    z1 = remap(z1);
    t1 = remap(t1);

    x0 = t0 ^ t1;
    y0 = x0 ^ x1;
    if ((y0 ^ y1) == (t0 ^ z1))  // check if there is a conflict
    {
      z0 = y0 ^ y1;
      x0 = (x0 &gt;&gt; 8) ^ (x0 &lt;&lt; 24);
      y0 = (y0 &gt;&gt; 16) ^ (y0 &lt;&lt; 16);
      z0 = (z0 &gt;&gt; 24) ^ (z0 &lt;&lt; 8);
      x0 = remap(x0);
      y0 = remap(y0);
      z0 = remap(z0);

      printf("%x-%x-%x", x0, y0, z0);
      break;
    }
    else
      continue;
  }
}
</pre>

Running the code and I got a key after some minutes: b6b09bf0-f23daa06-ac4ee747

Submiting to server, I got this: &#8220;Gratz <img src="http://vnsec-new.cloudapp.net/wp/wp-includes/images/smilies/icon_smile.gif" alt=":)" class="wp-smiley" /> the flag is: 1h3ardul1k3mmX&#8221;.

P/S : @hacklu: I do enjoy the the Rickrolld clip&#8230; lolz&#8230;