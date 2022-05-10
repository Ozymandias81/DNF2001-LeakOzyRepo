/*-----------------------------------------------------------------------------
	HumanMeshChunk
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HumanMeshChunk extends CreatureChunks;

var class<MasterCreatureChunk>	MasterReplacement;
var int mainbone;

/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Increment the death zone's carcass count.
	DeathZone = Region.Zone;
	if (DeathZone != None)
		DeathZone.NumCarcasses++;

	// Start lifespan timer.
	LifeSpan = 0.0;
	SetTimer(10.0, false);
}

simulated function Destroyed()
{
	// Reduce the death zone's carcass count.
	if ( DeathZone != None )
		DeathZone.NumCarcasses--;

	Super.Destroyed();
}

simulated function InitFor( RenderActor Other )
{
	local int i;
	local vector RandDir;

	Super.InitFor( Other );
	RotationRate *= 0.01;

	// Reset the trashed bones list to zero.
	for (i=0; i<6; i++)
		TrashedBones[i] = 0;

	Mesh					= Other.Mesh;
	AnimSequence			= Other.AnimSequence;
	AnimFrame				= Other.AnimFrame;
	AnimRate				= Other.AnimRate;
	TweenRate				= Other.TweenRate;
	AnimMinRate				= Other.AnimMinRate;
	AnimLast				= Other.AnimLast;
	bAnimLoop				= Other.bAnimLoop;
	SimAnim.X				= 10000 * AnimFrame;
	SimAnim.Y				= 5000  * AnimRate;
	SimAnim.Z				= 1000  * TweenRate;
	SimAnim.W				= 10000 * AnimLast;
	bAnimFinished			= Other.bAnimFinished;
	ItemName				= "A big piece of"@Other.ItemName;
	bProjTarget				= Other.bProjTarget;
	bCollideWorld			= Other.bCollideWorld;
	bSearchable				= dnCarcass(Other).bSearchable;
	bDamageProtect			= true;
	Mass					= Other.Mass;
	SetCollisionSize( Other.CollisionRadius, Other.CollisionHeight );

	// Carcass fly!!
	RandDir = 400 * FRand() * VRand();
	RandDir.Z = (FRand()+0.2);
	Velocity = (0.2 + FRand()) * (BlastVelocity + RandDir);
}

/*-----------------------------------------------------------------------------
	Bone Manipulation
-----------------------------------------------------------------------------*/

simulated function SetMainTrash( name Bone, int i )
{
	GetMeshInstance();
	if ( MeshInstance == None )
		return;

	if ( Bone == 'Chest' )
		mainbone = MeshInstance.BoneFindNamed('Pelvis');
	else if ( Bone == 'Pelvis' )
		mainbone = MeshInstance.BoneFindNamed('Chest');

	Trash( Bone, i );
}

simulated function AnimEnd()
{
	local float OldCollisionHeight;
	local vector v, newloc;

	GetMeshInstance();
	if ( MeshInstance == None )
		return;

	if (AnimSequence == 'A_Suffer_RLeg')
		PlayAnim( 'A_Suffer_RLegDie', 1.0, 0.2 );
	else if (AnimSequence == 'A_Suffer_Chest')
		PlayAnim( 'A_Suffer_ChestDie', 1.0, 0.2 );

	v = MeshInstance.BoneGetTranslate( mainbone, true, false );
	v = MeshInstance.MeshToWorldLocation(v);
	v = Location - v;
	v.z = 0;
	PrePivot = v;
	OldCollisionHeight = CollisionHeight;
	SetCollisionSize( CollisionHeight + CollisionHeight*0.25, 10 );
	newloc = Location;
	newloc.Z -= OldCollisionHeight - 10;
	newloc -= v;
	SetLocation(newloc);
	SetCollision(true,false,false);
}

simulated function Trash( name Bone, int i )
{
	GetMeshInstance();
	if (MeshInstance == none)
		return;

	TrashedBones[i] = MeshInstance.BoneFindNamed(Bone);
}

simulated function bool OnEvalBones(int Channel)
{
	local int i;

	// OnEvalBones should do nothing on a dedicated server.
	if ( Level.NetMode == NM_DedicatedServer )
		return false;
	
	if ( Channel == 3 )
	{
		// Shrink trashed bones to zero.
		for ( i=0; i<6; i++ )
		{
			if ( TrashedBones[i] != 0 )
				MeshInstance.BoneSetScale( TrashedBones[i], vect(0,0,0), true );
		}

		// Shake damage bone.
		if ( DamageBoneShakeFactor > 0.0 )
			EvalShakeDamageBone();
	}

	return true;
}

