<#
.SYNOPSIS
    This script sets a group to have delegated permissions for creating and deleting child objects in the specified Organizational Unit (OU).

.DESCRIPTION
    The script performs the following actions:
    1. Retrieves the Access Control List (ACL) of the specified OU.
    2. Gets the Security Identifier (SID) for the delegation group.
    3. Creates an Active Directory Access Rule for the delegation group, granting it the right to create and delete child objects in the OU.
    4. Applies the updated ACL to the OU.

.PARAMETER TargetOU
    The Organizational Unit (OU) where delegated permissions should be set.

.PARAMETER DelegationObject
    The name of the Active Directory group that should be granted delegated permissions.

.EXAMPLE
    .\script.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier0,OU=weritadmin,DC=int,DC=werit,DC=dk" -DelegationObject "SGLifeCMGMT"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetOU,
    [Parameter(Mandatory=$true)]
    [string]$DelegationObject
)

Function SetGroupCreateDeleteDelegation{
    Param(
        $ou,
        $ADObjectName
    )
      
    $acl = get-acl ("ad:"+ $ou)
    $ADObject = Get-ADObject -filter {Name -eq $ADObjectName} -Properties ObjectSID
    $sid = new-object System.Security.Principal.SecurityIdentifier $ADObject.ObjectSID

    # The following object specific AC is to grant delegated permission on specifiec user attributes to the specified group
        $inheritedobjecttypeguid = $AllGuid

        $identity = [System.Security.Principal.IdentityReference] $SID
        $adRights = [System.DirectoryServices.ActiveDirectoryRights] "CreateChild, DeleteChild"
        $type = [System.Security.AccessControl.AccessControlType] "Allow"
        $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"

        $objecttypeguid = $GroupGuid
        $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity,$adRights,$type,$objecttypeguid,$inheritanceType,$inheritedobjecttypeguid))

    Set-ACl -Path "AD:\$ou" -AclObject $acl
}

#Dependencies
    Import-Module ActiveDirectory

#Constant definitions
        $GroupGuid = [GUID]::Parse('bf967a9c-0de6-11d0-a285-00aa003049e2') #http://www.selfadsi.org/deep-inside/ad-security-descriptors.htm
        $AllGuid   = [GUID]::Parse('00000000-0000-0000-0000-000000000000')


Try{
        SetGroupCreateDeleteDelegation -ou $TargetOU -ADObjectName $DelegationObject

        Write-Host "Delegation created successfully."
}catch{
    Write-Host $_.Exception.Message
}