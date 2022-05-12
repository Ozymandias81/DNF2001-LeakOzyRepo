//=============================================================================
// UnrealChooseGameMenu
// finds all the single player game types (using the .int files)
// then allows the player to choose one (if there is only one, this menu never displays)
//=============================================================================
class UnrealChooseGameMenu extends UnrealLongMenu;

var() config string StartMaps[20];
var() config string GameNames[20];

function PostBeginPlay()
{
	local string NextGame;
	local class<SinglePlayer> GameClass;

	Super.PostBeginPlay();
	MenuLength = 0;
	NextGame = GetNextInt("SinglePlayer", 0); 
	while ( (NextGame != "") && (MenuLength < 20) )
	{
		GameClass = class<SinglePlayer>(DynamicLoadObject(NextGame, class'Class'));
		if ( GameClass != None )
		{
			MenuLength++;
			StartMaps[MenuLength] = GameClass.Default.StartMap;
			GameNames[MenuLength] = GameClass.Default.GameName;
		}
		NextGame = GetNextInt("SinglePlayer", MenuLength); 
	}
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = spawn(class'UnrealNewGameMenu', owner);
	HUD(Owner).MainMenu = ChildMenu;
	ChildMenu.PlayerOwner = PlayerOwner;
	PlayerOwner.UpdateURL("Game","", false);
	UnrealNewGameMenu(ChildMenu).StartMap = StartMaps[Selection];

	if ( MenuLength == 1 )
	{
		ChildMenu.ParentMenu = ParentMenu;
		Destroy();
	}
	else
		ChildMenu.ParentMenu = self;
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;

	if ( MenuLength == 1 )
	{
		DrawBackGround(Canvas, false);
		Selection = 1;
		ProcessSelection();
		return;
	}

	DrawBackGround(Canvas, false);
	DrawTitle(Canvas);

	Canvas.Style = 3;
	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	for ( i=0; i<20; i++ )
		MenuList[i] = GameNames[i];
	DrawList(Canvas, false, Spacing, StartX, StartY); 

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing + 8, 228);
}

defaultproperties
{
     
     MenuLength=0
     HelpMessage(1)="Choose which game to play."
     HelpMessage(2)="Choose which game to play."
     HelpMessage(3)="Choose which game to play."
     HelpMessage(4)="Choose which game to play."
     HelpMessage(5)="Choose which game to play."
     HelpMessage(6)="Choose which game to play."
     HelpMessage(7)="Choose which game to play."
     HelpMessage(8)="Choose which game to play."
     HelpMessage(9)="Choose which game to play."
     HelpMessage(10)="Choose which game to play."
     HelpMessage(11)="Choose which game to play."
     HelpMessage(12)="Choose which game to play."
     HelpMessage(13)="Choose which game to play."
     HelpMessage(14)="Choose which game to play."
     HelpMessage(15)="Choose which game to play."
     HelpMessage(16)="Choose which game to play."
     HelpMessage(17)="Choose which game to play."
     HelpMessage(18)="Choose which game to play."
     HelpMessage(19)="Choose which game to play."
     MenuTitle="CHOOSE GAME"
}
