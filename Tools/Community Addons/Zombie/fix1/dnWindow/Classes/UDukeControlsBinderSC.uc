class UDukeControlsBinderSC extends UWindowDialogClientWindow;

// Bindable Key Info
var localized string LocalizedKeyName[255];
var localized string LabelList[70];
var string AliasNames[70];

var string RealKeyName[255];
var localized string OrString;
var int BoundKey1[70];
var int BoundKey2[70];

var int AliasCount;
var bool bInitialized, bLoadedExisting, bPolling;

// Bindable Controls
var UDukeControlsBindButton KeyButtons[70];
var UDukeControlsBindButton SelectedButton;
var int Selection;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int ButtonTop, i, j, KeyHeight;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/5)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Create all the key entries.
	KeyHeight = 16;
	for (i=0; i<ArrayCount(AliasNames); i++)
	{
		if(AliasNames[i] == "")
			break;

		j = InStr(LabelList[i], "*");
		if (j != -1)
		{
			KeyButtons[i] = UDukeControlsBindButton(CreateControl(class'UDukeControlsBindButton', 2, ButtonTop, WinWidth - LookAndFeel.SBPosIndicator.W - 2, 16));
			KeyButtons[i].ActionText = Right(LabelList[i], Len(LabelList[i])-1);
			KeyButtons[i].NotifyWindow = Self;
			KeyButtons[i].bAcceptsFocus = false;
			KeyButtons[i].bIsHeading = true;
			ButtonTop += 16;
			i++;
			AliasCount++;
		}

		KeyButtons[i] = UDukeControlsBindButton(CreateControl(class'UDukeControlsBindButton', 2, ButtonTop, WinWidth - LookAndFeel.SBPosIndicator.W - 2, 16));
		KeyButtons[i].ActionText = LabelList[i];
		KeyButtons[i].NotifyWindow = Self;
		KeyButtons[i].bAcceptsFocus = false;
		ButtonTop += 16;

		AliasCount++;
	}
	LoadExistingKeys();

	DesiredWidth = WinWidth;
	DesiredHeight = ButtonTop;

	Super.Created();

	bInitialized = true;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	if (!bInitialized)
		return;

	switch(E)
	{
	case DE_Click:
		if (bPolling)
		{
			bPolling = false;
			Root.DontCloseOnEscape = false;
			ProcessMenuKey(1, RealKeyName[1]);
			return;
		}

		for ( i=0; i<AliasCount; i++ )
		{
			if ((KeyButtons[i] == C) && (!KeyButtons[i].bIsHeading))
			{
				if (SelectedButton != None)
					SelectedButton.Selected = false;
				KeyButtons[i].Selected = true;
				SelectedButton = KeyButtons[i];
				SelectedButton.AssignedText = "Press the key to assign...";
				Selection = i;

				bPolling = true;
				Root.DontCloseOnEscape = true;

				return;
			}
		}
	case DE_RClick:
		if (bPolling)
		{
			bPolling = false;
			Root.DontCloseOnEscape = false;
			ProcessMenuKey(2, RealKeyName[2]);
			return;
		}
		break;
	case DE_MClick:
		if (bPolling)
		{
			bPolling = false;
			Root.DontCloseOnEscape = false;
			ProcessMenuKey(4, RealKeyName[4]);
			return;
		}
		break;
	}
}

