class UDukeControlsBinder extends UWindowPageWindow;

var UDukeArrowButton NextButton;
var UDukeArrowButton PrevButton;
var UWindowComboControl CategoryCombo;
var localized string CategoryHelp;

var UWindowVScrollbar VertSB;
var bool bSetVertSBRange;

var localized string LocalizedKeyName[255];
var string RealKeyName[255];
var localized string OrString;
var int BoundKey1[120];
var int BoundKey2[120];
var int AliasCount;

var localized string CommandCategories[6];

var localized string Commands[120];
var localized string AliasNames[120];

var float FontHeight;
var bool bPolling;
var int SelectedIndex;

function Created()
{
	local int i;

	Super.Created();

	// Scroll bar.
	VertSB = UWindowVScrollbar( CreateWindow(class'UWindowVScrollbar', 1, 1, 1, 1) );
	VertSB.CancelAcceptsFocus();
	VertSB.bInBevel = true;
	bSetVertSBRange = true;

	// Scroll left button
	PrevButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', 1, 1, 1, 1 ) );
	PrevButton.CancelAcceptsFocus();
	PrevButton.SetHelpText("Scroll command category left.");
	PrevButton.bLeft = true;

	// Scroll right button
	NextButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', 1, 1, 1, 1 ) );
	NextButton.CancelAcceptsFocus();
	NextButton.SetHelpText("Scroll command category right.");

	// Categories
	CategoryCombo = UWindowComboControl( CreateControl(class'UWindowComboControl', 1, 1, 1, 1) );
	CategoryCombo.CancelAcceptsFocus();
	CategoryCombo.SetHelpText( CategoryHelp );
	CategoryCombo.SetFont( F_Normal );
	CategoryCombo.SetEditable( false );
	CategoryCombo.Align = TA_Right;

	// Add categories.
	for ( i=0; i<6; i++ )
	{
		if ( CommandCategories[i] != "" )
			CategoryCombo.AddItem( CommandCategories[i] );
	}
	CategoryCombo.SetSelectedIndex(0);

	// Load keys.
	LoadExistingKeys();

	ResizeFrames = 3;
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;
	local float XL, YL, XPos;

	Super.BeforePaint( C, X, Y );

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	CategoryCombo.SetSize( WinWidth - 92, CategoryCombo.WinHeight );
	CategoryCombo.WinLeft = (WinWidth - CategoryCombo.WinWidth) / 2;
	CategoryCombo.WinTop = 0;

	PrevButton.SetSize( 36, 29 );
	PrevButton.WinTop = 0;
	PrevButton.WinLeft = CategoryCombo.WinLeft - PrevButton.WinWidth;
	PrevButton.WinHeight = 29;

	NextButton.SetSize( 36, 29 );
	NextButton.WinTop = 0;
	NextButton.WinLeft = CategoryCombo.WinLeft + CategoryCombo.WinWidth;
	NextButton.WinHeight = 29;

	VertSB.WinTop = PrevButton.WinHeight + 12 + LookAndFeel.Bevel_GetHeaderedTop();
	VertSB.SetSize( LookAndFeel.SBPosIndicatorBevel.W, WinHeight - VertSB.WinTop - 14 );
	VertSB.WinLeft = WinWidth - LookAndFeel.SBPosIndicatorBevel.W - 14;
}

