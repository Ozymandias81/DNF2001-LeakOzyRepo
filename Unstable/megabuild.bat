@ECHO OFF
ECHO
ECHO Grabbing latest data from the network:
call update.bat

ECHO .
ECHO Rebuilding engine and editor classes:
CD system
del engine.u
del editor.u
ucc make -nobind
CD ..

ECHO .
ECHO Rebuilding the code:
MSDEV Duke4.dsw /MAKE "BuildRelease - Win32 Release" /REBUILD

ECHO .
ECHO Rebuilding the scripts:
CD system
del *.u
ucc make -nobind
CD ..

ECHO
ECHO Done.

