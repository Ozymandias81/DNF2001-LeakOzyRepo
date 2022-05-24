# Welcome to Duke Nukem Forever 2001 Leak repository Ozy Variant #

IMPORTANT NOTE: THIS REPOSITORY IS NOT INTENDED TO BE USED WITH THEBaratusII Multiplayer Repository, THINGS HERE ARE IN CONTINUED DEVELOPMENT AND THAT'S NOT A GOOD THING WHEN IT COMES MP. INSTEAD USE https://github.com/sirbaratusii/DNF01-MP-PatchPackage FOR A MP EXPERIENCE AND READ CAREFULLY THE README AT https://github.com/sirbaratusii/DNF01-MP-PatchPackage#readme

This repository has multiple aims:

- Let the leak live Forever in the web with also my little contribute
- Improved experience for Windows 7 users mainly
- An easy to go build that allows you to run all of its leaked versions and relative editors
- Pack all improvements and such from the Duke3d community and by myself avoiding conflicts
- Have a repository where all can contribute easily through pushing requests
- Include documentation for the know-how of the leak and its console commands and such

# The Content #

As you might have notice, this version has different folders names and changed files compared to its original leak, that can be found at https://archive.org/details/duke-nukem-forever-2001-leak

The Stable folder was originally the "October 26" folder, that has been patched with the MegaPatch and the dnGame.u file re-enabled inside System thanks to Zombie (you can find the thread here https://forums.duke4.net/topic/12013-leaked-duke-nukem-forever-2001/ )

The Unstable folder was originally the "August 21" folder, that only had System in it, and which has been built with unpatched files from October 26 version. While in game, in order to access the menu you must open the console and use ccmds. A list soon will be provided here.

The Tools folder might contain in future apps necessary to create a packed .pk3 file and proper distribution files to build up sources in a organized way, if it will be possible (so using zlib like in ZDoom ports)

# How To Run It #

Simply double-click on #PLAY.bat and follow on screen directions.

If you want to edit your windowed/fullscreen resolutions and settings, check inside Stable-Unstable/Players folder and edit the
DukeForever.ini file inside the folder of your Profile name. My monitor can't handle more than 1280x1024, but you will find those
values under Engine.WindowsClient list. You might also attempt to play with D3DDrv.D3DRenderDevice settings.

You can also press F12 in game and type setres YOURRESOLUTION and press enter: it will freeze the app, but you can close it and load it again and the chosen res will be applied (windowed).

# Credits #

- Ozymandias81: Archive Maintainer, Playtester
- NUKEMDAVE: Graphical resources fixes
- StrikerMan780: Some fixes regarding Multiplayer and Sounds
- Shivaxi: Maps & Scripts fixes
- MisterzPvP: Some Slick Willy maps fixes
- Zombie: Unstable menu fixes, some maps fixes
- Raziel: Hair fix, pistol ammo clip fix

Extra Content:
- Xinerki: DXVK Wrapper
- Novak/YeOldeFellerNoob: DM-WolfGrid map
- Slade: Various DM maps conversions
- TheBaratusII: Various DM maps conversions
- Protox: Duke Nukem skin fixes

# CCMDS (use SOS) #

More commands can be found at https://www.oldunreal.com/UnrealReference/Console.htm

- setres YOURxRES > apply desired resolution, freeze the app, you must run the game again
- slomo 1.0-10.0 > slows or speeds up your game (default 1.0)
- setspeed 1.0-10.0 > changes the movement speed (default 1.0)
- setjumpz 100.0-1000.0 > changes the height to which you will jump (on UT default is 350)
- fov 1.0-170.0 > changes your field of view (on TU default is 90)
- behindview 0/1 > first/third person toggle
- open MAPNAME > opens specified map which is present inside "maps" folder
- summon ITEMNAME > spawns instantly specified item in front of you
- killall ITEMNAME > removes all items of the indicated type

# Cheats (use SOS) #

- AllAmmo > All Weapons
- Fly > Fly mode On
- Ghost > NoClip
- God > GodMode On
- God2 > GodMode Alternative
- suicide > Kills the player

# Known Bugs #

- ONLY FOR WINDOWS7 USERS: in order to make DukeED work, you have to make a copy of your Stable folder and move it on minimal directory, like C:/Stable, and from there remove any .log files inside your System folder and remove everything from Players folder; after that, remove all wrappers belonging to d3d8 fix. After these changes you can run DukeED, and make sure that you didn't altered too much the DukeED.ini file (all X-Y values should be set to 0).

- DO NOT PRESS F10 IN GAME, IT TRIES TO SAVE A SCREENSHOT BUT INSTEAD IT FREEZES THE APP (it works with DXVK wrapper)
- Changing brightness with F11 works only with the unpatched wrapper on October 26 folder (Stable) , other wrappers doesn't
- Save/Load game doesn't work properly, but it works instead on Unstable build
- You can pee in any circumstances and in a infinite way (default bind F)
- Some actors routines might break during gameplay and softlock your game
- Obviously the game is not complete at all, it is very unstable and you can't save properly the game in several situations

# License #

It needs to be added yet

# EOF #

Join our Discord Channel for a better feedback: https://discord.gg/ZxaexEwgSv

==> ALWAYS BET ON DUKE COMMUNITY <==