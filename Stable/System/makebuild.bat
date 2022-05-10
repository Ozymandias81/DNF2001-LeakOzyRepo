@ECHO OFF
ECHO Copying all build files to server.
xcopy /d *.* o:\duke4\dist\system
del o:\duke4\dist\system\*.ilk
del o:\duke4\dist\system\*.log
del o:\duke4\dist\system\dukeforever.ini
del o:\duke4\dist\system\user.ini
del o:\duke4\dist\system\running.ini
del o:\duke4\dist\system\GlideDrv.*
del o:\duke4\dist\system\Softdrv.*
ECHO Finished!
