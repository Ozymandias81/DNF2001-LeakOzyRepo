//=============================================================================
// UnrealCoopGameOptions
//=============================================================================
class UnrealCoopGameOptions extends UnrealGameOptionsMenu;

var localized string Difficulties[4];

function bool ProcessLeft()
{
	if ( Selection == 3 )
		UnrealServerMenu(ParentMenu).Difficulty = Max( 0, UnrealServerMenu(ParentMenu).Difficulty - 1 );
	else 
		return Super.ProcessLeft();

	return true;
}

function bool ProcessRight()
{
	if ( Selection == 3 )
		UnrealServerMenu(ParentMenu).Difficulty = Min( 3, UnrealServerMenu(ParentMenu).Difficulty + 1 );
	else 
		return Super.ProcessRight();

	return true;
}

function DrawOptions(canvas Canvas, int StartX, int StartY, int Spacing)
{
	MenuList[3] = Default.MenuList[3];
	Super.DrawOptions(Canvas, StartX, StartY, Spacing);
}

function DrawValues(canvas Canvas, int StartX, int StartY, int Spacing)
{
	local DeathMatchGame DMGame;

	DMGame = DeathMatchGame(GameType);

	// draw text
	if ( UnrealServerMenu(ParentMenu).Difficulty < 0 )
		UnrealServerMenu(ParentMenu).Difficulty = 1;
	MenuList[3] = Difficulties[UnrealServerMenu(ParentMenu).Difficulty];
	Super.DrawValues(Canvas, StartX, StartY, Spacing);
}

defaultproperties
{
	MenuLength=3
	MenuList(3)="Difficulty"
	HelpMessage(3)="Skill level setting."
    GameClass=CoopGame
	Difficulties(0)="Easy"
	Difficulties(1)="Medium"
	Difficulties(2)="Hard"
	Difficulties(3)="Unreal"
}