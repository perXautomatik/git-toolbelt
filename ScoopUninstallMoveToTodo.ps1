﻿$toUninstall = (Get-ChildItem 'B:\PF\scoopbucket-1\Todo\').basename ; $toUninstall | % { sudo scoop uninstall $_ } ; scoop list | ? { $_.info -match "failed" } | select name,version,source,updated | Format-Table