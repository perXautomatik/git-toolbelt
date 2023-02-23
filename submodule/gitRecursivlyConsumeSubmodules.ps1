

cd 'B:\Users\chris\Documents\'


if dir is not a git dir
    initialize

Get-ChildItem -Recurse -Filter '.git'


for each .git folder in path

recursivly

to each git repo in path which does not yeat have path as submodule
    starting from depethest repo
    ,
    each repo, 
     identify remote origion url
     identify paths to currently known submodules, and if this submodules is damaged, throw error and exclude it from the original que.
     identify remote url to known submodules
     submodules git does not exsist but folder does exsist with content, then intialise the folder.



     add as submodule
        each repo located underneth
            assume empty
                reset index
                    reset head
                        add .
                         commit all
     then absorbe the git dir


identify comming merges, "what if"
    simulate 
         