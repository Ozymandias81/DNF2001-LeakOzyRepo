//=============================================================================
// UnrealVideoMenu
//=============================================================================
class UnrealVideoMenu extends UnrealLongMenu;

var float brightness;
var string CurrentRes;
var string AvailableRes;
var string MenuValues[20];
var string Resolutions[16];
var localized string LowText, HighText;
var int resNum;
var int SoundVol, MusicVol;
var bool bLowTextureDetail, bLowSoundQuality;

function bool ProcessLeft()
{
	if ( Selection == 1 )
	{
		Brightness = FMax(0.2, Brightness - 0.1);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$Brightness);
		PlayerOwner.ConsoleCommand("FLUSH");
		return true;
	}
	else if ( Selection == 3 )
	{
		ResNum--;
		if ( ResNum < 0 )
		{
			ResNum = ArrayCount(Resolutions) - 1;
			While ( Resolutions[ResNum] == "" )
				ResNum--;
		}
		MenuValues[3] = Resolutions[ResNum];
		return true;
	}	
	else if ( Selection == 5 )
	{
		MusicVol = Max(0, MusicVol - 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVol);
		return true;
	}
	else if ( Selection == 6 )
	{
		SoundVol = Max(0, SoundVol - 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$SoundVol);
		return true;
	}	
	else if ( Selection == 4 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if(bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 7 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 8 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 9 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}

	return false;
}

function bool ProcessRight()
{
	local string ParseString;
	local string FirstString;
	local int p;

	if ( Selection == 1 )
	{
		Brightness = FMin(1, Brightness + 0.1);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$Brightness);
		PlayerOwner.ConsoleCommand("FLUSH");
		return true;
	}
	else if ( Selection == 3 )
	{
		ResNum++;
		if ( (ResNum >= ArrayCount(Resolutions)) || (Resolutions[ResNum] == "") )
			ResNum = 0;
		MenuValues[3] = Resolutions[ResNum];
		return true;
	}	
	else if ( Selection == 5 )
	{
		MusicVol = Min(255, MusicVol + 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVol);
		return true;
	}
	else if ( Selection == 6 )
	{
		SoundVol = Min(255, SoundVol + 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$SoundVol);
		return true;
	}
	else if ( Selection == 4 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if(bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 7 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 8 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 9 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}

	return false;
}		

function bool ProcessSelection()
{
	if ( Selection == 2 )
	{
		PlayerOwner.ConsoleCommand("TOGGLEFULLSCREEN");
		CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
		GetAvailableRes();
		return true;
	}
	else if ( Selection == 3 )
	{
		PlayerOwner.ConsoleCommand("SetRes "$MenuValues[3]);
		CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
		GetAvailableRes();
		return true;
	}
	else if ( Selection == 4 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if(bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 7 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 8 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 9 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}
		
	return false;
}


function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, i, HelpPanelX;

	DrawBackGround(Canvas, (Canvas.ClipY < 250));
	HelpPanelX = 228;

	Spacing = Clamp(0.04 * Canvas.ClipY, 16, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);

	DrawTitle(Canvas);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);  

	// draw icons
	Brightness = float(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
	DrawSlider(Canvas, StartX + 155, StartY + 1, (10 * Brightness - 2), 0, 1);

	SoundVol = int(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"));
	MusicVol = int(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));
	DrawSlider(Canvas, StartX + 155, StartY + 4*Spacing + 1, MusicVol, 0, 32);
	DrawSlider(Canvas, StartX + 155, StartY + 5*Spacing + 1, SoundVol, 0, 32);

	if ( CurrentRes == "" )
		GetAvailableRes();
	else if ( AvailableRes == "" )
		GetAvailableRes();

	SetFontBrightness( Canvas, (Selection == 3) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 2);
	if ( MenuValues[3] ~= CurrentRes )
		Canvas.DrawText("["$MenuValues[3]$"]", false);
	else
		Canvas.DrawText(" "$MenuValues[3], false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	bLowTextureDetail = PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetail") != "High";

	SetFontBrightness( Canvas, (Selection == 4) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 3);
	if ( bLowTextureDetail )
		Canvas.DrawText(LowText, false);
	else
		Canvas.DrawText(HighText, false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	bLowSoundQuality = bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice LowSoundQuality"));
	SetFontBrightness( Canvas, (Selection == 7) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 6);
	if ( bLowSoundQuality )
		Canvas.DrawText(LowText, false);
	else
		Canvas.DrawText(HighText, false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	SetFontBrightness( Canvas, (Selection == 8) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 7);
	Canvas.DrawText(!PlayerOwner.bNoVoices, false);

	SetFontBrightness( Canvas, (Selection == 9) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 8);
	Canvas.DrawText(PlayerOwner.bMessageBeep, false);
		
	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, HelpPanelX);
}

function GetAvailableRes()
{
	local int p,i;
	local string ParseString;

	AvailableRes = PlayerOwner.ConsoleCommand("GetRes");
	resNum = 0;
	ParseString = AvailableRes;
	p = InStr(ParseString, " ");
	while ( (ResNum < ArrayCount(Resolutions)) && (p != -1) ) 
	{
		Resolutions[ResNum] = Left(ParseString, p);
		ParseString = Right(ParseString, Len(ParseString) - p - 1);
		p = InStr(ParseString, " ");
		ResNum++;
	}

	Resolutions[ResNum] = ParseString;
	for ( i=ResNum+1; i< ArrayCount(Resolutions); i++ )
		Resolutions[i] = "";

	CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
	MenuValues[3] = CurrentRes;
	for ( i=0; i< ResNum+1; i++ )
		if ( MenuValues[3] ~= Resolutions[i] )
		{
			ResNum = i;
			return;
		}

	ResNum = 0;
	MenuValues[3] = Resolutions[0];
}

defaultproperties
{
     LowText="Low"
     HighText="High"
     MenuLength=9
     HelpMessage(1)="Adjust display brightness using the left and right arrow keys."
     HelpMessage(2)="Display Unreal in a window. Note that going to a software display mode may remove high detail actors that were visible with hardware acceleration."
     HelpMessage(3)="Use the left and right arrows to select a resolution, and press enter to select this resolution."
     HelpMessage(4)="Use the low texture detail option to improve performance.  Changes to this setting will take effect on the next level change."
     HelpMessage(5)="Adjust the volume of the music using the left and right arrow keys."
     HelpMessage(6)="Adjust the volume of sound effects in the game using the left and right arrow keys."
     HelpMessage(7)="Use the low sound quality option to improve performance on machines with 32 megabytes or less of memory.  Changes to this setting will take effect on the next level change."
	 HelpMessage(8)="If true, you will hear voice messages during gametypes that use them."
	 HelpMessage(9)="If true, you will hear a beep when you receive a message."
     MenuList(1)="Brightness"
     MenuList(2)="Toggle Fullscreen Mode"
     MenuList(3)="Select Resolution"
     MenuList(4)="Texture Detail"
     MenuList(5)="Music Volume"
     MenuList(6)="Sound Volume"
     MenuList(7)="Sound Quality"
	 MenuList(8)="Voice Messages"
	 MenuList(9)="Message Beep"
     MenuTitle="AUDIO/VIDEO"
}
