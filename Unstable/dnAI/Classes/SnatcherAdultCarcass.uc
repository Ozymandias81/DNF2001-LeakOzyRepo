/*=============================================================================
	SnatcherAdultCarcass
	Author: Jess Crable

=============================================================================*/
class SnatcherAdultCarcass extends CreaturePawnCarcass;

function InitFor( RenderActor Other )
{
	local int i;

    local int bone;
	local vector newloc, v;
	local MeshInstance minst;
	local float OldCollisionHeight;	
	local MeshDecal Decal;

	// Initialize critical details based on the owner actor.
	SetLocation( Other.Location );
	SetCollisionSize( Other.CollisionRadius*2, Other.CollisionHeight );
	if( !bNoTakeOwnerProperties )
	{
		Mesh					= Other.Mesh;
		Skin					= Other.Skin;
		Texture					= Other.Texture;
		Fatness					= Other.Fatness;
		ScaleGlow				= Other.ScaleGlow;
		DrawScale				= Other.DrawScale;
	}
	DesiredRotation			= Other.Rotation;
	DesiredRotation.Roll	= 0;
	DesiredRotation.Pitch	= 0;
	AnimSequence			= Other.AnimSequence;
	AnimFrame				= Other.AnimFrame;
	AnimRate				= Other.AnimRate;
	TweenRate				= Other.TweenRate;
	AnimMinRate				= Other.AnimMinRate;
	AnimLast				= Other.AnimLast;
	AnimBlend               = Other.AnimBlend;
	bAnimLoop				= Other.bAnimLoop;
	SimAnim.X				= 10000 * AnimFrame;
	SimAnim.Y				= 5000  * AnimRate;
	SimAnim.Z				= 1000  * TweenRate;
	SimAnim.W				= 10000 * AnimLast;
	bAnimFinished			= Other.bAnimFinished;	

	// Pawn specific
	if ( Other.bIsPawn )
	{
		BlastVelocity		= Other.Velocity;
	}

	Mass					= Other.Mass;
	bMeshLowerByCollision	= Other.bMeshLowerByCollision;
	if ( Buoyancy < 0.8 * Mass )
		Buoyancy			= 0.9 * Mass;
	for ( i=0; i<4; i++ )
		Multiskins[i]		= Pawn(Other).MultiSkins[i];

	// Copy mounted decorations.
	if ( Other.bIsPawn )
	{
		for ( i=0; i<6; i++ )
		{
			if ( Pawn(Other).MountedDecorations[i] != None )
			{
				MountedDecorations[i] = Pawn(Other).MountedDecorations[i];
				Pawn(Other).MountedDecorations[i] = None;
				MountedDecorations[i].AttachActorToParent( self, true, true );
			}
			ExpandedBones[i] = Pawn(Other).ExpandedBones[i];
			ExpandedScales[i] = Pawn(Other).ExpandedScales[i];
		}
		bExpandedCollision = Pawn(Other).bExpandedCollision;
		bExpanding = Pawn(Other).bExpanding;
		ExpandTimeRemaining = Pawn(Other).ExpandTimeRemaining;
		ExpandTimeEnd = Pawn(Other).ExpandTimeEnd;
		ShrinkCounter = Pawn(Other).ShrinkCounter;
	}

	// Copy heat vision settings.
	if ( Other.bHeated )
	{
		bHeated				= true;
		HeatIntensity		= Other.HeatIntensity;
		HeatRadius			= Other.HeatRadius;
		HeatFalloff			= Other.HeatFalloff;
	}

	// Move effects.
	if ( Other.bIsPawn )
	{
		ImmolationClass = Pawn(Other).ImmolationClass;
		if ( (Pawn(Other).ImmolationActor != None) && !Pawn(Other).ImmolationActor.bDeleteMe )
		{
			ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
			ImmolationActor.Initialize();
		}

		ShrinkClass = Pawn(Other).ShrinkClass;
		if ( (Pawn(Other).ShrinkActor != None) && !Pawn(Other).ShrinkActor.bDeleteMe )
		{
			ShrinkActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ShrinkClass, class'Class' )), Self );
			ShrinkActor.Initialize();
		}	

		self.MeshDecalLink  = Other.MeshDecalLink;
		Other.MeshDecalLink = None;		
		for ( Decal = MeshDecalLink; Decal != None; Decal = Decal.MeshDecalLink )
		{
			Decal.Actor = self;
		}
	}

	FixCollisionRadius();
}

function FixCollisionRadius()
{
	local Actor HitActor;
	local Vector HitNormal, HitLocation;
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Rotator Rot;
	local float Rad, NewRadius;
	local int i;

	// Search around the carcass to try and not get the carcass stuck in the wall.
	StartTrace = Location;
	NewRadius  = CollisionRadius;

	for ( i=0; i<16; i++ )
	{
		GetAxes( Rot, X, Y, Z );

		EndTrace  = StartTrace + ( CollisionRadius * X );
		HitActor  = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
				
		if ( HitActor == Level )
		{
			Rad = VSize(HitLocation - StartTrace);
			if ( Rad < NewRadius )
			{
				NewRadius = Rad;
			}
		}		
		Rot.Yaw += 65535/16;
	}

	if ( NewRadius < CollisionRadius )
	{		
		SetCollisionSize( NewRadius*0.9, CollisionHeight );
	}
}

function bool OnEvalBones( int channel )
{
	log( "RAD: "$CollisionRadius );

	return Super.OnEvalBones( channel );
}


defaultproperties
{
     CollisionHeight=10.0
	 CollisionRadius=60.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.alien_AdultSnatcher'
     Physics=PHYS_Falling
     ItemName="Adult Snatcher Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
     BloodPoolName="dnGame.dnAlienBloodPool"
     BloodHitDecalName="dnGame.dnAlienBloodHit"
     HitPackageClass=class'HitPackage_AlienFlesh'
     BigChunksClass=class'dnParticles.dnBloodFX_BloodChunksSmall'
     BloodHazeClass=class'dnParticles.dnBloodFX_BloodHazeSmall'
     SmallChunksClass=class'dnParticles.dnBloodFX_BloodChunksSmall'
     SmallBloodHazeClass=class'dnParticles.dnBloodFX_BloodHazeSmall'
}
