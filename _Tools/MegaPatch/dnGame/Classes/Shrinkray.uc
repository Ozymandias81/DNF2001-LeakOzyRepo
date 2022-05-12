/*-----------------------------------------------------------------------------
	Shrinkray
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Shrinkray expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var() int HitDamage;

var vector ThirdMountOffset;				// Third person mount point offset.

// ChargeEffect
var SoftParticleSystem ChargeEffect;
var SoftParticleSystem OldChargeEffect;
var SoftParticleSystem ChargeEffectThird;	// Third person.

// ExpendEffect
var SoftParticleSystem ExpendEffect;
var SoftParticleSystem OldExpendEffect;
var SoftParticleSystem ExpendEffectThird;	// Third person.

// Beam effects.
var BeamSystem BeamEffect;
var BeamSystem BeamEffectThird;				// Third person.

// Beam wall hit.
var SoftParticleSystem BeamWallHit, BeamWallHitStreamers;

// Beam pawn hit.
var BeamAnchor PawnFingerR, PawnFingerL, PawnFootR, PawnFootL, PawnHead;
var BeamSystem PawnChestBlast, EmissionBlast, EmissionBlastThird;

// Third person effects anchor.
var ShrinkRayBeamAnchor ThirdPersonAnchor;

// Sounds.
var sound ShrinkChargeSound, ShrinkLoopSound, ShrinkReleaseSound;

var Actor ShrinkActor;



/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	reliable if ( Role == ROLE_Authority )
		ThirdPersonAnchor, ShrinkActor;
}



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( (ThirdPersonAnchor == None) && (Level.NetMode != NM_Client) )
	{
		ThirdPersonAnchor = spawn( class'ShrinkRayBeamAnchor', Self );
		ThirdPersonAnchor.RemoteRole = ROLE_SimulatedProxy;
	}
}

// Called by the engine when the object is destroyed.
simulated function Destroyed()
{
	// Make sure associated effects are destroyed.
	if ( Owner != None )
		Owner.StopSound( SLOT_Talk );
	DestroyChargeEffect();
	DestroyExpendEffect();
	DestroyBeamEffect();
	DestroyHitEffects( false );	

	if ( ThirdPersonAnchor != None )
		ThirdPersonAnchor.Destroy();

	Super.Destroyed();
}



/*-----------------------------------------------------------------------------
	Beam Effects
-----------------------------------------------------------------------------*/

// Creates the charging up effect.
simulated function SpawnChargeEffect()
{
	local vector ChargeOffset, X, Y, Z;

	if ( ChargeEffect == None )
	{
		// First person.
		GetAxes( Instigator.ViewRotation, X, Y, Z );
		ChargeOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
		ChargeEffect = spawn( class'dnShrinkRayFX_Shrink_ChargeUp', Owner,, ChargeOffset );
		ChargeEffect.bOnlyOwnerSee = true;
		ChargeEffect.bDontReflect = true;
		ChargeEffect.bIgnoreBList = true;
	}
}

// Creates the charging up effect for third person.
simulated function SpawnChargeEffectThird()
{
	if ( ChargeEffectThird == None )
	{
		// Third person.
		ChargeEffectThird = spawn( class'dnShrinkRayFX_Shrink_ChargeUp', Self );
		ChargeEffectThird.bOwnerSeeSpecial = true;
		ChargeEffectThird.SetPhysics( PHYS_MovingBrush );
		ChargeEffectThird.MountType = MOUNT_MeshSurface;
		ChargeEffectThird.MountMeshItem = 'MuzzleMount';
		ChargeEffectThird.AttachActorToParent( Self, true, true );
		ChargeEffectThird.MountOrigin += ThirdMountOffset;
		ChargeEffectThird.bIgnoreBList = true;
	}
}

