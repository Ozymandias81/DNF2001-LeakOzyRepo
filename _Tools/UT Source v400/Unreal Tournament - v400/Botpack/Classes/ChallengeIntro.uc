//=============================================================================
// ChallengeIntro.
//=============================================================================
class ChallengeIntro extends DeathMatchPlus;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	MaxPlayers = 1;
	RemainingBots = 5;
	Difficulty = 1;
	TimeLimit = 0;
	FragLimit = 0;
	bRequireReady = false;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;

	SpawnClass = class'CHSpectator';
	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	return NewPlayer;
}

function Timer()
{
	local Pawn P;

	Super.Timer();

	for ( P = Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('CHSpectator') && (PlayerPawn(P).ViewTarget == None) )
		{
			PlayerPawn(P).ViewClass(class'Pawn');
			Pawn(PlayerPawn(P).ViewTarget).skill = 2;
			if ( PlayerPawn(P).ViewTarget.IsA('Bot') )
				Bot(PlayerPawn(P).ViewTarget).ReSetSkill();
		}
}

defaultproperties
{
     bPauseable=False
     HUDType=Class'Botpack.CHSpectatorHUD'
}
