//=============================================================================
// TournamentGameInfo.
//
// default game info is normal single player
//
//=============================================================================
class TournamentGameInfo extends GameInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\Resp2a.wav" NAME="Resp2A" GROUP="General"

var(DeathMessage) localized string DeathMessage[32];    // Player name, or blank if none.
var(DeathMessage) localized string DeathModifier[5];
var(DeathMessage) localized string MajorDeathMessage[8];
var(DeathMessage) localized string HeadLossMessage[2];
var(DeathMessage) localized string DeathVerb;
var(DeathMessage) localized string DeathPrep;
var(DeathMessage) localized string DeathTerm;
var(DeathMessage) localized string ExplodeMessage;
var(DeathMessage) localized string SuicideMessage;
var(DeathMessage) localized string FallMessage;
var(DeathMessage) localized string DrownedMessage;
var(DeathMessage) localized string BurnedMessage;
var(DeathMessage) localized string CorrodedMessage;
var(DeathMessage) localized string HackedMessage;
var(DeathMessage) localized string MortarMessage;
var(DeathMessage) localized string MaleSuicideMessage;
var(DeathMessage) localized string FemaleSuicideMessage;

var bool bRatedGame;

var class<Weapon> RedeemerClass;
var class<EndStats> EndStatsClass;

var int TotalGames;
var int TotalFrags;
var int TotalDeaths;
var int TotalFlags;

var string BestPlayers[3];
var int BestFPHs[3];
var string BestRecordDate[3];

function bool AtCapacity(string Options)
{
	local string OverrideClass;
	local class<PlayerPawn> SpecClass;

	OverrideClass = ParseOption ( Options, "OverrideClass" );	
	if ( OverrideClass != "" )
		SpecClass = class<PlayerPawn>(DynamicLoadObject(OverrideClass,class'Class'));

	if ( ClassIsChildOf(SpecClass, class'Spectator') )
		return ( (NumSpectators >= MaxSpectators)
				|| ((Level.Netmode == NM_ListenServer) && (NumPlayers == 0)) );
	return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local string OverrideClass;
	local class<PlayerPawn> SpecClass;
	local string InVoice;

	if ( !bRatedGame )
	{
		OverrideClass = ParseOption ( Options, "OverrideClass" );	
		if ( OverrideClass != "" )
		{
			SpecClass = class<PlayerPawn>(DynamicLoadObject(OverrideClass,class'Class'));
			if ( SpecClass != None )
				SpawnClass = SpecClass;
		}
		if ( ClassIsChildOf(SpawnClass, class'Spectator') )
		{
			if ( !ClassIsChildOf( SpawnClass, class'CHSpectator') )
				SpawnClass = class'CHSpectator';
		}
		else if ( !ClassIsChildOf(SpawnClass, class'TournamentPlayer') )
			SpawnClass = DefaultPlayerClass;
	}
	else if ( !ClassIsChildOf(SpawnClass, class'TournamentPlayer') )
		SpawnClass = DefaultPlayerClass;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( NewPlayer != None )
	{
		if ( !NewPlayer.IsA('Spectator') )
		{
			InVoice = ParseOption ( Options, "Voice" );
			if ( InVoice != "" )
				NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(InVoice, class'Class'));
			if ( NewPlayer.PlayerReplicationInfo.VoiceType == None )
				NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewPlayer.VoiceType, class'Class'));
			if ( NewPlayer.PlayerReplicationInfo.VoiceType == None )
				NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("Botpack.VoiceMaleOne", class'Class'));
		}
	}

	return NewPlayer;
}


function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'EnhancedReSpawn',Inv,, Inv.Location );
	return 0.3;
}

function bool ShouldRespawn(Actor Other)
{
	return false;
}

static function string KillMessage( name damageType, pawn Other )
{
	local string message;
	
	if (damageType == 'Exploded')
		message = Default.ExplodeMessage;
	else if ( damageType == 'Eradicated' )
		message = Default.ExplodeMessage;
	else if (damageType == 'Suicided')
		message = Default.SuicideMessage;
	else if ( damageType == 'Fell' )
		message = Default.FallMessage;
	else if ( damageType == 'Drowned' )
		message = Default.DrownedMessage;
	else if ( damageType == 'Burned' )
		message = Default.BurnedMessage;
	else if ( damageType == 'Corroded' )
		message = Default.CorrodedMessage;
	else if ( damageType == 'Mortared' )
		message = Default.MortarMessage;
	else
		message = Default.DeathVerb$Default.DeathTerm;
		
	return message;	
}

