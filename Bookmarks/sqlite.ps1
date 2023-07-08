
function NewSqliteConnection ($source,$query) { 
	$source
	$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
	$con.ConnectionString = "Data Source=$source"
try {
	$con.Open()

	$sql = $con.CreateCommand()
	$sql.CommandText = $query
	$adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
	$data = New-Object System.Data.DataSet
	[void]$adapter.Fill($data)    
	$data.tables

	}
catch {
$con
}
}        

$query = "select path, rightstr(path,instr(reverse(path),'/')-1) exe from (select max(path) path,max(cast(replace(version,'.','') as integer)) version from applications group by case when online_app_id = 0 then name else online_app_id end)"
$path = "D:\portapps\4. windows check\PortableApps\WhatPulse\whatpulse.db"
newSqliteConnection $path $query
