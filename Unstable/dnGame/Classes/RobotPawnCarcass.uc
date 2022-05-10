/*-----------------------------------------------------------------------------
	RobotPawnCarcass
-----------------------------------------------------------------------------*/
class RobotPawnCarcass extends CreaturePawnCarcass;

#exec OBJ LOAD FILE=..\Sounds\a_edf.dfx
#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx
var bool bLegless;

function ImpactGround()
{
	PlaySound( Sound'EDFRobotFall01', SLOT_Misc, 0.96, true );
}

simulated function bool EvalMissingLegs()
{
	local Meshinstance Minst;
	local int Bone;

	if( bLegless )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Shin_L');
		if (bone!=0)
		{			
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		}
		bone = minst.BoneFindNamed('Shin_R');
		if (bone!=0)
		{
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		}
		bone = minst.BoneFindNamed('Knee_L');
		if (bone!=0)
		{			
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		}
		bone = minst.BoneFindNamed('Knee_R');
		if (bone!=0)
		{
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		}
		bone = minst.BoneFindNamed('Thigh_L');
		if (bone!=0)
		{			
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		}
		bone = minst.BoneFindNamed('Thigh_R');
		if (bone!=0)
		{
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		}
		return true;
	}
	return false;
}

simulated function bool OnEvalBones(int Channel)
{
	// OnEvalBones should do nothing on a dedicated server.
	if (Level.NetMode == NM_DedicatedServer)
		return false;
	
	// Perform client-side bone manipulation.

	if( bNoPupils || bSteelSkin )
		EvalNoPupils();
	if (bEyesShut)
		EvalEyesShut();
	if (bLegless)
		EvalMissingLegs();

	if (Channel==3)
	{
		EvalBodyDamage();
		if (DamageBoneShakeFactor > 0.0)
			EvalShakeDamageBone();
		//if (bSlack)
		//	EvalSlack();
		return true;
	}	
}

simulated function AnimEnd()
{
//	log( "AnimEnd: "$AnimSequence );
//	if( AnimSequence == 'A_RobotDeathEMP' || AnimSequence == 'A_RobotDeathA' || AnimSequence == 'A_RobotDeathB' )
//	{
//		log( "Calling LandThump" );
//		PlaySound( Sound'EDFRobotFall01', SLOT_Misc, 0.96, true );
//	}
	// If we are not lying still, do so.
	if (!bLyingStill)
	{
		if ( Physics == PHYS_None )
			LieStill();
		else if ( Region.Zone.bWaterZone )
		{
			bThumped = true;
			LieStill();
		}
		bLyingStill = true;
	}

	// If we are suffering, continue the animation.
	if ( AnimSequence == 'A_Suffer_ChestFall' )
	{
		if (!bLostHead)
		{
			bSuffering = true;
			SetTimer( 10.0 + FRand()*5.0, false, 2 );
			FinishAnim( 0 );
			LoopAnim( 'A_Suffer_Chest', 1.0, 0.2 );
		} else { 
			PlayAnim( 'A_Suffer_ChestDie', 1.0, 0.2 );
			if (FRand() < 0.8)
				bEyesShut = true;
		}
	}
	else if ( AnimSequence == 'A_Suffer_RLegFall' )
	{
		if (!bLostHead)
		{
			bSuffering = true;
			SetTimer( 10.0 + FRand()*5.0, false, 2 );
			FinishAnim( 0 );
			LoopAnim( 'A_Suffer_RLeg', 1.0, 0.2 );
		} else { 
			PlayAnim( 'A_Suffer_RLegDie', 1.0, 0.2 );
			if (FRand() < 0.8)
				bEyesShut = true;
		}
	}
}

/*-----------------------------------------------------------------------------
	Damage
-----------------------------------------------------------------------------*/

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	local int i, Trashed;

	if ( ClassIsChildOf(DamageType, class'BulletDamage') )
	{
		// Spawn a hit effect.
		HitEffect( HitLocation, DamageType, Momentum, 0, 0, false );

		// Apply the damage.
		CumulativeDamage += Damage;
		Velocity = vect(0,0,0);
	}
	else if ( DamageType.default.bGibDamage )
	{
		BlastVelocity = Momentum / 100;
		ChunkCarcass( CHS_ChunkComplete );
		ChunkUpBlastLoc = HitLocation;
	}
}

defaultproperties
{
	TrailClass=class'dnParticles.dnBloodFX_SmokeTrail'
	BloodPoolName="dnGame.dnOilPool"
	BloodHitDecalName="DNGAme.DNOilHit"
	Mass=100.000000
	Mesh=c_characters.edf1
	Physics=PHYS_Falling
	BloodPuffName="dnParticles.dnWallSpark"
	bBloodPool=true
	MasterReplacement=class'dnGame.RobotMasterChunk'
	bSteelSkin=true
	bRandomName=false
	bCanHaveCash=false
	//LandedSound=Sound'a_edf.Robot.EDFRobotFall01'
	GibSounds(0)=Sound'a_impact.metal.MetalGibExpl01'
	GibSounds(1)=Sound'a_impact.metal.MetalGibExpl01'
	GibSounds(2)=Sound'a_impact.metal.MetalGibExpl01'
	GibSounds(3)=Sound'a_impact.metal.MetalGibExpl01'
	GibbySound(0)=Sound'a_impact.metal.MetalGibExpl01'
	GibbySound(1)=Sound'a_impact.metal.MetalGibExpl01'
	GibbySound(2)=Sound'a_impact.metal.MetalGibExpl01'
	BigChunksClass=class'dnParticles.dnRobotGibFX_MachineChunks'
	BloodHazeClass=None
	SmallChunksClass=class'dnParticles.dnRobotGibFX_MachineChunksSmall'
	SmallBloodHazeClass=None
	ChunkClass=class'RobotMeshChunk'
}