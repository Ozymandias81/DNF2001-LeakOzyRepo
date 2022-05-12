//
// An Unreal Tournament Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the Killer's Weapon Class.
//
// Switch 1: Suicide
//	RelatedPRI_1 guy who killed himself.

class DeathMessagePlus extends LocalMessagePlus;

var localized string KilledString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch (Switch)
	{
		case 0:
			if (RelatedPRI_1 == None)
				return "";
			if (RelatedPRI_1.PlayerName == "")
				return "";
			if (RelatedPRI_2 == None)
				return "";
			if (RelatedPRI_2.PlayerName == "")
				return "";
			if (Class<Weapon>(OptionalObject) == None)
			{
				return "";
			}
			return class'GameInfo'.Static.ParseKillMessage(
				RelatedPRI_1.PlayerName, 
				RelatedPRI_2.PlayerName,
				Class<Weapon>(OptionalObject).Default.ItemName,
				Class<Weapon>(OptionalObject).Default.DeathMessage
			);
			break;
		case 1: // Suicided
			if (RelatedPRI_1 == None)
				return "";
			if (RelatedPRI_1.bIsFemale)
				return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.FemaleSuicideMessage;
			else
				return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.MaleSuicideMessage;
			break;
		case 2: // Fell
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.FallMessage;
			break;
		case 3: // Eradicated (Used for runes, but not in UT)
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.ExplodeMessage;
			break;
		case 4:	// Drowned
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.DrownedMessage;
			break;
		case 5: // Burned
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.BurnedMessage;
			break;
		case 6: // Corroded
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.CorrodedMessage;
			break;
		case 7: // Mortared
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.PlayerName$class'TournamentGameInfo'.Default.MortarMessage;
			break;
		case 8: // Telefrag
			if (RelatedPRI_1 == None)
				return "";
			if (RelatedPRI_2 == None)
				return "";
			return class'GameInfo'.Static.ParseKillMessage(
				RelatedPRI_1.PlayerName,
				RelatedPRI_2.PlayerName,
				class'Translocator'.Default.ItemName,
				class'Translocator'.Default.DeathMessage
			);
			break;
	}
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == P.PlayerReplicationInfo)
	{
		// Interdict and send the child message instead.
		if ( TournamentPlayer(P).myHUD != None )
		{
			TournamentPlayer(P).myHUD.LocalizedMessage( Default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
			TournamentPlayer(P).myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		}

		if ( Default.bIsConsoleMessage )
		{
			TournamentPlayer(P).Player.Console.AddString(Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ));
		}

		if (( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None ))
		{
			if ( (TournamentPlayer(P).Level.TimeSeconds - TournamentPlayer(P).LastKillTime < 3) && (Switch != 1) )
			{
				TournamentPlayer(P).MultiLevel++;
				TournamentPlayer(P).ReceiveLocalizedMessage( class'MultiKillMessage', TournamentPlayer(P).MultiLevel );
			} 
			else
				TournamentPlayer(P).MultiLevel = 0;
			TournamentPlayer(P).LastKillTime = TournamentPlayer(P).Level.TimeSeconds;
		}
		else
			TournamentPlayer(P).MultiLevel = 0;
		if ( ChallengeHUD(P.MyHUD) != None )
			ChallengeHUD(P.MyHUD).ScoreTime = TournamentPlayer(P).Level.TimeSeconds;
	} 
	else if (RelatedPRI_2 == P.PlayerReplicationInfo) 
	{
		TournamentPlayer(P).ReceiveLocalizedMessage( class'VictimMessage', 0, RelatedPRI_1 );
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	} 
	else
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	ChildMessage=class'Botpack.KillerMessagePlus'
	DrawColor=(R=255,G=0,B=0)
	KilledString="was killed by"
	LifeTime=3
}