function LoadExistingKeys()
{
	local int i, j, pos;
	local string KeyName;
	local string Alias;

	for (i=0; i<AliasCount; I++)
	{
		BoundKey1[i] = 0;
		BoundKey2[i] = 0;
	}

	for (i=0; i<255; i++)
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
				for (j=0; j<AliasCount; j++)
				{
					if ( AliasNames[j] ~= Alias && AliasNames[j] != "None" )
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

	bLoadedExisting = true;

	for (i=0; i<AliasCount; i++ )
	{
		if ( BoundKey1[i] == 0 )
			KeyButtons[i].AssignedText = "";
		else
		if ( BoundKey2[i] == 0 )
			KeyButtons[i].AssignedText = LocalizedKeyName[BoundKey1[i]];
		else
			KeyButtons[i].AssignedText = LocalizedKeyName[BoundKey1[i]]$OrString$LocalizedKeyName[BoundKey2[i]];

		if (AliasNames[i] ~= "Console")
			KeyButtons[i].AssignedText = LocalizedKeyName[Root.Console.ConsoleKey];

		if (AliasNames[i] ~= "QuickMenu" && ( DukeConsole(Root.Console) != None ) )
			KeyButtons[i].AssignedText = LocalizedKeyName[DukeConsole(Root.Console).InGameWindowKey];

	}
}

function KeyDown( int Key, float X, float Y )
{
	if (bPolling)
	{
		ProcessMenuKey(Key, RealKeyName[Key]);
		bPolling = false;
		Root.DontCloseOnEscape = false;
	} else
		Super.KeyDown(Key, X, Y);
}

function RemoveExistingKey(int KeyNo, string KeyName)
{
	local int i;
	local bool bResetKeyButton2;

	// Remove this key from any existing binding display
	for ( i=0; i<AliasCount; i++ )
	{
		if(i != Selection)
		{
			bResetKeyButton2 = false;
			if ( BoundKey2[i] == KeyNo )  {
				BoundKey2[i] = 0;
				bResetKeyButton2 = true;
			}

			if ( BoundKey1[i] == KeyNo )
			{
				BoundKey1[i] = BoundKey2[i];
				BoundKey2[i] = 0;

				if(bResetKeyButton2)
					KeyButtons[i].AssignedText = "";
				else
					KeyButtons[i].AssignedText = LocalizedKeyName[BoundKey1[i]];
			}
		}
	}
}

function SetKey(int KeyNo, string KeyName)
{
	local DukeConsole DukeCon;

	DukeCon = DukeConsole(Root.Console);

	if ( ( DukeCon != None ) && ( AliasNames[Selection] ~= "QuickMenu" ) )
	{
		DukeCon.InGameWindowKey = KeyNo;
		KeyButtons[Selection].AssignedText = LocalizedKeyName[DukeCon.InGameWindowKey];
		DukeCon.SaveConfig();
		return;
	}

	if ( AliasNames[Selection] ~= "Console" )
	{
		Root.Console.ConsoleKey = KeyNo;
		KeyButtons[Selection].AssignedText = LocalizedKeyName[Root.Console.ConsoleKey];
		Root.Console.SaveConfig();
		return;
	}

	if ( BoundKey1[Selection] != 0 )
	{
		// if this key is already chosen, just clear out other slot
		if(KeyNo == BoundKey1[Selection])
		{
			// if 2 exists, remove it it.
			if(BoundKey2[Selection] != 0)
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey2[Selection]]);
				BoundKey2[Selection] = 0;
			}
		}
		else 
		if(KeyNo == BoundKey2[Selection])
		{
			// Remove slot 1
			GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey1[Selection]]);
			BoundKey1[Selection] = BoundKey2[Selection];
			BoundKey2[Selection] = 0;
		}
		else
		{
			// Clear out old slot 2 if it exists
			if(BoundKey2[Selection] != 0)
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[BoundKey2[Selection]]);
				BoundKey2[Selection] = 0;
			}

			// move key 1 to key 2, and set ourselves in 1.
			BoundKey2[Selection] = BoundKey1[Selection];
			BoundKey1[Selection] = KeyNo;
			GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@AliasNames[Selection]);		
		}
	}
	else
	{
		BoundKey1[Selection] = KeyNo;
		GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@AliasNames[Selection]);		
	}

	if ( BoundKey1[Selection] == 0 )
		KeyButtons[Selection].AssignedText = "";
	else
	if ( BoundKey2[Selection] == 0 )
		KeyButtons[Selection].AssignedText = LocalizedKeyName[BoundKey1[Selection]];
	else
		KeyButtons[Selection].AssignedText = LocalizedKeyName[BoundKey1[Selection]]$OrString$LocalizedKeyName[BoundKey2[Selection]];
}

function ProcessMenuKey( int KeyNo, string KeyName )
{
	if ( (KeyName == "") || (KeyName == "Escape")  
		|| ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
		|| ((KeyNo >= 0x30 ) && (KeyNo <= 0x39))) // number keys
		return;

	// Don't let the player bind mouse keys to the console.
	if (SelectedButton.ActionText == "Console Access")
	{
		if ((KeyName == "LeftMouse") || (KeyName == "RightMouse") || (KeyName == "MiddleMouse") ||
			(KeyName == "MouseWheelUp") || (KeyName == "MouseWheelDown"))
			return;
	}

	SelectedButton.Selected = false;

	RemoveExistingKey(KeyNo, KeyName);
	SetKey(KeyNo, KeyName);
}

function Close(optional bool bByParent)
{
	if (GetPlayerOwner().MyHUD.IsA('DukeHUD'))
		DukeHUD(GetPlayerOwner().MyHUD).LoadKeyBindings();
	Super.Close(bByParent);
}

