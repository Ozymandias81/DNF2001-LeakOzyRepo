/*-----------------------------------------------------------------------------
	dnTossedGrenade
-----------------------------------------------------------------------------*/
class dnTossedGrenade extends PipeBomb;

function PostBeginPlay()
{
	SetTimer(1.75+FRand()*0.5,false);
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	Velocity = 0.75*(( Velocity dot Normal( HitLocation ) ) * Normal( HitLocation ) * (-2.0) + Velocity);
	if (!bHitWater)
		RandSpin(100000);
	speed = VSize(Velocity);
	if ( (Level.NetMode != NM_DedicatedServer) && (speed > 50) )
		PlayOwnedSound(ImpactSound, SLOT_Misc, FMax(0.5, speed/800) );
	if ( speed < 20 ) 
	{
		bBounce = false;
		SetPhysics(PHYS_None);
		if (MyFearSpot == None)
			MyFearSpot = Spawn( class'FearSpot', Instigator,, Location );
	}
}


defaultproperties
{
}
