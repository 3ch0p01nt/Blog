param (
    [parameter(Mandatory = $true)]
    [string]$Name
)

#Connect-ExchangeOnline –CertificateThumbprint $connection.CertificateThumbprint –AppId $connection.ApplicationID –ShowBanner:$false –Organization $tenant
$UserCredential = Get-AutomationPSCredential -Name 'Mailbox_Automation@echopoint.net'
Connect-ExchangeOnline -Credential $UserCredential

$folders = Get-EXOMailboxFolderStatistics -identity $Name |Where-Object {
$_.SearchFolder -eq $false -and
@("Root","Calendar","Inbox","User Created") -contains $_.FolderType -and
(@("IPF.Note","IPF.Appointment",$null) -contains $_.ContainerClass -or $_.Name -eq "Top of Information Store")
} | Select-Object @{Label="Identity";Expression={
if($_.Name -eq "Top of Information Store"){
$_.Identity.Substring(0,$_.Identity.IndexOf("\"))
} else {
$_.Identity.Substring(0,$_.Identity.IndexOf("\"))+':'+$_.Identity.Substring($_.Identity.IndexOf("\")).Replace([char]63743,"/")
}
}}
write-output "------------------------START Mailbox Folder Permissions--------------------"
foreach ($item in $folders)
{
Get-exoMailboxFolderPermission -identity $item.Identity | select Identity,FolderName,User,@{Name=”AccessRights”;Expression={$_.AccessRights}},SharingPermissionFlags | where {$_.AccessRights.tostring() -notlike "None" -and $_.User.tostring() -ne "$Name"}
}
write-output "------------------------ END Mailbox Folder Permissions--------------------"
write-output "---------------------------------------------------------------------------"
write-output "----------------------------START Mailbox Permissions----------------------"
Get-EXOMailboxPermission -identity $Name | select-object Identity,User,@{Name=”AccessRights”;Expression={$_.AccessRights}},IsInherited,Deny,InheritanceType
write-output "----------------------------END Mailbox Permissions----------------------"
