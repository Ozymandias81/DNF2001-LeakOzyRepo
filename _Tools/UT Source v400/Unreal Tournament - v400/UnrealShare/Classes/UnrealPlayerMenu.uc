//=============================================================================
// UnrealPlayerMenu
//=============================================================================
class UnrealPlayerMenu extends UnrealShortMenu
	config(user);

var actor RealOwner;
var bool bSetup, bPulseDown;
var string PlayerName;
var int CurrentTeam;
var localized string Teams[4];
var globalconfig string PreferredSkin;
var globalconfig string ClassString;

function FindSkin(int Dir)
{
	local string SkinName, SkinDesc, MeshName;
	local texture NewSkin;
	local int pos;

	MeshName = GetItemName(String(Mesh));
	SkinName = string(Skin);
	if( Left(SkinName, Len(MeshName)) != MeshName )
		SkinName = MeshName$"Skins."$GetItemName(SkinName);
	GetNextSkin(MeshName, SkinName, Dir, SkinName, SkinDesc);
	if( SkinName != "" )
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
			Skin = NewSkin;
	}
}

function ProcessMenuInput( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
	{
		PlayerOwner.ChangeName(InputString);
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
		PlayerOwner.UpdateURL("Name", InputString, true);
	}
}

function ProcessMenuEscape()
{
	PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
}

function ProcessMenuUpdate( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
		PlayerName = (InputString$"_");
}

function Menu ExitMenu()
{
	SetOwner(RealOwner);
	Super.ExitMenu();
}

function bool ProcessLeft()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( Selection == 2 )
	{
		CurrentTeam--;
		if (CurrentTeam < 0)
			CurrentTeam = 3;
	}
	else if ( Selection == 3 )
		FindSkin(-1);

	return true;
}

function bool ProcessRight()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( Selection == 2 )
	{
		CurrentTeam++;
		if (CurrentTeam > 3)
			CurrentTeam = 0;
	}
	else if ( Selection == 3 )
		FindSkin(1);

	return true;
}

function bool ProcessSelection()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	return true;
}

function SaveConfigs()
{
	if ( ClassString == "" )
	{
		ClassString = string(PlayerOwner.Class);
		Skin = PlayerOwner.Skin;
	}
	PlayerOwner.UpdateURL("Class",ClassString, true);
	PreferredSkin = String(Skin);
	PlayerOwner.UpdateURL("Skin",PreferredSkin, true);
	if ( Mesh == PlayerOwner.Mesh )
		PlayerOwner.ServerChangeSkin( PreferredSkin, "", CurrentTeam );

	if ( CurrentTeam != PlayerOwner.PlayerReplicationInfo.Team )
	{
		PlayerOwner.ChangeTeam(CurrentTeam);
		PlayerOwner.UpdateURL("Team",string(CurrentTeam), true);
	}

	SaveConfig();
	PlayerOwner.SaveConfig();
	//PlayerOwner.PlayerReplicationInfo.SaveConfig();
}

function MenuTick(float DeltaTime)
{
	local int I;
	
	Super.MenuTick(DeltaTime);
	
	// Update FadeTimes.
	if (TitleFadeTime >= 0.0)
		TitleFadeTime += DeltaTime;
	for (I=0; I<24; I++)
		if (MenuFadeTimes[I] >= 0.0)
			MenuFadeTimes[I] += DeltaTime;
}

function SetUpDisplay()
{
	local int I;
	
	bSetup = true;
	
	// Init the FadeTimes.
	// -1.0 means not updated.
	TitleFadeTime = -1.0;
	for (I=0; I<24; I++)
		MenuFadeTimes[I] = -1.0;
	
	RealOwner = Owner;
	SetOwner(PlayerOwner);
	CurrentTeam = PlayerOwner.PlayerReplicationInfo.Team;
	PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	PlayerOwner.bBehindView = false;
	Mesh = PlayerOwner.Mesh;
	Skin = PlayerOwner.Skin;
	FindSkin(0);
	if ( Mesh != None )
		LoopAnim(AnimSequence);
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;
	local vector DrawOffset, DrawLoc;
	local rotator NewRot, DrawRot;

	if (!bSetup)
		SetUpDisplay();

	// Set menu location.
	if ( PlayerOwner.ViewTarget == None )
	{
		PlayerOwner.ViewRotation.Pitch = 0;
		PlayerOwner.ViewRotation.Roll = 0;
		DrawRot = PlayerOwner.ViewRotation;
		DrawOffset = ((vect(10.0,-5.0,0.0)) >> PlayerOwner.ViewRotation);
		DrawLoc = PlayerOwner.Location + PlayerOwner.EyeHeight * vect(0,0,1);
	}
	else
	{
		DrawLoc = PlayerOwner.ViewTarget.Location;
		DrawRot = PlayerOwner.ViewTarget.Rotation;
		if ( Pawn(PlayerOwner.ViewTarget) != None )
		{
			if ( (Level.NetMode == NM_StandAlone) 
				&& (PlayerOwner.ViewTarget.IsA('PlayerPawn') || PlayerOwner.ViewTarget.IsA('Bot')) )
					DrawRot = Pawn(PlayerOwner.ViewTarget).ViewRotation;

			DrawLoc.Z += Pawn(PlayerOwner.ViewTarget).EyeHeight;
		}
	}
	DrawOffset = (vect(10.0,-5.0,0.0)) >> DrawRot;
	SetLocation(DrawLoc + DrawOffset);
	NewRot = DrawRot;
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	Canvas.DrawActor(Self, false);
		
	// Draw title.
	DrawFadeTitle(Canvas);

	Spacing = Clamp(0.04 * Canvas.ClipY, 12, 32);
	StartX = Canvas.ClipX/2;
	StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	for ( i=1; i<6; i++ )
		MenuList[i] = Default.MenuList[i];
	DrawFadeList(Canvas, Spacing, StartX, StartY);  

	if ( !PlayerOwner.Player.Console.IsInState('MenuTyping') )
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	MenuList[1] = PlayerName;
	MenuList[2] = Teams[Clamp(CurrentTeam,0,3)];

	if ( Mesh != None )
		MenuList[3] = GetItemName(string(Skin));
	else
		MenuList[3] = "";

	MenuList[5] = "";
	DrawFadeList(Canvas, Spacing, StartX + 80, StartY);  

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

defaultproperties
{
     MenuLength=3
     HelpMessage(1)="Hit enter to type in your name. Be sure to do this before joining a multiplayer game."
     HelpMessage(2)="Use the arrow keys to change your team color (Red, Blue, Green, or Yellow)."
     HelpMessage(3)="Change your skin using the left and right arrow keys."
     MenuList(1)="Name: "
     MenuList(2)="Team Color:"
     MenuList(3)="Skin:"
     MenuTitle="Select Digital Representation"
	 Teams(0)="Red"
	 Teams(1)="Blue"
	 Teams(2)="Green"
	 Teams(3)="Gold"
     Physics=PHYS_Rotating
     AnimSequence=Walk
     DrawType=DT_Mesh
     DrawScale=0.100000
     bUnlit=True
     bOnlyOwnerSee=True
     bFixedRotationDir=True
     RotationRate=(Yaw=8000)
     DesiredRotation=(Yaw=30000)
}
