$a = 'a_wif'
$profileFolder = 'C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\_side_profiles'
$rename = $true
$RenameAfter = !($a -match 'a_') -or $rename
$cloneIfempty = $true


function RenameAsCopyMoveTask{}

function SelectItemFromListBox($list)
{

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select a Computer'
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

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a computer:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80

$list | %{
[void] $listBox.Items.Add($_)
}

$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
    $x
}
}

#--allow-profiles-outside-user-dir 
#--allowlisted-extension-id ⊗	Adds the given extension ID to all the permission allowlists. ↪
#--apps-gallery-download-url ⊗	The URL that the webstore APIs download extensions from. Note: the URL must contain one '%s' for the extension ID. ↪
#--copy-to-download-dir ⊗	Copy user action data to download directory. ↪

$profilex = $a
$presentFolders = Get-ChildItem -Path $profileFolder -Directory | Sort-Object -Property name, LastWriteTime -Descending 
$presentFolders             

$SelectedFolder = ( $presentFolders   |
                ? { $_.name -eq $profilex} |
                    select name -First 1).Name

if(!($SelectedFolder))
{
    $toRename = (selectItemFromListBox -list $presentFolders)
                
    $toRename | Rename-Item -NewName $profilex

    $SelectedFolder = ( (Get-ChildItem -Path $profileFolder -Directory)   |
              ? { $_.name -eq $profilex} |
               select name -First 1).Name
}


function Launch_opera_profile ($profile) {
$param = '--side-profile-name=' +'"'+ $profile+'"'
$AllArgs = @($param, ' --with-feature:side-profiles --no-default-browser-check')

echo $AllArgs

    $processOptions = @{
        FilePath = "C:\Program Files\Opera GX\launcher.exe"
        ArgumentList = $AllArgs
    }

Start-Process @processOptions -Wait 

}
#'353238305F393330303834303437' 
Launch_opera_profile $SelectedFolder 
if($RenameAfter)
{
    echo "after waiting"

    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

    $title = 'Do you want to rename '+$profilex
    $msg   = 'NewName:'

    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    if($text)
    {
    ($profileFolder | Join-Path -ChildPath $profilex) | Rename-Item -NewName $text
    }
    else
    {
    echo "empty"
    }


}