# LocalGroupMembershipLifeCylceMaintenance
Bits and bytes to create a fully automated solution where AD computers local groups are managed and the lifecycle of groups in ad maintained




#Prepare script environment

.\PrepareScriptEnv.ps1

#Copy scripts to server

#Clone repo, copy server_group_lifecycle.ps1 from source folder to scripts folder

#Create gMSA

.\NewgMSA.ps1 -gmsaname "SGLifeCMGMT" -server "scriptserver01"

#Delegate permissions

.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier0,OU=company,DC=int,DC=domain,DC=com" -DelegationObject "SGLifeCMGMT"
.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier1,OU=company,DC=int,DC=domain,DC=com" -DelegationObject "SGLifeCMGMT"

#Scheduled tasks

.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier0 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier0,OU=company,DC=int,DC=domain,DC=com' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier0,OU=company,DC=int,DC=domain,DC=com'" -gMSAAccount "SGLifeCMGMT"
.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier1 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier1,OU=company,DC=int,DC=domain,DC=com' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier1,OU=company,DC=int,DC=domain,DC=com'" -gMSAAccount "SGLifeCMGMT"


#Import GPOs
 .\ImportGPO.ps1 -GPOName "Server - Local Users and Groups" -BackupPath "C:\source\LocalGroupMembershipLifeCylceMaintenance\Server - Local Users and Groups.zip" -BackupGpoName 'Server - Local Users and Groups'
