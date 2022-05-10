/*-----------------------------------------------------------------------------
	Book
	Author: From Unreal, in here for Level Desginers dependent on old stuff.
-----------------------------------------------------------------------------*/
class Book extends Decoration;

var bool bFirstHit;

auto state Animate
{
	function HitWall ( vector HitNormal, actor Wall )
	{
		local float speed;

		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);
		if ( Speed > 500 )
			PlaySound( PushSound, SLOT_Misc, 1.0 );
		if ( bFirstHit && Speed < 400 )
		{
			bFirstHit = false;
			bRotatetoDesired = true;
			bFixedRotationDir = false;
			DesiredRotation.Pitch = 0;	
			DesiredRotation.Yaw = FRand()*65536;
			DesiredRotation.Roll = 0;		
		}
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;	
		if ( Speed < 30 )
			bBounce = false;
	}	

	function TakeDamage( int NDamage, Pawn InstigatedBy, Vector HitLocation, 
						Vector Momentum, class<DamageType> DamageType)
	{
		SetPhysics(PHYS_Falling);
		bBounce = true;
		Momentum.Z = abs(Momentum.Z*4+3000);
		Velocity=Momentum*0.02;
		RotationRate.Yaw = 250000*FRand() - 125000;
		RotationRate.Pitch = 250000*FRand() - 125000;
		RotationRate.Roll = 250000*FRand() - 125000;	
		DesiredRotation = RotRand();
		bRotateToDesired = false;
		bFixedRotationDir = true;
		bFirstHit = true;
	}
}

defaultproperties
{
     bStatic=false
     DrawType=DT_Sprite
     bMeshCurvy=false
     CollisionRadius=+00012.000000
     CollisionHeight=+00004.000000
	 bPushable=true
     bCollideActors=true
     bCollideWorld=true
     bBlockActors=true
     bBlockPlayers=true
     Mass=+00001.000000
}
