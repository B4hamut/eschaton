import winim/lean
import obf
proc ArrangeSePrivilege*(privilegeName:string,enableFlag:bool):bool =
    var 
        returnValue : bool = true
        tokenPrivileges : TOKEN_PRIVILEGES
        luid : LUID
        tokenHandle : HANDLE
        
    if (FALSE == OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, addr tokenHandle)):
        echo obf("[-] Failed to OpenProcessToken")
        return false
    if (FALSE == LookupPrivilegeValue(NULL, privilegeName, addr luid)):
        echo obf("[-] LookupPrivilegeValue error")
        return false
    tokenPrivileges.PrivilegeCount = 1
    tokenPrivileges.Privileges[0].Luid = luid
    if (enableFlag):
        tokenPrivileges.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED
    else:
        tokenPrivileges.Privileges[0].Attributes = 0
    if (0 == AdjustTokenPrivileges(tokenHandle,FALSE,addr tokenPrivileges,cast[DWORD](sizeof(TOKEN_PRIVILEGES)),cast [PTOKEN_PRIVILEGES](NULL),cast [PDWORD](NULL))):
        echo obf("[-] AdjustTokenPrivileges error")
        return false
    if(GetLastError() == ERROR_NOT_ALL_ASSIGNED):
        echo obf("[-] AdjustTokenPrivileges error")
        returnValue = false
    return returnValue