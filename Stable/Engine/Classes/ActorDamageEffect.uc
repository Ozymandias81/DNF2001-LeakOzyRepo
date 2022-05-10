/*-----------------------------------------------------------------------------
	ActorDamageEffect
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ActorDamageEffect extends Info
	abstract
	native;

simulated function PostNetInitial()
{
	if ( Role < ROLE_Authority )
		Initialize();
}

simulated function Initialize()
{
	AttachEffect( Owner );
	AttachActorToParent( Owner, false, false );
	SetPhysics( PHYS_MovingBrush );
}

simulated function Destroyed()
{
	RemoveEffect();
	Super.Destroyed();
}

simulated function RemoveEffect();
simulated function AttachEffect( Actor Other )
{
	// Remove any previous effects.
	RemoveEffect();
}

// Used to scale the size of the entire system.
simulated function ScaleDrawScale( float Scale );

// Specifically for bones.
simulated function TrashBone( name bonename );
simulated function TrashBoneByIndex( int Index );

defaultproperties
{
	Physics=PHYS_MovingBrush
	LifeSpan=10.0
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}