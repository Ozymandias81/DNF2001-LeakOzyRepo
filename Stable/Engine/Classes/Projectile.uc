/*-----------------------------------------------------------------------------
	Projectile

	A delayed-hit projectile moves around for some time after it is created.
	An instant-hit projectile acts immediately. 
-----------------------------------------------------------------------------*/
class Projectile extends RenderActor
	abstract
	native;

#exec Texture Import File=Textures\S_Camera.pcx Name=S_Camera Mips=Off Flags=2

// Motion information.
var() float		Speed				?("Initial speed of projectile.");
var() float		MaxSpeed			?("Limit on speed of projectile (0 means no limit).");

// Damage attributes.
var() float		Damage				?("Damage projectile inflicts.");
var() int		MomentumTransfer	?("Momentum imparted by impacting projectile.");

// Projectile sound effects
var() sound		SpawnSound			?("Sound made when projectile is spawned.");
var() sound		ImpactSound			?("Sound made when projectile hits something.");
var() sound		MiscSound			?("Miscellaneous Sound.");

var() float		ExploWallOut		?("Distance to move explosions out from wall.");

// Explosion decal.
var() class<Decal> ExplosionDecal	?("Decal to place upon exploding.");

simulated function InitEffects();

/*-----------------------------------------------------------------------------
	Encroachment
-----------------------------------------------------------------------------*/

function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

/*-----------------------------------------------------------------------------
	Touching
-----------------------------------------------------------------------------*/

simulated singular function Touch(Actor Other)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, TestLocation;
	
	// JEP...
	if (Other.IsA('BreakableGlass'))
	{
		// BR: I added ReplicateBreakGlassDir to handle network logic of breaking glass.
		BreakableGlass(Other).ReplicateBreakGlassDir( Location, Velocity, 100.0f );
		return;
	}
	// ...JEP

	if ( Other.IsA('BlockAll') )
	{
		HitWall( Normal(Location - Other.Location), Other);
		return;
	}
	if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) )
	{
		//get exact hitlocation
	 	HitActor = Trace(HitLocation, HitNormal, Location, OldLocation, true);
		if (HitActor == Other)
		{
			if ( Other.bIsPawn 
				&& !Pawn(Other).AdjustHitLocation(HitLocation, Velocity) )
					return;
			ProcessTouch(Other, HitLocation); 
		}
		else 
			ProcessTouch(Other, Other.Location + Other.CollisionRadius * Normal(Location - Other.Location));
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	//should be implemented in subclass
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	// JEP...
	if (Wall.IsA('BreakableGlass'))
	{
		BreakableGlass(Wall).ReplicateBreakGlassDir( Location, Velocity, 100.0f );
		return;
	}
	// ...JEP

	if ( Role == ROLE_Authority )
	{
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), class'ExplosionDamage' );

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( ExplosionDecal != None )
		Spawn(ExplosionDecal,self,,Location, rotator(HitNormal));
}

simulated function Explode( vector HitLocation, optional vector HitNormal, optional bool bNoDestroy )
{
	Destroy();
}

simulated function RandSpin( float spinRate )
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

defaultproperties
{
     MaxSpeed=+02000.000000
     bDirectional=true
     DrawType=DT_Mesh
     Texture=S_Camera
     SoundVolume=0
     CollisionRadius=+00000.000000
     CollisionHeight=+00000.000000
     bCollideActors=true
     bCollideWorld=true
	 bNetTemporary=true
	 bGameRelevant=true
	 bReplicateInstigator=true
     Physics=PHYS_Projectile
     LifeSpan=+00140.000000
     NetPriority=+00002.500000
}
