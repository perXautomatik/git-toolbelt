function compareObjectWithBeyondCompare() {
    param (
    $file1,
    $file2
    )

    $u = New-TemporaryFile

    $d = 'file-report layout:statistics &
output-to:clipboard &
 output-options:html-color "%1" "%2"'

    $d | Set-Content -Path $u

    $scriptPath = "@$u"

    bcomp $scriptPath $file1 $file2   # sets clipboard 
 
     function bCompare-HtmlReportToObject ($htmlContent) 
     {
      $u = (((($htmlContent[$htmlContent.IndexOf("<!--StartFragment-->")..($htmlContent.IndexOf("<!--EndFragment-->")-1)]) -join '') -split '<br>' ) | 
        ? { $_ -match '&nbsp' } ) -replace (' &nbsp;','') ;
      ($u[1] | ConvertFrom-Csv -Header ($u[0] -split ',') ) | 
      select IOriginal,IAdded,IDeleted,IChanged,UOriginal,UAdded,UDeleted,UChanged 
     };

    bCompare-HtmlReportToObject (Get-Clipboard)

}

