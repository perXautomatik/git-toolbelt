<#There are a few ways to get the content of a HTML element in PowerShell. One way is to use the **HTMLFile** COM object and the **IHTMLDocument2_write** method to parse the HTML content, then use the **getElementById** or **getElementsByClassName** methods to access the element you want. You can then use the **innerHTML** or **innerText** properties to get the content of the element¹². For example:

```powershell#>
add-type 'C:\Program Files $(x86$)\Microsoft SQL Server Management Studio 18\Common7\IDE\Mashup\Microsoft.mshtml.dll'


#using assembly $dllPath

$q = New-TemporaryFile
GET-CLipboard | Set-Content ($q) 
 
$content = $q | Get-Content -Raw

$classname = 'br'

$html = New-Object -ComObject "HTMLFile"
#$content = Get-Content -Path "test.html" -Raw
$html.IHTMLDocument2_write($content)

$body = $html.body

<#```

Another way is to cast the HTML content as an XML object and use the **where** clause to filter the elements by their attributes¹. For example:

```powershell#>
#$content = Get-Content -Path "test.html"

#$xmlContent = [xml]$content
[XML]$xmlContent = [String]$content

$body = $xmlContent.html.body

$bar1 = $body.getElementsByClassName($classname)[0]
$bar1.innerText


$bar = $body.div | where {$_.div -eq $classname}
$bar.InnerXML
<#```

You can also use external libraries like **HtmlAgilityPack** to parse HTML files in PowerShell, but that would require installing the library first.

I hope this helps you with your task.😊

Source: Conversation with Bing, 2023-06-29
(1) Returning the contents of a HTML div with Powershell. https://stackoverflow.com/questions/26465672/returning-the-contents-of-a-html-div-with-powershell.
(2) Get content of an HTML Com Object in Powershell. https://stackoverflow.com/questions/48200098/get-content-of-an-html-com-object-in-powershell.
(3) Get-Content (Microsoft.PowerShell.Management) - PowerShell. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.3.
#>

