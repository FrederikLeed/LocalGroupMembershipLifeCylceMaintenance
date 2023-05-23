<#
.SYNOPSIS
    This script manages Active Directory (AD) groups for servers. It creates AD groups for each server and removes groups for which there are no corresponding servers.

.DESCRIPTION
    The script performs the following actions:
    1. Retrieves the Primary Domain Controller (PDC).
    2. Fetches the list of AD computers in the specified search base.
    3. For each computer, it tries to create two AD groups: an 'ADM' and an 'RDP' group.
    4. If there are any groups for which there is no corresponding server, it removes these groups.

.PARAMETER ServerSearchbase
    The Organizational Unit (OU) where the script should search for server computers.

.PARAMETER GroupTargetPath
    The OU where the script should create the server groups.

.EXAMPLE
    .\script.ps1 -ServerSearchbase "OU=weritadmin,DC=int,DC=werit,DC=dk" -GroupTargetPath "OU=Servers,OU=Groups,OU=Tier0,OU=weritadmin,DC=int,DC=werit,DC=dk"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerSearchbase,
    [Parameter(Mandatory=$true)]
    [string]$GroupTargetPath
)

function log{
    param(
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    if ( $message )
    {
        write-debug $message
        ((get-date).tostring("yyyy-MM-dd hh:mm ") + $message) | out-file ("c:\scripts\logs\server_group_lifecycle.log") -append
    }
}

Function GetPDC{
    Return (Get-ADDomain | Select-Object -Property PDCEmulator).PDCEmulator
}

$domaincontroller = GetPDC
    

#Create group
foreach ($c in Get-ADComputer -SearchBase $ServerSearchbase -Filter *){
    Try{
        New-ADGroup -Name ("ADM-" + $c.name) -GroupCategory Security -GroupScope DomainLocal -Path $GroupTargetPath -Server $domaincontroller
        log -message (("ADM-" + $c.name) + " created")
    }catch{
        if($error[0].Exception.Message -eq "The specified local group already exists"){}else{
            log -message ("ERROR creating: "+ ("ADM-" + $c.name) + " " + $error[0])
        }
    }
    Try{
        New-ADGroup -Name ("RDP-" + $c.name) -GroupCategory Security -GroupScope DomainLocal -Path $GroupTargetPath -Server $domaincontroller
        log -message (("RDP-" + $c.name) + " created")
    }catch{
        if($error[0].Exception.Message -eq "The specified local group already exists"){}else{
            log -message ("ERROR creating: "+ ("ADM-" + $c.name) + " " + $error[0])
        }
    }
}

 #Remove groups where no server
 foreach($g in Get-ADGroup -SearchBase $GroupTargetPath -Filter *){
    $serversnamelist = Get-ADComputer -SearchBase $ServerSearchbase -Filter * -ErrorAction SilentlyContinue
    if($serversnamelist.name -match $g.name.Substring(4)){
        #"Server exists - do nothing"
    }else{
        Remove-ADGroup $g.DistinguishedName -Confirm:$false
        log -message ($g.DistinguishedName + " removed")
    }
 }