defaultproperties
{
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
     LabelList(0)="*Basic Controls"
     LabelList(1)="Fire"
     LabelList(2)="Alternate Fire"
     LabelList(3)="Move Forward"
     LabelList(4)="Move Backward"
     LabelList(5)="Turn Left"
     LabelList(6)="Turn Right"
     LabelList(7)="Strafe Left"
     LabelList(8)="Strafe Right"
     LabelList(9)="Use / Grab"
     LabelList(10)="Jump / Up"
     LabelList(11)="Crouch / Down"
     LabelList(12)="Mouse Look"
     LabelList(13)="Look Up"
     LabelList(14)="Look Down"
     LabelList(15)="Center View"
     LabelList(16)="Walk"
     LabelList(17)="Strafe"
     LabelList(18)="*Communications"
     LabelList(19)="Say"
     LabelList(20)="Team Say"
     LabelList(21)="Show Scoreboard"
     LabelList(22)="*Inventory"
     LabelList(23)="Open Inventory Manager"
     LabelList(24)="Use Medkit"
     LabelList(25)="*Weapons"
     LabelList(26)="Next Weapon"
     LabelList(27)="Prev Weapon"
     LabelList(28)="Throw Weapon"
     LabelList(29)="Best Weapon"
     LabelList(30)="Duke's Foot"
     LabelList(31)="Pistol"
     LabelList(32)="Shotgun"
     LabelList(33)="M-16"
     LabelList(34)="RPG"
     LabelList(35)="Shrinkray"
     LabelList(36)="Quick Kick"
     LabelList(37)="Reload"
     LabelList(38)="*SOS Powers"
     LabelList(39)="Thermal Vision"
     LabelList(40)="Night Vision"
     LabelList(41)="Zoom Targeting"
     LabelList(42)="EMP"
     LabelList(43)="*Heads Up Display"
     LabelList(44)="Grow HUD"
     LabelList(45)="Shrink HUD"
     LabelList(46)="*Console"
     LabelList(47)="Field Objectives"
     LabelList(48)="Console Access"
     LabelList(49)="Quick Console"
     LabelList(50)="In Game Menu"
     AliasNames(0)=" "
     AliasNames(1)="Fire"
     AliasNames(2)="AltFire"
     AliasNames(3)="MoveForward"
     AliasNames(4)="MoveBackward"
     AliasNames(5)="TurnLeft"
     AliasNames(6)="TurnRight"
     AliasNames(7)="StrafeLeft"
     AliasNames(8)="StrafeRight"
     AliasNames(9)="Use"
     AliasNames(10)="Jump"
     AliasNames(11)="Duck"
     AliasNames(12)="Look"
     AliasNames(13)="LookUp"
     AliasNames(14)="LookDown"
     AliasNames(15)="CenterView"
     AliasNames(16)="Walking"
     AliasNames(17)="Strafe"
     AliasNames(18)=" "
     AliasNames(19)="Talk"
     AliasNames(20)="TeamTalk"
     AliasNames(21)="Scoreboard"
     AliasNames(22)=" "
     AliasNames(23)="MouseInventoryAction"
     AliasNames(24)="UseMedkit"
     AliasNames(25)=" "
     AliasNames(26)="NextWeaponAction"
     AliasNames(27)="PrevWeaponAction"
     AliasNames(28)="ThrowWeapon"
     AliasNames(29)="switchtobestweapon"
     AliasNames(30)="switchweapon 1"
     AliasNames(31)="switchweapon 2"
     AliasNames(32)="switchweapon 3"
     AliasNames(33)="switchweapon 4"
     AliasNames(34)="switchweapon 5"
     AliasNames(35)="switchweapon 6"
     AliasNames(36)="QuickKick"
     AliasNames(37)="Reload"
     AliasNames(38)=" "
     AliasNames(39)="DoHeatVision"
     AliasNames(40)="DoNightVision"
     AliasNames(41)="DoZoomDown"
     AliasNames(42)="DoEMPPulse"
     AliasNames(43)=" "
     AliasNames(44)="GrowHUD"
     AliasNames(45)="ShrinkHUD"
     AliasNames(46)=" "
     AliasNames(47)="ShowObjectives"
     AliasNames(48)="Console"
     AliasNames(49)="Type"
     AliasNames(50)="QuickMenu"
     OrString=" or "
     bNoScanLines=True
}
