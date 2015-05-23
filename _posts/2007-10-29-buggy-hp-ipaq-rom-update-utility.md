---
title: Buggy HP iPAQ ROM Update Utility
author: rd
layout: post
tweetcount:
  - 0
tweetbackscheck:
  - 1408359071
shorturls:
  - 'a:4:{s:9:"permalink";s:68:"https://www.vnsecurity.net/2007/10/buggy-hp-ipaq-rom-update-utility/";s:7:"tinyurl";s:26:"http://tinyurl.com/y933ahx";s:4:"isgd";s:18:"http://is.gd/aOtkm";s:5:"bitly";s:20:"http://bit.ly/8efKrW";}'
twittercomments:
  - 'a:0:{}'
category:
  - tutorials
---
Last weekend I tried to re-flash a HP ipaq rw6828 using the latest <a href="http://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc=us&prodTypeId=215348&prodSeriesId=1839223&prodNameId=1839228&swEnvOID=2067&swLang=8&mode=2&taskId=135&swItem=ip-45505-1" target="_blank">HP iPAQ ROM Update 1.01.03</a> from HP website.

After about 20 minutes, the ROM flash process crashed at 90% and the phone became dead and was not able to power on any longer (tried different suggested methods to get it boot into the bootloader mode but all failed).

I did a quick <a href="http://www.google.com/search?q=ipaq+6828+rom+upgrade+fail+90%25" target="_blank">google</a> on &#8220;ipaq 6828 ROM update fail 90%&#8221; keywords. Quite a lot of people got the same problem. Some were lucky enough to be able to re-flash the phone again as the phone still can boot into bootloader mode. But many other people had to send the phone to HP Service Center to replace the main board.

