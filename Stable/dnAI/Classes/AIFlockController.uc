/*=============================================================================
	AIFlockController
	Author: Jess Crable

	Not fully implemented.
=============================================================================*/

class AIFlockController extends AIPawn;

var() bool bWaitUntilTriggered;

function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

event FootZoneChange(ZoneInfo newFootZone)
{
}

function EncroachedBy( actor Other )
{
}
	
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
}
	
function BaseChange()
{
}
	
defaultproperties
{
    // bForceStasis=True
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     Mass=5.00
     Buoyancy=5.00
}