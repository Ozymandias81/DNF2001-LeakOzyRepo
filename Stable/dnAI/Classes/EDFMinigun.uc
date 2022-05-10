class EDFMinigun extends dnDecoration;

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx

/*================================================================
	Sequences:
	
	FireLoop
	FireStart
	FireStop
	OffIdle
================================================================*/

var bool bReadyToFire;

function Tossed(optional bool Dropped)
{
	local int UpsideDirection, RandDir;
	local bool FoundDir;

	CarriedBy = None;
	bDropped = Dropped;
	bWaterLogged = false;
	bBobbing = false;
	bDoneTumbling = false;
	// Pick a random side to land on.
	while(!FoundDir)
	{
		RandDir = Rand(6);

		if ((RandDir == 0) && (bLandForward))
		{
			FoundDir = true;
			LandDirection = LAND_Forward;
			OrigCollisionRadius = LandFrontCollisionRadius;
			OrigCollisionHeight = LandFrontCollisionHeight;
		} 
		else if ((RandDir == 1) && (bLandBackwards))
		{
			FoundDir = true;
			LandDirection = LAND_Backwards;
			OrigCollisionRadius = LandFrontCollisionRadius;
			OrigCollisionHeight = LandFrontCollisionHeight;
		}
		else if ((RandDir == 2) && (bLandLeft))
		{
			FoundDir = true;
			LandDirection = LAND_Left;
			OrigCollisionRadius = LandSideCollisionRadius;
			OrigCollisionHeight = LandSideCollisionHeight;
		}
		else if ((RandDir == 3) && (bLandRight))
		{
			FoundDir = true;
			LandDirection = LAND_Right;
			OrigCollisionRadius = LandSideCollisionRadius;
			OrigCollisionHeight = LandSideCollisionHeight;
		}
		else if ((RandDir == 4) && (bLandUpright))
		{
			FoundDir = true;
			LandDirection = LAND_Upright;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
		else if ((RandDir == 5) && (bLandUpsideDown))
		{
			FoundDir = true;
			LandDirection = LAND_UpsideDown;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
		
		if ((!bLandForward) && (!bLandBackwards) && (!bLandLeft) && (!bLandRight) && (!bLandUpright) && (!bLandUpsideDown))
		{
			FoundDir = true;
			LandDirection = LAND_Upright;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
	}
	ResetMassProperties();
	bRotateByQuat = true;
	bRotateToDesired = false;
	bFixedRotationDir = true;
	if (LandDirection != LAND_Backwards)
		RotationRate.Pitch = BaseTumbleRate;
	else
		RotationRate.Pitch = -BaseTumbleRate;
	bCanTumble = true;
	bDamageFromToss = true;
	GotoState( 'Detonate' );
}

state Detonate
{
Begin:
	//sleep( 0.2 );
	Spawn( Class'dnParticles.dnGrenadeFX_Shrunk_Explosion_Flash' );
	Spawn( class'dnParticles.dnRobotGibFX_MachineChunksSmall' );
	Spawn( class'dnParticles.dnRobotGibFX_MachineChunksSmall' );
	Destroy();
}


function PlayFireStart()
{
	PlayAnim( 'FireStart' );
	PlaySound( sound'VStartSpinLp07', SLOT_Talk );
}

function PlayFireStop()
{
	if( AnimSequence != 'OffIdle' )
	{
		bReadyToFire = false;
		LoopAnim( 'OffIdle' );
		PlaySound( sound'VOff07', SLOT_Talk );
	}
}

auto state Active
{
	function BeginState()
	{
		Enable( 'AnimEnd' );
	}
	
	function AnimEnd()
	{
		local name CurrentSeq;

		//CurrentSeq = GetSequence( 0 );
		if( AnimSequence == 'Firestart' )
		{
			bReadyToFire = true;
			LoopAnim( 'FireLoop' );
		}
	}
}


DefaultProperties
{
	Mesh=DukeMesh'MiniGun_L'
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    CollisionHeight=0
    CollisionRadius=0
    VisibilityRadius=8000
	HitPackageClass=class'HitPackage_Steel'
}