static function string CreatureKillMessage(name damageType, pawn Other)
{
	local string message;
	
	if (damageType == 'exploded')
		message = Default.ExplodeMessage;
	else if ( damageType == 'Eradicated' )
		message = Default.ExplodeMessage;
	else if ( damageType == 'Burned' )
		message = Default.BurnedMessage;
	else if ( damageType == 'Corroded' )
		message = Default.CorrodedMessage;
	else if ( damageType == 'Hacked' )
		message = Default.HackedMessage;
	else
		message = Default.DeathVerb$Default.DeathTerm;

	return ( message$Default.DeathPrep );
}

static function string PlayerKillMessage( name damageType, PlayerReplicationInfo Other )
{
	local string message;
	local float decision;
	
	decision = FRand();

	if ( decision < 0.2 )
		message = Default.MajorDeathMessage[Rand(3)];
	else
	{
		if ( DamageType == 'Decapitated' )
			message = Default.HeadLossMessage[Rand(2)];
		else 
			message = Default.DeathMessage[Rand(32)];

		if ( decision < 0.75 )
			message = Default.DeathModifier[Rand(5)]$message;
	}	
	
	return ( Default.DeathVerb$message$Default.DeathPrep );
} 	

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
 	local UTTeleportEffect PTE;

	if ( Incoming.bIsPawn && (Incoming.Mesh != None) )
	{
		if ( bSound )
		{
 			PTE = Spawn(class'UTTeleportEffect',,, Incoming.Location, Incoming.Rotation);
 			PTE.Initialize(Pawn(Incoming), bOut);
			Incoming.PlaySound(sound'Resp2A',, 10.0);
		}
	}
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	if (damageType == 'RedeemerDeath')
	{
		if ( RedeemerClass == None )
			RedeemerClass = class<Weapon>(DynamicLoadObject("Botpack.Warheadlauncher", class'Class'));
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, RedeemerClass);
	}
	else if (damageType == 'Eradicated')
		BroadcastLocalizedMessage(class'EradicatedDeathMessage', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	else if ((damageType == 'RocketDeath') || (damageType == 'GrenadeDeath'))
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, class'UT_Eightball');
	else if (damageType == 'Gibbed')
		BroadcastLocalizedMessage(DeathMessageClass, 8, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	else {
		if (Killer.Weapon != None)
			BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
		else
			BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	}
}

//
// Discard a player's inventory after he dies.
//
function DiscardInventory( Pawn Other )
{
	local actor dropped;
	local inventory Inv, NextInv;
	local weapon weap;
	local float speed;
	local LadderInventory MainLadderInventory;

	if( Other.DropWhenKilled != None )
	{
		dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
		Inv = Inventory(dropped);
		if ( Inv != None )
		{ 
			Inv.RespawnTime = 0.0; //don't respawn
			Inv.BecomePickup();		
		}
		if ( dropped != None )
		{
			dropped.RemoteRole = ROLE_DumbProxy;
			dropped.SetPhysics(PHYS_Falling);
			dropped.bCollideWorld = true;
			dropped.Velocity = Other.Velocity + VRand() * 280;
		}
		if ( Inv != None )
			Inv.GotoState('PickUp', 'Dropped');
	}					
	if( (Other.Weapon!=None) && (Other.Weapon.Class!=BaseMutator.MutatedDefaultWeapon()) 
		&& ((Other.Weapon.Ammotype == None) || (Other.Weapon.Ammotype.AmmoAmount > 0))
		&& Other.Weapon.bCanThrow )
	{
		speed = VSize(Other.Velocity);
		weap = Other.Weapon;
		if (speed != 0)
			weap.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
		else {
			weap.Velocity.X = 0;
			weap.Velocity.Y = 0;
			weap.Velocity.Z = 0;
		}
		Other.TossWeapon();
	}
	Other.Weapon = None;
	Other.SelectedItem = None;

	// Destroy the inventory list.
	Inv = Other.Inventory;
	while (Inv != None)
	{
		NextInv = Inv.Inventory;
		if (!Inv.IsA('LadderInventory'))
		{
			Inv.DropInventory();
			Inv.Destroy();
		} else
			MainLadderInventory = LadderInventory(Inv);
		Inv = NextInv;
	}
	if (MainLadderInventory != None)
	{
		Other.Inventory = MainLadderInventory;
		MainLadderInventory = None;
	}
}

