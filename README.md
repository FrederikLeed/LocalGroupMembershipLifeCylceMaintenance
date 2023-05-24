# A solution to manage membership of local groups on domain joined computers

Bits and bytes to create a fully automated solution where Active Directory computers, local groups are managed and the lifecycle of groups in AD is maintained.

This repository offers a solution for managing and maintaining the membership of local groups in Active Directory (AD) for Windows servers and computers. It is designed to assist organizations in controlling access to servers and effectively maintaining security by regulating who has permissions.

The solution consistently resets unauthorized changes made to the membership of local groups, thereby ensuring that the original access permissions remain intact. If any existing admin modifies the group membership, this change will be reverted, preserving the integrity of access control.



#Prepare script environment
This is just a simple script to create some folder structure used to host script and log files. The structure can be anything you want, but some scripts might need editing if a different folder structure is selected / preferred. 

```powershell
<#
.SYNOPSIS
    This script creates a specific folder structure if it does not already exist.

.DESCRIPTION
    The script creates the following folders:
    - C:\scripts\
    - C:\scripts\logs\
    - C:\source\
    If the folders already exist, the script does nothing for that folder.
#>

.\PrepareScriptEnv.ps1
```

#Copy scripts to server

1. Clone repo: https://github.com/FrederikLeed/LocalGroupMembershipLifeCylceMaintenance
2. copy server_group_lifecycle.ps1 from source folder to scripts folder

#Create gMSA
```powershell
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
    The hostname of the server that should be allowed to retrieve the service account's password
 #>
.\NewgMSA.ps1 -gmsaname "SGLifeCMGMT" -server "scriptserver01"
```

#Delegate permissions
```powershell
<#
.SYNOPSIS
    This script sets an ADObject to have delegated permissions for creating and deleting child objects in the specified Organizational Unit (OU).

.DESCRIPTION
    The script performs the following actions:
    1. Retrieves the Access Control List (ACL) of the specified OU.
    2. Gets the Security Identifier (SID) for the delegation object.
    3. Creates an Active Directory Access Rule for the delegation object, granting it the right to create and delete child objects in the OU.
    4. Applies the updated ACL to the OU.

.PARAMETER TargetOU
    The Organizational Unit (OU) where delegated permissions should be set.

.PARAMETER DelegationObject
    The name of the Active Directory object that should be granted delegated permissions.
 #>
 
.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier0,OU=company,DC=int,DC=domain,DC=com" -DelegationObject "SGLifeCMGMT"
.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier1,OU=company,DC=int,DC=domain,DC=com" -DelegationObject "SGLifeCMGMT"
```

#Scheduled tasks

```powershell
<#
.SYNOPSIS
    This script creates a scheduled task on a Windows server. The task is set to execute a PowerShell script every 5 minutes using a Group Managed Service Account (gMSA).

.DESCRIPTION
    The script performs the following actions:
    1. Defines the action for the task (the execution of a specific PowerShell script).
    2. Sets a trigger for the task, defining when it should run.
    3. Creates a principal to run the scheduled task using the specified gMSA.
    4. Registers the task with the task name, description, action, trigger, and principal.
    5. Sets the task triggers to repeat the task every 5 minutes for a duration of one day.
    6. Updates the task with the defined triggers.

.PARAMETER TaskName
    The name of the task to be created.

.PARAMETER TaskDescription
    A brief description of the task.

.PARAMETER TaskScriptPath
    The full path of the PowerShell script to be executed by the task.

.PARAMETER gMSAAccount
    The name of the Group Managed Service Account (gMSA) to run the task.
#>

.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier0 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier0,OU=company,DC=int,DC=domain,DC=com' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier0,OU=company,DC=int,DC=domain,DC=com'" -gMSAAccount "SGLifeCMGMT"

.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier1 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier1,OU=company,DC=int,DC=domain,DC=com' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier1,OU=company,DC=int,DC=domain,DC=com'" -gMSAAccount "SGLifeCMGMT"
```

#Import GPOs
```powershell
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
#>
 .\ImportGPO.ps1 -GPOName "Server - Local Users and Groups" -BackupPath "C:\source\LocalGroupMembershipLifeCylceMaintenance\Server - Local Users and Groups.zip" -BackupGpoName 'Server - Local Users and Groups'
```
