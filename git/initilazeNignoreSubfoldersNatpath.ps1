. .\filesystem\DirectoriesAtDepthN.ps1
. .\git\InitializeNewReposInEachSubfolder.ps1
. .\git\folderContToignored.ps1

ListDirectoriesAtDepth 'D:\PortableApps\' 2  |
    NewRepo $_.fullname 'portableapps.com'   |
    addToIgnored 