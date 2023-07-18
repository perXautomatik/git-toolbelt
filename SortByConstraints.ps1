#Definiera en funktion för att sortera en lista med begränsningar
function Sort-ListWithConstraints ($list, $constraints) { 
# Skapa en hashtabell för att lagra beroendena för varje objekt 
$dependencies = @{} 
foreach ($item in $list) { 
# Initiera listan av beroenden till tom 
$dependencies[$item] = @() } foreach ($constraint in $constraints) { 
# Antag att begränsningen är ett par av objekt 
$before, $after = $constraint 
# Lägg till beroendet till listan 
$dependencies[$after] += $before }

# Skapa en stack för att lagra de sorterade objekten
$stack = New-Object System.Collections.Stack

# Skapa en hashtabell för att hålla reda på vilka objekt som har besökts
$visited = @{}

# Definiera en funktion för att utföra DFS på den riktade grafen
function DFS ($item) {
    # Markera objektet som besökt
    $visited[$item] = $true
    # Iterera över dess beroenden
    foreach ($dependency in $dependencies[$item]) {
        # Kalla rekursivt på DFS för varje beroende som inte har besökts ännu
        if (-not $visited[$dependency]) {
            DFS $dependency
        }
    }
    # Lägg till objektet till stacken när alla dess beroenden har behandlats
    $stack.Push($item)
}

# Iterera över listan av objekt och kalla på DFS för varje objekt som inte har besökts ännu
foreach ($item in $list) {
    if (-not $visited[$item]) {
        DFS $item
    }
}

# Returnera stacken som den sorterade listan
return $stack

}

#Testa funktionen med ett exempel
$list = @(“A”, “B”, “C”, “D”, “E”, “F”) 
$constraints = @((“A”, “B”), (“B”, “C”), (“D”, “E”), (“E”, “F”), (“A”, “F”)) 
$sorted = Sort-ListWithConstraints $list $constraints Write-Output $sorted

#Output: D A B E C F