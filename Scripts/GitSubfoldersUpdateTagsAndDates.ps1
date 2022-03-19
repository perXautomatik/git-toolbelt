

#Commit every folder     if containing sub repo

for each Folder containging file of esp
        forEach(run Header gen) {git tag $_}
        t.add($_ | select dateCreated,DateModified,DateAccessed)
        t.add(stringToDate(OldFilename);
        SetCommitEnviormentDateTime(max(t),min(t)) #custom date = Oldest Create/Mod/access (OR digit)  of this year
        git commit -m "$_.mb $_.kb $_.byte" 



function SetCommitEnviormentDateTime(date Committer,date Author)
{
# the timestamp you want to use. I usually use ISO 8601 format but you can also use RFC 2822.

    set GIT_COMMITTER_DATE=Committer #"2011-12-02T23:37:52"

    set GIT_AUTHOR_DATE=Author #"2011-12-02T23:37:52"
}



function InitGit
Git init