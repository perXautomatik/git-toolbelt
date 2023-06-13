[cmdletbinding()]
param(
    $SyncHash
)
#-------------------------------------------------------------#
#----XML Form Declarations------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Windows.Forms

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="300" Height="600"
    HorizontalAlignment="Left"
    VerticalAlignment="Top" Margin="0,0,0,0" WindowStartupLocation="CenterScreen" Topmost="true">
    <Grid>
        <StackPanel Orientation="Vertical">
            <DockPanel>
                <Menu VerticalAlignment="Top" HorizontalAlignment="Left" Height="20" Width="160">
                    <MenuItem Header="File">
                        <MenuItem Header="New" Name="MenuNew" />
                        <MenuItem Header="Open" Name="MenuOpen" />
                        <MenuItem Header="Save" Name="MenuSave" />
                        <Separator />
                        <MenuItem Header="Exit" Name="MenuExit" />
                    </MenuItem>
                    <MenuItem Header="Edit">
                        <MenuItem Header="Cut" Name="MenuCut" />
                        <MenuItem Header="Copy" Name="MenuCopy" />
                        <MenuItem Header="Paste" Name="MenuPaste" />
                    </MenuItem>
                    <MenuItem Header="Help">
                        <MenuItem Header="About" Name="MenuAbout" />
                        <Separator />
                        <MenuItem Header="Help" Name="MenuHelp" />
                    </MenuItem>
                </Menu>
            </DockPanel>
            <Border BorderBrush="Black" BorderThickness="1">
                <Grid>
                    <StackPanel>
                        <DataGrid Margin="0,0,0,0" HorizontalAlignment="Left"
                            VerticalAlignment="Top"
                            AutoGenerateColumns="False" CanUserAddRows="False" Name="DG_Clipboard"
                            ItemsSource="{Binding Clipboard}" Height="600" Width="300">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="Clipboard Item" Binding="{Binding Item}" />
                            </DataGrid.Columns>
                        </DataGrid>
                        <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                            <Button Name="Btn_Clear" Content="Clear History" Width="100" Height="20"
                                Margin="0,0,5,0"
                                HorizontalAlignment="Left" VerticalAlignment="Top" />
                            <TextBox Name="TxtBox_ClipboardSearch" Width="200" Height="20"
                                Margin="0,0,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" />
                        </StackPanel>
                    </StackPanel>
                </Grid>
            </Border>
        </StackPanel>
    </Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Form Creation--------------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)
[xml]$xml = $Xaml
$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }
#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#

$MenuExit.Add_Click({ $Window.Close() })
$MenuAbout.Add_Click({ New-PopUpBox -Title "About" -Message $State.About })
$MenuHelp.Add_Click({ Start-process "https://www.the-ostrich.com" })
$MenuNew.Add_Click({ "" })
$MenuOpen.Add_Click({ "" })
$MenuSave.Add_Click({ "" })
$MenuCut.Add_Click({ "" })
$MenuCopy.Add_Click({ "" })
$MenuPaste.Add_Click({ "" })
$DG_Clipboard.Add_CurrentCellChanged({
        $State.CopiedToClipBoard = $DG_Clipboard.CurrentCell.item.item
        _SetClipboard
    })
$TxtBox_ClipboardSearch.Add_TextChanged({
        _SearchDatagridRows -SearchText $TxtBox_ClipboardSearch.Text
    })
$Btn_Clear.Add_Click({
        _ClearClipboard
    })

