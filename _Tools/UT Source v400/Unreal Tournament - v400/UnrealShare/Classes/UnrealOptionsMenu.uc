//=============================================================================
// UnrealOptionsMenu
//=============================================================================
class UnrealOptionsMenu extends UnrealLongMenu;

#exec Texture Import File=Textures\hud1.pcx Name=Hud1 MIPS=OFF
#exec Texture Import File=Textures\hud2.pcx Name=Hud2 MIPS=OFF
#exec Texture Import File=Textures\hud3.pcx Name=Hud3 MIPS=OFF
#exec Texture Import File=Textures\hud4.pcx Name=Hud4 MIPS=OFF
#exec Texture Import File=Textures\hud5.pcx Name=Hud5 MIPS=OFF
#exec Texture Import File=Textures\hud6.pcx Name=Hud6 MIPS=OFF

var() texture HUDIcon[6];
var   string MenuValues[20];
var	  bool bJoystick;
var localized string HideString;

var localized string InternetOption;
var localized string FastInternetOption;
var localized string LANOption;

function int StepSize()
{
	if ( PlayerOwner.Player.CurrentNetSpeed < 5000 )
		return 100;
	else if ( PlayerOwner.Player.CurrentNetSpeed < 10000 )
		return 500;
	else
		return 1000;
}

function bool ProcessYes()
{
	if ( Selection == 1 )
		PlayerOwner.ChangeAutoAim(0.93);
	else if ( Selection == 2 )
	{
		bJoystick = true;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bInvertMouse = True;
	else if ( Selection == 5 )
		PlayerOwner.ChangeSnapView(True);
	else if ( Selection == 6 )
		PlayerOwner.ChangeAlwaysMouseLook(True);
	else if ( Selection == 7 )
		PlayerOwner.ChangeStairLook(True);
	else if ( Selection == 8 )
		PlayerOwner.bNoFlash = true;
	else 
		return false;

	return true;
}

function bool ProcessNo()
{
	if ( Selection == 1 )
		PlayerOwner.ChangeAutoAim(1);
	else if ( Selection == 2 )
	{
		bJoystick = false;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bInvertMouse = False;
	else if ( Selection == 5 )
		PlayerOwner.ChangeSnapView(False);
	else if ( Selection == 6 )
		PlayerOwner.ChangeAlwaysMouseLook(False);
	else if ( Selection == 7 )
		PlayerOwner.ChangeStairLook(False);
	else if ( Selection == 8 )
		PlayerOwner.bNoFlash = false;
	else 
		return false;

	return true;
}

function bool ProcessLeft()
{
	local int NewSpeed;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 3 )
		PlayerOwner.UpdateSensitivity(FMax(1,PlayerOwner.MouseSensitivity - 1));
	else if ( Selection == 4 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 5 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 6 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 7 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 8 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 9 )
		PlayerOwner.ChangeCrossHair();
	else if ( Selection == 10 )
	{
		if ( PlayerOwner.Handedness == 1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Right");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Left");
		else 
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 14 )
		PlayerOwner.myHUD.ChangeHUD(-1);
	else if ( Selection == 15 )
		PlayerOwner.UpdateBob(PlayerOwner.Bob - 0.004);
	else if ( Selection == 16 )
	{
		if ( PlayerOwner.Player.CurrentNetSpeed <= 3000 )
			NewSpeed = 20000;
		else if ( PlayerOwner.Player.CurrentNetSpeed < 12500 )
			NewSpeed = 2600;
		else
			NewSpeed = 5000;

		PlayerOwner.ConsoleCommand("NETSPEED "$NewSpeed);
	}
	else 
		return false;

	return true;
}

function bool ProcessRight()
{
	local int NewSpeed;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 3 )
		PlayerOwner.UpdateSensitivity(PlayerOwner.MouseSensitivity + 1);
	else if ( Selection == 4 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 5 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 6 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 7 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 8 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 9 )
		PlayerOwner.MyHUD.ChangeCrossHair(-1);
	else if ( Selection == 10 )
	{
		if ( PlayerOwner.Handedness == -1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Left");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Right");
		else
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 14 )
		PlayerOwner.myHUD.ChangeHUD(1);
	else if ( Selection == 15 )
		PlayerOwner.UpdateBob(PlayerOwner.Bob + 0.004);
	else if ( Selection == 16 )
	{
		if ( PlayerOwner.Player.CurrentNetSpeed <= 3000 )
			NewSpeed = 5000;
		else if ( PlayerOwner.Player.CurrentNetSpeed < 12500 )
			NewSpeed = 20000;
		else
			NewSpeed = 2600;

		PlayerOwner.ConsoleCommand("NETSPEED "$NewSpeed);
	}
	else
		return false;

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 5 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 6 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 7 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 8 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 9 )
		PlayerOwner.ChangeCrossHair();
	else if ( Selection == 10 )
	{
		if ( PlayerOwner.Handedness == 1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Right");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Left");
		else 
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 14 )
		PlayerOwner.myHUD.ChangeHUD(1);
	else if ( Selection == 12 )
		ChildMenu = spawn(class'UnrealKeyboardMenu', owner);
	else if ( Selection == 13 )
		ChildMenu = spawn(class'UnrealWeaponMenu', owner);
	else if ( Selection == 17 )
		PlayerOwner.ConsoleCommand("PREFERENCES");
	else
		return false;

	if ( ChildMenu != None )
	{
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	return true;
}

