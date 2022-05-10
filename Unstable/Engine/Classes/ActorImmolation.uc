/*-----------------------------------------------------------------------------
	ActorImmolation
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ActorImmolation extends ActorDamageEffect
	abstract;

// Initialization.
simulated function Initialize()
{
	// Don't spawn under water.
	if ( Owner.Region.Zone.bWaterZone )
		Destroy();
	else
		Super.Initialize();
}

// Flame interface.
simulated function RemoveEffect()
{
	Super.RemoveEffect();

	// Remove burning flag.
	if ( RenderActor(Owner) != None )
		RenderActor(Owner).bBurning = false;

	// Remove burning dot.
	if ( Owner.bIsPawn )
		Pawn(Owner).RemoveDOT( DOT_Fire );
}

simulated function AttachEffect( Actor Other )
{
	Super.AttachEffect( Other );

	// Set burning flag.
	if ( RenderActor(Owner) != None )
		RenderActor(Owner).bBurning = true;

	// Add fire DOT if owner is a pawn.
	if ( Owner.bIsPawn )
		Pawn(Owner).AddDOT( DOT_Fire, Lifespan, 2.0, 5.0, Instigator );
}

function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if ( Owner == None )
		return;

	// Blacken the burning object.
	if ( Owner.ScaleGlow > 0.1 )
	{
		Owner.ScaleGlow -= DeltaTime / 20.0;
		if ( Owner.ScaleGlow < 0.1 )
			Owner.ScaleGlow = 0.1;
	}

	if ( Owner.Region.Zone.bWaterZone )
		Destroy();
}