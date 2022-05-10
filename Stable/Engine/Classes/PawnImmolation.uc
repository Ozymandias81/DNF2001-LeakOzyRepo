/*-----------------------------------------------------------------------------
	PawnImmolation
	Author: Brandon Reinhart

	A cl@ss for managing effects related to pawns that are on fire.

	* Fire lasts 20 seconds.
	* Fire transfers to corpses.
	* Fire sets the owner's bBurning setting.
	* Fire slowly lowers the owner's scale glow.
	* Water extinguishes fire.
	* Fire is extinguished with trashed bones on corpses.
	* Fire does fire DOT. (5 damage per second)
	* Immolation subclass: Human
	* Immolation subclass: Octabrain
	* Immolation subclass: Alien Pig
	* Burning creatures leave firey footsteps.
	- Need crackling fire sound.
	- Need crackling fire to fire out transition sound?
	- Need fire extinguished in water sound.
-----------------------------------------------------------------------------*/
class PawnImmolation extends ActorImmolation;

var class<SoftParticleSystem> LimbFlameClass;
var class<SoftParticleSystem> LimbFlameClassShrunk;
var SoftParticleSystem LimbFlames[10];
var name LimbBones[10];

var class<SoftParticleSystem> BodyFlameClass;
var class<SoftParticleSystem> BodyFlameClassShrunk;
var SoftParticleSystem BodyFlame;
var name BodyBone;

// Cached bone indicies. (Actually these are pointers.)
var int BoneIndicies[11];

simulated function RemoveEffect()
{
	local int i;

	Super.RemoveEffect();

	// Trigger effects off.
	for ( i=0; i<10; i++ )
	{
		if ( LimbFlames[i] != None )
			LimbFlames[i].Trigger( Self, None );
	}
	if ( BodyFlame != None )
		BodyFlame.Trigger( Self, None );
}

simulated function AttachEffect( Actor Other )
{
	local int i;
	local MeshInstance minst;

	if ( (Owner == None) || (Other == None) )
	{
		Destroy();
		return;
	}

	minst = Owner.GetMeshInstance();

	Super.AttachEffect( Other );

	// Get indicies.
	for ( i=0; i<10; i++ )
	{
		if ( LimbBones[i] != '' )
			BoneIndicies[i] = minst.BoneFindNamed( LimbBones[i] );
	}
	if ( BodyBone != '' )
		BoneIndicies[10] = minst.BoneFindNamed( BodyBone );

	// Mount limb flames.
	for ( i=0; i<10; i++ )
	{
		if ( LimbBones[i] != '' )
		{
			if ( Other.bIsPawn && Pawn(Other).bFullyShrunk )
				LimbFlames[i] = MountFireToBone( LimbFlameClassShrunk, LimbBones[i], minst );
			else
				LimbFlames[i] = MountFireToBone( LimbFlameClass, LimbBones[i], minst );
		}
	}

	// Mount fire to body.
	if ( BodyBone != '' )
	{
		if ( Other.bIsPawn && Pawn(Other).bFullyShrunk )
			BodyFlame = MountFireToBone( BodyFlameClassShrunk, BodyBone, minst );
		else
			BodyFlame = MountFireToBone( BodyFlameClass, BodyBone, minst );
	}
}

simulated function SoftParticleSystem MountFireToBone( class<SoftParticleSystem> MountClass, name MountBone, MeshInstance minst )
{
	local SoftParticleSystem s;
	local vector BoneLoc;
	local int Bone;

	Bone = minst.BoneFindNamed( MountBone );
	if ( Bone == 0 )
		return None;
	BoneLoc = minst.BoneGetTranslate( Bone, false, false );
	BoneLoc = minst.MeshToWorldLocation( BoneLoc );
	s = spawn( MountClass, Self,, BoneLoc );
	s.SetPhysics( PHYS_MovingBrush );
	s.MountType = MOUNT_MeshBone;
	s.MountMeshItem = MountBone;
	s.AttachActorToParent( Owner, false, false );

	return s;
}

simulated function TrashBone( name bonename )
{
	local int i;

	if ( bonename == '' )
		return;

	for ( i=0; i<10; i++ )
	{
		if ( bonename == LimbBones[i] )
		{
			if ( LimbFlames[i] != None )
				LimbFlames[i].Trigger( Self, None );
		}
	}
	if ( bonename == BodyBone )
	{
		if ( BodyFlame != None )
			BodyFlame.Trigger( Self, None );
	}
}

simulated function TrashBoneByIndex( int Index )
{
	local int i;

	if ( Index == 0 )
		return;

	for ( i=0; i<11; i++ )
	{
		if ( BoneIndicies[i] == Index )
		{
			if ( i == 11 )
				TrashBone( BodyBone );
			else
				TrashBone( LimbBones[i] );
		}
	}
}