// Updates the location fo the charging effect.
simulated function UpdateChargeEffect( float DeltaTime )
{
	local vector ChargeOffset, X, Y, Z;

	if ( (ChargeEffect != None) || (OldChargeEffect != None) )
	{
		// Update the charge effect location.
		GetAxes( Instigator.ViewRotation, X, Y, Z );
		ChargeOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
	}

	if ( ChargeEffect != None )
		ChargeEffect.SetLocation( ChargeOffset );
	if ( OldChargeEffect != None )
		OldChargeEffect.SetLocation( ChargeOffset );
}

// Destroys the charging up effect.
simulated function DestroyChargeEffect()
{
	if ( ChargeEffect != None )
	{
		ChargeEffect.Trigger( Self, Pawn(Owner) );
		OldChargeEffect = ChargeEffect;
		ChargeEffect = None;
	}
}

// Destroys the charging up effect third.
simulated function DestroyChargeEffectThird()
{
	if ( ChargeEffectThird != None )
	{
		ChargeEffectThird.Trigger( Self, Pawn(Owner) );
		ChargeEffectThird = None;
	}
}

// Creates the energy expend effect.
simulated function SpawnExpendEffect()
{
	local vector ExpendOffset, X, Y, Z;

	if ( ExpendEffect == None )
	{
		// First person.
		GetAxes( Instigator.ViewRotation, X, Y, Z );
		ExpendOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
		ExpendEffect = spawn( class'dnShrinkRayFX_Shrink_Expend', Owner,, ExpendOffset );
		ExpendEffect.bOnlyOwnerSee = true;
		ExpendEffect.bDontReflect = true;
		ExpendEffect.bIgnoreBList = true;
	}
}

// Creates the third person expend effect.
simulated function SpawnExpendEffectThird()
{
	local vector ExpendOffset, X, Y, Z;

	if ( ExpendEffectThird == None )
	{
		// Third person.
		ExpendEffectThird = spawn( class'dnShrinkRayFX_Shrink_Expend', Self );
		ExpendEffectThird.bOwnerSeeSpecial = true;
		ExpendEffectThird.SetPhysics( PHYS_MovingBrush );
		ExpendEffectThird.MountType = MOUNT_MeshSurface;
		ExpendEffectThird.MountMeshItem = 'MuzzleMount';
		ExpendEffectThird.AttachActorToParent( Self, true, true );
		ExpendEffectThird.MountOrigin += ThirdMountOffset;
		ExpendEffectThird.bIgnoreBList = true;
	}
}

// Updates the location of the expend effect.
simulated function UpdateExpendEffect( float DeltaTime )
{
	local vector ExpendOffset, X, Y, Z;

	if ( (ExpendEffect != None) || (OldExpendEffect != None) )
	{
		// Update the Expend effect location.
		GetAxes( Instigator.ViewRotation, X, Y, Z );
		ExpendOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
	}

	if ( ExpendEffect != None )
		ExpendEffect.SetLocation( ExpendOffset );
	if ( OldExpendEffect != None )
		OldExpendEffect.SetLocation( ExpendOffset );
}

// Destroys the energy expend effect.
simulated function DestroyExpendEffect()
{
	if ( ExpendEffect != None )
	{
		ExpendEffect.Trigger( Self, Pawn(Owner) );
		OldExpendEffect = ExpendEffect;
		ExpendEffect = None;
	}
}

// Destroys the expend effect thirdperson.
simulated function DestroyExpendEffectThird()
{
	if ( ExpendEffectThird != None )
	{
		ExpendEffectThird.Trigger( Self, Pawn(Owner) );
		ExpendEffectThird = None;
	}
}

