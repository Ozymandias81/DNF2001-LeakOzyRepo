/*-----------------------------------------------------------------------------
	UDukeSOSCW
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeSOSCW expands UDukePageWindow;

// Theme Combo
var UWindowLabelControl ThemeLabel;
var UWindowComboControl ThemeCombo;
var localized string ThemeText;
var localized string ThemeHelp;

// Background Combo
var UWindowLabelControl BackgroundLabel;
var UWindowComboControl BackgroundCombo;
var localized string BackgroundText;
var localized string BackgroundHelp;

// Mouse Speed
var UWindowLabelControl MouseLabel;
var UWindowHSliderControl MouseSlider;
var localized string MouseText;
var localized string MouseHelp;

// Window Red
var UWindowLabelControl GUIRedLabel;
var UWindowHSliderControl GUIRedSlider;
var() localized string GUIRedText;
var() localized string GUIRedHelp;

// Window Green
var UWindowLabelControl GUIGreenLabel;
var UWindowHSliderControl GUIGreenSlider;
var() localized string GUIGreenText;
var() localized string GUIGreenHelp;

// Window Bright
var UWindowLabelControl GUIBlueLabel;
var UWindowHSliderControl GUIBlueSlider;
var() localized string GUIBlueText;
var() localized string GUIBlueHelp;

// Text Red
var UWindowLabelControl GUITextRedLabel;
var UWindowHSliderControl GUITextRedSlider;
var() localized string GUITextRedText;
var() localized string GUITextRedHelp;

// Text Green
var UWindowLabelControl GUITextGreenLabel;
var UWindowHSliderControl GUITextGreenSlider;
var() localized string GUITextGreenText;
var() localized string GUITextGreenHelp;

// Text Bright
var UWindowLabelControl GUITextBlueLabel;
var UWindowHSliderControl GUITextBlueSlider;
var() localized string GUITextBlueText;
var() localized string GUITextBlueHelp;

var bool bInitialized;
var float ControlOffset;

function Created()
{
	local string ThingName, ThingDesc, ExtraData;

	Super.Created();

	// Theme
	ThemeLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	ThemeLabel.SetText( ThemeText );
	ThemeLabel.SetFont( F_Normal );
	ThemeLabel.Align = TA_Right;

	ThemeCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	ThemeCombo.SetHelpText( ThemeHelp );
	ThemeCombo.SetFont( F_Normal );
	ThemeCombo.SetEditable( false );
	ThemeCombo.Align = TA_Right;

	// Background
	BackgroundLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	BackgroundLabel.SetText( BackgroundText );
	BackgroundLabel.SetFont( F_Normal );
	BackgroundLabel.Align = TA_Right;

	BackgroundCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	BackgroundCombo.SetHelpText( BackgroundHelp );
	BackgroundCombo.SetFont( F_Normal );
	BackgroundCombo.SetEditable( false );
	BackgroundCombo.Align = TA_Right;

	// Mouse speed
	MouseLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MouseLabel.SetText(MouseText);
	MouseLabel.SetFont(F_Normal);
	MouseLabel.Align = TA_Right;

	MouseSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1));
	MouseSlider.bNoSlidingNotify = True;
	MouseSlider.SetRange(40, 500, 5);
	MouseSlider.SetHelpText(MouseHelp);
	MouseSlider.SetFont(F_Normal);
	MouseSlider.Align = TA_Right;

	CreateGUISliders();

	LoadAvailableSettings();

	ResizeFrames = 3;
}

function LoadAvailableSettings()
{
	local string TestName, ThingName, ThingDesc, ExtraData, Package;
	local int i, Index;

	TestName = "";
	i = 0;
	while ( true )
	{
		GetPlayerOwner().GetNextThing( "Theme", "Theme", ThingName, 1, ThingName, ThingDesc, ExtraData );
		if ( ThingName == TestName )
			break;
		if ( TestName == "" )
			TestName = ThingName;

		ThemeCombo.AddItem( ThingDesc, ThingName$"|"$ExtraData );
		if ( UDukeRootWindow(Root).Desktop.ThemePackage == ThingName )
			Index = i;
		i++;
	}
	ThemeCombo.SetSelectedIndex( Index );

	TestName = "";
	i = 0;
	while ( true )
	{
		GetPlayerOwner().GetNextThing( "Background", "Background", ThingName, 1, ThingName, ThingDesc, ExtraData );
		if ( ThingName == TestName )
			break;
		if ( TestName == "" )
			TestName = ThingName;

		BackgroundCombo.AddItem( ThingDesc, ThingName$"|"$ExtraData );
		if ( UDukeRootWindow(Root).Desktop.BackgroundName == ThingName )
			Index = i;
		i++;
	}
	BackgroundCombo.SetSelectedIndex( Index );

	MouseSlider.SetValue( Root.Console.MouseScale * 100 );

	bInitialized = true;
}

function CreateGUISliders()
{
	GUIRedLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUIRedLabel.SetText(GUIRedText);
	GUIRedLabel.SetFont(F_Normal);
	GUIRedLabel.Align = TA_Right;

	GUIRedSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUIRedSlider.SetRange(25, 255, 1);
	GUIRedSlider.SetHelpText(GUIRedHelp);
	GUIRedSlider.SetFont(F_Normal);
	GUIRedSlider.Align = TA_Right;

	GUIGreenLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUIGreenLabel.SetText(GUIGreenText);
	GUIGreenLabel.SetFont(F_Normal);
	GUIGreenLabel.Align = TA_Right;

	GUIGreenSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUIGreenSlider.SetRange(25, 255, 1);
	GUIGreenSlider.SetHelpText(GUIGreenHelp);
	GUIGreenSlider.SetFont(F_Normal);
	GUIGreenSlider.Align = TA_Right;

	GUIBlueLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUIBlueLabel.SetText(GUIBlueText);
	GUIBlueLabel.SetFont(F_Normal);
	GUIBlueLabel.Align = TA_Right;

	GUIBlueSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUIBlueSlider.SetRange(25, 255, 1);
	GUIBlueSlider.SetHelpText(GUIBlueHelp);
	GUIBlueSlider.SetFont(F_Normal);
	GUIBlueSlider.Align = TA_Right;
	
	GUITextRedLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUITextRedLabel.SetText(GUITextRedText);
	GUITextRedLabel.SetFont(F_Normal);
	GUITextRedLabel.Align = TA_Right;

	GUITextRedSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUITextRedSlider.SetRange(25, 255, 1);
	GUITextRedSlider.SetHelpText(GUITextRedHelp);
	GUITextRedSlider.SetFont(F_Normal);
	GUITextRedSlider.Align = TA_Right;
	
	GUITextGreenLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUITextGreenLabel.SetText(GUITextGreenText);
	GUITextGreenLabel.SetFont(F_Normal);
	GUITextGreenLabel.Align = TA_Right;

	GUITextGreenSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUITextGreenSlider.SetRange(25, 255, 1);
	GUITextGreenSlider.SetHelpText(GUITextGreenHelp);
	GUITextGreenSlider.SetFont(F_Normal);
	GUITextGreenSlider.Align = TA_Right;

	GUITextBlueLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GUITextBlueLabel.SetText(GUITextBlueText);
	GUITextBlueLabel.SetFont(F_Normal);
	GUITextBlueLabel.Align = TA_Right;

	GUITextBlueSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1 ));
	GUITextBlueSlider.SetRange(25, 255, 1);
	GUITextBlueSlider.SetHelpText(GUITextBlueHelp);
	GUITextBlueSlider.SetFont(F_Normal);
	GUITextBlueSlider.Align = TA_Right;

	ResetGUISliderValues( false );
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint(C, X, Y);

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	ThemeCombo.SetSize( 200, ThemeCombo.WinHeight );
	ThemeCombo.WinLeft = CColRight;
	ThemeCombo.WinTop = ControlOffset;

	ThemeLabel.AutoSize( C );
	ThemeLabel.WinLeft = CColLeft - ThemeLabel.WinWidth;
	ThemeLabel.WinTop = ThemeCombo.WinTop + 8;

	BackgroundCombo.SetSize( 200, BackgroundCombo.WinHeight );
	BackgroundCombo.WinLeft = CColRight;
	BackgroundCombo.WinTop = ThemeCombo.WinTop + ThemeCombo.WinHeight + ControlOffset;

	BackgroundLabel.AutoSize( C );
	BackgroundLabel.WinLeft = CColLeft - BackgroundLabel.WinWidth;
	BackgroundLabel.WinTop = BackgroundCombo.WinTop + 8;

	MouseSlider.SetSize( CenterWidth, MouseSlider.WinHeight );
	MouseSlider.SliderWidth = 150;
	MouseSlider.WinLeft = CColRight;
	MouseSlider.WinTop = BackgroundCombo.WinTop + BackgroundCombo.WinHeight + ControlOffset;

	MouseLabel.AutoSize( C );
	MouseLabel.WinLeft = CColLeft - MouseLabel.WinWidth;
	MouseLabel.WinTop = MouseSlider.WinTop + 4;

	GUIRedSlider.SetSize( CenterWidth, GUIRedSlider.WinHeight );
	GUIRedSlider.SliderWidth = 150;
	GUIRedSlider.WinLeft = CColRight;
	GUIRedSlider.WinTop = MouseSlider.WinTop + MouseSlider.WinHeight + ControlOffset;

	GUIRedLabel.AutoSize( C );
	GUIRedLabel.WinLeft = CColLeft - GUIRedLabel.WinWidth;
	GUIRedLabel.WinTop = GUIRedSlider.WinTop + 4;

	GUIGreenSlider.SetSize( CenterWidth, GUIGreenSlider.WinHeight );
	GUIGreenSlider.SliderWidth = 150;
	GUIGreenSlider.WinLeft = CColRight;
	GUIGreenSlider.WinTop = GUIRedSlider.WinTop + GUIRedSlider.WinHeight + ControlOffset/4;

	GUIGreenLabel.AutoSize( C );
	GUIGreenLabel.WinLeft = CColLeft - GUIGreenLabel.WinWidth;
	GUIGreenLabel.WinTop = GUIGreenSlider.WinTop + 4;

	GUIBlueSlider.SetSize( CenterWidth, GUIBlueSlider.WinHeight );
	GUIBlueSlider.SliderWidth = 150;
	GUIBlueSlider.WinLeft = CColRight;
	GUIBlueSlider.WinTop = GUIGreenSlider.WinTop + GUIGreenSlider.WinHeight + ControlOffset/4;

	GUIBlueLabel.AutoSize( C );
	GUIBlueLabel.WinLeft = CColLeft - GUIBlueLabel.WinWidth;
	GUIBlueLabel.WinTop = GUIBlueSlider.WinTop + 4;

	GUITextRedSlider.SetSize( CenterWidth, GUITextRedSlider.WinHeight );
	GUITextRedSlider.SliderWidth = 150;
	GUITextRedSlider.WinLeft = CColRight;
	GUITextRedSlider.WinTop = GUIBlueSlider.WinTop + GUIBlueSlider.WinHeight + ControlOffset;

	GUITextRedLabel.AutoSize( C );
	GUITextRedLabel.WinLeft = CColLeft - GUITextRedLabel.WinWidth;
	GUITextRedLabel.WinTop = GUITextRedSlider.WinTop + 4;

	GUITextGreenSlider.SetSize( CenterWidth, GUITextGreenSlider.WinHeight );
	GUITextGreenSlider.SliderWidth = 150;
	GUITextGreenSlider.WinLeft = CColRight;
	GUITextGreenSlider.WinTop = GUITextRedSlider.WinTop + GUITextRedSlider.WinHeight + ControlOffset/4;

	GUITextGreenLabel.AutoSize( C );
	GUITextGreenLabel.WinLeft = CColLeft - GUITextGreenLabel.WinWidth;
	GUITextGreenLabel.WinTop = GUITextGreenSlider.WinTop + 4;

	GUITextBlueSlider.SetSize( CenterWidth, GUITextBlueSlider.WinHeight );
	GUITextBlueSlider.SliderWidth = 150;
	GUITextBlueSlider.WinLeft = CColRight;
	GUITextBlueSlider.WinTop = GUITextGreenSlider.WinTop + GUITextGreenSlider.WinHeight + ControlOffset/4;

	GUITextBlueLabel.AutoSize( C );
	GUITextBlueLabel.WinLeft = CColLeft - GUITextBlueLabel.WinWidth;
	GUITextBlueLabel.WinTop = GUITextBlueSlider.WinTop + 4;
}

function Paint( Canvas C, float X, float Y )
{
	local byte OldStyle;
	local color OldDrawColor;
	local float XL, YL, XPos, YPos;
	local Texture T;

	Super.Paint( C, X, Y );

	T = texture'hud_effects.ingame_hud.dmg_radiation';

	XPos = (WinWidth - T.USize*2)/2;
	YPos = GUITextBlueSlider.WinTop + GUITextBlueSlider.WinHeight + ControlOffset;

	LookAndFeel.Bevel_DrawSimpleBevel( Self, C, XPos, YPos, T.USize*2, T.VSize );

	OldStyle = C.Style;
	OldDrawColor = C.DrawColor;

	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
	C.DrawColor = class'DukeHUD'.default.HUDColor;
	DrawStretchedTextureSegment( C, XPos, YPos,	T.USize*2, T.VSize, 0, 0, 1, 1, texture'BlackTexture', 1.0 );

	C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
	C.DrawColor = class'DukeHUD'.default.HUDColor;
	DrawStretchedTextureSegment( C, XPos, YPos,	T.USize, T.VSize, 0, 0, T.USize, T.VSize, T, 1.0 );
	DrawStretchedTextureSegment( C, XPos+T.USize, YPos, T.USize, T.VSize, 0, 0, T.USize, T.VSize, T, 1.0 );

	C.DrawColor = class'DukeHUD'.default.TextColor;
	TextSize( C, "Color Sample", XL, YL );
	C.SetPos( WinLeft + XPos + (T.USize*2-XL)/2, WinTop + YPos + (T.VSize-YL)/2 );
	C.DrawText( "Color Sample" );

	C.DrawColor = OldDrawColor;
	C.Style = OldStyle;
}

function Notify( UWindowDialogControl C, byte E )
{
	switch( E )
	{
		case DE_Change:
			switch( C )
			{
				case ThemeCombo:
					ThemeChanged();
					break;
				case BackgroundCombo:
					BackgroundChanged();
					break;
				case MouseSlider:
					MouseChanged();
					break;
				case GUIRedSlider:
				case GUIGreenSlider:
				case GUIBlueSlider:
					ChangeGUIToCustomColor();
					break;
				case GUITextRedSlider:
				case GUITextGreenSlider:
				case GUITextBlueSlider:
					ChangeGUITextToCustomColor();
					break;
			}
	}
	Super.Notify( C, E );
}

function ThemeChanged()
{
	local string Data, Package, ExtraData, RestOfData, BackgroundName;
	local int Pos;
	local bool bColorize, bTranslucentIcons;

	if ( !bInitialized )
		return;

	Data = ThemeCombo.GetValue2();
	Package = Left( Data, InStr(Data, "|") );
	ExtraData = Right( Data, Len(Data) - InStr(Data, "|") - 1 );

	GetPlayerOwner().BroadcastMessage("Switching theme to"@ThemeCombo.GetValue());
	GetPlayerOwner().BroadcastMessage("  Package:"@Package);

	// Is it colorizable?
	Pos = InStr( ExtraData, "flag_colorizable" );
	if ( Pos > -1 )
	{
		bColorize = true;
		GetPlayerOwner().BroadcastMessage("  Type: Colorized");
	}
	else
	{
		bColorize = false;
		GetPlayerOwner().BroadcastMessage("  Type: Normal");
	}

	// Does it use translucent icons?
	Pos = InStr( ExtraData, "flag_translucenticons" );
	if ( Pos > -1 )
	{
		bTranslucentIcons = true;
		GetPlayerOwner().BroadcastMessage("  Icons: Translucent");
	}
	else
	{
		bTranslucentIcons = false;
		GetPlayerOwner().BroadcastMessage("  Icons: Normal");
	}

	// Load the background.
	Pos = InStr( ExtraData, "flag_background" );
	if ( Pos > -1 )
	{
		RestOfData = Right( ExtraData, Len(ExtraData) - Pos );
		Pos = InStr( RestOfData, "=" );
		if ( Pos > -1 )
		{
			RestOfData = Right( RestOfData, Len(RestOfData) - (Pos+1) );
			Pos = InStr( RestOfData, "," );
			if ( Pos > -1 )
				BackgroundName = Left( RestOfData, Pos );
			else
				BackgroundName = RestOfData;
			GetPlayerOwner().BroadcastMessage("  Background:"@BackgroundName);
		}
		else
		{
			GetPlayerOwner().BroadcastMessage("This theme does not properly specify a background (missing ='s).  Aborting.");
			return;
		}
	}
	else
	{
		GetPlayerOwner().BroadcastMessage("This theme does not specify a background.  Aborting.");
		return;
	}

	// Find the background and set the combo to it.
	Pos = BackgroundCombo.FindItemIndex( BackgroundName, true );
	if ( Pos > -1 )
	{
		// This will call background changed.
		BackgroundCombo.SetSelectedIndex( Pos );
	}
	else
	{
		GetPlayerOwner().BroadcastMessage("Could not find the specified background.  Aborting.");
		return;
	}

	// Assign everything.
	UDukeRootWindow(Root).Desktop.ThemePackage = Package;
	UDukeRootWindow(Root).Desktop.ThemeColorizable = bColorize;
	UDukeRootWindow(Root).Desktop.ThemeTranslucentIcons = bTranslucentIcons;

	// Load the art.
	UDukeRootWindow(Root).Desktop.LoadArt();

	// Save changes.
	UDukeRootWindow(Root).Desktop.SaveConfig();
}

function BackgroundChanged()
{
	local string Data, Name, ExtraData, RestOfData, LayoutString, TextureName;
	local string Tiles[12];
	local int Pos, H, V, i, j, k, RightPos;
	local bool bIsSmack;

	if ( !bInitialized )
		return;

	Data = BackgroundCombo.GetValue2();
	Name = Left( Data, InStr(Data, "|") );
	ExtraData = Right( Data, Len(Data) - InStr(Data, "|") - 1 );

	GetPlayerOwner().BroadcastMessage("Switching background to"@BackgroundCombo.GetValue());
	GetPlayerOwner().BroadcastMessage("  Name:"@Name);

	// What is the layout?
	Pos = InStr( ExtraData, "flag_layout" ); 
	if ( Pos > -1 )
	{
		RestOfData = Right( ExtraData, Len(ExtraData) - Pos );
		Pos = InStr( RestOfData, "=" );
		if ( Pos > -1 )
		{
			LayoutString = Mid( RestOfData, Pos+1, 3 );
			H = int(Left( LayoutString, 1 ));
			V = int(Right( LayoutString, 1 ));
			GetPlayerOwner().BroadcastMessage("  Layout:"@H$"x"$V);
		}
		else
		{
			GetPlayerOwner().BroadcastMessage("This background improperly specifies a layout (flag_layout has no ='s).  Aborting.");
			return;
		}
	}
	else
	{
		GetPlayerOwner().BroadcastMessage("This background doesn't specify a layout.  Aborting.");
		return; 
	}

	// Is it a smack?
	Pos = InStr( ExtraData, "flag_smack" );
	if ( Pos > -1 )
	{
		bIsSmack = true;
		GetPlayerOwner().BroadcastMessage("  Type: Smack");
	}
	else
	{
		bIsSmack = false;
		GetPlayerOwner().BroadcastMessage("  Type: Normal");
	}

	// Load the textures.
	RestOfData = ExtraData;
	for ( i=0; i<H; i++ )
	{
		for ( j=0; j<V; j++ )
		{
			Pos = InStr( RestOfData, "flag_texture" );
			if ( Pos > -1 )
			{
				RestOfData = Right( RestOfData, Len(RestOfData) - Pos );
				Pos = InStr( RestOfData, "=" );
				if ( Pos > -1 )
				{
					RestOfData = Right( RestOfData, Len(RestOfData) - (Pos+1) );
					Pos = InStr( RestOfData, "," );
					if ( Pos > -1 )
					{
						TextureName = Left( RestOfData, Pos );
						RestOfData = Right( RestOfData, Len(RestOfData) - Pos );
					}
					else
					{
						TextureName = RestOfData;
						RestOfData = "";
					}
					Tiles[k] = TextureName;
					GetPlayerOwner().BroadcastMessage("  Texture["$k$"]:"@TextureName@Tiles[k]);
				}
				else
				{
					GetPlayerOwner().BroadcastMessage("This background does not specify enough textures."@k@"of"@i*j@"specified. Aborting.");
					return;
				}
			}
			else
			{
				GetPlayerOwner().BroadcastMessage("This background does not specify enough textures."@k@"of"@i*j@"specified. Aborting.");
				return;
			}
			k++;
		}
	}

	// Assign everything if we got this far.
	UDukeRootWindow(Root).Desktop.BackgroundName = Name;
	UDukeRootWindow(Root).Desktop.BackgroundSmack = bIsSmack;
	UDukeRootWindow(Root).Desktop.BackgroundTileCountH = H;
	UDukeRootWindow(Root).Desktop.BackgroundTileCountV = V;
	for ( i=0; i<12; i++ )
	{
		UDukeRootWindow(Root).Desktop.BackgroundTiles[i] = Tiles[i];
	}

	// Load the new backdrop.
	UDukeRootWindow(Root).Desktop.LoadBackdrop();

	// Save configuration.
	UDukeRootWindow(Root).Desktop.SaveConfig();
}

function ChangeGUIToCustomColor()
{
	local Color C;

	C.R = GUIRedSlider.GetValue();
	C.G = GUIGreenSlider.GetValue();
	C.B = GUIBlueSlider.GetValue();

	class'DukeHUD'.default.HUDColor = C;
	LookAndFeel.colorGUIWindows = C;
}

function ChangeGUITextToCustomColor()
{
	local Color C;

	C.R = GUITextRedSlider.GetValue();
	C.G = GUITextGreenSlider.GetValue();
	C.B = GUITextBlueSlider.GetValue();

	class'DukeHUD'.default.TextColor = C;
	LookAndFeel.DefaultTextColor = C;
}

function ResetGUISliderValues( optional bool bNotify )
{
	local Color C;

	C = class'DukeHUD'.default.HUDColor;
	GUIRedSlider.SetValue( C.R, bNotify );
	GUIGreenSlider.SetValue( C.G, bNotify );
	GUIBlueSlider.SetValue( C.B, bNotify );

	C = class'DukeHUD'.default.TextColor;
	GUITextRedSlider.SetValue( C.R, bNotify );
	GUITextGreenSlider.SetValue( C.G, bNotify );
	GUITextBlueSlider.SetValue( C.B, bNotify );
}	

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	class'DukeHUD'.static.StaticSaveConfig();
	Root.Console.SaveConfig();
	LookAndFeel.SaveConfig();

	Super.SaveConfigs();
}

function MouseChanged()
{
	if ( bInitialized )
	{
		Root.Console.MouseScale = (MouseSlider.Value / 100);
		Root.Console.SaveConfig();
	}
}

defaultproperties
{
	 ThemeText="Window Theme"
	 ThemeHelp="Select a visual theme for the windowing system."
	 BackgroundText="Desktop Background"
	 BackgroundHelp="Select a desktop background for the windowing system."
     MouseText="Mouse Speed"
     MouseHelp="Adjust the speed of the mouse in the user interface."

     ControlOffset=10.000000

     GUIRedText="HUD Color Red"
     GUIRedHelp="Set HUD red component."
	 GUIGreenText="HUD Color Green"
	 GUIGreenHelp="Set HUD green component."
     GUIBlueText="HUD Color Blue"
     GUIBlueHelp="Set HUD blue component"
     GUITextRedText="Text Color Red"
     GUITextRedHelp="Set HUD text red component."
	 GUITextGreenText="Text Color Green"
	 GUITextGreenHelp="Set HUD text green component."
     GUITextBlueText="Text Color Blue"
     GUITextBlueHelp="Set HUD text blue component."
}
