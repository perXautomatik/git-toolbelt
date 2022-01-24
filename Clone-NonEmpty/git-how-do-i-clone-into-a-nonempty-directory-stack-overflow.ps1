```
git init
git remote add origin PATH/TO/REPO
git fetch
git reset origin/master  # Required when the versioned files existed in path before "git init" of this repo.
git checkout -t origin/master
```

**NOTE:** `-t` will set the upstream branch for you, if that is what you want, and it usually is.

Url: https://stackoverflow.com/questions/2411031/how-do-i-clone-into-a-non-empty-directory