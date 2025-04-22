###### IAVM TO CVE To Plugin ######
# Harbor Higginbotham
# ISD IA Team
# 11/8/2022
# Auto IAVM to Plugin
# "Woke up this morning just about noon cause I knew I had to be at the Coast Guard soon" - Melvin

############################################################## Conditions ##############################################################
# Files:
# - Must be in the same directory as Out.csv, Find.csv, IAVM.csv
# - See instructions for more. 
# Dependancies:
# - Internet Connection

############################################################## Functions ##############################################################


##################### Web Scraper #####################

# Gets our plugin ID's:
Function Get-PlugID($CVE, $URL) 
{
	# Variable Dec:
	$Agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.5249.181 Safari/537.36"
	$Plug = "/plugins"	
	$Name = @()
	$Desc = @()
	$Temp = @()
	
	foreach($x in $CVE)
	{	
		
		# Web-Scraper: 
        	
		# PS Web Request:
        
        	$Site = Invoke-WebRequest "$URL$x$Plug" -UserAgent $Agent

        

		# Get Plugin Number: 
		$Name += $Site.Links | Where-Object innerText -match "^\d+$" | Select-Object innerText
		

		# Get Description of Plugin:  
		$Desc = $Site.Content -split "," | select-string "script_name"
		
	
	}

	Return $Name
		
}

############################################################## Var Dec ##############################################################
# CSV Variable Dec: 
$Sort = Import-CSV -Path ".\IAVM.csv" # Found from downloading Here: https://iavm.csd.disa.mil/
$Find = Import-CSV -Path ".\Find.csv" # Single Column from the working IAVM sheet of what we need to find. 
$Out = Import-CSV -Path ".\Out.csv"

# Tenable Web Scrape Variable Dec:
$URL = "https://www.tenable.com/cve/"

# For Loop Var Dec:
$NewRow = @()
$Counter = 0
$WebReqs = 0

############################################################## Write to CSV ##############################################################
# For Each IAVM In $FIND 
foreach($i in $Find)
{
	# Load up a new object:
	$NewRow += [PSCustomObject] @{
	
		# Add IAVM:
		"IAVM #" = $Find.IAVM_FIND[$Counter]; 

		# Add List of CVE:
		"CVE" = ($Sort -match $Find.IAVM_FIND[$Counter]).CVE -join ", "; 
		

		# Add List of Plugins: 
		"Plugins" = (Get-PlugID -CVE (($Sort -match $Find.IAVM_FIND[$Counter]).CVE) -URL $URL) -join ", ";

	}
	
    $WebReqs += ($Sort -match $Find.IAVM_FIND[$Counter]).CVE.Count
	$Counter++
	
	# Progress Bar:
	# Write-Progress -Activity "Processing IAVM's" -PercentComplete (($Counter / $Find.count) * 100) -Status "$WebReqs : Web Requests"
	# Start-Sleep -Milliseconds 200

	

}

# Export Object to CSV: 
$NewRow | Export-CSV '.\Out.csv' -Force

# Le Fin. 
