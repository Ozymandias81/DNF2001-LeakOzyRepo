//=============================================================================
// TriggerDamage. 						November 1st, 2000 - Charlie Wiederhold
//
// When triggered, *DAMAGES* the object(s) indicated by 'Event'.
//=============================================================================
class TriggerDamage expands Triggers;

var () int DamageAmount; // Amount to damage the event actors. 

// Damage all objects with tag equal to Event:
function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;
	
	// Validate Event.
	if( Event != '' ) 
		// Damage all actors with matching triggers 
		foreach AllActors( class 'Actor', A, Event )	
		{		
//			A.Health-=DamageAmount;
			A.TakeDamage( DamageAmount, EventInstigator, A.Location, Vect(0,0,1)*900, class'ExplosionDamage' );		
		}
}

defaultproperties
{
     Texture=Texture'Engine.S_TriggerDestroy'
}
