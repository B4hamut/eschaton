import winim

const IOCTL_CLOSE_HANDLE* = 2201288708
const CONST_SYSTEM_HANDLE_INFORMATION* = 16


type NtQuerySystemInformation_t* = proc(SystemInformationClass : SYSTEM_INFORMATION_CLASS, SystemInformation : PVOID, SystemInformationLength : ULONG, ReturnLength : PULONG) : NTSTATUS {.stdcall.}


type
    system_HANDLE_TABLE_ENTRY_INFO* = object
        processId* : ULONG
        objectTypeNumber* : BYTE
        flags* : BYTE
        handle* : USHORT 
        object_thingy* : PVOID   #Pointer to the object, the object resides in kernel space
        grantedAccess* : ACCESS_MASK 

type
    system_HANDLE_INFORMATION* = object
        number_of_handles* : ULONG
        handles* : array[500000, system_HANDLE_TABLE_ENTRY_INFO]

    psystem_HANDLE_INFORMATION* = ptr system_HANDLE_INFORMATION

type 
    ioControl* = object
        ulPID* : ULONGLONG
        lpObjectAddress* : PVOID
        ulSize* : ULONGLONG
        ulHandle* : ULONGLONG