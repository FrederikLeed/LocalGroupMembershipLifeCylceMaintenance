

#Prepare script environment

.\PrepareScriptEnv.ps1

#Copy scripts to server

#Clone repo, copy server_group_lifecycle.ps1 from source folder to scripts folder

#Create gMSA

.\NewgMSA.ps1 -gmsaname "SGLifeCMGMT" -server "azureapp02"

#Delegate permissions

.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier0,OU=weritadmin,DC=int,DC=werit,DC=dk" -DelegationObject "SGLifeCMGMT"
.\DelegateGroupLifecyclePermission.ps1 -TargetOU "OU=Servers,OU=Groups,OU=Tier1,OU=weritadmin,DC=int,DC=werit,DC=dk" -DelegationObject "SGLifeCMGMT"

#Schedule tasks

.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier0 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier0,OU=weritadmin,DC=int,DC=werit,DC=dk' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier0,OU=weritadmin,DC=int,DC=werit,DC=dk'" -gMSAAccount "SGLifeCMGMT"
.\Create_Scheduled_task_gmsa.ps1 -TaskName "Tier1 Server Group LifeCycle Management" -TaskDescription "Automatic group provisioning and deprovisioning based on computerobjects" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -TaskScriptArgument "-ServerSearchbase 'OU=Tier1,OU=weritadmin,DC=int,DC=werit,DC=dk' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier1,OU=weritadmin,DC=int,DC=werit,DC=dk'" -gMSAAccount "SGLifeCMGMT"


#Import GPOs
 .\ImportGPO.ps1 -GPOName "Server - Local Users and Groups" -BackupPath "C:\source\LocalGroupMembershipLifeCylceMaintenance\Server - Local Users and Groups.zip" -BackupGpoName 'Server - Local Users and Groups'

 C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "& 'C:\Scripts\Get-HyperVReport.ps1' -ClusterName MyCluster -SendMail $true -SMTPServer smtp.mail.com -MailFrom hyper-v@mail.com -MailTo some.mail@mail.com"

 powershell.exe -Command C:\scripts\server_group_lifecycle.ps1 -ServerSearchbase 'OU=Tier1,OU=weritadmin,DC=int,DC=werit,DC=dk' -GroupTargetPath 'OU=Servers,OU=Groups,OU=Tier1,OU=weritadmin,DC=int,DC=werit,DC=dk'