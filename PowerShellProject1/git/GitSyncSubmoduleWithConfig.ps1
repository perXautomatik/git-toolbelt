import-submodule Git-helper
import-submodule ini-helper

#git syncronize submodules with config

$root = get-GitDirPath {git dir path}

$rootKnowledge = get-IniContent($root + '\config') | select submodule

cd get-GitRootDir { git root path }

for each $rootx in $rootKnowledge
   try {
    cd $rootx.path
        $q = get-GitRemoteUrl
        $isPath = pathNotUrl($q)
    if ($isPath -or $isEmpty)
        set-gitRemote($rootx) -overwrite
    else
        
        if  $isEmpty
            $rep | append-Ini($root+'\config') 
        elseif pathNotUrl($rootx.url)
            
            ($rootx+ appendProperty($q)) | replace-iniElement($root+'\config',$rootx)
        if $rootx.url not in $q.url
            if ( $flagConfigDecides )
                $rootx | replace-iniElement($rootx.path,$rep)
            else
                throw "conflicting url"
        }
    catch {
        if error due to path not exsisting
            return "unitinilized"
        if error due to path exsisting but no subroot present
            return "already in index"
        if error due to path exsisting, git root exsisting, but git not recognized
            return "corrupted"
    }

gitmodules = inifile

subrepo remote 
