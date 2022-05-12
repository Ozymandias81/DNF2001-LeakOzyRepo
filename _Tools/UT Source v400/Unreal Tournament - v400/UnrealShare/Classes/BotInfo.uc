//=============================================================================
// BotInfo.
//=============================================================================
class BotInfo extends Info;

var() config bool	bAdjustSkill;
var() config bool	bRandomOrder;
var   config byte	Difficulty;

var() config string BotNames[32];
var() config int BotTeams[32];
var() config float BotSkills[32];
var() config float BotAccuracy[32];
var() config float CombatStyle[32]; 
var() config float Alertness[32];
var() config float Camping[32];
var() config class<Weapon> FavoriteWeapon[32];
var	  byte ConfigUsed[32];
var() config string BotClasses[32];
var() config string BotSkins[32];
var string AvailableClasses[32], AvailableDescriptions[32], NextBotClass;
var int NumClasses;

function PreBeginPlay()
{
	//DON'T Call parent prebeginplay
}

function PostBeginPlay()
{
	local string NextBotClass, NextBotDesc;
	local int i;

	Super.PostBeginPlay();

	GetNextIntDesc("Bots", 0, NextBotClass, NextBotDesc); 
	while ( (NextBotClass != "") && (NumClasses < 32) )
	{
		AvailableClasses[NumClasses] = NextBotClass;
		AvailableDescriptions[NumClasses] = NextBotDesc;
		NumClasses++;
		GetNextIntDesc("Bots", NumClasses, NextBotClass, NextBotDesc); 
	}
}

function String GetAvailableClasses(int n)
{
	return AvailableClasses[n];
}

function int ChooseBotInfo()
{
	local int n, start;

	if ( bRandomOrder )
		n = Rand(16);
	else 
		n = 0;

	start = n;
	while ( (n < 32) && (ConfigUsed[n] == 1) )
		n++;

	if ( (n == 32) && bRandomOrder )
	{
		n = 0;
		while ( (n < start) && (ConfigUsed[n] == 1) )
			n++;
	}

	if ( n > 31 )
		n = 31;

	return n;
}

function class<bots> GetBotClass(int n)
{
	return class<bots>( DynamicLoadObject(GetBotClassName(n), class'Class') );
}

function Individualize(bots NewBot, int n, int NumBots)
{
	local texture NewSkin;

	// Set bot's skin
	if ( (n >= 0) && (n < 32) && (BotSkins[n] != "") && (BotSkins[n] != "None") )
	{
		NewSkin = texture(DynamicLoadObject(BotSkins[n], class'Texture'));
		if ( NewSkin != None )
			NewBot.Skin = NewSkin;
	}

	// Set bot's name.
	if ( (BotNames[n] == "") || (ConfigUsed[n] == 1) )
		BotNames[n] = "Bot";

	Level.Game.ChangeName( NewBot, BotNames[n], false );
	if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( NewBot, ("Bot"$NumBots), false);

	ConfigUsed[n] = 1;

	// adjust bot skill
	NewBot.Skill = FClamp(NewBot.Skill + BotSkills[n], 0, 3);
	NewBot.ReSetSkill();
}

function SetBotClass(String ClassName, int n)
{
	BotClasses[n] = ClassName;
}

function SetBotName( coerce string NewName, int n )
{
	BotNames[n] = NewName;
}

function String GetBotName(int n)
{
	return BotNames[n];
}

function int GetBotTeam(int num)
{
	return BotTeams[Num];
}

function SetBotTeam(int NewTeam, int n)
{
	BotTeams[n] = NewTeam;
}

function int GetBotIndex( coerce string BotName )
{
	local int i;
	local bool found;

	found = false;
	for (i=0; i<ArrayCount(BotNames)-1; i++)
		if (BotNames[i] == BotName)
		{
			found = true;
			break;
		}

	if (!found)
		i = -1;

	return i;
}

function string GetBotSkin( int num )
{
	return BotSkins[Num];
}

function SetBotSkin( coerce string NewSkin, int n )
{
	BotSkins[n] = NewSkin;
}

function String GetBotClassName(int n)
{
	if ( (n < 0) || (n > 31) )
		return AvailableClasses[Rand(NumClasses)];

	if ( BotClasses[n] == "" )
		BotClasses[n] = AvailableClasses[Rand(NumClasses)];

	return BotClasses[n];
}

defaultproperties
{
	Difficulty=1
	BotNames(0)="Dante"
	BotNames(1)="Ash"
	BotNames(2)="Rhiannon"
	BotNames(3)="Kurgan"
	BotNames(4)="Sonja"
	BotNames(5)="Avatar"
	BotNames(6)="Dominator"
	BotNames(7)="Cholerae"
	BotNames(8)="Apocalypse"
	BotNames(9)="Bane"
	BotNames(10)="Hippolyta"
	BotNames(11)="Eradicator"
	BotNames(12)="Nikita"
	BotNames(13)="Arcturus"
	BotNames(14)="Shiva"
	BotNames(15)="Vindicator"

	BotClasses(0)="UnrealShare.MaleThreeBot"
	BotClasses(1)="Unreali.MaleTwoBot"
	BotClasses(2)="UnrealShare.FemaleOneBot"
	BotClasses(3)="Unreali.MaleOneBot"
	BotClasses(4)="Unreali.FemaleTwoBot"
	BotClasses(5)="UnrealShare.MaleThreeBot"
	BotClasses(6)="Unreali.SkaarjPlayerBot"
	BotClasses(7)="UnrealShare.FemaleOneBot"
	BotClasses(8)="UnrealShare.MaleThreeBot"
	BotClasses(9)="Unreali.MaleTwoBot"
	BotClasses(10)="Unreali.FemaleTwoBot"
	BotClasses(11)="Unreali.SkaarjPlayerBot"
	BotClasses(12)="UnrealShare.FemaleOneBot"
	BotClasses(13)="Unreali.MaleOneBot"
	BotClasses(14)="Unreali.MaleTwoBot"
	BotClasses(15)="Unreali.SkaarjPlayerBot"

	BotTeams(0)=1
	BotTeams(1)=0
	BotTeams(2)=1
	BotTeams(3)=0
	BotTeams(4)=1
	BotTeams(5)=0
	BotTeams(6)=1
	BotTeams(7)=0
	BotTeams(8)=1
	BotTeams(9)=0
	BotTeams(10)=1
	BotTeams(11)=0
	BotTeams(12)=1
	BotTeams(13)=0
	BotTeams(14)=1
	BotTeams(15)=0
}
