//=============================================================================
// UnrealMeshMenu
//=============================================================================
class UnrealMeshMenu extends UnrealPlayerMenu
	config;

var Class<PlayerPawn> PlayerClass;
var string PlayerClasses[32];
var int NumPlayerClasses;
var int PlayerClassNum;
var string StartMap;
var bool SinglePlayerOnly;
var string GamePassword;

function PostBeginPlay()
{
	local string NextPlayer;

	Super.PostBeginPlay();
	NextPlayer = GetNextInt("UnrealiPlayer", 0); 
	while ( (NextPlayer != "") && (NumPlayerClasses < 16) )
	{
		PlayerClasses[NumPlayerClasses] = NextPlayer;
		NumPlayerClasses++;
		NextPlayer = GetNextInt("UnrealiPlayer", NumPlayerClasses);
	}
}	

function UpdatePlayerClass( string NewClass, int Offset )
{
	PlayerClasses[Offset] = NewClass;
}

function ProcessMenuInput( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
	{
		PlayerOwner.ChangeName(InputString);
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
		PlayerOwner.UpdateURL("Name",InputString, true);
	} 
	else if ( selection == 5 ) 
	{
		GamePassword = InputString;
		PlayerOwner.UpdateURL("Password",GamePassword, true);
	}
}

function ProcessMenuUpdate( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
		PlayerName = (InputString$"_");
	else if ( selection == 5 )
		GamePassword = (InputString$"_");
}

function bool ProcessSelection()
{
	local int i, p;

	if ( Selection == 5 )
	{
		GamePassword = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	} 
	else if( selection == 6 )
	{
		SetOwner(RealOwner);
		bExitAllMenus = true;

		SaveConfigs();

		StartMap = StartMap
					$"?Class="$ClassString
					$"?Skin="$Skin
					$"?Name="$PlayerOwner.PlayerReplicationInfo.PlayerName
					$"?Team="$PlayerOwner.PlayerReplicationInfo.Team;

		if ( GamePassword != "" )
			StartMap = StartMap$"?Password="$GamePassword;

		PlayerOwner.ClientTravel(StartMap, TRAVEL_Absolute, false);
	}
	else
		Super.ProcessSelection();
	return true;
}

function bool ProcessLeft()
{
	if ( selection == 4 )
	{
		PlayerClassNum++;
		if ( PlayerClassNum == NumPlayerClasses )
			PlayerClassNum = 0;
		PlayerClass = ChangeMesh();
		if ( SinglePlayerOnly && !PlayerClass.Default.bSinglePlayer )
		{
			ProcessLeft();
			return true;
		}
	}
	else if ( Selection == 5 )
	{
		GamePassword = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');		
	}
	else
		Super.ProcessLeft();

	return true;
}

function bool ProcessRight()
{
	if ( selection == 4 )
	{
		PlayerClassNum--;
		if ( PlayerClassNum < 0 )
			PlayerClassNum = NumPlayerClasses - 1;
		PlayerClass = ChangeMesh();
		if ( SinglePlayerOnly && !PlayerClass.Default.bSinglePlayer )
		{
			ProcessRight();
			return true;
		}
	}
	else if ( Selection == 5 )
	{
		GamePassword = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	} 
	else 
		Super.ProcessRight();

	return true;
}

function class<PlayerPawn> ChangeMesh()
{ 
	local class<playerpawn> NewPlayerClass;

	NewPlayerClass = class<playerpawn>(DynamicLoadObject(PlayerClasses[PlayerClassNum], class'Class'));

	if ( NewPlayerClass != None )
	{
		PlayerClass = NewPlayerClass;
		ClassString = PlayerClasses[PlayerClassNum];
		mesh = NewPlayerClass.Default.mesh;
		skin = NewPlayerClass.Default.skin;
		if ( Mesh != None )
			LoopAnim('Walk');
	}
	return NewPlayerClass;
}	

function LoadAllMeshes()
{
	local int i;

	for ( i=0; i<NumPlayerClasses; i++ )
		DynamicLoadObject(PlayerClasses[i], class'Class');
}

function SetUpDisplay()
{
	local int i;
	local texture NewSkin;
	local string MeshName;

	Super.SetUpDisplay();

	if ( ClassString == "" )
		ClassString = string(PlayerOwner.Class);

	for ( i=0; i<NumPlayerClasses; i++ )
		if ( PlayerClasses[i] ~= ClassString )
		{
			PlayerClassNum = i;
			break;
		}

	ChangeMesh();
	if ( PreferredSkin != "" )
	{
		MeshName = GetItemName(String(Mesh));
		if ( Left(PreferredSkin, Len(MeshName)) != MeshName )
			PreferredSkin = MeshName$"Skins."$GetItemName(PreferredSkin);
		NewSkin = texture(DynamicLoadObject(PreferredSkin, class'Texture'));
		if ( NewSkin != None )
			Skin = NewSkin;
	}		
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

	for ( i=1; i<7; i++ )
		MenuList[i] = Default.MenuList[i];
	DrawFadeList(Canvas, Spacing, StartX, StartY);  

	if ( !PlayerOwner.Player.Console.IsInState('MenuTyping') )
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	MenuList[1] = PlayerName;
	if ( CurrentTeam == 255 )
		MenuList[2] = "";
	else
		MenuList[2] = Teams[CurrentTeam];

	if ( Mesh != None )
		MenuList[3] = GetItemName(string(Skin));
	else
		MenuList[3] = "";
	MenuList[4] = PlayerClass.Default.MenuName;
	MenuList[5] = GamePassword;
	MenuList[6] = "";
	DrawFadeList(Canvas, Spacing, StartX + 80, StartY);  

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

defaultproperties
{
     Selection=6
     MenuLength=6
     MenuList(4)="Class:"
     HelpMessage(4)="Change your class using the left and right arrow keys."
	 HelpMessage(5)="Enter the admin password here, or game password if required."
     HelpMessage(6)="Press enter to start game."
	 MenuList(5)="Password:"
     MenuList(6)="Start Game"
}
