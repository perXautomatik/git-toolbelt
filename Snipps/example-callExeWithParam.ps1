#https://social.technet.microsoft.com/wiki/contents/articles/7703.powershell-running-executables.aspx

$AllArgs = @('filename1', '-someswitch', 'C:\documents and settings\user\desktop\some other file.txt', '-yetanotherswitch')
 
& 'SuperApp.exe' $AllArgs