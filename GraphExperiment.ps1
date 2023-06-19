# Define the names of the two files to compare
$importFolder = "B:\PF\Gephi"
$file1 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar_dodorz.json"
$file2 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar.json"
# Load the assemblies for System.Windows.Forms and System.Windows.Forms.DataVisualization.Charting

function PrefixDupes($a)
{

    # Assuming $a and $b are two string arrays
    # Creating an empty hashtable $ha
    $ha = @{}


    # Defining a recursive function that takes a string $l as a parameter
    function recursive ($l) {

        # Checking if $ha does not contain the key $l
        if (!$ha.ContainsKey($l)) {

            # Assigning the value of $i to the key $l
            $ha[$l] = $i

        } else {

            # Storing the value of $ha[$l] in a variable $q
            $q = $ha[$l]

            # Calling the recursive function with a new key "$l+1"
            recursive ("$l+1")

            # Assigning the value of $q to the new key "$l+1"
            $ha["$l+1"] = $q

        }
    }


    # Looping through the elements of $a
    for ($i = 0; $i -lt $a.length; $i++) {

        # Calling the recursive function with the element of $a at index $i
        recursive ($a[$i])
    }

    # Sorting the hashtable by value and displaying the result
    $ha.GetEnumerator() | Sort-Object Value
}


# Read the lines of the text files and store them in arrays
$lines1 = PrefixDupes (Get-Content $file1) 
$lines2 = PrefixDupes (Get-Content $file2) 

# Create a CSV file for the node list
$nodeFile = "$importFolder\nodes.csv"
$nodeHeader = "Id,Label"
$nodeHeader | Out-File $nodeFile

foreach ($lines in @($lines1,$lines2))
{
    # Add the lines of the first text file as nodes with a prefix of 1
    foreach ($keyvalues in $lines) {
        $label = $keyvalues.value
        $id = [$keyvalues.key
        "$id,$label" | Out-File $nodeFile -Append
    }
}

# Create a CSV file for the edge list
$edgeFile = "$importFolder\edges.csv"
$edgeHeader = "Source,Target,Type"
$edgeHeader | Out-File $edgeFile
foreach ($lines in @($lines1,$lines2))
{
    # Add the edges between the lines of the first text file as directed edges with a prefix of 1
    for ($i = 0; $i -lt ($lines1.Count - 1); $i++) {
        $source = $lines1[$i]
        $target = $lines1[$i+1]
        "$source,$target,Directed" | Out-File $edgeFile -Append
    }
}

# Import the CSV files into Gephi using the Data Laboratory