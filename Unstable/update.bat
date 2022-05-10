@ECHO off
ECHO updating c:\duke4\ (Copying from o:\duke4\dist\*.* and o:\duke4\packages\*.*)
del o:\duke4\dist\maps\autoplay.dnf
xcopy /y /d /s o:\duke4\dist\*.*
xcopy /y /d /s o:\duke4\packages\*.*

ECHO Copying current font to Windows directory, Don't worry if you see a sharing violation below, it is normal.
copy impact.ttf c:\windows\fonts

del system\*.ilk