// Spawns the beam effect.
simulated function SpawnBeamEffect()
{
	local vector BeamOffset, X, Y, Z;

	if ( BeamEffect == None )
	{
		// First person.
		GetAxes( Instigator.ViewRotation, X, Y, Z );
		BeamOffset = Pawn(Owner).BaseEyeHeight * vect(0,0,1) + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
		BeamEffect = spawn( class'dnShrinkBeamFX_MainStream', Owner,, Location+BeamOffset );
		BeamEffect.bOnlyOwnerSee = true;
		BeamEffect.bDontReflect = true;
		BeamEffect.DestinationActor[0] = ThirdPersonAnchor;
		BeamEffect.NumberDestinations = 1;
		BeamEffect.bIgnoreBList = true;
		BeamEffect.RemoteRole = ROLE_None;
	}

	// Hit effects.
	if ( BeamWallHit == None )
		SpawnNormalHitEffects();
}

// Destroys the beam effect.
simulated function DestroyBeamEffect()
{
	ShrinkActor = None;
	if ( BeamEffect != None )
	{
		BeamEffect.Destroy();
		BeamEffect = None;
	}

	// Destroy hit effects.
	DestroyHitEffects( false );
}

// Spawns the third person beam effect.
simulated function SpawnBeamEffectThird( BeamAnchor Anchor )
{
	local vector BeamOffset, X, Y, Z;

	if ( BeamEffectThird == None )
	{
		BeamEffectThird = spawn( class'dnShrinkBeamFX_MainStream', Owner );
		BeamEffectThird.bOwnerNoSee = true;
		BeamEffectThird.DestinationActor[0] = Anchor;
		BeamEffectThird.NumberDestinations = 1;
		BeamEffectThird.bIgnoreBList = true;
		BeamEffectThird.RemoteRole = ROLE_None;
		BeamEffectThird.SetPhysics( PHYS_MovingBrush );
		BeamEffectThird.AttachActorToParent( ExpendEffectThird, true, true );
	}

	// Hit effects.
	if ( BeamWallHit == None )
		SpawnNormalHitEffects( Anchor );
}

// Destroys the third person beam effect.
simulated function DestroyBeamEffectThird()
{
	if ( BeamEffectThird != None )
	{
		BeamEffectThird.Destroy();
		BeamEffectThird = None;
	}

	// Destroy hit effects.
	DestroyHitEffects( false );
}

// Spawns the wall hit effect.
simulated function SpawnNormalHitEffects( optional BeamAnchor Anchor )
{
	DestroyHitEffects( true );

	if ( BeamWallHit == None )
	{
		BeamWallHit = spawn( class'dnShrinkRayFX_Shrink_WallHit', Self );
		BeamWallHit.bIgnoreBList = true;
	}
	if ( BeamWallHitStreamers == None )
	{
		BeamWallHitStreamers = spawn( class'dnShrinkRayFX_Shrink_WallHit_Streamers', Self );
		BeamWallHitStreamers.bIgnoreBList = true;
	}

	// On the client side, mount these effects to the third person anchor.
	if ( Anchor != None )
	{
		BeamWallHit.SetPhysics( PHYS_MovingBrush );
		BeamWallHit.AttachActorToParent( Anchor, true, true );
		BeamWallHitStreamers.SetPhysics( PHYS_MovingBrush );
		BeamWallHitStreamers.AttachActorToParent( Anchor, true, true );
	}
}

