<#
To write a Pester script that tests the functions Sort-ListWithConstraints, Detect-CyclesInDirectedGraph and DFS, you need to follow these steps:

- Create a file named Sort-ListWithConstraints.Tests.ps1 in the same folder as the module file that contains the functions. This file will contain the Pester tests for the functions.
- Import the module file in the test file using Import-Module .\Sort-ListWithConstraints.psm1
- Use the Describe block to group the tests for each function. The Describe block takes a name and a script block as parameters. The name should describe the function being tested, and the script block should contain the tests for that function.
- Use the Context block to group the tests for different scenarios or cases for each function. The Context block takes a name and a script block as parameters. The name should describe the scenario or case being tested, and the script block should contain the tests for that scenario or case.
- Use the It block to define each individual test for each function and scenario. The It block takes a name and a script block as parameters. The name should describe what the test is checking, and the script block should contain the code to perform the test.
- Use the Should function to assert the expected outcome of each test. The Should function takes various parameters to specify different types of assertions, such as -Be, -BeExactly, -BeGreaterThan, -Throw, etc. You can also use -Not to negate any assertion.
- Use the Mock function to replace the behavior of any command inside of a piece of PowerShell code being tested. The Mock function takes various parameters to specify which command to mock, what parameters to match, what output to return, etc.

Here is an example of how you can write a Pester script that tests the functions Sort-ListWithConstraints, Detect-CyclesInDirectedGraph and DFS:

# Import the module file#>
Import-Module .\Sort-ListWithConstraints.psm1

# Test the Sort-ListWithConstraints function
Describe 'Sort-ListWithConstraints' {
    # Test different scenarios with different lists and constraints
    Context 'Given an empty list' {
        It 'Returns an empty list' {
            $list = @()
            $constraints = @()
            $sorted = Sort-ListWithConstraints $list $constraints
            $sorted | Should -BeNullOrEmpty
        }
    }
    Context 'Given a list with one item' {
        It 'Returns the same list' {
            $list = @("A")
            $constraints = @()
            $sorted = Sort-ListWithConstraints $list $constraints
            $sorted | Should -BeExactly $list
        }
    }
    Context 'Given a list with multiple items and no constraints' {
        It 'Returns the same list' {
            $list = @("A", "B", "C", "D", "E")
            $constraints = @()
            $sorted = Sort-ListWithConstraints $list $constraints
            $sorted | Should -BeExactly $list
        }
    }
    Context 'Given a list with multiple items and some constraints' {
        It 'Returns a sorted list according to the constraints' {
            $list = @("A", "B", "C", "D", "E")
            $constraints = @(("A", "B"), ("B", "C"), ("D", "E"), ("E", "F"), ("A", "F"))
            $sorted = Sort-ListWithConstraints $list $constraints
            $sorted | Should -BeExactly @("D", "A", "B", "E", "C")
        }
    }
}

# Test the Detect-CyclesInDirectedGraph function
Describe 'Detect-CyclesInDirectedGraph' {
    # Test different scenarios with different nodes and edges
    Context 'Given an empty graph' {
        It 'Returns false' {
            $nodes = @()
            $edges = @()
            $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
            $hasCycle | Should -BeFalse
        }
    }
    Context 'Given a graph with one node and no edges' {
        It 'Returns false' {
            $nodes = @("A")
            $edges = @()
            $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
            $hasCycle | Should -BeFalse
        }
    }
    Context 'Given a graph with multiple nodes and no edges' {
        It 'Returns false' {
            $nodes = @("A", "B", "C", "D", "E")
            $edges = @()
            $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
            $hasCycle | Should -BeFalse
        }
    }
    Context 'Given a graph with multiple nodes and some edges without cycles' {
        It 'Returns false' {
            $nodes = @("A", "B", "C", "D", "E")
            $edges = @(("A", "B"), ("B", "C"), ("C", "D"), ("D", "E"))
            $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
            $hasCycle | Should -BeFalse
        }
    }
    Context 'Given a graph with multiple nodes and some edges with cycles' {
        It 'Returns true' {
            $nodes = @("A", "B", "C", "D", "E")
            $edges = @(("A", "B"), ("B", "C"), ("C", "D"), ("D", "E"), ("E", "B"))
            $hasCycle = Detect-CyclesInDirectedGraph $nodes $edges
            $hasCycle | Should -BeTrue
        }
    }
}

