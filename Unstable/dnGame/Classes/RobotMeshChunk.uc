/*-----------------------------------------------------------------------------
	RobotMeshChunk
-----------------------------------------------------------------------------*/
class RobotMeshChunk extends HumanMeshChunk;

// For taking little chunks off.
// Copied from dnCarcass.  That's temporary though.  I should generalize it to the common base class.
simulated function ChunkUpMore()
{
	local int bone, i, j, minigibs;
	local CreatureChunks chunk;
	local vector v;

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
			
				spawn(class'dnParticles.dnRobotGibFX_MachineChunksSmall', Self, , v);

				TrashedBones[i] = bone;
				return;
			}
		}
	}
}

simulated function GibSound()
{
	local int r;

	r = Rand(4);
	log( "Playing GIb Sound: "$class'RobotPawnCarcass'.default.GibSounds[r] );

	PlayOwnedSound(class'RobotPawnCarcass'.default.GibSounds[r], SLOT_Interact, 16);
}

// Called when the body takes massive damage from a blast or is utterly annihilated.
simulated function ChunkUpComplete(optional vector BlastLocation,optional bool bFlyCarcass)
{
	GetMeshInstance();
	if (MeshInstance == none)
		return;

	if (Level.NetMode != NM_DedicatedServer)
	{
		// Spawn a few nasty effects.
		spawn(class'dnParticles.dnRobotGibFX_MachineChunks');

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

simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, float DecoHealth, float HitDamage, bool bNoCreationSounds )
{
	local vector BloodOffset, Mo;
	local sound GibSound;

	if ( DamageType.default.bBloodEffect )
	{
		// Blood wall decal.
		BloodOffset   = 0.2 * CollisionRadius * Normal(HitLocation - Location);
		BloodOffset.Z = BloodOffset.Z * 0.5;		
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		if ( BloodHitDecal == None )
			BloodHitDecal = class<Actor>( DynamicLoadObject(BloodHitDecalName, class'Class') );
		Spawn( BloodHitDecal, Self,, HitLocation + BloodOffset, rotator(Mo) );

		// Play a gibby sound.
		GibSound = class'RobotPawnCarcass'.default.GibbySound[Rand(3)];
		if ( !bNoCreationSounds && (GibSound != None) )
			PlaySound( GibSound, SLOT_Interact );
	}
}
defaultproperties
{
	ItemName="Robot Mesh Chunk"
	MasterReplacement=class'RobotMasterChunk'
    TrailClass=class'dnParticles.dnBloodFX_SmokeTrail'
    BloodPoolName="dnGame.dnOilPool"
    BloodHitDecalName="DNGAme.DNOilHit"
    BloodPuffName="dnParticles.dnWallSpark"
    bSteelSkin=true
	bloodSplatClass=class'dngame.dnOilSplat'
}