// Spawns hit effects for pawns.
simulated function SpawnPawnHitEffects( optional BeamAnchor Anchor )
{
	local MeshInstance minst;
	local Pawn HitPawn;
	local int bone;
	local vector AnchorLoc, BeamOffset, X, Y, Z;
	local BeamSystem lEmissionBlast;

	if ( ShrinkActor == None )
		return;

	HitPawn = Pawn(ShrinkActor);
	minst = HitPawn.GetMeshInstance();
	if ( minst == None )
		return;

	// Spawn the new hit effects and attach them.
	DestroyHitEffects( true );
	if ( BeamWallHit == None )
		BeamWallHit = spawn( class'dnShrinkRayFX_Shrink_BodyPart', Self );
	if ( BeamWallHitStreamers == None )
		BeamWallHitStreamers = spawn( class'dnShrinkRayFX_Shrink_BodyPart_Streamers', Self );

	// On the client side, mount these effects to the third person anchor.
	if ( Anchor != None )
	{
		BeamWallHit.SetPhysics( PHYS_MovingBrush );
		BeamWallHit.AttachActorToParent( Anchor, true, true );
		BeamWallHitStreamers.SetPhysics( PHYS_MovingBrush );
		BeamWallHitStreamers.AttachActorToParent( Anchor, true, true );
	}

	// Spawn the anchors.
	if ( PawnFingerR == None )
	{
		bone = minst.BoneFindNamed( 'Forefingtip_R' );
		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
		PawnFingerR = spawn( class'BeamAnchor', Self,, AnchorLoc );
		PawnFingerR.MountType = MOUNT_MeshBone;
		PawnFingerR.MountMeshItem = 'Forefingtip_R';
		PawnFingerR.SetPhysics( PHYS_MovingBrush );
		PawnFingerR.AttachActorToParent( HitPawn, false, false );
	}

	if ( PawnFingerL == None )
	{
		bone = minst.BoneFindNamed( 'Forefingtip_L' );
		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
		PawnFingerL = spawn( class'BeamAnchor', Self,, AnchorLoc );
		PawnFingerL.MountType = MOUNT_MeshBone;
		PawnFingerL.MountMeshItem = 'Forefingtip_L';
		PawnFingerL.SetPhysics( PHYS_MovingBrush );
		PawnFingerL.AttachActorToParent( HitPawn, false, false );
	}

	if ( PawnHead == None )
	{
		bone = minst.BoneFindNamed( 'Head' );
		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
		PawnHead = spawn( class'BeamAnchor', Self,, AnchorLoc );
		PawnHead.MountType = MOUNT_MeshBone;
		PawnHead.MountMeshItem = 'Head';
		PawnHead.SetPhysics( PHYS_MovingBrush );
		PawnHead.AttachActorToParent( HitPawn, false, false );
	}

	if ( PawnFootR == None )
	{
		bone = minst.BoneFindNamed( 'Foot_R' );
		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
		PawnFootR = spawn( class'BeamAnchor', Self,, AnchorLoc );
		PawnFootR.MountType = MOUNT_MeshBone;
		PawnFootR.MountMeshItem = 'Foot_R';
		PawnFootR.SetPhysics( PHYS_MovingBrush );
		PawnFootR.AttachActorToParent( HitPawn, false, false );
	}

	if ( PawnFootL == None )
	{
		bone = minst.BoneFindNamed( 'Foot_L' );
		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
		PawnFootL = spawn( class'BeamAnchor', Self,, AnchorLoc );
		PawnFootL.MountType = MOUNT_MeshBone;
		PawnFootL.MountMeshItem = 'Foot_L';
		PawnFootL.SetPhysics( PHYS_MovingBrush );
		PawnFootL.AttachActorToParent( HitPawn, false, false );
	}

	if ( PawnChestBlast == None )
	{
		// Mount the chest blast.
//		bone = minst.BoneFindNamed( 'Chest' );
//		AnchorLoc = minst.BoneGetTranslate( bone, true, false );
//		AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
//		PawnChestBlast = spawn( class'dnShrinkBeamFX_WrapUp', Self,, AnchorLoc );
		PawnChestBlast = spawn( class'dnShrinkBeamFX_WrapUp', Self );
		PawnChestBlast.DestinationActor[0] = PawnFingerR;
		PawnChestBlast.DestinationActor[1] = PawnFingerL;
		PawnChestBlast.DestinationActor[2] = PawnFootR;
		PawnChestBlast.DestinationActor[3] = PawnFootL;
		PawnChestBlast.DestinationActor[4] = PawnHead;
		PawnChestBlast.NumberDestinations = 5;
		PawnChestBlast.MountType = MOUNT_MeshBone;
		PawnChestBlast.MountMeshItem = 'Chest';
		PawnChestBlast.SetPhysics( PHYS_MovingBrush );
		PawnChestBlast.AttachActorToParent( HitPawn, false, false );
	}

	// Create the emission blast, first person.
	EmissionBlast = spawn( class'dnShrinkBeamFX_WrapUp', Owner );
	EmissionBlast.DestinationActor[0] = PawnFingerR;
	EmissionBlast.DestinationActor[1] = PawnFingerL;
	EmissionBlast.DestinationActor[2] = PawnFootR;
	EmissionBlast.DestinationActor[3] = PawnFootL;
	EmissionBlast.DestinationActor[4] = PawnHead;
	EmissionBlast.NumberDestinations = 5;
	EmissionBlast.SetPhysics( PHYS_MovingBrush );
	EmissionBlast.bOnlyOwnerSee = true;
	EmissionBlast.AttachActorToParent( BeamEffect, true, true );

	// Create the emission blast, third person.
	EmissionBlastThird = spawn( class'dnShrinkBeamFX_WrapUp', Owner );
	EmissionBlastThird.DestinationActor[0] = PawnFingerR;
	EmissionBlastThird.DestinationActor[1] = PawnFingerL;
	EmissionBlastThird.DestinationActor[2] = PawnFootR;
	EmissionBlastThird.DestinationActor[3] = PawnFootL;
	EmissionBlastThird.DestinationActor[4] = PawnHead;
	EmissionBlastThird.NumberDestinations = 5;
	EmissionBlastThird.SetPhysics( PHYS_MovingBrush );
	EmissionBlastThird.bOwnerSeeSpecial = true;
	EmissionBlastThird.AttachActorToParent( BeamEffectThird, true, true );
}

