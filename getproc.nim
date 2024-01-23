import winim/com, std/strformat
import obf

proc getprocs*(target : string) : string = 
    var 
        pid: string = "null"
        wmi = GetObject(obf(r"winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2"))
        
    for i in wmi.execQuery(obf("select * from win32_process")):   
        if i.name == fmt"{target}" :
            pid = i.handle
            echo fmt"[+] found {target} at {i.handle}"
            break
    if (pid == "null") :
        echo fmt"[-] {target} not found, exiting..."
        quit()
    return pid