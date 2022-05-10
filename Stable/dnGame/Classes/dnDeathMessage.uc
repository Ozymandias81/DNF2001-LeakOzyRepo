//
// DukeForever Death Messages
//
// Switch 0: Kill
//	KillerPRI is the Killer.
//	VictimPRI is the Victim.
//	OptionalClass is the Damage Type
//

class dnDeathMessage extends LocalMessage;

var localized string KilledString;
var localized string KilledSelfMessage;

// When the HUD displays a message, it calls GetString to decide what to display
static function string GetString 
(
	optional int					Switch,
	optional PlayerReplicationInfo	KillerPRI, 
	optional PlayerReplicationInfo	VictimPRI,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	switch ( Switch )
	{
		case 0: // Regular death message.  Use the OptionalClass to derive the message
			if ( KillerPRI == None )
				return "";
			if ( KillerPRI.PlayerName == "" )
				return "";
			if ( VictimPRI == None )
				return "";
			if ( VictimPRI.PlayerName == "" )
				return "";
			if ( Class<DamageType>(OptionalClass) == None )
				return "";

			return class'GameInfo'.Static.ParseKillMessage
							( 
								KillerPRI.PlayerName, 
								VictimPRI.PlayerName,
								Class<DamageType>(OptionalClass).Default.DamageName,
								Class<DamageType>(OptionalClass).Default.DeathMessage
							);
			break;
	}
}

static function ClientReceive // Called from the server, which puts the message into the HUD.
	( 
	PlayerPawn						P,
	optional int					Switch,
	optional PlayerReplicationInfo	KillerPRI, 
	optional PlayerReplicationInfo	VictimPRI,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
	)
{
	// Add a death event to the HUD.  This will display the player's names and associated death icons.
	if ( dnDeathmatchGameHUD( DukePlayer(P).MyHUD ) != None )
	{
		dnDeathmatchGameHUD( DukePlayer(P).MyHUD ).AddDeathEvent( KillerPRI, VictimPRI, OptionalClass );
	}

	if ( VictimPRI == P.PlayerReplicationInfo )
	{
		//P.ReceiveLocalizedMessage( class'dnVictimMessage', 0, KillerPRI );

		if ( KillerPRI != None && KillerPRI.PlayerName != "" )
		{
/*
			if ( ( P != None ) && ( P.ScoreboardType != None ) && ( P.Scoreboard == None ) )
			{
				P.SpawnScoreboard();
			}
*/
			if ( dnDeathmatchGameScoreboard( P.scoreboard ) != None )
			{
				if ( true ) //KillerPRI == VictimPRI )
				{
					if ( DukePlayer( P ) != None )
					{
						DukePlayer( P ).LastKilledByPlayerName = KillerPRI.PlayerName;
						DukePlayer( P ).LastKilledByPlayerIcon = KillerPRI.Icon;
					}
					// Set up the player that last killed you
					// dnDeathmatchGameScoreboard( P.scoreboard ).LastKilledByMessage = Default.KilledSelfMessage;	
				}
				else
				{
					DukePlayer( P ).LastKilledByPlayerName = "";
					DukePlayer( P ).LastKilledByPlayerIcon = None;

//					dnDeathmatchGameScoreboard( P.scoreboard ).LastKilledByMessage = 
//						class'dnVictimMessage'.Default.YouWereKilledBy @ KillerPRI.PlayerName $ class'dnVictimMessage'.Default.KilledByTrailer;
				}
			}
		}
	}

	Super.ClientReceive( P,Switch,KillerPRI,VictimPRI,OptionalObject,OptionalClass );
}

defaultproperties
{
	bIsConsoleMessage=false
	KilledSelfMessage="You killed yourself."
}