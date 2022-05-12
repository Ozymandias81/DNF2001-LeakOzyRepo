//=============================================================================
// UnrealGameInfo.
//
// default game info is normal single player
//
//=============================================================================
class UnrealGameInfo extends GameInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.WAV" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.WAV" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\pickups\genwep1.WAV" NAME="WeaponPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Generic\teleport1.WAV" NAME="Teleport1" GROUP="Generic"

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

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if ( instigatedBy == None)
		return Damage;
	//skill level modification
	if ( instigatedBy.bIsPlayer )
	{
		if ( injured == instigatedby )
		{ 
			if ( instigatedby.skill == 0 )
				Damage = 0.25 * Damage;
			else if ( instigatedby.skill == 1 )
				Damage = 0.5 * Damage;
		}
		else if ( !injured.bIsPlayer )
			Damage = float(Damage) * (1.1 - 0.1 * injured.skill);
	}
	else if ( injured.bIsPlayer )
		Damage = Damage * (0.4 + 0.2 * instigatedBy.skill);
	return (Damage * instigatedBy.DamageScaling);
}

function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'ReSpawn',,, Inv.Location );
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
	else if (damageType == 'Suicided')
		message = Default.SuicideMessage;
	else if ( damageType == 'Fell' )
		message = Default.FallMessage;
	else if ( damageType == 'Drowned' )
		message = Default.DrownedMessage;
	else if ( damageType == 'Special' )
		message = Default.SpecialDamageString;
	else if ( damageType == 'Burned' )
		message = Default.BurnedMessage;
	else if ( damageType == 'Corroded' )
		message = Default.CorrodedMessage;
	else
		message = Default.DeathVerb$Default.DeathTerm;
		
	return message;	
}

static function string CreatureKillMessage( name damageType, pawn Other )
{
	local string message;
	
	if (damageType == 'exploded')
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
	local PawnTeleportEffect PTE;

	if ( Incoming.IsA('Pawn') )
	{
		if ( bSound )
		{
			PTE = Spawn(class'PawnTeleportEffect',,, Incoming.Location, Incoming.Rotation);
			PTE.Initialize(Pawn(Incoming), bOut);
			if ( Incoming.IsA('PlayerPawn') )
				PlayerPawn(Incoming).SetFOVAngle(170);
			Incoming.PlaySound(sound'Teleport1',, 10.0);
		}
	}
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
     DefaultWeapon=Class'UnrealShare.DispersionPistol'
     GameMenuType=Class'UnrealShare.UnrealGameOptionsMenu'
     HUDType=Class'UnrealShare.UnrealHUD'
	 DefaultPlayerClass=Class'UnrealShare.MaleThree'
	 WaterZoneType=Class'UnrealShare.WaterZone'
}
