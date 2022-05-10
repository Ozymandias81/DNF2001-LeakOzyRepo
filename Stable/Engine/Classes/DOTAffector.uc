/*-----------------------------------------------------------------------------
	DOTAffector
	Author: Brandon Reinhart

	Attaches on to a linked list on the pawn and does damage over time.
-----------------------------------------------------------------------------*/
class DOTAffector extends Info
	native;

// DOT Affector linked list.
var DOTAffector	NextAffector;

var int	  Type;							// Type of DOT.
var float Damage;						// Damage to inflict on a DOT ping.
var float Time;							// Frequency of a DOT ping.
var float Counter;						// How long we've been taking damage so far.
var float Duration;						// Total duration of DOT.
var float LastDamageTime;				// Last time this DOT hurt the player.
var bool  bNoTimeoutWhileTouching;		// If true, the DOT won't die out as long as we are touching the actor that assigned DOT to us.
var Actor TouchingActor;
var Pawn  AffectedPawn;
var Pawn  DOTInstigator;

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		Type, NextAffector;
}

function StartTimer()
{
	SetCallbackTimer( Time, true, 'DoDOT' );
}

function DoDOT()
{
	local DOTAffector PrevDOT, CurrentDOT;
	local Actor A;
	local bool bIncrement;

	if ( (AffectedPawn.Health < 0) || (Level.NetMode == NM_Client) )
		return;

	if ( Damage > 0 )
		AffectedPawn.TakeDamage( Damage, DOTInstigator, Location, vect(0,0,0), GetDamageTypeForDOT( Type ) );

	LastDamageTime = Level.TimeSeconds;

	// Check to see if we should increment our counter.
	// If bNoTimeoutWhileTouching, we don't increment if we are 
	// touching the source of the DOT (fire, cloud of poison, etc).
	bIncrement = true;
	if ( bNoTimeoutWhileTouching )
	{
		foreach AffectedPawn.TouchingActors( class'Actor', A )
		{
			if ( A == TouchingActor )
				bIncrement = false;
		}
	}

	if ( !bIncrement )
		return;

	// Increment time and see if we have ended.
	Counter += Time;
	if ( Counter >= Duration )
	{
		for ( CurrentDOT = AffectedPawn.DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
		{
			if ( CurrentDOT == Self )
			{
				if ( PrevDOT == None )
					AffectedPawn.DOTAffectorList = CurrentDOT.NextAffector;
				else
					PrevDOT.NextAffector = CurrentDOT.NextAffector;
				Destroy();
				return;
			}
			PrevDOT = CurrentDOT;
		}
	}
}

static function class<DamageType> GetDamageTypeForDOT( int i )
{
	local class<DamageType> DamageType;

	switch (i)
	{
		case 0:
			DamageType = class'ElectricalDamage';
			break;
		case 1:
			DamageType = class'FireDamage';
			break;
		case 2:
			DamageType = class'ColdDamage';
			break;
		case 3:
			DamageType = class'PoisonDamage';
			break;
		case 4:
			DamageType = class'RadiationDamage';
			break;
		case 5:
			DamageType = class'BiochemicalDamage';
			break;
		case 6:
			DamageType = class'DrowningDamage';
			break;
		case 7:
			DamageType = class'SteroidBurnoutDamage';
			break;
		case 8:
			DamageType = class'ElectricalDamage';
			break;
		case 9:
			DamageType = class'ElectricalDamage';
			break;
	}

	return DamageType;
}

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
}