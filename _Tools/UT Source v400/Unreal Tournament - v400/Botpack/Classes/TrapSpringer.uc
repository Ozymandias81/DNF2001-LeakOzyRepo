//=============================================================================
// TrapSpringer.
//=============================================================================
class TrapSpringer extends Inventory;

var() name TrapTag; //tag of trap - could be zone, mover, or a trigger which counts touches
var() name TriggerTag;	// tag of trigger for trap
var Actor Trap[8];
var Actor TrapTrigger;
var() bool bShootIt;
var int trapnum;

function PostBeginPlay()
{
	local int num;
	local Actor A;

	Super.PostBeginPlay();
	DrawType = DT_None;

	if ( (TrapTag == '') || (TriggerTag == '') )
	{
		Destroy();
		return;
	}

	ForEach AllActors(class'Actor', TrapTrigger, TriggerTag)
		break;

	trapnum = 0;
	ForEach AllActors(class'Actor', A, TrapTag)
		if ( A.IsA('ZoneInfo') )
		{
			Trap[0] = A;
			TrapNum = 1;
			return;
		}
		else if ( A.IsA('Mover') || A.IsA('Trigger') )
		{
			Trap[trapnum] = A;
			trapnum++;
			if ( trapnum == 8 )
				return;
		}
}

//=============================================================================
// AI inventory functions.

function float CalcDesire( Pawn Bot, Pawn Enemy )
{
	TrapTrigger.SpecialHandling(Bot);

	return 1.5;
}

event float BotDesireability( pawn Bot )
{
	local Pawn P;
	local int i,j;
	local float dist;

	if ( (Trap[0] == None) || (TrapTrigger == None) )
	{
		Destroy();
		return -1;
	}
	
	if ( bShootit && ((Bot.bFire !=0) || (Bot.bAltFire != 0)) )
		return -1;

	dist = VSize(Bot.Location - Location);

	if ( dist > 1600 )
		return -1;

	for ( j=0; j<trapnum; j++ )
		if ( Trap[j] != None )
		{
			if ( Trap[j].IsA('ZoneInfo') )
			{
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Region.Zone == Trap[j]) && FoundTrapTarget(Bot, P) )
						return CalcDesire(Bot, P);
			}
			else if ( Trap[j].bBlockActors || Trap[j].bBlockPlayers )
			{
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Base == Trap[j]) && FoundTrapTarget(Bot, P) )
						return CalcDesire(Bot, P);
			}
			else if ( Trap[j].bCollideActors )
			{
				for ( i=0 ;i<4; i++ )
				{
					P = Pawn(Trap[j].Touching[i]);
					if ( (P != None) && FoundTrapTarget(Bot, P) )
						return CalcDesire(Bot, Pawn(Trap[j].Touching[i]));
				}
			}
		}
	return -1;
}

function bool FoundTrapTarget(Pawn Bot, Pawn P)
{
	return ( P.bIsPlayer && (P != Bot) && (P.Health > 0) 
			&& (!Level.Game.bTeamGame || (P.PlayerReplicationInfo.Team != Bot.PlayerReplicationInfo.Team)) );
}

//
// Become a pickup.
//
function BecomePickup()
{
	SetCollision( true, false, false );
}

//
// Become an inventory item.
//
function BecomeItem()
{
}

//
// Give this inventory item to a pawn.
//
function GiveTo( pawn Other )
{
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
function inventory SpawnCopy( pawn Other )
{
	return None;
}

//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	singular function ZoneChange( ZoneInfo NewZone )
	{
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		local Actor A;

		if( (Event != '') && (Pawn(Other)!=None) 
			&& Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0) )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Other, Other.Instigator );
	}

	function BeginState()
	{
		BecomePickup();
	}

Begin:
	BecomePickup();

Dropped:
}

defaultproperties
{
	 MaxDesireability=1.0
     DrawType=DT_Sprite
     Texture=Texture'Engine.S_Inventory'
	 bHidden=false
}