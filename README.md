# Welcome to Duke Nukem Forever 2001 Leak repository Ozy Variant #

This repository has multiple aims:

- Let the leak live Forever in the web with also my little contribute
- An easy to go build that allows you to run all of its leaked versions and relative editors
- Pack all improvements and such from the Duke3d community and by myself
- Have a repository where all can contribute easily through pushing requests
- Include documentation for the know-how of the leak and its console commands and such

# The Content #

As you might have notice, this version has different folders names compared to its original leak, that can be found at https://archive.org/details/duke-nukem-forever-2001-leak

The Stable folder was originally the "October 26" folder, that has been patched with the MegaPatch and the dnGame.u file re-enabled inside System thanks to Zombie (you can find the thread here https://forums.duke4.net/topic/12013-leaked-duke-nukem-forever-2001/ )

The Unstable folder was originally the "August 21" folder, that only had System in it, and which has been built with unpatched files from October 26 version. While in game, in order to access the menu you must open the console and use ccmds. A list soon will be provided here.

The Tools folder might contain in future apps necessary to create a packed .pk3 file and proper distribution files to build up sources in a organized way. At the moment the DNF2001.exe has been created using the "Slimm BAT to EXE" tool, you might want to modify the #PLAY.bat and rebuild the .exe in case you want to update actual DNF2001 executable file.

# How To Run It #

Simply double-click on DNF2001.exe and follow on screen directions.

RESET.bat - It removes previously generated .ini files from the very first start of the game, unlike any old UE1 games you had 
to follow your accelerator card tests to see which rendering method was the best for you, though here we have only Direct3d

REBUILD.bat - This should rebuild somehow the whole structure of "Stable" files, but it should work properly only under Win98.

If you want to edit your windowed/fullscreen resolutions and settings, check inside Stable-Unstable/Players folder and edit the
DukeForever.ini file inside the folder of your Profile name. My monitor can't handle more than 1280x1024, but you will find those
values under Engine.WindowsClient list. You might also attempt to play with D3DDrv.D3DRenderDevice settings.

# Features #

It needs to be added yet

# Authors #

- Ozymandias81: Archive Maintainer, Programmer
- StrikerMan780: Several fixes regarding Multiplayer and Sounds (https://github.com/StrikerMan780/DNF2001Fixes)
- Xinarki: DXVK Wrapper
- BFG9000: Other minor wrappers attempts (D3D8-9)
- neoxaero: Discord Coordinator Lead

# Known Bugs #

DO NOT PRESS F10 IN GAME, IT TRIES TO SAVE A SCREENSHOT BUT INSTEAD IT FREEZES THE APP (it works with DXVK wrapper)
Changing brightness with F11 works only with the unpatched wrapper on October 26 folder (Stable) , other wrappers doesn't
Obviously the game is not complete at all, it is very unstable and you can't save properly the game in several situations

# License #

It needs to be added yet

# EOF #

Join our Discord Channel for a better feedback: https://discord.gg/ZxaexEwgSv

==> ALWAYS BET ON DUKE COMMUNITY <==