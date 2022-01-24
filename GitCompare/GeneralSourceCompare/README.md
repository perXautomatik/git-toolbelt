# GitCompare
Powershell script to coppy each file in provided filelist into a single local repo,
used to overview files lacking version control


#idea
input: take arbitary number of files as array

then
 for each file entry
    create a commit
        and replace if already exsisting.
    commit with filepath,modification,size, date as message



Todo:
  * don't tag with hash, as it's visually cluttering.
  * make commit message more usefull: like lines added / removed, Renaming if that occured
  ** make double sure order of versioning is by edit date.
  * separate branch for preserving filestructure or assuming distinct or same filename