function Paint( Canvas C, float X, float Y )
{
	local int Index, Base, i, Visible;
	local float XL, YL, XPos, XPos2, YPos, YPos2;
	local Region OldClipReg;;

	Super.Paint( C, X, Y );

	LookAndFeel.Bevel_DrawSplitHeaderedBevel( Self, C, 10, PrevButton.WinHeight + 10, WinWidth - 20, WinHeight - (PrevButton.WinHeight + 10) - 10, "Game Command", "Input Key(s)" );

	TextSize( C, "TESTy", XL, YL );
	FontHeight = YL;

	Index = CategoryCombo.GetSelectedIndex();
	Base = Index * 20;
	XPos = 10 + LookAndFeel.Bevel_GetSplitLeft();
	XPos2 = 10 + LookAndFeel.Bevel_GetSplitRight( WinWidth - 20 );
	YPos = PrevButton.WinHeight + 12 + LookAndFeel.Bevel_GetHeaderedTop();

	OldClipReg = ClippingRegion;
	ClippingRegion.X = XPos;
	ClippingRegion.Y = YPos;
	ClippingRegion.W = VertSB.WinLeft - XPos;
	ClippingRegion.H = (YL+1)*13;

	if ( bSetVertSBRange )
	{
		for ( i=Base; i<Base+20; i++ )
		{
			if ( Commands[i] != "" )
				Visible++;
		}
		VertSB.Pos = 0;
		VertSB.SetRange( 0, (YL+1)*Visible, (YL+1)*13, 10 );
		bSetVertSBRange = false;

		if ( Visible <= 13 )
			VertSB.HideWindow();
		else
			VertSB.ShowWindow();
	}

	YPos -= VertSB.Pos;

	for ( i=Base; i<Base+20; i++ )
	{
		if ( Commands[i] != "" )
		{
			// Key name.
			if ( (Y > YPos) && (Y < YPos+YL) && (X > XPos2) && (X < VertSB.WinLeft) )
			{
				C.DrawColor = LookAndFeel.GetTextColor( Self );
			}
			else
			{
				C.DrawColor = LookAndFeel.GetTextColor( Self );
				C.DrawColor.R = 3 * (C.DrawColor.R / 4);
				C.DrawColor.G = 3 * (C.DrawColor.G / 4);
				C.DrawColor.B = 3 * (C.DrawColor.B / 4);
			}
			ClipText( C, XPos, YPos, Commands[i] );

			// Bound key.
			if ( SelectedIndex == i )
			{
				C.DrawColor = LookAndFeel.GetTextColor( Self );
				ClipText( C, XPos2, YPos, "Press key to assign..." );
			}
//			else if ( BoundKey1[i] == 0 )
//				ClipText( C, XPos2, YPos, "Click To Set" );
			else if ( BoundKey2[i] == 0 )
				ClipText( C, XPos2, YPos, LocalizedKeyName[BoundKey1[i]] );
			else
				ClipText( C, XPos2, YPos, LocalizedKeyName[BoundKey1[i]]$OrString$LocalizedKeyName[BoundKey2[i]] );
			YPos += YL + 1;
		}
	}
	ClippingRegion = OldClipReg;
}

function LoadExistingKeys()
{
	local int i, j, pos;
	local string KeyName;
	local string Alias;

	for ( i=0; i<120; i++ )
	{
		BoundKey1[i] = 0;
		BoundKey2[i] = 0;
	}

	for ( i=0; i<255; i++ )
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		RealKeyName[i] = KeyName;
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				pos = InStr(Alias, " ");
				if ( pos != -1 )
				{
					if( !(Left(Alias, pos) ~= "taunt") &&
						!(Left(Alias, pos) ~= "getweapon") &&
						!(Left(Alias, pos) ~= "viewplayernum"))
						Alias = Left(Alias, pos);
				}
				for ( j=0; j<120; j++ )
				{
					if ( AliasNames[j] ~= Alias && AliasNames[j] != "None" && AliasNames[j] != "" )
					{
						if ( BoundKey1[j] == 0 )
							BoundKey1[j] = i;
						else
						if ( BoundKey2[j] == 0)
							BoundKey2[j] = i;
					}
				}
			}
		}
	}
}

