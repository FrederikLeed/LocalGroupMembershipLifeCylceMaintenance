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

.EXAMPLE
    .\script.ps1 -TaskName "MyScheduledTask" -TaskDescription "This task executes a PowerShell script every 5 minutes" -TaskScriptPath "C:\scripts\server_group_lifecycle.ps1" -gMSAAccount 'SGLifeCMGMT'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskName,
    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,
    [Parameter(Mandatory=$true)]
    [string]$TaskScriptPath,
    [Parameter(Mandatory=$false)]
    [string]$TaskScriptArgument,
    [Parameter(Mandatory=$true)]
    [string]$gMSAAccount
)

try {
    # Create an action for the task - what the task should do
    if($TaskScriptArgument){
        $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command $TaskScriptPath $TaskScriptArgument"
    }else{
        $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command $TaskScriptPath"
    }

    # Set the trigger for the task - when the task should be run
    $TaskTrigger = New-ScheduledTaskTrigger -Daily -At (Get-Date).Date

    # Create principal to run the scheduled task
    $Principal =  New-ScheduledTaskPrincipal -UserID ($gMSAAccount + "$") -LogonType Password

    # Register the task with all the information
    $task = Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Action $TaskAction -Trigger $TaskTrigger -Principal $Principal

    # Set task triggers
    $task.Triggers.Repetition.Duration = "P1D" #Repeat for a duration of one day
    $task.Triggers.Repetition.Interval = "PT5M" #Repeat every 5 minutes, use PT1H for every hour
    $task | Set-ScheduledTask

    Write-Host "Scheduled task $TaskName created successfully."
} 
catch {
    Write-Host $_.Exception.Message
}