// Removes hit effects for pawns.
simulated function DestroyHitEffects( bool bFast )
{
	if ( BeamWallHit != None )
	{
		if ( bFast )
			BeamWallHit.Destroy();
		else
			BeamWallHit.Trigger( Self, Pawn(Owner) );
		BeamWallHit = None;
	}

	if ( BeamWallHitStreamers != None )
	{
		if ( bFast )
			BeamWallHitStreamers.Destroy();
		else
			BeamWallHitStreamers.Trigger( Self, Pawn(Owner) );
		BeamWallHitStreamers = None;
	}

	if ( PawnFingerR != None )
	{
		PawnFingerR.Destroy();
		PawnFingerR = None;
	}
	if ( PawnFingerL != None )
	{
		PawnFingerL.Destroy();
		PawnFingerL = None;
	}
	if ( PawnHead != None )
	{
		PawnHead.Destroy();
		PawnHead = None;
	}
	if ( PawnFootR != None )
	{
		PawnFootR.Destroy();
		PawnFootR = None;
	}
	if ( PawnFootL != None )
	{
		PawnFootL.Destroy();
		PawnFootL = None;
	}
	if ( PawnChestBlast != None )
	{
		PawnChestBlast.Destroy();
		PawnChestBlast = None;
	}
	if ( EmissionBlast != None )
	{
		EmissionBlast.Destroy();
		EmissionBlast = None;
	}
	if ( EmissionBlastThird != None )
	{
		EmissionBlastThird.Destroy();
		EmissionBlastThird = None;
	}
}