function Notify( UWindowDialogControl C, byte E )
{
	local int i;

	switch( E )
	{
		case DE_Click:
			switch( C )
			{
				case PrevButton:
					i = CategoryCombo.GetSelectedIndex();
					i--;
					if ( i < 0 )
						i = CategoryCombo.List.Items.Count() - 1;
					CategoryCombo.SetSelectedIndex( i );
					break;
				case NextButton:
					i = CategoryCombo.GetSelectedIndex();
					i++;
					if ( i >= CategoryCombo.List.Items.Count() )
						i = 0;
					CategoryCombo.SetSelectedIndex( i );
					break;
			}
			break;
		case DE_Change:
			switch( C )
			{
				case CategoryCombo:
					bSetVertSBRange = true;
					break;
			}

	}
}

simulated function DoubleClick( float X, float Y )
{
	if ( bPolling )
	{
		Click( X, Y );
		return;
	}

	Super.DoubleClick( X, Y );
}

simulated function Click( float X, float Y ) 
{
	local int i;
	local float XPos, YPos, YL, BaseClickY, TestY;

	if ( bPolling )
	{
		ProcessMenuKey( 1, RealKeyName[1] );
		return;
	}

	YL = FontHeight;
	YPos = PrevButton.WinHeight + 12 + LookAndFeel.Bevel_GetHeaderedTop();

	if ( (Y > YPos) && (Y < YPos+(YL+1)*13) && (X > XPos) && (X < VertSB.WinLeft) )
	{
		// Click might be in a valid region.
		BaseClickY = (Y - YPos + VertSB.Pos) / (YL+1);
		SelectedIndex = int(BaseClickY) + CategoryCombo.GetSelectedIndex()*20;
		bPolling = true;
		Root.DontCloseOnEscape = true;
		FocusWindow();
	} else
		Super.Click( X, Y );
}

function RClick( float X, float Y ) 
{
	if ( bPolling )
		ProcessMenuKey( 2, RealKeyName[2] );
	else
		Super.RClick( X, Y );
}

function MClick( float X, float Y ) 
{
	if ( bPolling )
		ProcessMenuKey( 4, RealKeyName[4] );
	else
		Super.MClick( X, Y );
}

function KeyDown( int Key, float X, float Y )
{
	if ( bPolling )
		ProcessMenuKey( Key, RealKeyName[Key] );
	else
		Super.KeyDown( Key, X, Y );
}

function ProcessMenuKey( int KeyNo, string KeyName )
{
	if ( (KeyName == "") || (KeyName == "Escape")  
		// || ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
		|| ((KeyNo >= 0x30 ) && (KeyNo <= 0x39))) // number keys
		return;

	bPolling = false;
	Root.DontCloseOnEscape = false;

	// Don't let the player bind mouse keys to the console.
	if ( Commands[SelectedIndex] == "Console Access" )
	{
		if ((KeyName == "LeftMouse") || (KeyName == "RightMouse") || (KeyName == "MiddleMouse") ||
			(KeyName == "MouseWheelUp") || (KeyName == "MouseWheelDown"))
			return;
	}

	RemoveExistingKey( KeyNo, KeyName );
	SetKey( KeyNo, KeyName );

	SelectedIndex = -1;
}

function RemoveExistingKey( int KeyNo, string KeyName )
{
	local int i;
	local bool bResetKeyButton2;

	// Remove this key from any existing binding display
	for ( i=0; i<120; i++ )
	{
		if ( i != SelectedIndex )
		{
			bResetKeyButton2 = false;
			if ( BoundKey2[i] == KeyNo )
			{
				BoundKey2[i] = 0;
				bResetKeyButton2 = true;
			}

			if ( BoundKey1[i] == KeyNo )
			{
				BoundKey1[i] = BoundKey2[i];
				BoundKey2[i] = 0;
			}
		}
	}
}

