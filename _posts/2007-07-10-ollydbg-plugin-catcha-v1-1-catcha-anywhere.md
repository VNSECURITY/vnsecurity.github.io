---
title: 'OllyDbg plugin: Catcha! v1.1 &#8211; Catcha anywhere'
author: mikado
layout: post
tweetcount:
  - 0
twittercomments:
  - 'a:0:{}'
shorturls:
  - 'a:4:{s:9:"permalink";s:77:"http://www.vnsecurity.net/2007/07/ollydbg-plugin-catcha-v1-1-catcha-anywhere/";s:7:"tinyurl";s:26:"http://tinyurl.com/ydnmnhn";s:4:"isgd";s:18:"http://is.gd/aOucH";s:5:"bitly";s:0:"";}'
tweetbackscheck:
  - 1408359063
category:
  - tutorials
---
<a title="OllyDbg plugin: Catcha! v1.1" class="generated" href="/vnsec/Members/internal/public/ollydbg-plugin-catcha/Catcha-1.1.rar">OllyDbg plugin: Catcha! v1.1</a> 

In order to reach the target program EntryPoint, we call CEngine::EngineTrap() function below before resuming the target program to hook its EntryPoint and raise debug exception by INT3 instruction then we can attach to it. 

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">///pAddress: the address inside target process (the EntryPoint in our case) that will be hooked with trap function.
VOID CEngine::EngineTrap(LPVOID pAddress)
{
	HANDLE hProcess = NULL, hLibRemote = NULL;
	UCHAR pEntryPointOpcodes[5] = {0,};
	//Trap function opcodes
	UCHAR pTrap[] = {0x50,				// 0 - PUSH EAX				; Save EAX
			 0xB8, 0x00, 0x00, 0x00, 0x00,	// 1 - MOV EAX,XXXXXXXX			; EAX = XXXXXXXX = pAddress
			 0xC6, 0x00, 0xFF,		// 6 - MOV BYTE PTR DS:[EAX],0FF	;
			 0xC6, 0x40, 0x01, 0xFF,	// 9 - MOV BYTE PTR DS:[EAX+1],0FF	; |
			 0xC6, 0x40, 0x02, 0xFF,	//13 - MOV BYTE PTR DS:[EAX+2],0FF	; | Restore original opcodes at pAddress
			 0xC6, 0x40, 0x03, 0xFF,	//17 - MOV BYTE PTR DS:[EAX+3],0FF	; |
			 0xC6, 0x40, 0x04, 0xFF,	//21 - MOV BYTE PTR DS:[EAX+4],0FF	;/
			 0x58,				//25 - POP EAX				; Restore EAX
			 0xCC,				//26 - INT3				; Raise debug exception
			 0xE9, 0x00, 0x00, 0x00, 0x00	//27 - JMP YYYYYYYY			; YYYYYYYY = relative address value of pAddress
			};
	DWORD nOldProtect;

	do {
		//Open target process
		hProcess = ::OpenProcess(PROCESS_ALL_ACCESS, FALSE, m_ProcessInfo.m_nProcessId);
		if (!hProcess) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::OpenProcess()");
			EngineError();
			break;
		}

		//Allocate memory space inside target process for trap function
		//hLibRemote = allocated virtual address inside target process
		hLibRemote = ::VirtualAllocEx(hProcess,
					      NULL,
					      sizeof(pTrap),
					      MEM_COMMIT,
					      PAGE_READWRITE);
		if (!hLibRemote) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::VirtualAllocEx()");
			EngineError();
			break;
		}

		//Ensure that we can read/write/execute sizeof(pEntryPointOpcodes) bytes at pAddress
		if (!::VirtualProtectEx(hProcess,
					(LPVOID)(m_ProcessInfo.m_nImageBase + m_ProcessInfo.m_nAddressOfEntryPoint),
					sizeof(pEntryPointOpcodes),
					PAGE_EXECUTE_READWRITE,
					&amp;nOldProtect)) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::VirtualProtectEx()");
			EngineError();
			break;
		}

		//Ensure that we can read/write/execute sizeof(pTrap) bytes at hLibRemote
		if (!::VirtualProtectEx(hProcess,
					(LPVOID)hLibRemote,
					sizeof(pTrap),
					PAGE_EXECUTE_READWRITE,
					&amp;nOldProtect)) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::VirtualProtectEx()");
			EngineError();
			break;
		}

		//Save sizeof(pEntryPointOpcodes) bytes at pAddress in pEntryPointOpcodes
		if (!::ReadProcessMemory(hProcess,
					 (LPVOID)(m_ProcessInfo.m_nImageBase + m_ProcessInfo.m_nAddressOfEntryPoint),
					 (LPVOID)pEntryPointOpcodes,
					 sizeof(pEntryPointOpcodes),
					 NULL)) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::ReadProcessMemory()");
			EngineError();
			break;
		}

		//Repair trap function

		//XXXXXXXX = pAddress
		*(PDWORD)(pTrap + 2) = (DWORD)pAddress;

		//Calculate value for JMP instruction
		//YYYYYYYY = relative address value of pAddress
		*(PDWORD)(pTrap + 28) = (DWORD)pAddress - ((DWORD)hLibRemote + sizeof(pTrap));

		//Restore original opcodes at pAddress
		pTrap[8] = pEntryPointOpcodes[0];
		pTrap[12] = pEntryPointOpcodes[1];
		pTrap[16] = pEntryPointOpcodes[2];
		pTrap[20] = pEntryPointOpcodes[3];
		pTrap[24] = pEntryPointOpcodes[4];

		//Replace opcodes at pAddress with JMP instruction to trap function
		pEntryPointOpcodes[0] = 0xE9;
		//Calculate value for JMP instruction
		*(PDWORD)(pEntryPointOpcodes + 1) = (DWORD)hLibRemote - ((DWORD)pAddress + sizeof(pEntryPointOpcodes));

		//Write our codes into target process

		if (!::WriteProcessMemory(hProcess,
					  pAddress,
					  (LPVOID)pEntryPointOpcodes,
					  sizeof(pEntryPointOpcodes),
					  NULL)) {
			EngineLog("Error: CEngine::EngineHookEntryPoint() -&gt; ::WriteProcessMemory()");
			EngineError();
			break;
		}

		if (!::WriteProcessMemory(hProcess,
					  (LPVOID)hLibRemote,
					  (LPVOID)pTrap,
					  sizeof(pTrap),
					  NULL)) {
			EngineLog("Error: CEngine::EngineTrap() -&gt; ::WriteProcessMemory()");
			EngineError();
			break;
		}
	}
	while (FALSE);

	::CloseHandle(hProcess);

	EngineLog("Done: CEngine::EngineTrap()");
}
</pre>

Besides, this function is also used to hook and trap at any address inside target process. It will be useful for attaching OllyDbg after bypassing some codes we are not interested in (e.g: anti-debugger codes :D). Because I don&#8217;t have much time at this moment, I will add this option in next version of Catcha!.

*mikado.* 

P.S: As lamer&#8217;s comment, the next feature can only be applied to applications that don&#8217;t handle INT3 exception themselves. Another problem is that this version is still not be able to catch .NET applications because their EntryPoint is located in mscoree.dll.