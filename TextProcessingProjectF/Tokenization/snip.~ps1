#regex pattern to identify a boundary, being a substring of input,

#([{}])(.*)$1 where $2 does not match $1


#considering input as a stream, and each match is a rang of said stream

#if we recursively find boundary pairs and replace them as we go, we should end up with a tokenized content.

#each range match could happen on a separate tread if no concurrent search occurs on overlapping ranges.

#the token key could be a @with a hash key 
#preferably something similar to gits gists

#we can then compare each token and measure there distance.

#and through this method identifying repeated code.




$test = 'function { 
    $hello = "hello" 
    allow(testing)
    output = $hello
    }
    
    addasd'


$test | echo

$inputx = @(

'ext:dll !C:\$ !E:\$ "libeay32"',
'ext:dll !C:\$ !E:\$ "libssl32"',
'ext:dll !C:\$ !E:\$ "linkman"',
'ext:dll !C:\$ !E:\$ "sqlite3.dll"',
'ext:dll !C:\$ !E:\$ "ssleay32.dll"',
'ext:dll !C:\$ !E:\$ sqlite',
'ext:dll !D:\ !E:\$ !C:\$ !C:\windows !E:\windows',
'ext:dll !D:\ !E:\$ !C:\$ !C:\windows !E:\windows !dupe: content:')

$hash = @{}
$inputx | %{    

    $b = $_
    $a = "ext:dll !C:\$ !E:\$"
    $conditionX = $a.Length -lt $b.Length 
    $patternX = if ($conditionX) { $a } else { $b}
    $stringX = if ($conditionX) { $b } else { $a}
    $sanetized = $patternX -replace '([?!<>\\()\]\[{}^$|])','\$1'
    
    
    $groups = [regex]::Match($stringX,$sanetized)
      
    if ($groups.captures.Count -gt 0) { 
        $q = $stringX -replace $sanetized , ''        
        $hash[$patternX]+="|$q"
    }
    else {
        $b
    }
}
; $hash | out-string -stream
