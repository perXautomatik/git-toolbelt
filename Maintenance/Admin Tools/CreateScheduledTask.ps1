// source: https://community.spiceworks.com/topic/2001422-create-scheduled-task-with-run-as-highest-level-whether-user-is-logged-or-not
$jobname = "Recurring PowerShell Task"
$script =  "w32tm /resync"
$action = New-ScheduledTaskAction –Execute "$pshome\powershell.exe" -Argument  "$script"
$duration = ([timeSpan]::maxvalue)
$repeat = (New-TimeSpan -hours 3)
$trigger =New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $repeat -RepetitionDuration $duration

 
$msg = "Enter the username and password that will run the task"; 
$credential = $Host.UI.PromptForCredential("Task username and password",$msg,"$env:userdomain\$env:username",$env:userdomain)
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
 Register-ScheduledTask -TaskName $jobname -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password -Settings $settings