simulated function bool EvalShakeDamageBone()
{
	local int bone;
	local rotator r;

	if (DamageBone=='None')
		return false;
	GetMeshInstance();
	if (MeshInstance==None)
		return false;

	if (!bDamageBoneShakeInit)
	{
		bone = MeshInstance.BoneFindNamed(DamageBone);
		if (bone!=0)
			DamageBoneShakeBaseRotate = MeshInstance.BoneGetRotate(bone, false);
		DamageBoneShakeAdjustRotate.Pitch = int(FRand()*2000.0);
		DamageBoneShakeAdjustRotate.Yaw = int(FRand()*2000.0);
		bDamageBoneShakeInit = true;
	}
	bone = MeshInstance.BoneFindNamed(DamageBone);
	if (bone!=0)
	{
		r = Slerp(sin((1.0 - DamageBoneShakeFactor)*pi), DamageBoneShakeBaseRotate, DamageBoneShakeBaseRotate+DamageBoneShakeAdjustRotate);
		MeshInstance.BoneSetRotate(bone, r, false);
	}
	return true;
}

// Use dnCarcass destroy heuristic.
function Timer(optional int TimerNum)
{
	// Check to see if we should be destroyed.
	if ( Region.Zone.NumCarcasses > Region.Zone.MaxCarcasses )
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
		else
			SetTimer(2.0, false);	
	}
	else
		SetTimer(2.0, false);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType )
{
	if ( !bDamageProtect && DamageType.default.bGibDamage || (mesh == mesh'Alien_Snatcher') )
	{
		ChunkDamageType = DamageType;
		BlastVelocity = Momentum / 100;
		ChunkUpComplete();
	}
}

// Use dnCarcass FakeDamage
simulated function FakeDamage( int Damage, name BoneName, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, bool bNoCreationSounds )
{
	HitEffect( HitLocation, DamageType, Momentum, 0, 0, bNoCreationSounds );

	if ( ClassIsChildOf(DamageType, class'BulletDamage') )
	{
		// Apply the damage.
		SetDamageBone(BoneName);
		CumulativeDamage += Damage;
		if ( (Damage > 30) || (CumulativeDamage > 30) )
		{
			// We've done enough damage to chunk off this piece...
			if ((DamageBone != 'Chest') && (DamageBone != 'Abdomen') && (DamageBone != 'Pelvis'))
				ChunkUpMore();
		}
		Velocity = vect(0,0,0);
	}
}

// For taking little chunks off.
// Copied from dnCarcass.  That's temporary though.  I should generalize it to the common base class.
simulated function ChunkUpMore()
{
	local int bone, i, j, minigibs;
	local CreatureChunks chunk;
	local vector v;
	local SoftParticleSystem p;

	CumulativeDamage = 0;

	GetMeshInstance();
	if (MeshInstance == none)
		return;

	// Blow up this bone.
	bone = MeshInstance.BoneFindNamed(DamageBone);
	if ((DamageBone == 'Thigh_L') && !bLeftFootTrashed)
		return;
	else if ((DamageBone == 'Thigh_R') && !bRightFootTrashed)
		return;
	else if ((DamageBone == 'Bicep_L') && !bLeftHandTrashed)
		return;
	else if ((DamageBone == 'Bicep_R') && !bRightHandTrashed)
		return;

	if (bone != 0)
	{
		for (i=0; i<5; i++)
		{
			if (TrashedBones[i] == 0)
			{
				if ( (bone == MeshInstance.BoneFindNamed('Foot_L')) || (bone == MeshInstance.BoneFindNamed('Shin_L')) )
					bLeftFootTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Foot_R')) || (bone == MeshInstance.BoneFindNamed('Shin_R')) )
					bRightFootTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Hand_L')) || (bone == MeshInstance.BoneFindNamed('Forearm_L')) )
					bLeftHandTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Hand_R')) || (bone == MeshInstance.BoneFindNamed('Forearm_R')) )
					bRightHandTrashed = true;
				v = MeshInstance.BoneGetTranslate(bone, true, false);
				v = MeshInstance.MeshToWorldLocation(v, false);

				p = spawn(class'dnParticles.dnBloodFX_BloodHazeSmall', Self, , v);
				p.DrawScale = p.default.DrawScale * (DrawScale / default.DrawScale);
				p.StartDrawScale = p.default.StartDrawScale * (DrawScale / default.DrawScale);
				p.EndDrawScale = p.default.EndDrawScale * (DrawScale / default.DrawScale);
				p.DrawScaleVariance = p.default.DrawScaleVariance * (DrawScale / default.DrawScale);
				p = spawn(class'dnParticles.dnBloodFX_BloodChunksSmall', Self, , v);
				p.DrawScale = p.default.DrawScale * (DrawScale / default.DrawScale);
				p.StartDrawScale = p.default.StartDrawScale * (DrawScale / default.DrawScale);
				p.EndDrawScale = p.default.EndDrawScale * (DrawScale / default.DrawScale);
				p.DrawScaleVariance = p.default.DrawScaleVariance * (DrawScale / default.DrawScale);

				TrashedBones[i] = bone;
				return;
			}
		}
	}
}