# Test the DFS function
Describe 'DFS' {
    # Test different scenarios with different nodes and edges
    Context 'Given an empty graph' {
        It 'Returns an empty stack' {
            Mock Detect-CyclesInDirectedGraph { return $false } -Verifiable
            Mock Sort-ListWithConstraints { return @() } -Verifiable
            Mock DFS { return @() } -Verifiable
            $nodes = @()
            $edges = @()
            DFS | Should -BeNullOrEmpty
            Assert-VerifiableMocks
        }
    }
    Context 'Given a graph with one node and no edges' {
        It 'Returns a stack with one node' {
            Mock Detect-CyclesInDirectedGraph { return $false } -Verifiable
            Mock Sort-ListWithConstraints { return @("A") } -Verifiable
            Mock DFS { return @("A") } -Verifiable
            $nodes = @("A")
            $edges = @()
            DFS | Should -BeExactly @("A")
            Assert-VerifiableMocks
        }
    }
    Context 'Given a graph with multiple nodes and no edges' {
        It 'Returns a stack with the same nodes as the graph' {
            Mock Detect-CyclesInDirectedGraph { return $false } -Verifiable
            Mock Sort-ListWithConstraints { return @("A", "B", "C", "D", "E") } -Verifiable
            Mock DFS { return @("A", "B", "C", "D", "E") } -Verifiable
            $nodes = @("A", "B", "C", "D", "E")
            $edges = @()
            DFS | Should -BeExactly @("A", "B", "C", "D", "E")
            Assert-VerifiableMocks
        }
    }
    Context 'Given a graph with multiple nodes and some edges without cycles' {
        It 'Returns a stack with the sorted nodes according to the edges' {
            Mock Detect-CyclesInDirectedGraph { return $false } -Verifiable
            Mock Sort-ListWithConstraints { return @("A", "B", "C", "D") } -Verifiable
            Mock DFS { return @("A", "B", "C", "D") } -Verifiable
            $nodes = @("A", "B", "C", "D")
            $edges = @(("A", "B"), ("B", "C"), ("C", "D"))
            DFS | Should -BeExactly @("A", "B", "C", "D")
            Assert-VerifiableMocks
        }
    }
    Context 'Given a graph with multiple nodes and some edges with cycles' {
        It 'Throws an exception' {
            Mock Detect-CyclesInDirectedGraph { return $true } -Verifiable
            Mock Sort-ListWithConstraints { throw [System.InvalidOperationException]::new('Cycle detected in the graph') } -Verifiable
            Mock DFS { throw [System.InvalidOperationException]::new('Cycle detected in the graph') } -Verifiable
            $nodes = @("A", "B", "C")
            $edges = @(("A","B"), ("B","C"), ("C","A"))
            { DFS } | Should -Throw 'Cycle detected in the graph'
            Assert-VerifiableMocks
        }
    }
}

<#
Källa: Konversation med Bing, 2023-07-18
(1) Invoke-Pester - PowerShell Command | PDQ. https://www.pdq.com/powershell/invoke-pester/.
(2) Quick Start | Pester. https://pester.dev/docs/quick-start/.
(3) Getting Started with Pester Testing in PowerShell. https://jeffbrown.tech/getting-started-with-pester-testing-in-powershell/.
(4) Test PowerShell code with Pester. https://techcommunity.microsoft.com/t5/azure-developer-community-blog/test-your-powershell-code-with-pester/ba-p/2835759.
#>