<#
.SYNOPSIS
    This script imports a Group Policy Object (GPO) from a specified backup.

.DESCRIPTION
    The script extracts a GPO backup from a ZIP file located in the source folder, then imports it into the specified GPO.
    If the GPO doesn't exist, the script will create it.

.PARAMETER GPOName
    The name of the GPO to import into.

.PARAMETER BackupPath
    The path to the ZIP file containing the GPO backup.

.EXAMPLE
    .\ImportGPO.ps1 -GPOName "TestGPO" -BackupPath "C:\GPOBackups\TestGPO.zip"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$GPOName,
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,
    [Parameter(Mandatory=$true)]
    [string]$BackupGpoName
)
Function GetPDC{
    Return (Get-ADDomain | Select-Object -Property PDCEmulator).PDCEmulator
}

$DomainController = GetPDC

Import-Module GroupPolicy

# Extract the ZIP file
$ExtractPath = [System.IO.Path]::GetDirectoryName($BackupPath)
$ExtractPath = Join-Path -Path $ExtractPath -ChildPath $GPOName

if(Test-Path $ExtractPath){
    Remove-Item -Path $ExtractPath -Force -Confirm:$false -Recurse
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($BackupPath, $ExtractPath)

# Check if the GPO already exists
$gpo = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue

# If the GPO doesn't exist, create it
if (!$gpo) {
    $gpo = New-GPO -Name $GPOName
}

# Import the GPO from the backup
$params = @{
    BackupGpoName  = $BackupGpoName
    TargetName     = $GPOName
    path           = $ExtractPath
    CreateIfNeeded = $true
    Server         = $DomainController
}
Import-GPO @params

Write-Host "GPO $GPOName imported successfully."
