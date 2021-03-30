## MB 1 of 3 pull

$working_directory = "C:\PowerShell_Scripts\Exchange\"
$todaysfolder = "$working_directory$env:USERNAME\$((Get-Date).ToString('yyyy-MM-dd'))" 
$results_path = $todaysfolder + "\" + "results_1.csv" 
$self = "NT AUTHORITY\SELF"
$file = $todaysfolder + "\" + "noquoteusers_1.txt" 
########## New Function to get specific attributes from MAILBOX############## 


Connect-ExchangeOnline
$users=get-content $file
foreach ($user in $users)
{write-host $user;Get-EXOMailboxPermission -identity $user | 
select-object Identity,User,@{Name=”AccessRights”;Expression={$_.AccessRights}},IsInherited,Deny,InheritanceType |  
where {$_.AccessRights.tostring() -notlike "None" -and $_.User.tostring() -ne "$Name" -and $_.User.tostring() -ne "$self" -and ($_.User -notlike "S-1-5-21*")} | 
Export-CSV -Path $results_path -Append -NoTypeInformation
} ##Output of Permissions


