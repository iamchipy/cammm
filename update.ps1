Stop-Process -Name "cammm"
if(Test-Path -Path "C:\Dropbox\_SCRIPTS\cammm\cammm.old") {Remove-Item "C:\Dropbox\_SCRIPTS\cammm\cammm.old"}
Rename-Item -Path "C:\Dropbox\_SCRIPTS\cammm\cammm.exe" -NewName "C:\Dropbox\_SCRIPTS\cammm\cammm.old" -force
if(Test-Path -Path "C:\Dropbox\_SCRIPTS\cammm\cammm.exe"){ Remove-Item "C:\Dropbox\_SCRIPTS\cammm\cammm.exe"}
Rename-Item -Path "C:\Dropbox\_SCRIPTS\cammm\cammm.new" -NewName "C:\Dropbox\_SCRIPTS\cammm\cammm.exe" -force
& "C:\Dropbox\_SCRIPTS\cammm\cammm.exe"