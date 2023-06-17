#Powershell notes.

#x86 are 32 bit version & without x86 are 64 bit version.

#click on the icon to set properties.
<# Getting familiar with powershell:
cmdlets: Verb - Noun
Native commands work #>

Example- ping, ipconfig, calc, notepad, mspaint

cls Clear-Host
cd Set-location
dir Get-Children
ls Get-Children
type cat  Get-Content
copy cp  Copy item
alias alias or get-alias or gal

help man
ipconfig /all

gal g* - #gives all alias for commands starting with 'g' which is Get-*
gal *sv - #all commands for sv - services

update-help -force #To update help we need internet connection
get-help
* #wild card
get-help *service*
get-help get-service -Detailed
get-help get-service -Full
get-help get-service -Online
get-help get-service -ShowWindow
get-help get-service -Examples
[] parameter enclosed with these brackets are not necessarily required.

#Pipeline
-PassThru - to show result what happend after a command
get-service | export-csv -path c:\service.csv
get-process | export-clixml -path c:\good.xml (when no additional application is on)
Now open notepad or calc and consider them as malware
compare-object -referenceobject (import-clixml c:\good.xml) -diff (get-process) -propertyname
export-csv = convert-csv + out-file
get-service | convertto-csv
get-service | convertto-html -property name,status
get-service | convertto-html -property name,status | out-file c:\test.htm
-whatif
-confirm
Get-Service | Stop-Service -WhatIf
Get-Service | Stop-Service -Confirm
get-module #Current list of modules loaded up

# Objects for Admin
# Rows are OBJECTS and Columns are their PROPERTY 

get-process #Each row of the output will be OBJECT
get-process | where handles -gt 900 | sort handles #Here 'handles' is PROPERTY of object
get-service | gm #Here gm is alias for get-member
Get-EventLog -LogName System -Newest 5 | Select -Property EventID, TimeWritten, Message | Sort -Property timewritten | Convertto-html | out-file c:\error.htm

#Let's assume we have an xml document in our drive.
$x= [xml](cat .\r_and_j.xml) #cast variable as xml and store value of the xml document
$x #Gives that it's xml
$x.gettype() #give type of the document

#Lets assume there are tags like Play, Act, scene, speech, speaker

$x.Play
$x.Play.Act
$x.Play.Act[0]
$x.Play.Act[0].Scene
$x.Play.Act[0].Scene[0].Speech
$x.Play.Act.Scene.Speech |group speaker |sort count
$_ #works same as $PSItem

Sudo code:
get-stuff |sort |where -somestuff |out-file
get-stuff |where -somestuff |sort |out-file -> best approach

get-service | where {$_.status -eq "Running"}
gps | where {$_.handles -ge 1000}
get-adcomputer -filter * | select -property name, @{name='ComputerName';expression={$_.name}}
get-wmiobject -class win32_bios -ComputerName (get-adcomputer -filter * | select -ExpandProperty name) #Since CoumpterName needs string and using -property would return objects, therefore used -expandproperty that returns string which can be computed by -ComputerName
get-wmiobject -class win32_bios -ComputerName (get-adcomputer -filter *).name
get-help Get-CimInstance
get-adcomputer -filter * | get-wmiobject win32_bios -ComputerName {$_.name}

# The Power in the Shell - Remoting
# Universal Code Excecution
# Computer Configuration/Policies/Administrative Templates/Windows Components/Windows Remote Management (WinRM)
# PowerShell Remoting is already enabled in Server 12

# To enable Remoting (Terms to undertand Serialized & Deserialized)
Enable-PSRemoting
Enter-PSSession -ComputerName dc #takes you to the dc (a secure telent)
get-service -name bits | gm #returns TypeName: System.ServiceProcess.ServiceController Here you'll find a lot of methods as it's a live object.
Invoke-Command -ComputerName s1 {get-service -name bits} | gm #returns TypeName: Deserialized.System.ServiceProcess.ServiceController Here you'll find just a single method as the object itself is gone and you have just a representation of the object.
# In windows servers
get-windowsfeature
install-windowsfeature WindowsPowerShellWebAccess
Install-PswaWebApplication -UseTestCertificate
Add-PswaAuthorizationRule * * *

<# Execution Policy:
1. By Default PowerShell does not run scripts
2. Get/Set-ExecutionPolicy
-Restricted
-Unrestricted
-AllSigned
-RemoteSigned 
-Bypass
-Undefined

Can be set with Group Policy #>

Get-PSDrive
dir Cert:\CurrentUser -Recurse -CodeSigningCert -OutVariable a
$cert=$a[0]
Get-ExecutionPolicy
Set-ExecutionPolicy "allsigned"

Set-AuthenticodeSignature -Certificate $cert -FilePath .\Test.ps1

# Playing with Variables
$var= Read-Host "Write a computer name"
# Write a computer name: dc
$var #dc
get-service -name bits -ComputerName $var
write-host $var -ForegroundColor Red -BackgroundColor Green
$var | gm # gives result
write-host $var | gm # gives error
write-output $var | gm # gives output
1..5 > .\test.txt
${path\test.txt}
icm -comp dc {$var=2} # it goes to dc and fires-up powershell and assign value '2' to var
icm -comp dc {write-output $var} # no output as the previous session was killed and currently there no value in var

# Now we'll create session
$s=New-PSSession -ComputerName dc
Get-PSSession # shows that dc state is opened
icm -Session $s {$var=2}
icm -Session $s {$var} # gives output '2'
Measure-Command {icm -ComputerName dc {Get-Process}} # gives the details to time it took to run the command approx. 886 milisecond
Measure-Command {icm -Session $s {Get-Process}} # gives the details to time it took to run the command approx. 556 milisecond

$servers='s1','s2'
$servers | foreach {start iexplore https://$_} # Nothings gets displayed in both servers
$s=New-PSSession -ComputerName $servers
icm -Session $s {install-windowsfeature web-server} # deploys web servers to s1 & s2
notepad c:\default.htm # create your web page
$servers | foreach{copy-item c:\default.htm -Destination \\$_\c$\inetpub\wwwroot}
$servers | foreach {start iexplore https://$_} # Gives your web page

Import-PSSession -Session $s -Module ActiveDirectory -Prefix Remote

# Introducing scripting and toolmaking
Get-WmiObject win32_logicaldisk -filter "DeviceID='c:'" | select @{n='freegb'; e={$_.freespace / 1gb -as [int]}}

<#
.Synopsis
This is the short explanation
.Description
This is long description
.Parameter ComputerName
This is for remote computers
.Example
DiskInfo -computername remote
This is for remote computer
#>
funtion get-diskinfo{
    [cmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        $bogus
    )
    Get-WmiObject win32_logicaldisk -filter "DeviceID='c:'" | select @{n='freegb'; e={$_.freespace / 1gb -as [int]}}
}

# Above example of powershell script could be used as cmdlet, now to convert it into module save the file with .psm1 extension.

Import-Module .\diskinfo.psm1 -Force -Verbose
#The verbose message stream is used to deliver more in depth information about command processing.