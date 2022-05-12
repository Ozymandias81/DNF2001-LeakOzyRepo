======================================================================
                      Unreal Beta Patch Notes
======================================================================

Unreal Beta Version 219
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

Report bugs to this email address: unreal219@epicgames.com

If you're experiencing a crash, please attach a copy of your 
log file: \Unreal\System\Unreal.log to help us troubleshoot.

Thanks.

--------------------------------
Improvements and fixes since 218
--------------------------------

Internet Play 
* When the server switches levels, all players were thrown into the holding cell, but don't properly rejoin the next level. Fixed.
* Entering a server as a spectator then typing "suicide" on the console caused the spectator to be visible to players as a little tiny chess pawn. Eliminated. 
* "RMODE" command is no longer allowed during network play (potential unfair advantage)
* Fixed object updates becoming erratic after 30+ minutes in the same level.

Internet Server 
* Fixed potential crash when players are downloading files.

LAN Play 
* Fixed message "Connecting to unreal://0.0.0.0/" without ever connecting.
* Fixed joining game from "find local servers menu" not connecting.

UnrealScript 
* Fixed crash calling static functions.
* Added function InternetLink.IpAddrToString
* Implemented ELinkMode MODE_Binary in UdpLink, for mod authors who need to implement binary UDP protocols.

Editor
* Fixed crash on exit

-------------------
Important 218 notes
-------------------

1. Unreal 218 is NOT network-compatible with previous versions 
   of Unreal.  You can only connect to servers and other players
   running Unreal 218 or later!

2. Quality network play totally depends on Unreal knowing how much
bandwidth is available on your Internet connection.  There are two
ways to set your bandwidth:

   A. In the "Join Game" menu, select "28K Internet", "56K Internet"
      or "LAN".

   B. At any time during gameplay, use the NETSPEED command. For 
      example, for a 28.8K connection:

      * Press TAB to bring up the console
      * Type the following: NETSPEED 2600
      * Press ENTER

Our testing has found the following NETSPEED settings ideal:

Modem Speed  Excellent ISP  Good ISP       Poor quality ISP
-----------  -------------  -------------  ----------------
28.8K        NETSPEED 2600  NETSPEED 2400  NETSPEED 2100
33.6K        NETSPEED 3000  NETSPEED 2800  NETSPEED 2400
56.6K+       NETSPEED 3500  NETSPEED 3000  NETSPEED 2600

If you see any of the following symptoms happen repeatedly
while playing Internet Unreal, you should lower your NETSPEED
setting:

   A. You experience delays of 1 second or more between when you
      press the FIRE button and you see your shot fire.
   B. The message "Bandwidth Saturated, Lower Your Net Speed" appears.
   C. You appear to "teleport" around haphazardly, rather than move
      smoothly through the level.
   D. Your PING time (displayed in STAT NET) starts increasing, or
      becomes unreasonably large.

The following PING times can be expected:

   * Modem connection: 200-350.
   * ISDN or cable modem connection: 100-200.
   * T1 connection (not saturated): 50-150.
   * LAN: 30-80.

Some modem connections are considerably worse.
Add 100-200 msec if server is in another country.

You tend to get 30% best ping times at night than day, because
the Internet is less saturated then.

3. While playing Internet Unreal, press TAB, type "STAT NET", and
   press ENTER to bring up network statistics.  You can use these
   statistics to diagnose problems with your connection:

   PING: Lag caused by Internet connection, in milliseconds. Lower=Better.
   CHANNELS: Number of actors the server is sending you.
   UNORDERED: Number of out-of-order packets received. If this
      number is not zero, you likely have a bad Internet connection.
   PACKET LOSS: Percentage of packets lost.  The lower the number,
      the better your connection.  If this number is frequently 
      above 10%, try lowering your NETSPEED.
   PACKETS/SEC: Number of packets sent and received.
   BUNCHES/SEC: Number of actor updates sent and received.
   BYTES/SEC: Number of bytes sent and received.
   NETSPEED: Your current NETSPEED setting.

4. For gameplay to perform acceptably, administrators running
   dedicated Unreal servers need to use the following settings in
   Advanced Options / Networking / TCPIP Network Play / MaxTicksPerSecond:

   For Internet servers: 15 to 25
   For LAN servers: 25 to 35

   The higher the number, the more frequently the server updates
   the game world--resulting in smoother gameplay, but also more
   network traffic.

5. While this version should improve Internet play, we have more work 
to do in this area before it's perfect.  There will be several more 
patches.

-----------
Latest News
-----------

See http://unreal.epicgames.com/ for the latest news about this
and other patches.

------------------------------
Improvements & Fixes Since 217
------------------------------

Hardware Support
	Improved Glide support: Voodoo2 Dual-TMU, more stable Voodoo Rush & Banshee support.
	Thanks to Jack Mathews @ 3dfx for the engineering help!
	Updated OpenGL support.
	New Direct3D support (alpha-test).

Networking
	More detailed "STAT NET" display
	Loss-free packet sequencing and retransmission (fixes disappearing weapon problems)
	Bitstream packet compression
	Optimized file downloading
	Now handles packet loss much more gracefully
	Fixed potential forced replication and forced RPC cheat
	Added "NETSPEED ####" command
	Added "Bandwidth Saturated" detection during gameplay
	Clamp server MaxTicksPerSecond to reasonable 15-60 range
	Fixed servers not being recognized when more than one network adapter
	installed (especially a problem with network cards and dial-up adapters
	conflicting).

Audio
	Fixed sound cutting out sometimes when switching fullscreen resolutions

UnrealScript
	The "reliable" and "always" keywords are ignored for replicated variables,
	because the network code guarantees eventual delivery.

UnrealEd
	Fixed script recompile possibly crashing on Scout.uc
	Fixed texture not being applied when adding/subtracting brush
	Fixed "rebuild lighting" creating weird colored shadow maps on maps with movers
	Fixed "rebuild geometry" potential for crashing
	Fixed broken .t3d map importer
	Fixed broken music and sound exporting

GameSpy
	New GameSpy Lite from http://www.gamespy.com/
	Now shows server game type and ping time

------------------------------
Improvements & Fixes Since 216
------------------------------

Fixed ESC in intro level crashing games in the software renderer on some machines.
Eliminated chance of server crashing when player limit is exceeded.
Disabled CD check, which was causing problems for some users.
Fixed problems with 3dfx Voodoo Rush cards under some versions of Glide.

------------------------------
Improvements & Fixes Since 209
------------------------------

Hardware support
	Kickass Creative Labs Sound Blaster Live support.
	Latest Unreal OpenGL support
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