function SaveConfigs()
{
	PlayerOwner.myHUD.SaveConfig();
	PlayerOwner.SaveConfig();
	//PlayerOwner.PlayerReplicationInfo.SaveConfig();
}

function DrawValues(canvas Canvas, Font RegFont, int Spacing, int StartX, int StartY)
{
	local int i;

	Canvas.Font = RegFont;
	for (i=0; i< MenuLength; i++ )
	{
		SetFontBrightness( Canvas, (i == Selection - 1) );
		Canvas.SetPos(StartX, StartY + Spacing * i);
		Canvas.DrawText(MenuValues[i + 1], false);
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, i, HelpPanelX;

	DrawBackGround(Canvas, (Canvas.ClipY < 250));

	HelpPanelX = 228;

	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);

	if ( Canvas.ClipY > 240 )
	{
		DrawTitle(Canvas);
		StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));
	}
	else
		StartY = Max(8, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);  
	MenuValues[1] = string( PlayerOwner.MyAutoAim < 1 );
	bJoystick =	bool(PlayerOwner.ConsoleCommand("get windrv.windowsclient usejoystick"));
	MenuValues[2] = string(bJoystick);
	MenuValues[3] = string(int(PlayerOwner.MouseSensitivity));
	MenuValues[4] = string(PlayerOwner.bInvertMouse);
	MenuValues[5] = string(PlayerOwner.bSnapToLevel);
	MenuValues[6] = string(PlayerOwner.bAlwaysMouseLook);
	MenuValues[7] = string(PlayerOwner.bLookUpStairs);
	MenuValues[8] = string(!PlayerOwner.bNoFlash);
	if ( PlayerOwner.Handedness == 1 )
		MenuValues[10] = LeftString;
	else if ( PlayerOwner.Handedness == 0 )
		MenuValues[10] = CenterString;
	else if ( PlayerOwner.Handedness == -1 )
		MenuValues[10] = RightString;
	else
		MenuValues[10] = HideString;
	if ( PlayerOwner.DodgeClickTime > 0 )
		MenuValues[11] = EnabledString;
	else
		MenuValues[11] = DisabledString;
	MenuValues[14] = string(PlayerOwner.MyHUD.HudMode);
	if ( PlayerOwner.Player.CurrentNetSpeed <= 3000 )
		MenuValues[16] = InternetOption;
	else if ( PlayerOwner.Player.CurrentNetSpeed < 12500 )
		MenuValues[16] =  FastInternetOption;
	else
		MenuValues[16] = LANOption;
	DrawValues(Canvas, Canvas.MedFont, Spacing, StartX+160, StartY);

	// draw icons
	DrawSlider(Canvas, StartX + 155, StartY + 14 * Spacing + 1, 1000 * PlayerOwner.Bob, 0, 4);

	PlayerOwner.MyHUD.DrawCrossHair(Canvas, StartX + 160, StartY + 8 * Spacing - 3 );
	Canvas.SetPos(StartX+168, Canvas.ClipY-125 );
	if (Selection==14)	
	{
		if (Canvas.ClipY > 380 && PlayerOwner.MyHUD.HudMode<=6 && HUDIcon[PlayerOwner.MyHud.HudMode]!=None)
			Canvas.DrawIcon(HUDIcon[PlayerOwner.MyHUD.HudMode],1.0);
		Canvas.Font = Canvas.MedFont;
		HelpPanelX = 150;
	}

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, HelpPanelX);
}

