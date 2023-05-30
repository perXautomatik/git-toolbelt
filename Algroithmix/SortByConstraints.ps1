# Define a function to create a hashtable of dependencies from a list of items and constraints
function Create-DependencyHashtable ($list, $constraints) {
    # Create a hashtable to store the dependencies for each item
    $dependencies = @{}
    foreach ($item in $list) {
        # Initialize the list of dependencies to empty
        $dependencies[$item] = @()
    }
    foreach ($constraint in $constraints) {
        # Assume that the constraint is a pair of items
        $before, $after = $constraint
        # Add the dependency to the list
        $dependencies[$after] += $before
    }
    # Return the hashtable of dependencies
    return $dependencies
}

# Define a function to perform DFS on a directed graph represented by a hashtable of dependencies
function DFS-DirectedGraph ($node, $dependencies, $stack, $visited) {
    # Mark the node as visited
    $visited[$node] = $true
    # Iterate over its dependencies
    foreach ($dependency in $dependencies[$node]) {
        # Call recursively DFS-DirectedGraph for each dependency that has not been visited yet
        if (-not $visited[$dependency]) {
            DFS-DirectedGraph $dependency $dependencies $stack $visited
        }
        # If an adjacent node is already in the recursion stack, there is a cycle in the graph
        elseif ($recStack[$dependency]) {
            return $true
        }
    }
    # Unmark the node from the recursion stack when all its dependencies have been processed
    $recStack[$node] = $false
    # Add the node to the stack when it is popped from the recursion stack
    $stack.Push($node)
    return $false
}

# Define a function to sort a list with constraints using topological sorting
function Sort-ListWithConstraints ($list, $constraints) {
    # Create a hashtable of dependencies using Create-DependencyHashtable function
    $dependencies = Create-DependencyHashtable $list $constraints

    # Create a stack to store the sorted items
    $stack = New-Object System.Collections.Stack

    # Create a hashtable to keep track of which nodes have been visited during the traversal
    $visited = @{}

    # Iterate over the list of items and call DFS-DirectedGraph for each item that has not been visited yet
    foreach ($item in $list) {
        if (-not $visited[$item]) {
            DFS-DirectedGraph $item $dependencies $stack $visited
        }
    }

    # Return the stack as the sorted list
    return $stack
}

# Define a function to detect cycles in a directed graph using DFS
function Detect-CyclesInDirectedGraph ($nodes, $edges) {
    # Create a hashtable of dependencies using Create-DependencyHashtable function
    $dependencies = Create-DependencyHashtable $nodes $edges

    # Create a stack to store the sorted nodes (not used for cycle detection but for consistency with Sort-ListWithConstraints)
    $stack = New-Object System.Collections.Stack

    # Create a hashtable to keep track of which nodes have been visited during the traversal
    $visited = @{}

    # Iterate over the list of nodes and call DFS-DirectedGraph for each node that has not been visited yet
    foreach ($node in $nodes) {
        if (-not $visited[$node]) {
            if (DFS-DirectedGraph $node $dependencies $stack $visited) {
                return $true
            }
        }
    }
    return $false
}