// Update beam end hit location and do shrinking.
simulated function UpdateBeamEnd( float DeltaTime )
{
	local actor HitActor;
	local vector HitLocation, HitNormal, RadLoc, X, Y, Z, BeamOffset;
	local vector TraceStart, TraceEnd, TraceOffset, TraceAxis;
	local float oldShrinkCounter, pX, pY, pZ;
	local class<Material> m;

	TraceAxis = vector(Instigator.ViewRotation);

	TraceOffset = Instigator.BaseEyeHeight * vect(0,0,1);
	TraceStart  = Location + TraceOffset + TraceAxis * Instigator.CollisionRadius * 1.01;
	TraceEnd    = Location + TraceOffset + TraceAxis * 1000.0;

	HitActor = Trace( HitLocation, HitNormal, TraceEnd, TraceStart, true );
	if ( HitActor != ShrinkActor )
	{
		if ( Pawn(HitActor) != None )
		{
			ShrinkActor = HitActor;
			if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
				ThirdPersonAnchor.BeamEffectImpulse = 3;
			SpawnPawnHitEffects();
		}
		else if ( Pawn(ShrinkActor) != None )
		{
			ShrinkActor = HitActor;
			if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
				ThirdPersonAnchor.BeamEffectImpulse = 4;
			SpawnNormalHitEffects();
		}
		ShrinkActor = HitActor;
	}

	if ( HitActor == None )
	{
		// The hit location is too far out.
		BeamWallHit.SetLocation ( TraceEnd );
		BeamWallHitStreamers.SetLocation ( TraceEnd );
	}
	else
	{
		// Set end on what we hit.
		BeamWallHit.SetLocation( HitLocation );
		BeamWallHitStreamers.SetLocation ( HitLocation );
	}

	// Shrink it!
	if ( FireAnimSentry == AS_Middle )
	{
		if ( (ShrinkActor != None) && ShrinkActor.bIsPawn )
			Pawn(ShrinkActor).TakeDamage( 0, Pawn(Owner), HitLocation, vect( 0, 0, 0 ), class'ShrinkerDamage' );
	}

	ThirdPersonAnchor.SetLocation( BeamWallHit.Location );
}

// Updates the beam's location.
simulated function UpdateBeamEffect( float DeltaTime )
{
	local vector BeamOffset, X, Y, Z;

	GetAxes( Instigator.ViewRotation, X, Y, Z );
	BeamOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;

	if ( BeamEffect != None )
		BeamEffect.SetLocation( BeamOffset );
}

// Update the positions of various effects.
simulated function Tick( float DeltaTime )
{
	if ( Owner != None )
	{
		if ( BeamEffect != None )
		{
			// Update the end of the beam location.
			UpdateBeamEnd( DeltaTime );

			// Update the beam effects.
			UpdateBeamEffect( DeltaTime );
		}

		// Update the charge effect.
		UpdateChargeEffect( DeltaTime );

		// Update the expend effect.
		UpdateExpendEffect( DeltaTime );
	}

	Super.Tick( DeltaTime );
}


/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

// Perform firing.
function Fire()
{
	// Do firing animation & firing state.
	bAltFiring = false;
	GotoState('Firing');
	StartFiring();
	ClientFire();
}

simulated function bool ClientAltFire()
{
	return false;
}

// Perform alt-firing.
function AltFire()
{
	// Do firing animation & firing state.
	bAltFiring = true;
	GotoState('Firing');
	StartFiring();
	ClientAltFire();
}



/*-----------------------------------------------------------------------------
	Ammo
-----------------------------------------------------------------------------*/

