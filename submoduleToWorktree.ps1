# Remove the submodule
git submodule deinit submodules/Foo
git rm submodules/Foo
git commit -m "Remove Foo submodule"

# Add the remote
git remote add Foo https://example.com/foo.git

# Fetch the history
git fetch Foo

# Create a new branch
git branch Foo Foo/master

# Create a new worktree
git worktree add ../Foo Foo
