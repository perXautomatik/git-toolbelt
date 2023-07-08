On checkout hook

define type
    submodule-entry inherents ini,git
        property : submodule
            type: ini headlineg
        property : path
            type: relative path string, unix or windows style
        property : branch
            type: git branch name


function
  take not of this.root path
  
  look for repo parent of current repo, (outside of this repo)
      if repo found
          take note of parent repo root as parent.root 
          take note of this.root relative to parent.root as this.relative
          
          ensure .gitmodule file @ parent.root 
              ensure submodule entry with path = this.relative
              ensure submodule entry has branch property = (branch checked out that triggered this hook)
              
        
        