defaultproperties
{
     HUDIcon(0)=Texture'UnrealShare.Hud1'
     HUDIcon(1)=Texture'UnrealShare.Hud2'
     HUDIcon(2)=Texture'UnrealShare.Hud3'
     HUDIcon(3)=Texture'UnrealShare.Hud4'
     HUDIcon(4)=Texture'UnrealShare.Hud5'
     HUDIcon(5)=Texture'UnrealShare.Hud6'
     MenuLength=17
     HelpMessage(1)="Enable or disable vertical aiming help."
     HelpMessage(2)="Toggle enabling of joystick."
     HelpMessage(3)="Adjust the mouse sensitivity, or how far you have to move the mouse to produce a given motion in the game."
     HelpMessage(4)="Invert the mouse X axis.  When true, pushing the mouse forward causes you to look down rather than up."
     HelpMessage(5)="If true, when you let go of the mouselook key the view will automatically center itself."
     HelpMessage(6)="If true, the mouse is always used for looking up and down, with no need for a mouselook key."
     HelpMessage(7)="If true, when not mouse-looking your view will automatically be adjusted to look up and down slopes and stairs."
	 HelpMessage(8)="If true, your screen will flash when you fire your weapon."
     HelpMessage(9)="Choose the crosshair appearing at the center of your screen"
     HelpMessage(10)="Select where your weapon will appear."
     HelpMessage(11)="If enabled, double tapping on the movement keys (forward, back, strafe left, and strafe right) will cause you to do a fast dodge move."
     HelpMessage(12)="Hit enter to customize keyboard, mouse, and joystick configuration."
     HelpMessage(13)="Hit enter to prioritize weapon switching order."
     HelpMessage(14)="Use the left and right arrow keys to select a Heads Up Display configuration."
     HelpMessage(15)="Adjust the amount of bobbing when moving."
	 HelpMessage(16)="Set your optimal networking speed.  This has an impact on internet gameplay."
     HelpMessage(17)="Open advanced preferences configuration menu."
	 HideString="Hidden"
     MenuList(1)="Auto Aim"
     MenuList(2)="Joystick Enabled"
     MenuList(3)="Mouse Sensitivity"
     MenuList(4)="Invert Mouse"
     MenuList(5)="LookSpring"
     MenuList(6)="Always MouseLook"
     MenuList(7)="Auto Slope Look"
	 MenuList(8)="Weapon Flash"
     MenuList(9)="Crosshair"
     MenuList(10)="Weapon Hand"
     MenuList(11)="Dodging"
     MenuList(12)="Customize Controls"
     MenuList(13)="Prioritize Weapons"
     MenuList(14)="HUD Configuration"
     MenuList(15)="View Bob"
	 MenuList(16)="Net Speed"
     MenuList(17)="Advanced Options"
     MenuTitle="OPTIONS MENU"
     InternetOption="Modem"
     FastInternetOption="ISDN/Cable"
     LANOption=" LAN"
}