function CalcEndStats()
{
	local int i, j;
	local float FPH;

	for (i=0; i<32; i++)
	{
		if (GameReplicationInfo.PRIArray[i] != None)
		{
			TotalFrags += GameReplicationInfo.PRIArray[i].Score;
			TotalDeaths += GameReplicationInfo.PRIArray[i].Deaths;
			FPH = 60 * GameReplicationInfo.PRIArray[i].Score/FMax(1, Level.TimeSeconds - GameReplicationInfo.PRIArray[i].StartTime);
			for (j=2; j>-1; j--)
			{
				if (FPH > BestFPHs[j])
				{
					EmptyBestSlot(j);
					BestFPHs[j] = FPH;
					BestPlayers[j] = GameReplicationInfo.PRIArray[i].PlayerName;
					GetTimeStamp(BestRecordDate[j]);
					j = -1; // break.
				}
			}
		}
	}

	for (i=0; i<3; i++)
	{
		if (BestPlayers[i] != "")
		{
			EndStatsClass.Default.BestPlayers[2-i] = BestPlayers[i];
			EndStatsClass.Default.BestFPHs[2-i] = BestFPHs[i];
			EndStatsClass.Default.BestRecordDate[2-i] = BestRecordDate[i];
		}
	}
	EndStatsClass.Default.TotalFrags = TotalFrags;
	EndStatsClass.Default.TotalDeaths = TotalDeaths;
	EndStatsClass.Default.TotalGames++;
	EndStatsClass.Static.StaticSaveConfig();
}

function EmptyBestSlot(int Slot)
{
	if (Slot == 2)
	{
		BestFPHs[0] = BestFPHs[1];
		BestPlayers[0] = BestPlayers[1];
		BestRecordDate[0] = BestRecordDate[1];

		BestFPHs[1] = BestFPHs[2];
		BestPlayers[1] = BestPlayers[2];
		BestRecordDate[1] = BestRecordDate[2];
	} else if (Slot == 1) {
		BestFPHs[0] = BestFPHs[1];
		BestPlayers[0] = BestPlayers[1];
		BestRecordDate[0] = BestRecordDate[1];
	}
}

function GetTimeStamp(out string AbsoluteTime)
{
	if (Level.Month < 10)
		AbsoluteTime = "0"$Level.Month;
	else
		AbsoluteTime = string(Level.Month);

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$"/0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"/"$Level.Day;

	AbsoluteTime = AbsoluteTime$"/"$Level.Year;

	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$" 0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$" "$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Second;
}

defaultproperties
{
     deathmessage(0)="killed"
     deathmessage(1)="ruled"
     deathmessage(2)="smoked"
     deathmessage(3)="slaughtered"
     deathmessage(4)="annihilated"
     deathmessage(5)="put down"
     deathmessage(6)="splooged"
     deathmessage(7)="perforated"
     deathmessage(8)="shredded"
     deathmessage(9)="destroyed"
     deathmessage(10)="whacked"
     deathmessage(11)="canned"
     deathmessage(12)="busted"
     deathmessage(13)="creamed"
     deathmessage(14)="smeared"
     deathmessage(15)="shut out"
     deathmessage(16)="beaten down"
     deathmessage(17)="smacked down"
     deathmessage(18)="pureed"
     deathmessage(19)="sliced"
     deathmessage(20)="diced"
     deathmessage(21)="ripped"
     deathmessage(22)="blasted"
     deathmessage(23)="torn up"
     deathmessage(24)="spanked"
     deathmessage(25)="eviscerated"
     deathmessage(26)="neutered"
     deathmessage(27)="whipped"
     deathmessage(28)="shafted"
     deathmessage(29)="trashed"
     deathmessage(30)="smashed"
     deathmessage(31)="trounced"
     DeathModifier(0)="thoroughly "
     DeathModifier(1)="completely "
     DeathModifier(2)="absolutely "
     DeathModifier(3)="totally "
     DeathModifier(4)="utterly "
     MajorDeathMessage(0)="ripped a new one"
     MajorDeathMessage(1)="messed up real bad"
     MajorDeathMessage(2)="given a new definition of pain"
     HeadLossMessage(0)="decapitated"
     HeadLossMessage(1)="beheaded"
     DeathVerb=" was "
     DeathPrep=" by "
     DeathTerm="killed"
     ExplodeMessage=" was blown up."
     SuicideMessage=" had a sudden heart attack."
     FallMessage=" left a small crater."
     DrownedMessage=" forgot to come up for air."
	 BurnedMessage=" was incinerated."
	 CorrodedMessage=" was slimed."
	 HackedMessage=" was hacked."
	 MortarMessage=" was blown up by a mortar."
	 MaleSuicideMessage=" killed his own dumb self."
	 FemaleSuicideMessage=" killed her own dumb self."
     DefaultWeapon=Class'Botpack.ImpactHammer'
	 DefaultPlayerClass=Class'Botpack.TMale1'
	 WaterZoneType=Class'UnrealShare.WaterZone'
	 StatLogClass=class'UTStatLogFile'
	 EndStatsClass=class'EndStats'
}