// Draws the amount of ammo for the weapon on the Q-Menu.
simulated function DrawAmmoAmount( Canvas C, DukeHUD HUD, float X, float Y )
{
	local float AmmoScale;

	AmmoScale = float(AmmoType.ModeAmount[0]) / AmmoType.MaxAmmo[0];
	DrawAmmoBar( C, HUD, AmmoScale, X+4*HUD.HUDScaleX*0.8, Y+51*HUD.HUDScaleY*0.8 );
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// This is the firing state.
state Firing
{
	// Called when the player releases the fire key on the client.
	simulated function ClientUnFire()
	{
		if ( bAltFiring && (FireAnimSentry != AS_Stop) )
			AnimFireStop();
	}

	// Called when the player releases the fire key on an authority (server/singleplayer).
	function UnFire()
	{
		if ( bAltFiring && (FireAnimSentry != AS_Stop) )
			AnimFireStop();
	}

	// Plays a fire start anim for this fire type.
	// Overridden for sounds and effects.
	simulated function AnimFireStart()
	{
		// Play charge up sound.
		Owner.PlaySound( ShrinkChargeSound, SLOT_Talk );

		// Call parent.
		Super.AnimFireStart();

		// Spawn the charge up effect.
		if ( bAltFiring )
		{
			if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
				ThirdPersonAnchor.BeamEffectImpulse = 1;
//			if ( Level.NetMode != NM_DedicatedServer )
				SpawnChargeEffect();
		}
	}

	// Plays a fire anim for this fire type.
	simulated function AnimFire()
	{
		// Call parent.
		Super.AnimFire();

		if ( bAltFiring && (BeamEffect == None) )
		{
			// Spawn the expend effect and beam.
			if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
				ThirdPersonAnchor.BeamEffectImpulse = 2;
//			if ( Level.NetMode != NM_DedicatedServer )
//			{
				DestroyChargeEffect();
				SpawnExpendEffect();
				SpawnBeamEffect();
//			}
		}
		else if ( !bAltFiring && (AmmoType.GetModeAmmo() >= 5) )
		{
			// Fire the expander shot.
			if ( Pawn(Owner).IsLocallyControlled() )
				Pawn(Owner).ServerSetLoadCount( AmmoLoaded - 5 );
			AmmoType.UseAmmo(5);
			ProjectileFire( ProjectileClass, ProjectileSpeed, false, FireOffset );
		}
	}

	// Plays a fire stop anim for this fire type.
	simulated function AnimFireStop()
	{
		// Call parent.
		Super.AnimFireStop();

		if ( bAltFiring )
		{
			// Turn off ammo use and destroy effects.
			SetTimer( 0.0, false );
			if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
				ThirdPersonAnchor.BeamEffectImpulse = 0;
//			if ( Level.NetMode != NM_DedicatedServer )
//			{
				DestroyChargeEffect();
				DestroyExpendEffect();
				DestroyBeamEffect();
				DestroyHitEffects( false );
//			}

			// Stop sounds.
			Owner.StopSound( SLOT_Talk );
			Owner.PlaySound( ShrinkReleaseSound, SLOT_Talk );
		}
	}

	// Called when the current animation ends.
	simulated function AnimEnd()
	{
		if ( FireAnimSentry == AS_Start )
		{
			// Start the looping sound.
			Owner.PlaySound( ShrinkLoopSound, SLOT_Talk );

			// Start the fire animation.
			AnimFire();

			if ( bAltFiring )
			{
				// Start an ammo draining timer and use a little now.
				SetTimer( 0.3, true );
				if ( Pawn(Owner).IsLocallyControlled() )
					Pawn(Owner).ServerSetLoadCount( AmmoLoaded - 1 );
				AmmoType.UseAmmo(1);
			}
		}
		else if ( FireAnimSentry == AS_Middle )
		{
			if ( CanFire() )
			{
				if ( ButtonFire() )
				{
					AnimFire();
					return;
				}
				else if ( ButtonAltFire() )
				{
					ChooseAltFire();
					return;
				}
			}

			if ( HasFireStop() )
				AnimFireStop();
			else
				FinishFire();
		}
		else if ( FireAnimSentry == AS_Stop )
			FinishFire();
	}

	// Periodically uses ammo.
	simulated function Timer( optional int TimerNum )
	{
		if ( (TimerNum == 0) && bAltFiring )
		{
			if ( AmmoLoaded == 0 )
			{
				// Out of ammo, so stop.
				AnimFireStop();
			}
			else
			{
				// Use some ammo.
				if ( Pawn(Owner).IsLocallyControlled() )
					Pawn(Owner).ServerSetLoadCount( AmmoLoaded - 1 );
				AmmoType.UseAmmo(1);
			}
		}
		Global.Timer( TimerNum );
	}
}



defaultproperties
{
	SAnimFire(0)=(AnimChance=1.000000,animSeq=AltFire,AnimRate=1.000000)
	SAnimAltFire(0)=(AnimChance=1.000000,animSeq=Fire,AnimRate=0.7)
	SAnimAltFireStart(0)=(AnimChance=1.000000,animSeq=FireStart,AnimRate=1.000000)
	SAnimAltFireStop(0)=(AnimChance=1.000000,animSeq=FireStop,AnimRate=1.000000)
	SAnimReload(0)=(AnimRate=1.350000,AnimTween=0.050000,AnimSound=Sound'dnsWeapn.pistol.GF01006')
	SAnimIdleSmall(0)=(AnimChance=0.5,animSeq=IdleA,AnimRate=1.0,AnimTween=0.1)
	SAnimIdleSmall(1)=(AnimChance=0.5,animSeq=IdleB,AnimRate=1.0,AnimTween=0.1)
	SAnimIdleLarge(0)=(AnimChance=1.0,animSeq=IdleA,AnimRate=1.0,AnimTween=0.1)

	bMultiMode=false
	AmmoName=class'dnGame.ShrinkAmmo'
	ReloadCount=40
	PickupAmmoCount(0)=40
	AltAmmoItemClass=class'HUDIndexItem_ShrinkRayAlt'
	AmmoItemClass=class'HUDIndexItem_ShrinkRay'

	bInstantHit=false

//	FireOffset=(X=25.00,Y=-4.0,Z=-15.0)
	FireOffset=(X=25.00,Y=-6.0,Z=-18.0)
    AIRating=0.900000
    AltAmmoName=None
    AltReloadCount=0
    AutoSwitchPriority=18

	ItemName="Shrinkray"
	PlayerViewMesh=Mesh'c_dnWeapon.shrinkray'
	PickupViewMesh=Mesh'c_dnWeapon.w_shrinkray'
	ThirdPersonMesh=Mesh'c_dnWeapon.w_shrinkray'
    Mesh=Mesh'c_dnWeapon.w_shrinkray'
	PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	Icon=Texture'hud_effects.mitem_shrinkray'
    PickupIcon=texture'hud_effects.am_shrinkray'

    AnimRate=4.000000
    SoundRadius=64
    SoundVolume=200
    CollisionHeight=8.000000
    Mass=1.000000
    dnInventoryCategory=3
    dnCategoryPriority=0
    TraceHitCategory=TH_Shrink
    PlayerViewScale=0.1
    PlayerViewOffset=(X=1.05,Y=-0.3,Z=-6.6)
    LodMode=LOD_Disabled

	bAltFireStart=true
	bAltFireStop=true
	bWeaponPenetrates=false

	ShrinkChargeSound=sound'dnsWeapn.ShrinkRayCharge01'
	ShrinkLoopSound=sound'dnsWeapn.ShrinkRayFireLp01'
	ShrinkReleaseSound=sound'dnsWeapn.ShrinkRayRelease01'

	ProjectileClass=class'dnRocket_ShrinkBlast'
	ProjectileSpeed=1000.0
	CrosshairIndex=13
	AutoSwitchPriority=10

	ThirdMountOffset=(Z=8)

	RunAnim=(AnimSeq=A_Run_2HandGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnim=(AnimSeq=T_M16Fire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    AltFireAnim=(AnimSeq=T_M16AltFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_M16Idle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ReloadStartAnim=(AnimSeq=T_M16Reload,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_GenGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	bAlwaysRelevant=true
	bIgnoreBList=true
	bInvForceRep=true

	MuzzleFlashOrigin=(X=0,Y=0,Z=0)
//	MuzzleFlashClass=class'dnMuzzleRPG'
	MuzzleFlashSprites(0)=texture'm_dnWeapon.brainblastx2'
	MuzzleFlashSprites(1)=texture'm_dnWeapon.brainblastx3'
	NumFlashSprites=1
	SpriteFlashX=340.0
	SpriteFlashY=330.0
	MuzzleFlashScale=4
	UseSpriteFlash=true
	MuzzleFlashLength=0.12
	bMultiFrameFlash=true
	bMuzzleFlashRotates=true
}