So I decided to take a look at the HP iPAQ ROM Update Utility binary ([hpRUU.exe &#8211; v3.3.2 build 831][1]) to find out the reason.

<img style="margin-left: auto;margin-right: auto;border: 0px initial initial" title="hpRUU" src="http://www.vnsecurity.net/wp/storage/uploads/2007/10/hpRUU.jpg" alt="hpRUU" width="600" height="337" />

It didn&#8217;t take long to find out that the &#8220;90%&#8221; problem is caused by a lame buggy code of the HP iPAQ ROM Update Utility itself.

[<img class="aligncenter size-full wp-image-362" title="hpRUU-bug01" src="http://www.vnsecurity.net/wp/storage/uploads/2007/10/hpRUU-bug01.jpg" alt="hpRUU-bug01" width="600" height="500" />][2]

The buggy code is inside the sub\_409DA0() (I renamed it to Client\_StartFlash()). Below is the reverse C code snippet of ROM update function (not exactly as the asm code)

<pre class="brush: cpp; gutter: true; highlight: [110,111,112,200,201,202]; title: ; notranslate" title="">void sub_409520(int c)
{
    DebugLog("odmLib/Client_StartFlash -- Flashing would start here");
    hEvent = CreateEventA(0, 0, 0, 0);
    dword_425B04 = CreateThread(0, 0, &sub_409DA0, 0, 0, 0);
    SetEvent(hEvent);

    DebugLog("odmLib/Client_StartFlash: pReturnCode-&gt;dwError = %d", 65520);
}

#define FLASH_ERROR(fmt, ...)   
{                               
  DebugLog(fmt, ...);           
  IsErrorFlag = 1;              
  pReturnCode_dwError = 401;    
  return;                       
}

void Client_StartFlash()      //sub_00409DA0()
{
    //WORD SelectFile[2];

    WaitForSingleObject(hEvent, INFINITE);
    DebugLog("DownloadFile: SelectFile = 0x%x TotalFileSize = 0x%x..rn",
        SelectFile, TotalFileSize);

    if (DeviceInBLMode == -1) {
        DebugLog("DownloadFile: DeviceInBLMode has a wrong value!");
        IsErrorFlag = 1;
        pReturnCode_dwError = 602;
        return;
    }

    if (SelectFile[0] & 8) {
        DebugLog("DownloadFile: COM_OS ..rn");
        wsprintfA(StatusBuffer, "Updating the ROM Image ...");
        byte_425884 = (DeviceInBLMode != 0) + 17;
        memset(_tFilename, 0, 0x64);
        pReturnCode_dwExtraInfo = 3;
        dHeaderLen = 0;
        sub_40A580(3, _tFilename, (int) &dHeaderLen);
        DebugLog("DownloadFile: tFilename = %s dHeaderLen = %drn",
            &_tFilename, dHeaderLen);

        _hFile = CreateFileA(_tFilename, GENERIC_READ | GENERIC_WRITE, 0, 0,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

        if (_hFile == INVALID_HANDLE_VALUE) {
            FLASH_ERROR("Jcs-CreateFile %s fail .. ", _tFilename);
        }

        HeaderBuffer = malloc(dHeaderLen);
        HeaderBuffer = malloc(dHeaderLen);
        ReadFile(_hFile, HeaderBuffer, dHeaderLen, &NumberOfBytesRead, 0);

        dFileLen = GetFileSize(_hFile, 0);
        dDataLen = dFileLen - dHeaderLen;
        DataBuffer = calloc(dFileLen - dHeaderLen, 1);
        ReadFile(_hFile, DataBuffer, dDataLen, &NumberOfBytesRead, 0);
        free(HeaderBuffer);

        ROMDecode(dDataLen, DataBuffer);

        if (memcmp(DataBuffer, 'R000ffn', 7)) {
            IsErrorFlag = 1;
            pReturnCode_dwError = 401;
            DebugLog("Jcs-Warning: The Image is invalid ... ");
            wsprintfA(StatusBuffer, "Warning: The Image is invalid ...");
            return;
        }

        if (!bDownLoadThrUSB(DataBuffer, dDataLen, dword_425B20,
            SelectFile)) {
            IsErrorFlag = 1;
            pReturnCode_dwError = 503;
            return;
        }
        free(DataBuffer);
        CloseHandle(_hFile);
    }

    if (SelectFile[0] & 4) {
        DebugLog("DownloadFile: COM_BL ..rn");
        wsprintfA(StatusBuffer, "Updating the Bootloader ...");
        dHeaderLen = 0;
        memset(_tFilename, 0, 0x64);
        pReturnCode_dwExtraInfo = 2;
        byte_425884 = 2;
        sub_40A580(2, _tFilename, (int) &dHeaderLen);
        DebugLog("DownloadFile: tFilename = %s dHeaderLen = %drn", _tFilename, dHeaderLen);
        _hFile = CreateFileA(_tFilename, GENERIC_READ | GENERIC_WRITE, 0, 0,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

        if (_hFile == INVALID_HANDLE_VALUE) {
            FLASH_ERROR("Jcs-CreateFile %s fail .. ", _tFilename);
        }
        HeaderBuffer = malloc(dHeaderLen);
        ReadFile(_hFile, HeaderBuffer, dHeaderLen, &NumberOfBytesRead, 0);
        dFileLen = GetFileSize(_hFile, 0);
        dDataLen = dFileLen - dHeaderLen;
        DataBuffer = calloc(dFileLen - dHeaderLen, 1);

        ReadFile(_hFile, DataBuffer, dDataLen, &NumberOfBytesRead, 0);
        free(HeaderBuffer);
        ReadFile(_hFile, DataBuffer, dDataLen, &NumberOfBytesRead, 0);
        free(HeaderBuffer);

        ROMDecode(dDataLen, DataBuffer);

        FILE = fopen("c:\ipaq\downloadEboot.txt", "wb");
        fwrite(DataBuffer, 1, dDataLen, FILE);
        fclose(FILE);

        if (!bDownLoadThrUSB(DataBuffer, dDataLen, dword_425B20,
            SelectFile)) {
            IsErrorFlag = 1;
            pReturnCode_dwError = 503;
            return;
        }
        free(DataBuffer);
        CloseHandle(_hFile);
    }
    if (!bDownLoadThrUSB(&unk_4253F0, 0x80, 0, SelectFile)) {
        IsErrorFlag = 1;
        pReturnCode_dwError = 401;
        DebugLog("Jcs-Download version infomation to device fail ..");
        return;
    }

    dTmp = SelectFile[1];
    if (SelectFile[0] & 0x20) {
        DebugLog("DownloadFile: COM_FS ..rn");
        dTmp = SelectFile[1];
    }

    if (dTmp & 0x80 && dTmp & 0x20) {
        DebugLog("DownloadFile: COM_WANOS + COM_WANBL ..rn");
        wsprintfA(StatusBuffer, "Updating the Radio Stack ...");
        dHeaderLen = 0;
        memset(_tFilename, 0, 0x64);
        pReturnCode_dwExtraInfo = 15;
        byte_425884 = 4;
        sub_40A580(13, _tFilename, (int) &dHeaderLen);
        DebugLog("DownloadFile: tFilename = %s dHeaderLen = %drn",
            _tFilename, dHeaderLen);

        _hFile = CreateFileA(_tFilename, GENERIC_READ | GENERIC_WRITE, 0, 0,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

        if (_hFile == INVALID_HANDLE_VALUE) {
            FLASH_ERROR("Jcs-CreateFile %s fail .. ", _tFilename);
        }

        HeaderBuffer = malloc(dHeaderLen);
        ReadFile(_hFile, HeaderBuffer, dHeaderLen, &NumberOfBytesRead, 0);
        dFileLen = GetFileSize(_hFile, 0);
        dDataLen = dFileLen - dHeaderLen;
        dFileLen = GetFileSize(_hFile, 0);
        dDataLen = dFileLen - dHeaderLen;

        DataBuffer = calloc(dDataLen, 1);
        dword_425B1C = DataBuffer;
        ReadFile(_hFile, DataBuffer, dDataLen, &NumberOfBytesRead, 0);
        free(HeaderBuffer);
        CloseHandle(_hFile);

        memset(_tFilename, 0, 0x64)
            sub_40A580(15, _tFilename, (int) &dHeaderLen)
            DebugLog ("DownloadFile: tFilename = %s dHeaderLen = %drn",
            &_tFilename, dHeaderLen)

            _hFile = CreateFileA(_tFilename, GENERIC_READ | GENERIC_WRITE, 0, 0,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

        if (_hFile == INVALID_HANDLE_VALUE) {
            FLASH_ERROR("Jcs-CreateFile %s fail .. ", _tFilename);
        }

        HeaderBuffer = malloc(dHeaderLen);
        ReadFile(_hFile, HeaderBuffer, dHeaderLen, &NumberOfBytesRead, 0);
        dDataLen = GetFileSize(_hFile, 0) - dHeaderLen;
        dword_425B84 = dDataLen;

        DataBuffer = calloc(dDataLen, 1);
        dword_425B10 = DataBuffer;
        ReadFile(_hFile, DataBuffer, dDataLen, &NumberOfBytesRead, 0);

        free(HeaderBuffer);
        CloseHandle(_hFile);

        DataBuffer = calloc(dDataLen + nNumberOfBytesToRead + 88, 1);
        szBuffer = _msize(DataBuffer);
        memset(DataBuffer, -1, szBuffer);

        if (sub_40A5E0()) {
            if (sub_40A770()) {
                if (sub_40A8F0()) {
                    ROMDecode(Count, DataBuffer);
                    if (DataBuffer) {
                        FILE = fopen ("c:\ipaq\downloadMot.txt", "wb");
                        fwrite(DataBuffer, 1, Count, FILE);
                        fclose(FILE);
                        if (bDownLoadThrUSB(DataBuffer, Count, dword_425B20, SelectFile)) {
                            if (sub_40B270()) {
                                free(DataBuffer);
                                free(dword_425B10);
                                free(dword_425B1C);
                                dword_425F58 = 1;
                            } else {
                                IsErrorFlag = 1;
                            } else {
                                IsErrorFlag = 1;
                                pReturnCode_dwError = 401;
                                DebugLog ("Jcs-bGetMOTBurnStatus fail ..");
                            }
                        } else {
                            IsErrorFlag = 1;
                            pReturnCode_dwError = 401;
                            DebugLog ("Jcs-Download Mot fail ..");
                        }
                    } else {
                        IsErrorFlag = 1;
                        pReturnCode_dwError = 401;
                        DebugLog ("Jcs-(pMOTBuf==NULL) fail ..");
                    }
                } else {
                    IsErrorFlag = 1;
                    pReturnCode_dwError = 401;
                    DebugLog("Jcs-PrepareMOTData fail ..");
                }
            } else {
                IsErrorFlag = 1;
                pReturnCode_dwError = 401;
                DebugLog("Jcs-PrepareMOTAgent fail ..");
            }
        } else {
            IsErrorFlag = 1;
            pReturnCode_dwError = 401;
            DebugLog("Jcs-PrepareMOTPara fail ..");
        }
    } else {
        dword_425F58 = 1;
    }
}
</pre>

The codes at line 110->112 and 200->202 inside Client_StartFlash() function try to write the &#8216;decrypted&#8217; EBOOT and MOT ROMs data to hard-coded file locations at c:ipaqdownloadMot.txt and c:ipaqdownloadEboot.txt. It doesn&#8217;t check whether the fopen() return a successful FILE pointer or not before writing the content.

So, If you install the ROM upgrade program in a different location (in my case, i installed it in d:tmpipaq) instead of default location (c:ipaq), the update program will get crashed at 90%. This stupid error had killed many ipaq and many people had to spend their time and money for the service & mainboard replacement since the update had been released by HP for almost a year. The HP developer who wrote this code should go back to college to learn how to code properly.

After knowing the problem, I sent the ipaq to HP Service Center a day after and got the mainboard replaced. After few hours of waiting, complaining and giving live proof of the bug to HP technical guy, I did not need to pay for mainboard replacement cost :). The technical guy was a nice guy. He even brought me inside HP technical service center for re-flashing few ipaqs to reproduce the problem. However, the experience with the girl at HP Customer Service Center was kind of bad though.

**  
**

**Links:**

1.  <a href="http://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc=us&prodTypeId=215348&prodSeriesId=1839223&prodNameId=1839228&swEnvOID=2067&swLang=8&mode=2&taskId=135&swItem=ip-45505-1" target="_blank">HP iPAQ ROM Update 1.01.03</a>
2.  [hpRUU.exe &#8211; v3.3.2 Build 831][1]

 [1]: /vnsec/Members/rd/Files/misc/hpRUU.rar "hpRUU.rar"
 [2]: http://www.vnsecurity.net/wp/storage/uploads/2007/10/hpRUU-bug01.jpg