D:

cd "D:\portapps\2. file Organization\PortableApps"

foreach ($a in ls)
{
    $q = Join-Path $a 'data'
    if(Test-Path($q))
        {
            cd $q
            git init
            git add .
            git commit 'initial'
        }
}

cd "D:\portapps\2. file Organization\PortableApps"

foreach ($a in ls)
{
    $q = Join-Path $a 'data'
        if(Test-Path($q))
        
}