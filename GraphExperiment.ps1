$bytes = [System.IO.File]::ReadAllBytes('C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.dll')
[System.Reflection.Assembly]::Load($bytes)

# Define the names of the two files to compare
$file1 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar_dodorz.json"
$file2 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar.json"

# Run git diff command and capture the output
$command = "git diff --no-index $file1 $file2"
$output = Invoke-Expression $command

# Count the number of lines that are different in each file
$diff1 = ($output | Select-String "^- ").Count
$diff2 = ($output | Select-String "^\+ ").Count

# Load the assembly for System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms

# Create a directed graph with System.Windows.Forms.DataVisualization.Charting
$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Width = 300
$chart.Height = 300

# Add a series for the nodes and set the chart type to Pie
$series = $chart.Series.Add("Nodes")
$series.ChartType = "Pie"

# Add the files as points and label them with the number of differences
$series.Points.AddXY("$file1 ($diff1)", $diff1)
$series.Points.AddXY("$file2 ($diff2)", $diff2)

# Add a series for the edge and set the chart type to Line
$series = $chart.Series.Add("Edge")
$series.ChartType = "Line"

# Add an edge from the file with more differences to the file with less differences
if ($diff1 -gt $diff2) {
    $series.Points.AddXY(0.25, 0.5)
    $series.Points.AddXY(0.75, 0.5)
}
else {
    $series.Points.AddXY(0.75, 0.5)
    $series.Points.AddXY(0.25, 0.5)
}

# Save the chart as an image file
$chart.SaveImage("graph.png", "PNG")
