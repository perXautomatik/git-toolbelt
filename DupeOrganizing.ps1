given a sorted list of [Initial]{size, name, path}
    group by size => [gS](count,size){name,path}

;filterStart
filter gr in [gs] 
    if count = 1
        delete gr
    else 
        for each g in gr
            gr excluding g => [other] 
             if g.path in [other].path 
                deleteDelegate(a,b)
                goto ;filterStart
              
group [gS] by name => [gSn](count,name){path}


recursive on [root][Index] => [ressult]
    while index > getParents().length
        for each entry in [gsn] where count > 1
            group by getParents()[Index] => [root](count,index++,{parrents}){path}


deleteDelegate(a,b)
{
    a type requiring obj a, obj b, delgate x <= deciding which to delete

    throw error if a & b still excists    
}

[ressult]

a list of truth statements
objects who are the same with different parrent whos node at index has same name

 obja,[parentId],objb,[parentId]
 obja,[subparentId],objb,[subparentId]
 objc,[parentId],objb,[parentId]


 obja @ c:\temp = objb @ c:\etc\osv\temp
 and
 obja @ c:\ = objb @ c:\etc\osv\
    for every subparent they share

 
ressult can then be consumed 
    group by size or number
        => path = path relationship


into a que of beond compare session files

aditionally could name be replaced with hash, and in the final step, we decouple names being != as a list of translations


            
    