# Microsoft Developer Studio Project File - Name="U_Generic" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=U_Generic - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "U_Generic.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "U_Generic.mak" CFG="U_Generic - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "U_Generic - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "U_Generic - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "U_Generic - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_GENERIC_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_GENERIC_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "U_Generic - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_GENERIC_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "U_GENERIC_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "U_Generic - Win32 Release"
# Name "U_Generic - Win32 Debug"
# Begin Group "Classes"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;uc"
# Begin Source File

SOURCE=.\Classes\BulletHole_Concrt.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Fabric.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_FreezeRay.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Generic.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Glass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Gravel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Ice.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Metal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Metal2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\BulletHole_Wood.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnBloodSplatDecal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnDecal_Generic.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnEDFGameRocket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl6.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl64_1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl64_2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl64_3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl7.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl8.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExpl9.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExplgrnd1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExplgrnd2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExplgrnd3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExplsmk1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DNExplsmk2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\dnVehicles.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_DropLatch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_Knob.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_Modern.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_Pushbar.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_Thumbnotch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\DoorHandle_Thumbnotch2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_ashtray1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Banana.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Barrel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Barrel2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Barricade1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Barricade2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_BasketBall.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_BasketBallHoop.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Cologne1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Faucet1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Shampoo1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Sink1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Soapdish1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bath_Toothbrush.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Big_Wheel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book1A.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book1B.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book1C.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book1D.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book2A.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Book2B.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bottle1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bottle2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bottle3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Bottle4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_BurntBug.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_CameraBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Can1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cardboard_Box.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cardboard_Box2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cardboard_Box3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cash_Register.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_CeilingFanBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_CeilingFanBlades.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cement_Bag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cement_Mixer1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cement_Mixer_Wheel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Chair.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Chandalier1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cinderblock.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Cinderblock2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Clipboard1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Coffeemug1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Desklamp.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_DeskToy.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_DigitalClock2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_DollarCoin.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_DoorGeneric1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_DoorGenGlass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_EmergencyLight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Extinguisher1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Eznet.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fan1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_FanBase.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_FanBlades.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fire1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fire2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_FireHydrant.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fireplace_Broom.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fireplace_Dustpan.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fireplace_Log.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fireplace_Poker.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Fireplace_Rack.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Firepole.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Gas_Can.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Grass.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Hammer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Hang_Bulb1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Hang_Bulb2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_LavaLamp.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Halogen.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Outdoor_Lamp1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Outdoor_Lamp2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Porchlight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Streetlight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Switch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Light_Table_Lamp.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_LightBeam.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_LightSwitch.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_LightSwitch1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Limo.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_LimoWheel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Metal_Faucet1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Metal_Handle_Hot1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Metal_Sink1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Mop.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_MopBucket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Newspaper1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Paintcan.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Paper_Bag.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Parking_Meter2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1A.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1A_Hollow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1B.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1B_Hollow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1C.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1C_Hollow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1D.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pipe1D_Hollow.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant_Pot.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Plant_Pot2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pmeter.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_PMeter2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Pole.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Power_Meter1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_RedSiren.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Rig.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Robo_Tender.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Rocketflare.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Sawhorse.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Scaffold1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Scaffold2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Scaffold3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_SecurityCam1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_SecurityCam2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_SecurityGlobe.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Shovel.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Siren_Red.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Soda_Pop.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Spotlight1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Stool1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Stoplight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Switch_Power1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Table1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_TaxiCab1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Tire1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Toilet.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Towel1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Towel2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Toy_Truck.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Tracklight_Bracket.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Tracklight_Housing.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Traffic_Cone1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Traffic_Cone2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Transformer.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Trashcan2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Tripod1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_TV1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_TV2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Umbrella.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Urinal.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Vehicle.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_VehicleHeadlight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_VehicleSkybox.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_VehicleSpawn.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_VehicleTaillight.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_WallClock.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Wallsconce1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Wallsconce2.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Wallsconce3.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Wallsconce4.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_Wallsconce5.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_WaterFountain.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\G_WetFloorSign1.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\Generic.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StreetBlastMark.uc
# End Source File
# Begin Source File

SOURCE=.\Classes\StreetParachuteBomb.uc
# End Source File
# End Group
# End Target
# End Project