function SetKey( int KeyNo, string KeyName )
{
	local DukeConsole DukeCon;

	DukeCon = DukeConsole(Root.Console);

	if ( DukeCon != None ) 
	{
		if ( AliasNames[SelectedIndex] ~= "QuickMenu" )
		{
			DukeCon.InGameWindowKey = KeyNo;
			BoundKey1[SelectedIndex] = KeyNo;
			BoundKey2[SelectedIndex] = 0;
			GetPlayerOwner().ConsoleCommand("SET Input" @ KeyName @ AliasNames[SelectedIndex] );
			DukeCon.SaveConfig();
			return;
		}
		else if ( AliasNames[SelectedIndex] ~= "Scoreboard" )
		{
			DukeCon.ScoreboardKey    = KeyNo;
			BoundKey1[SelectedIndex] = KeyNo;
			BoundKey2[SelectedIndex] = 0;
			GetPlayerOwner().ConsoleCommand("SET Input" @ KeyName @ AliasNames[SelectedIndex] );
			DukeCon.SaveConfig();
			return;
		}
	}

	if ( AliasNames[SelectedIndex] ~= "Console" )
	{
		Root.Console.ConsoleKey = KeyNo;
		BoundKey1[SelectedIndex] = KeyNo;
		BoundKey2[SelectedIndex] = 0;
		GetPlayerOwner().ConsoleCommand("SET Input" @ KeyName @ AliasNames[SelectedIndex] );
		Root.Console.SaveConfig();
		return;
	}

	if ( BoundKey1[SelectedIndex] != 0 )
	{
		// If this key is already chosen, just clear out other slot.
		if ( KeyNo == BoundKey1[SelectedIndex] )
		{
			// If 2 exists, remove it it.
			if ( BoundKey2[SelectedIndex] != 0 )
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey2[SelectedIndex]]);
				BoundKey2[SelectedIndex] = 0;
			}
		}
		else if ( KeyNo == BoundKey2[SelectedIndex] )
		{
			// Remove slot 1
			GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey1[SelectedIndex]]);
			BoundKey1[SelectedIndex] = BoundKey2[SelectedIndex];
			BoundKey2[SelectedIndex] = 0;
		}
		else
		{
			// Clear out old slot 2 if it exists
			if ( BoundKey2[SelectedIndex] != 0 )
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey2[SelectedIndex]]);
				BoundKey2[SelectedIndex] = 0;
			}

			// Move key 1 to key 2, and set ourselves in 1.
			BoundKey2[SelectedIndex] = BoundKey1[SelectedIndex];
			BoundKey1[SelectedIndex] = KeyNo;
			GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@AliasNames[SelectedIndex]);		
		}
	}
	else
	{
		BoundKey1[SelectedIndex] = KeyNo;
		GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@AliasNames[SelectedIndex]);		
	}
}

function Close( optional bool bByParent )
{
	if ( GetPlayerOwner().MyHUD.IsA('DukeHUD') )
		DukeHUD(GetPlayerOwner().MyHUD).LoadKeyBindings();
	Super.Close( bByParent );
}

