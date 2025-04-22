# Harbor Higginbotham
# 01/6/2023
# IA PIT 

[xml]$NmapFile = Get-Content # [NMAP XML File Name and Path HERE]

$Serv = @()
$App = @()
$Prt = @()
$Ip = @()
$Mac = @()
$Stat = @()
$Os = @()
$Proto = @()

$NewRow = @()

# Ignore the Errors.  

foreach($x in $NmapFile.nmaprun.host)
{
    # Get Service Name:
    $Serv += ($x.ports.port.service.name).Trim() 
    
    # Get App List:
    foreach($i in $x.ports.port.service)
    {
        
        # There is not always an app name for every service so we gotta add the blanks its not showing.
        if(($i.product -eq $null) -or ($i.product -eq "")) { $App += "<BLANK>" }
        else { $App += ($i.product).Trim() }

    }

    
    # Get list of Ports:
    $Prt += ($x.ports.port.portid).Trim() 
    
   
    # Get List of Stats: 
    $Stat += ($x.ports.port.state.state).Trim() 

    #Get List of Protocol:
    $Proto += ($x.ports.port.protocol).Trim()
    
    
    # Get Ip, Mac, Os:
    for($j = 0; $j -lt ($x.ports.port.service).Count; $j++)
    {
        # Get Ip
        $Ip += $x.address.addr | select-string -pattern ":" -NotMatch
        
        # Get Mac
        $Mac += $x.address.addr | select-string -pattern ":"

        # Get Os Guess
        $Os += $x.os.osmatch.name
    }
    

    # Input into spreadsheet: 
    for($k = 0; $k -lt ($x.ports.port.service).Count; $k++)
    {
        $NewRow += [PSCustomObject] @{
            
	        "Service" = $Serv[$k] ;

	        "Application" = $App[$k] ; 

            "Port" = $Prt[$k] ;

            "Protocol" = $Proto[$k] ;

            "Status" = $Stat[$k] ;

            "Ip Address" = $Ip[$k] ; 

            "Datalink Address" = $Mac[$k] ;

            "OS Guess" = $Os[$k] ;
        }
    }

    # Reset Variables:
    $Serv = @()
    $App = @()
    $Prt = @()
    $Ip = @()
    $Mac = @()
    $Stat = @()
    $Os = @()

    
    # echo ($Prt)
    # echo ($App)
    # echo ($Serv)
    # echo ($Mac)
    # echo ($Stat)
    # echo ($Ip)
}

# Write To File: 
$NewRow | Export-CSV '.\Out.csv' -Force