# Create a GUI form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI List"
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = "CenterScreen"

# Create a list box
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,10)
$listBox.Size = New-Object System.Drawing.Size(260,200)
$listBox.SelectionMode = "MultiExtended"

# Add some items to the list box
$listBox.Items.Add("Apple")
$listBox.Items.Add("Banana")
$listBox.Items.Add("Cherry")
$listBox.Items.Add("Date")
$listBox.Items.Add("Elderberry")

# Add an event handler for the list box click event
$listBox.Add_Click({
    # Get the selected items as an array
    $selectedItems = $listBox.SelectedItems -join ", "
    # Display a message box with the selected items
    [System.Windows.Forms.MessageBox]::Show("You selected: $selectedItems", "Selection")
})

# Create a button to output the selected items
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,220)
$button.Size = New-Object System.Drawing.Size(75,23)
$button.Text = "Output"

# Add an event handler for the button click event
$button.Add_Click({
    # Get the selected items as an array
    $selectedItems = $listBox.SelectedItems -join ", "
    # Write the selected items to the console
    Write-Host "You selected: $selectedItems"
})

# Add the controls to the form
$form.Controls.Add($listBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()