simulated function SetDamageBone(name BoneName)
{
    if (BoneName=='None')
		return;
	DamageBone = BoneName;
	DamageBoneShakeFactor = 1.0;
	bDamageBoneShakeInit = false;
}

simulated function GibSound()
{
	local int r;

	r = Rand(4);
	PlayOwnedSound(class'dnCarcass'.default.GibSounds[r], SLOT_Interact, 16);
}

simulated function SpawnGibShower( vector Location )
{
	local MasterCreatureChunk carc;
	
	if (bHidden)
		return;

	carc = Spawn(MasterReplacement,Self,, Location + CollisionHeight * vect(0,0,0.5)); 
	if (carc != None)
	{
		carc.SetLocation( Location );
	}
}
// Called when the body takes massive damage from a blast or is utterly annihilated.
simulated function ChunkUpComplete(optional vector BlastLocation, optional bool bFlyCarcass)
{
	local SoftParticleSystem p;

	GetMeshInstance();
	if (MeshInstance == none)
		return;

	if (Level.NetMode != NM_DedicatedServer)
	{
		// Spawn a few nasty effects.
		if ( DrawScale > 0.3 )
		{
			p = spawn(class'dnParticles.dnBloodFX_BloodHaze', Owner);
			p.DrawScale = p.default.DrawScale * (DrawScale / default.DrawScale);
			p.StartDrawScale = p.default.StartDrawScale * (DrawScale / default.DrawScale);
			p.EndDrawScale = p.default.EndDrawScale * (DrawScale / default.DrawScale);
			p.DrawScaleVariance = p.default.DrawScaleVariance * (DrawScale / default.DrawScale);

			p = spawn(class'dnParticles.dnBloodFX_BloodChunks', Owner);
			p.DrawScale = p.default.DrawScale * (DrawScale / default.DrawScale);
			p.StartDrawScale = p.default.StartDrawScale * (DrawScale / default.DrawScale);
			p.EndDrawScale = p.default.EndDrawScale * (DrawScale / default.DrawScale);
			p.DrawScaleVariance = p.default.DrawScaleVariance * (DrawScale / default.DrawScale);
		}
		else
		{
			p = spawn(class'dnParticles.dnBloodFX_BloodHazeSmall', Owner);
			p = spawn(class'dnParticles.dnBloodFX_BloodChunksSmall', Owner);
		}

		// Play the gib sound.
		GibSound();

		// Create a shower of gibs.
		SpawnGibShower(Location);
	}

	// Destroy the carcass.
	SetPhysics(PHYS_None);
	bHidden = true;
	SetCollision(false,false,false);
	bProjTarget = false;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	bDamageProtect = false;

    // Shake the bones!
	if (DamageBoneShakeFactor > 0.0)
	{
		DamageBoneShakeFactor -= DeltaTime*4.0;
		if (DamageBoneShakeFactor < 0.0)
			DamageBoneShakeFactor = 0.0;
	}
}

simulated function Landed(vector HitNormal)
{
	local rotator FinalRot;

	if (Velocity.Z < -800)
	{
		ChunkUpComplete();
		return;
	}

	Super.Landed( HitNormal );
}

defaultproperties
{
	ItemName="Human Mesh Chunk"
	MasterReplacement=class'DukeMasterChunk'
	TrailClass=Class'dnParticles.dnBloodFX_BloodTrail'
}