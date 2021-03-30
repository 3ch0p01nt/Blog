$working_directory = "C:\PowerShell_Scripts\Exchange\" ##This is the directory your data will be processed in and out of

##### Create a new folder for today ######
$test = test-path -PathType container -path "$working_directory$((Get-Date).ToString('yyyy-MM-dd'))"
$root_dir = test-path -PathType Container -path $working_directory
$todaysfolder = "$working_directory$env:USERNAME\$((Get-Date).ToString('yyyy-MM-dd'))" 
if ($root_dir -eq $false) #Test for root directory
{New-Item -ItemType Directory -Path $working_directory | Out-Null} 
if ($test -eq $false) #Test for todays folder
{New-Item -ItemType Directory -Path "$working_directory$env:USERNAME\$((Get-Date).ToString('yyyy-MM-dd'))" | Out-Null}
#$outputpath = $todaysfolder + "\" + $ip + "_AzureADAuditSigninLogs_IP.csv"
#$dater = get-azureadauditsigninlogs -filter "IpAddress eq '$ip'"
#$Report1 = [System.Collections.Generic.List[Object]]::new()
#$cleanoutfile = $Path + '\' + 'User_clean.csv'
########## End Folder for today #########




$accounts = Get-exoMailbox -Results unlimited -RecipientTypeDetails UserMailbox,SharedMailbox| Select-Object Alias | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 #Get list of accounts and Skip Alias
$accounts | out-file $todaysfolder\accounts.csv 

#$accounts | export-csv $todaysfolder\accounts.csv -NoTypeInformation  ##List of all accounts


$bks = "\" # This variable is used when directory variables do not have a trailing backslash
$todaysdate =  (Get-Date).ToString('yyyyMMdd')  # Todays Date
$SourceFileName="accounts" #Source File Name
$ext = ".csv"   # Declare File Extentsion
$filename = $todaysfolder +"\" + $SourceFileName + $ext   #Source File location and File Name
$rootName = $todaysfolder      # Split File Location 
$moveFileLocation = $todaysfolder + "\" + $SourceFileName + $ext #Move File location and File Name
$renameFileName=$SourceFileName+$ext #Rename File
$by3 = $accounts.Count/3 #divide total number of accounts by 3 
$rounded = [math]::ceiling($by3)   # round $by3 up to next number 
$linesperFile = $rounded #Number of Line Records
$filecount = 1
$reader = $null

if (Test-Path $filename)
{
try{
$reader = [io.file]::OpenText($filename)
try{
"Creating file number $filecount"
$writer = [io.file]::CreateText("{0}{1}{2}{3}{4}" -f ($rootName,$bks,$todaysdate,$filecount.ToString("000"),$ext)) #Inside brackets corelate to the other brackets
$filecount++
$linecount = 0
while($reader.EndOfStream -ne $true) {
"Reading $linesperFile"
while( ($linecount -lt $linesperFile) -and ($reader.EndOfStream -ne $true)){
$writer.WriteLine($reader.ReadLine());
$linecount++
}
if($reader.EndOfStream -ne $true) {
"Closing file"
$writer.Dispose();
"Creating file number $filecount"
$writer = [io.file]::CreateText("{0}{1}{2}{3}{4}" -f ($rootName,$bks,$todaysdate,$filecount.ToString("000"),$ext))
$filecount++
$linecount = 0
}
}
} finally {
$writer.Dispose();
}
} finally {
$reader.Dispose();
}
Write-Host "Move File Started to " $filename $moveFileLocation
Move-Item $filename $moveFileLocation
Write-Host "Rename File " $moveFileLocation "  -----  " $renameFileName
Rename-Item $moveFileLocation $renameFileName

}
else
{
Write-Host "No File Found to Process " $filename 
}
#$sw.Stop()
#Write-Host "Time Taken " $sw.Elapsed.TotalSeconds "seconds"


###Create a function to get the mailbox attributes of interest
#


#$destinationfolderpath = "c:\temp\rob\"
#$accounts | export-csv C:\temp\rob\2020-11-06\accounts.csv -NoTypeInformation


cd $rootName
#Start-Process -FilePath 'PowerShell.exe' -ArgumentList '-NoExit',"-command `"COMMANDHERE`""
$files = gci $rootname | findstr $todaysdate
$filenames = $files -split " " | findstr .csv ##Only grab the filename
$filename1 = $rootName+ "\" + $todaysdate+"001.csv"
$filename2 = $rootName+ "\" + $todaysdate+"002.csv"
$filename3 = $rootName+ "\" + $todaysdate+"003.csv"

$userlist_1 = get-content $filename1| ForEach-Object {$_ -replace '"',''} 
$userlist_2 = get-content $filename2| ForEach-Object {$_ -replace '"',''}
$userlist_3 = get-content $filename3| ForEach-Object {$_ -replace '"',''}
#$userlist_4 = get-content $filename4| ForEach-Object {$_ -replace '"',''}
$userlist_1 | out-file "noquoteusers_1.txt"
$userlist_2 | out-file "noquoteusers_2.txt"
$userlist_3 | out-file "noquoteusers_3.txt"
#$userlist_4 | out-file "noquoteusers_4.txt"

$path1 = $working_directory + 'email_pull_1.ps1'
$path2 = $working_directory + 'email_pull_2.ps1'
$path3 = $working_directory + 'email_pull_3.ps1'

get-pssession | Remove-PSSession #Kill your active session so you can use the connection to query permissions
Start-Process -FilePath 'PowerShell.exe' -ArgumentList '-NoExit',"-command $path1"
Start-Process -FilePath 'PowerShell.exe' -ArgumentList '-NoExit',"-command $path2"
Start-Process -FilePath 'PowerShell.exe' -ArgumentList '-NoExit',"-command $path3"
