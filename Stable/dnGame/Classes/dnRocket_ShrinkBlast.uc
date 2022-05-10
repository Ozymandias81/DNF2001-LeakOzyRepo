/*-----------------------------------------------------------------------------
	dnRocket_ShrinkBlast
	Author: Brandon Reinhart, Charlie Weinerholder

	Bouncey like the "laserjack!" CLIFFY B WHAT ARE YOU DOING IN THAT BUSHES?
-----------------------------------------------------------------------------*/
class dnRocket_ShrinkBlast expands dnRocket_BrainBlast;

#exec OBJ LOAD FILE=..\Meshes\c_fx.dmx
#exec OBJ LOAD FILE=..\sounds\D3DSounds.dfx

var int NumWallHits;
var bool bCanHitInstigator;

function PostBeginPlay()
{
	PlayAnim('Start');
	Super(dnRocket).PostBeginPlay();
}

function AnimEnd()
{
	LoopAnim('Loop');
}

simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	if ( bCanHitInstigator || (Other != Instigator) ) 
	{
		if ( Role == ROLE_Authority )
			Explode( HitLocation, Normal(HitLocation-Other.Location) );
//		if ( Other.bIsPawn )
//			PlaySound( MiscSound, SLOT_Misc, 2.0 );
//		else
//			PlaySound( ImpactSound, SLOT_Misc, 2.0 );
		Destroy();
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector Vel2D, Norm2D;

	// JEP...
	if ( Wall.IsA('BreakableGlass') )
	{
		BreakableGlass(Wall).ReplicateBreakGlass( Location-(HitNormal*10), true, 100.0f );
		return;
	}
	// ...JEP

//	PlaySound(ImpactSound, SLOT_Misc, 2.0);
//	LoopAnim('Spin',1.0);
	bCanHitInstigator = true;
	if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
	{
		if ( Role == ROLE_Authority )
			Wall.TakeDamage( Damage, Instigator, Location, MomentumTransfer * Normal(Velocity), class'ShrinkerDamage' );
		Destroy();
		return;
	}
	NumWallHits++;
	MakeNoise( 0.3 );
	if ( NumWallHits > 1 )
		Explode( Location, HitNormal );
	else
		Explode( Location, HitNormal, true );

	Velocity -= 2 * (Velocity dot HitNormal) * HitNormal;  
	SetRoll( Velocity );
}

simulated function SetRoll( vector NewVelocity )
{
	local rotator newRot;	

	newRot = rotator(NewVelocity);	
	SetRotation( newRot );
}

defaultproperties
{
	 Damage=100.0
	 DamageRadius=100.0
	 DamageClass=class'ShrinkerDamage'
     TrailClass=Class'dnParticles.dnBrainBlastFX_Plasma'
     AdditionalMountedActors(0)=(ActorClass=Class'dnParticles.dnBrainBlastFX_ShrinkBlast_CenterGlow')
     speed=1000.000000
     MaxSpeed=1000.000000
     MomentumTransfer=10000
     Texture=None
     Mesh=DukeMesh'c_FX.ShrinkBlast'
     DrawScale=0.675000
}
