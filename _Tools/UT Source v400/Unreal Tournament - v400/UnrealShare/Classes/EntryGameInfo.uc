//=============================================================================
// EntryGameInfo.
//
//=============================================================================
class EntryGameInfo extends UnrealGameInfo;

event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	local int RealMax;

	RealMax=MaxPlayers;
	MaxPlayers = 0;
	Super.PreLogin(Options, Address, Error, FailCode);
	MaxPlayers = RealMax;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local int RealMax;
	local PlayerPawn result;

	RealMax=MaxPlayers;
	MaxPlayers = 0;
	result = Super.Login(Portal, Options, Error, SpawnClass);
	MaxPlayers = RealMax;
	return result;
}

defaultproperties
{
	bLoggingGame=False
}