defaultproperties
{
	SelectedIndex=-1

	OrString=" or "

	CategoryHelp="Select a category of commands to bind."
	CommandCategories(0)="Basic Controls"
	CommandCategories(1)="Additional Controls"
	CommandCategories(2)="Multiplayer"
	CommandCategories(3)="Inventory"
	CommandCategories(4)="Weapons"
	CommandCategories(5)="Shades OS"

	AliasNames(0)="Fire"
	AliasNames(1)="AltFire"
	AliasNames(2)="MoveForward"
	AliasNames(3)="MoveBackward"
	AliasNames(4)="StrafeLeft"
	AliasNames(5)="StrafeRight"
	AliasNames(6)="Use"
	AliasNames(7)="Jump"
	AliasNames(8)="Duck"

	AliasNames(20)="TurnLeft"
	AliasNames(21)="TurnRight"
	AliasNames(22)="LookUp"
	AliasNames(23)="LookDown"
	AliasNames(24)="Look"
	AliasNames(25)="CenterView"
	AliasNames(26)="Walking"
	AliasNames(27)="Strafe"

	AliasNames(40)="Talk"
	AliasNames(41)="TeamTalk"
    AliasNames(42)="Scoreboard"

	AliasNames(60)="MouseInventoryAction"
	AliasNames(61)="UseMedkit"
	AliasNames(62)="Jetpack"

	AliasNames(80)="NextWeaponAction"
	AliasNames(81)="PrevWeaponAction"
	AliasNames(82)="ThrowWeapon"
	AliasNames(83)="switchtobestweapon"
	AliasNames(84)="switchweapon 1"
	AliasNames(85)="switchweapon 2"
	AliasNames(86)="switchweapon 3"
	AliasNames(87)="switchweapon 4"
	AliasNames(88)="switchweapon 5"
	AliasNames(89)="switchweapon 6"
	AliasNames(90)="QuickKick"
	AliasNames(91)="Reload"

	AliasNames(100)="DoHeatVision"
	AliasNames(101)="DoNightVision"
	AliasNames(102)="DoZoomDown"
    AliasNames(103)="DoEMPPulse"
	AliasNames(104)="GrowHUD"
	AliasNames(105)="ShrinkHUD"
	AliasNames(106)="Console"
	AliasNames(107)="Type"
	AliasNames(108)="QuickMenu"

	Commands(0)="Fire"
	Commands(1)="Alternate Fire"
	Commands(2)="Move Forward"
	Commands(3)="Move Backward"
	Commands(4)="Strafe Left"
	Commands(5)="Strafe Right"
	Commands(6)="Use / Grab"
	Commands(7)="Jump / Up"
	Commands(8)="Crouch / Down"

	Commands(20)="Turn Left"
	Commands(21)="Turn Right"
	Commands(22)="Look Up"
	Commands(23)="Look Down"
	Commands(24)="Mouse Look"
	Commands(25)="Center View"
	Commands(26)="Walk"
	Commands(27)="Strafe"

	Commands(40)="Say"
	Commands(41)="Team Say"
    Commands(42)="Show Scoreboard"

	Commands(60)="Open Inventory Manager"
	Commands(61)="Use Medkit"
	Commands(62)="Use Jetpack"

	Commands(80)="Next Weapon"
	Commands(81)="Prev Weapon"
	Commands(82)="Throw Weapon"
	Commands(83)="Best Weapon"
	Commands(84)="Duke's Foot"
	Commands(85)="Pistol"
	Commands(86)="Shotgun"
	Commands(87)="M-16"
	Commands(88)="RPG"
	Commands(89)="Shrinkray"
	Commands(90)="Quick Kick"
	Commands(91)="Reload"

	Commands(100)="Thermal Vision"
	Commands(101)="Night Vision"
	Commands(102)="Zoom Targeting"
    Commands(103)="EMP"
	Commands(104)="Grow HUD"
	Commands(105)="Shrink HUD"
	Commands(106)="Console Access"
	Commands(107)="Quick Console"
	Commands(108)="In Game Menu"

	LocalizedKeyName(0)=""
	LocalizedKeyName(1)="LeftMouse"
	LocalizedKeyName(2)="RightMouse"
	LocalizedKeyName(3)="Cancel"
	LocalizedKeyName(4)="MiddleMouse"
	LocalizedKeyName(5)="Unknown05"
	LocalizedKeyName(6)="Unknown06"
	LocalizedKeyName(7)="Unknown07"
	LocalizedKeyName(8)="Backspace"
	LocalizedKeyName(9)="Tab"
	LocalizedKeyName(10)="Unknown0A"
	LocalizedKeyName(11)="Unknown0B"
	LocalizedKeyName(12)="Unknown0C"
	LocalizedKeyName(13)="Enter"
	LocalizedKeyName(14)="Unknown0E"
	LocalizedKeyName(15)="Unknown0F"
	LocalizedKeyName(16)="Shift"
	LocalizedKeyName(17)="Ctrl"
	LocalizedKeyName(18)="Alt"
	LocalizedKeyName(19)="Pause"
	LocalizedKeyName(20)="CapsLock"
	LocalizedKeyName(21)="Unknown15"
	LocalizedKeyName(22)="Unknown16"
	LocalizedKeyName(23)="Unknown17"
	LocalizedKeyName(24)="Unknown18"
	LocalizedKeyName(25)="Unknown19"
	LocalizedKeyName(26)="Unknown1A"
	LocalizedKeyName(27)="Escape"
	LocalizedKeyName(28)="Unknown1C"
	LocalizedKeyName(29)="Unknown1D"
	LocalizedKeyName(30)="Unknown1E"
	LocalizedKeyName(31)="Unknown1F"
	LocalizedKeyName(32)="Space"
	LocalizedKeyName(33)="PageUp"
	LocalizedKeyName(34)="PageDown"
	LocalizedKeyName(35)="End"
	LocalizedKeyName(36)="Home"
	LocalizedKeyName(37)="Left"
	LocalizedKeyName(38)="Up"
	LocalizedKeyName(39)="Right"
	LocalizedKeyName(40)="Down"
	LocalizedKeyName(41)="Select"
	LocalizedKeyName(42)="Print"
	LocalizedKeyName(43)="Execute"
	LocalizedKeyName(44)="PrintScrn"
	LocalizedKeyName(45)="Insert"
	LocalizedKeyName(46)="Delete"
	LocalizedKeyName(47)="Help"
	LocalizedKeyName(48)="0"
	LocalizedKeyName(49)="1"
	LocalizedKeyName(50)="2"
	LocalizedKeyName(51)="3"
	LocalizedKeyName(52)="4"
	LocalizedKeyName(53)="5"
	LocalizedKeyName(54)="6"
	LocalizedKeyName(55)="7"
	LocalizedKeyName(56)="8"
	LocalizedKeyName(57)="9"
	LocalizedKeyName(58)="Unknown3A"
	LocalizedKeyName(59)="Unknown3B"
	LocalizedKeyName(60)="Unknown3C"
	LocalizedKeyName(61)="Unknown3D"
	LocalizedKeyName(62)="Unknown3E"
	LocalizedKeyName(63)="Unknown3F"
	LocalizedKeyName(64)="Unknown40"
	LocalizedKeyName(65)="A"
	LocalizedKeyName(66)="B"
	LocalizedKeyName(67)="C"
	LocalizedKeyName(68)="D"
	LocalizedKeyName(69)="E"
	LocalizedKeyName(70)="F"
	LocalizedKeyName(71)="G"
	LocalizedKeyName(72)="H"
	LocalizedKeyName(73)="I"
	LocalizedKeyName(74)="J"
	LocalizedKeyName(75)="K"
	LocalizedKeyName(76)="L"
	LocalizedKeyName(77)="M"
	LocalizedKeyName(78)="N"
	LocalizedKeyName(79)="O"
	LocalizedKeyName(80)="P"
	LocalizedKeyName(81)="Q"
	LocalizedKeyName(82)="R"
	LocalizedKeyName(83)="S"
	LocalizedKeyName(84)="T"
	LocalizedKeyName(85)="U"
	LocalizedKeyName(86)="V"
	LocalizedKeyName(87)="W"
	LocalizedKeyName(88)="X"
	LocalizedKeyName(89)="Y"
	LocalizedKeyName(90)="Z"
	LocalizedKeyName(91)="Unknown5B"
	LocalizedKeyName(92)="Unknown5C"
	LocalizedKeyName(93)="Unknown5D"
	LocalizedKeyName(94)="Unknown5E"
	LocalizedKeyName(95)="Unknown5F"
	LocalizedKeyName(96)="NumPad0"
	LocalizedKeyName(97)="NumPad1"
	LocalizedKeyName(98)="NumPad2"
	LocalizedKeyName(99)="NumPad3"
	LocalizedKeyName(100)="NumPad4"
	LocalizedKeyName(101)="NumPad5"
	LocalizedKeyName(102)="NumPad6"
	LocalizedKeyName(103)="NumPad7"
	LocalizedKeyName(104)="NumPad8"
	LocalizedKeyName(105)="NumPad9"
	LocalizedKeyName(106)="GreyStar"
	LocalizedKeyName(107)="GreyPlus"
	LocalizedKeyName(108)="Separator"
	LocalizedKeyName(109)="GreyMinus"
	LocalizedKeyName(110)="NumPadPeriod"
	LocalizedKeyName(111)="GreySlash"
	LocalizedKeyName(112)="F1"
	LocalizedKeyName(113)="F2"
	LocalizedKeyName(114)="F3"
	LocalizedKeyName(115)="F4"
	LocalizedKeyName(116)="F5"
	LocalizedKeyName(117)="F6"
	LocalizedKeyName(118)="F7"
	LocalizedKeyName(119)="F8"
	LocalizedKeyName(120)="F9"
	LocalizedKeyName(121)="F10"
	LocalizedKeyName(122)="F11"
	LocalizedKeyName(123)="F12"
	LocalizedKeyName(124)="F13"
	LocalizedKeyName(125)="F14"
	LocalizedKeyName(126)="F15"
	LocalizedKeyName(127)="F16"
	LocalizedKeyName(128)="F17"
	LocalizedKeyName(129)="F18"
	LocalizedKeyName(130)="F19"
	LocalizedKeyName(131)="F20"
	LocalizedKeyName(132)="F21"
	LocalizedKeyName(133)="F22"
	LocalizedKeyName(134)="F23"
	LocalizedKeyName(135)="F24"
	LocalizedKeyName(136)="Unknown88"
	LocalizedKeyName(137)="Unknown89"
	LocalizedKeyName(138)="Unknown8A"
	LocalizedKeyName(139)="Unknown8B"
	LocalizedKeyName(140)="Unknown8C"
	LocalizedKeyName(141)="Unknown8D"
	LocalizedKeyName(142)="Unknown8E"
	LocalizedKeyName(143)="Unknown8F"
	LocalizedKeyName(144)="NumLock"
	LocalizedKeyName(145)="ScrollLock"
	LocalizedKeyName(146)="Unknown92"
	LocalizedKeyName(147)="Unknown93"
	LocalizedKeyName(148)="Unknown94"
	LocalizedKeyName(149)="Unknown95"
	LocalizedKeyName(150)="Unknown96"
	LocalizedKeyName(151)="Unknown97"
	LocalizedKeyName(152)="Unknown98"
	LocalizedKeyName(153)="Unknown99"
	LocalizedKeyName(154)="Unknown9A"
	LocalizedKeyName(155)="Unknown9B"
	LocalizedKeyName(156)="Unknown9C"
	LocalizedKeyName(157)="Unknown9D"
	LocalizedKeyName(158)="Unknown9E"
	LocalizedKeyName(159)="Unknown9F"
	LocalizedKeyName(160)="LShift"
	LocalizedKeyName(161)="RShift"
	LocalizedKeyName(162)="LControl"
	LocalizedKeyName(163)="RControl"
	LocalizedKeyName(164)="UnknownA4"
	LocalizedKeyName(165)="UnknownA5"
	LocalizedKeyName(166)="UnknownA6"
	LocalizedKeyName(167)="UnknownA7"
	LocalizedKeyName(168)="UnknownA8"
	LocalizedKeyName(169)="UnknownA9"
	LocalizedKeyName(170)="UnknownAA"
	LocalizedKeyName(171)="UnknownAB"
	LocalizedKeyName(172)="UnknownAC"
	LocalizedKeyName(173)="UnknownAD"
	LocalizedKeyName(174)="UnknownAE"
	LocalizedKeyName(175)="UnknownAF"
	LocalizedKeyName(176)="UnknownB0"
	LocalizedKeyName(177)="UnknownB1"
	LocalizedKeyName(178)="UnknownB2"
	LocalizedKeyName(179)="UnknownB3"
	LocalizedKeyName(180)="UnknownB4"
	LocalizedKeyName(181)="UnknownB5"
	LocalizedKeyName(182)="UnknownB6"
	LocalizedKeyName(183)="UnknownB7"
	LocalizedKeyName(184)="UnknownB8"
	LocalizedKeyName(185)="UnknownB9"
	LocalizedKeyName(186)="Semicolon"
	LocalizedKeyName(187)="Equals"
	LocalizedKeyName(188)="Comma"
	LocalizedKeyName(189)="Minus"
	LocalizedKeyName(190)="Period"
	LocalizedKeyName(191)="Slash"
	LocalizedKeyName(192)="Tilde"
	LocalizedKeyName(193)="UnknownC1"
	LocalizedKeyName(194)="UnknownC2"
	LocalizedKeyName(195)="UnknownC3"
	LocalizedKeyName(196)="UnknownC4"
	LocalizedKeyName(197)="UnknownC5"
	LocalizedKeyName(198)="UnknownC6"
	LocalizedKeyName(199)="UnknownC7"
	LocalizedKeyName(200)="Joy1"
	LocalizedKeyName(201)="Joy2"
	LocalizedKeyName(202)="Joy3"
	LocalizedKeyName(203)="Joy4"
	LocalizedKeyName(204)="Joy5"
	LocalizedKeyName(205)="Joy6"
	LocalizedKeyName(206)="Joy7"
	LocalizedKeyName(207)="Joy8"
	LocalizedKeyName(208)="Joy9"
	LocalizedKeyName(209)="Joy10"
	LocalizedKeyName(210)="Joy11"
	LocalizedKeyName(211)="Joy12"
	LocalizedKeyName(212)="Joy13"
	LocalizedKeyName(213)="Joy14"
	LocalizedKeyName(214)="Joy15"
	LocalizedKeyName(215)="Joy16"
	LocalizedKeyName(216)="UnknownD8"
	LocalizedKeyName(217)="UnknownD9"
	LocalizedKeyName(218)="UnknownDA"
	LocalizedKeyName(219)="LeftBracket"
	LocalizedKeyName(220)="Backslash"
	LocalizedKeyName(221)="RightBracket"
	LocalizedKeyName(222)="SingleQuote"
	LocalizedKeyName(223)="UnknownDF"
	LocalizedKeyName(224)="JoyX"
	LocalizedKeyName(225)="JoyY"
	LocalizedKeyName(226)="JoyZ"
	LocalizedKeyName(227)="JoyR"
	LocalizedKeyName(228)="MouseX"
	LocalizedKeyName(229)="MouseY"
	LocalizedKeyName(230)="MouseZ"
	LocalizedKeyName(231)="MouseW"
	LocalizedKeyName(232)="JoyU"
	LocalizedKeyName(233)="JoyV"
	LocalizedKeyName(234)="UnknownEA"
	LocalizedKeyName(235)="UnknownEB"
	LocalizedKeyName(236)="MouseWheelUp"
	LocalizedKeyName(237)="MouseWheelDown"
	LocalizedKeyName(238)="Unknown10E"
	LocalizedKeyName(239)="Unknown10F"
	LocalizedKeyName(240)="JoyPovUp"
	LocalizedKeyName(241)="JoyPovDown"
	LocalizedKeyName(242)="JoyPovLeft"
	LocalizedKeyName(243)="JoyPovRight"
	LocalizedKeyName(244)="UnknownF4"
	LocalizedKeyName(245)="UnknownF5"
	LocalizedKeyName(246)="Attn"
	LocalizedKeyName(247)="CrSel"
	LocalizedKeyName(248)="ExSel"
	LocalizedKeyName(249)="ErEof"
	LocalizedKeyName(250)="Play"
	LocalizedKeyName(251)="Zoom"
	LocalizedKeyName(252)="NoName"
	LocalizedKeyName(253)="PA1"
	LocalizedKeyName(254)="OEMClear"
}
