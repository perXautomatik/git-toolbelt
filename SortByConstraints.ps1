<#Define a function to detect cycles in a directed graph#>
function Detect-CyclesInDirectedGraph ($nodes, $edges) { 
# Create a hashtable to store the adjacent nodes for each node 
$adjacent = @{} 
foreach ($node in $nodes) { 
# Initialize the list of adjacent nodes to empty 
$adjacent[$node] = @() } foreach ($edge in $edges) { 
# Assume that the edge is a pair of nodes 
$from, $to = $edge 
# Add the adjacent node to the list 
$adjacent[$from] += $to }

# Create a stack to store the sorted nodes
$stack = New-Object System.Collections.Stack

# Create a hashtable to keep track of which nodes have been visited
$visited = @{}

# Create another hashtable to keep track of which nodes are in the recursion stack
$recStack = @{}

# Define a function to perform DFS on the directed graph
function DFS ($node) {
    # Mark the node as visited
    $visited[$node] = $true
    # Mark the node as in the recursion stack
    $recStack[$node] = $true
    # Iterate over its adjacent nodes
    foreach ($adjNode in $adjacent[$node]) {
        # Call recursively DFS for each node that has not been visited yet
        if (-not $visited[$adjNode]) {
            if (DFS $adjNode) {
                return $true
            }
        }
        # If an adjacent node is already in the recursion stack, there is a cycle in the graph
        elseif ($recStack[$adjNode]) {
            return $true
        }
    }
    # Unmark the node from the recursion stack when all its adjacent nodes have been processed
    $recStack[$node] = $false
    # Add the node to the stack when it is popped from the recursion stack
    $stack.Push($node)
    return $false
}

# Iterate over the list of nodes and call DFS for each node that has not been visited yet
foreach ($node in $nodes) {
    if (-not $visited[$node]) {
        if (DFS $node) {
            return $true
        }
    }
}
return $false

}

#Test the function with an example
$nodes = @(“A”, “B”, “C”, “D”, “E”)
 $edges = @((“A”, “B”), (“B”, “C”), (“C”, “D”), (“D”, “E”), (“E”, “B”))
  $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
   Write-Output $hasCycle