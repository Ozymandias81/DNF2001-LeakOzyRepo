While I had to struggle a lot to make it work since I don't have a widescreen monitor, I noticed that I had to uncomment a line
inside the file ..\Stable\Engine\Src\UnCanvas.cpp , precisely line 1063, otherwise I would get an error with wrong canvas
screen size inheritance belonging to fonts on screen (probably). If you get an inversed issue, simply remove the // from that
line.

Now that you have downloaded this file, run the #PLAY.bat file double-clicking on it and follow on screen instructions.
I am still trying to understand how to fix Cannibal and DNF editors, and "Unstable" leak has an issue on the menu screen, but at 
least now you have a sort of easy-to-go loader with everything configured. I used the MegaPatch folder plus the dnGame.u fix
inside System found on the web.

#NOTES

DO NOT PRESS F10 IN GAME, IT SEEMS THAT IT CHANGES BRIGHTNESS OR RENDERING METHOD AND IT FREEZES THE APP

RESET.bat - It removes previously generated .ini files from the very first start of the game, unlike any old UE1 games you had 
to follow your accelerator card tests to see which rendering method was the best for you, though here we have only Direct3d

REBUILD.bat - This should rebuild somehow the whole structure of "Stable" files, but I am not sure yet how much it changes
or if it is related to prebuilt method for hackers who have leaked this build (it was common during 90s on cracked gamed to 
shrink games into separate files that would have fit into a CD or floppy via lha, zip or rar or more else), use it at your own
risk.

Obviously the game is not complete at all, has chunks of the game as stated on WWW infos about this leak
.DTX files seems sadly slightly different from UE1 .UTX files for textures, but I must investigate still on it to rip textures

If you want to edit your windowed/fullscreen resolutions and settings, check inside Stable-Unstable/Players folder and edit the
DukeForever.ini file inside the folder of your Profile name. My monitor can't handle more than 1280x1024, but you will find those
values under Engine.WindowsClient list. You might also attempt to play with D3DDrv.D3DRenderDevice settings.

ALWAYS BET ON DUKE... and sometimes on Ozy81 :P