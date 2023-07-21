#webdav

# Import the WinFsp module
Import-Module WinFsp

# Create a new file system object
$FileSystem = New-FspFileSystem -Name "WebDAV" -Device "https://example.com/webdav" -FileSystemApi "KS2.Drive"

# Set the mount point and options
$MountPoint = "W:"
$MountOptions = "-o uid=-1,gid=-1,umask=000"

# Mount the file system
Mount-FspFileSystem -FileSystem $FileSystem -MountPoint $MountPoint -MountOptions $MountOptions

# Check the status of the file system
Get-FspFileSystemStatus -FileSystem $FileSystem

# Unmount the file system when done
Dismount-FspFileSystem -FileSystem $FileSystem