#-------------------------------------------------------------#
#----Functions------------------------------------------------#
#-------------------------------------------------------------#
Function New-PopUpBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    [System.Windows.MessageBox]::show($Message, $Title)
}
Function _Clipboard {
    param(
        [String]$Text
    )
    if ($State.ClearClipboardHistory -eq "1") {
        $State.PreviousClipboard.Clear()
        $State.CopiedToClipboard.Clear()
        $State.Clipboard.Clear()
        [System.Windows.Clipboard]::Clear()
        $State.ClearClipboardHistory = "0"
        return
    }
    $State.PreviousClipboard = [System.Windows.Clipboard]::GetText()
    if ($state.Clipboard[-1].Item -eq $state.PreviousClipboard) {
        return
    }
    elseif (([System.Windows.Clipboard]::GetText() -eq $State.CopiedToClipBoard)) {
        return
    }
    Else {
        $o = [PSCustomObject]@{
            Item = [System.Windows.Clipboard]::GetText()
        }
        $State.Clipboard.Add($o) | Out-Null
    }
}
Function _SetClipboard {
    $o = $State.CopiedToClipBoard
    [System.Windows.Clipboard]::SetText($o)
}
Function _SearchDatagridRows {
    param(
        [String]$SearchText
    )
    for ($i = 0; $i -lt $DG_Clipboard.ItemContainerGenerator.Items.count ; $i++) {
        if ($DG_Clipboard.ItemContainerGenerator.ContainerFromIndex($i).item.item -notmatch $SearchText) {
            $DG_Clipboard.ItemContainerGenerator.ContainerFromIndex($i).Visibility = "Collapsed"
        }
        else {
            $DG_Clipboard.ItemContainerGenerator.ContainerFromIndex($i).Visibility = "Visible"
        }
    }
}
Function _ClearClipboard {
    $State.ClearClipboardHistory = "1"
}
#-------------------------------------------------------------#
#----Finalize Form and Bind Objects---------------------------#
#-------------------------------------------------------------#
$Script:IconFile = Get-ChildItem -File -Filter "Icon.ico" -Recurse -Path (Get-Module -Name FTI.ClipboardManager).ModuleBase
if (!($Script:IconFile)) {
    New-PopUpBox -Title "Missing Icon File" -Message "Icon.txt was not found in the module directory."
    break
}
$State = [PSCustomObject]::new()
$DataContext = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
Function _SetBinding {
    Param(
        $Target,
        $Property,
        $Index
    )
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Mode = [System.Windows.Data.BindingMode]::TwoWay
    $Binding.UpdateSourceTrigger = [System.Windows.Data.UpdateSourceTrigger]::PropertyChanged
    $Binding.Path = [System.Windows.PropertyPath]::new("[" + $Index + "]")
    $Target.SetBinding($Property, $Binding) | Out-Null
}
function _FillDataContext {
    param(
        [Parameter(ValueFromPipeline)]$Prop
    )
    begin {
        $i = 0
    }
    process {
        $DataContext.Add($DataObject."$prop")
        $getter = [scriptblock]::Create("Write-Output `$DataContext['$i'] -noenumerate")
        $setter = [scriptblock]::Create("param(`$val) return `$DataContext['$i']=`$val")
        $State | Add-Member -Name $prop -MemberType ScriptProperty -Value  $getter -SecondValue $setter
        $i++
    }
}

$About = @"
    Ostriches can run faster than horses.
    If properly motivated, even an ostrich can fly.

    ____________________________________________

$DataObject = ConvertFrom-Json @"
{
    "About" : "",
    "Clipboard" : "",
    "PreviousClipboard" : "",
    "CopiedToClipBoard" : "",
    "ClearClipboardHistory" : ""
}
"@

$Timer = [System.Windows.Threading.DispatcherTimer]::New()
$Timer.Interval = New-TimeSpan -Seconds 1
$Timer.Add_Tick({ _Clipboard })
$DataContextObjects = @("About", "Clipboard", "PreviousClipboard", "CopiedToClipboard", "ClearClipboardHistory")
$DataContextObjects | _FillDataContext
_SetBinding -Target $DG_Clipboard -Property $([System.Windows.Controls.DataGrid]::ItemsSourceProperty) -Index 1
$Window.DataContext = $DataContext
$State.Clipboard = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
$State.CopiedToClipboard = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
$state.PreviousClipboard = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
$State.About = $About
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $Base64Icon = [Convert]::ToBase64String((Get-Content -Path $Script:IconFile.FullName -Encoding Byte) )
}
else {
    $Base64Icon = [Convert]::ToBase64String((Get-Content -Path $Script:IconFile.FullName -AsByteStream ) )
}
$Bitmap = [System.Windows.Media.Imaging.BitmapImage]::New()
$Bitmap.BeginInit()
$Bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($Base64Icon)
$Bitmap.EndInit()
$Bitmap.Freeze()
#$Window.Icon = $Bitmap
$Timer.Start()
$Window.Add_Closed({
        $Timer.Stop()
    })
$async = $window.Dispatcher.InvokeAsync({
        $window.ShowDialog() | Out-Null
    })
$async.Wait() | Out-Null