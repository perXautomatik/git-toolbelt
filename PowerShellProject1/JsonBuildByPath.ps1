# as admin
#Install-Package chilkat-x64


Clear-Host
#then
# might need to everything for the exact path
add-type -Path "C:\Program Files\PackageManagement\NuGet\Packages\chilkat-x64.9.5.0.93\lib\net47\ChilkatDotNet47.dll"

#build your json from paths

$json = New-Object Chilkat.JsonObject

#$json.UpdateString("bookmarks[0].children[0].title","Zoo")
#$json.UpdateString("bookmarks[0].children[0].url","file:///C:/")
#$json.UpdateString("bookmarks[0].title","ToolbarFolder")
#$json.UpdateString("browser","Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0")
#$json.UpdateNumber("createDate","1.65912e+12")
#$json.UpdateString("version","0.0.4")

#$json.toString();
$jsonPath = "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\_side_profiles\a_jap\Bookmarks"
$json.LoadFile($jsonPath)


#' Find the account with the name "Advertising"
$arrayPath = "QueryResponse.Account"
$relativePath = "Name"
$value = "Advertising"
$caseSensitive = 1

#' accountRec is a Chilkat_9_5_0.JsonObject
#$res = $json.FindRecord($arrayPath,$relativePath,$value,$caseSensitive)
#$res.ToString()

#$q = $json.FindObjectWithMember("url")
#$q = $json.FindObjectWithMember("trash")
#$q = $json.sizeOfArray("roots")
$q = $json.ArrayOf("roots.custom_root.speedDial.children")

$q.ToString()

#$psObject = (get-content -Path $jsonPath | ConvertFrom-Json)