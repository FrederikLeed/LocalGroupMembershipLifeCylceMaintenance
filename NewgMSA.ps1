<#
.SYNOPSIS
    This script creates and tests an Active Directory service account.

.DESCRIPTION
    The script performs the following actions:
    1. Retrieves the Active Directory Domain.
    2. Creates a new Active Directory Service Account using the given name and current domain.
    3. Sets the principals allowed to retrieve the managed password for the service account.
    4. Tests the service account to ensure it has been created and configured correctly.

.PARAMETER gmsaname
    The name of the Group Managed Service Account (gMSA) to be created.

.PARAMETER server
    The hostname of the server that should be allowed to retrieve the service account's password.

.EXAMPLE
    .\gMSACreate.ps1 -gmsaname "gMSA_SGroupMGMT" -server "servername$"

.NOTES
    To run this script, you need to have the appropriate Active Directory permissions to create and manage service accounts.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$gmsaname,
    
    [Parameter(Mandatory=$true)]
    [string]$server,

    [Parameter(Mandatory=$true)]
    [string]$domaincontroller
)
try {
    $domain = Get-ADDomain
    New-ADServiceAccount -Name $gmsaname -DNSHostName ($gmsaname + $domain.DNSRoot) -Enabled $True -Server $domaincontroller
    Set-ADServiceAccount -Identity $gmsaname -PrincipalsAllowedToRetrieveManagedPassword ($server + "$") -Server $domaincontroller
    Test-ADServiceAccount -Identity $gmsaname
} 
catch {
    Write-Host $_.Exception.Message
}
#Don't yet know if it is needed to install the account for this to work. The code blow does not work and needs to be fixed if needed.
#Try{
#    Invoke-Command -ComputerName $server -ScriptBlock {Install-ADServiceAccount $args[0]} -ArgumentList $gmsaname
#}catch{
#    Write-Host $_.Exception.Message
#}