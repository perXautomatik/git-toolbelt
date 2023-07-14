# Define the nested hash to sort
$nested = @{
  "b" = 3;
  "a" = @(2, 1);
}

# Convert the hash to json
$json = $nested | ConvertTo-Json

# Invoke ruby with the code that uses deepsort
$output = ruby -e "
require 'json'
require 'deepsort'
nested = JSON.parse('$json')
puts nested.deep_sort.to_json
"

# Convert the output back to a hash
$sorted = $output | ConvertFrom-Json

# Print the sorted hash
$sorted