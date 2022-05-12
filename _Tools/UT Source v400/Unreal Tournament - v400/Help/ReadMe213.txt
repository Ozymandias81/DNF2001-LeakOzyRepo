======================================================================
                 Unreal Beta Patch Notes: Version 213
======================================================================

Unreal Beta Version 213
Developed by: Epic MegaGames & Digital Extremes
Published by: GT Interactive

----------
Installing
----------

You should have unzipped these files into your \Unreal\System
directory, replacing the ones that are currently there.

--------------
Reporting Bugs
--------------

Report bugs to this email address: unreal213@epicgames.com

If you're experiencing a crash, please attach a copy of your 
log file: \Unreal\System\Unreal.log to help us troubleshoot.

Thanks.

------------
Known issues
------------

1. When connecting to a network game through the "Join Game" menu, you 
absolutely need to select your connection speed, either "Lan",
"28K Internet", or "56K internet".  If you don't select your speed,
you will probably experience erratic performance.

2. While this version should improve Internet play, we have more work 
to do in this area before it's perfect...there will be several more 
patches.

-----------
Latest News
-----------

See http://unreal.epicgames.com/ for the latest news about this
and other patches.

--------------------
Improvements & Fixes
--------------------

Hardware support
	Kickass Creative Labs Sound Blaster Live support.
	Latest Unreal OpenGL support
	Latest 3dfx Voodoo2 dual TMU support
	More AMD K6-2 / 3DNow! optimizations
	Intellimouse support on Win95

Networking
	Improved play on low-bandwidth connections (still not the ultimate, but it's a step in the right direction).
	Better, faster GameSpy support.

General
	Shaved a couple megs off the memory usage
	Further improved the loading time
	If Unreal is already running in the background, clicking on a web browser
		link now redirects the existing copy of Unreal rather than launching
		a new one
	Bug fixes: Server memory leak when switching levels, sporadic dynamic 
		lighting crash, sporadic file loading crash on low-memory machines.

Server
	New server querying interface.
	Server now runs quietly in the background by default (a tray icon)
	Network statistics display & log to help us track down performance problems that people report
	Unreal.ini ServerActors can now have parameters sent to them, i.e. for launching
		multiple master server uplinks pointing to different IP addresses.
	Far lower memory usage (over 2X less memory in typical levels)

UnrealScript
	C style 'continue' keyword
	Java style "new" function for creating new objects
	Improved TcpLink, UdpLink support for Internet mods

UnrealEd
	Faster loading time
	Significantly lower memory usage
	Misc UnrealEd improvements from Mark Poesch @ Legend Entertainment
	Improved "undo" support

-------
The End
-------
