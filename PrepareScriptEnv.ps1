<#
.SYNOPSIS
    This script creates a specific folder structure if it does not already exist.

.DESCRIPTION
    The script creates the following folders:
    - C:\scripts\
    - C:\scripts\logs\
    - C:\source\
    If the folders already exist, the script does nothing for that folder.

.EXAMPLE
    .\CreateFolderStructure.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Paths = @(
        "C:\scripts\",
        "C:\scripts\logs\",
        "C:\source\"
    )
)

function CreateFolder {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (!(Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path
        Write-Host "Created directory: $Path"
    } else {
        Write-Host "Directory already exists: $Path"
    }
}

foreach ($Path in $Paths) {
    CreateFolder -Path $Path
}
