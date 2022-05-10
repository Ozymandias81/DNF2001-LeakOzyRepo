/*-----------------------------------------------------------------------------
	PawnShrink
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PawnShrink extends ActorDamageEffect
	abstract;

// Beam pawn hit.
var BeamAnchor PawnFingerR, PawnFingerL, PawnFootR, PawnFootL, PawnHead;
var class<BeamSystem> PawnChestBlastClass;
var BeamSystem PawnChestBlast, EmissionBlast, EmissionBlastThird;

simulated function AttachAnchorToBone( name AttachBone, Actor AttachOther, out BeamAnchor AttachAnchor )
{
	local int bone;
	local vector AnchorLoc;
	local MeshInstance minst;

	minst = Owner.GetMeshInstance();
	bone = minst.BoneFindNamed( AttachBone );
	AnchorLoc = minst.BoneGetTranslate( bone, true, false );
	AnchorLoc = minst.MeshToWorldLocation( AnchorLoc );
	AttachAnchor = spawn( class'BeamAnchor', Self,, AnchorLoc );
	AttachAnchor.MountType = MOUNT_MeshBone;
	AttachAnchor.MountMeshItem = AttachBone;
	AttachAnchor.SetPhysics( PHYS_MovingBrush );
	AttachAnchor.AttachActorToParent( AttachOther, false, false );
}

simulated function RemoveEffect()
{
	Super.RemoveEffect();

	// Remove anchors.
	if ( PawnFingerR != None )
		PawnFingerR.Destroy();

	if ( PawnFingerL != None )
		PawnFingerL.Destroy();

	if ( PawnHead != None )
		PawnHead.Destroy();

	if ( PawnFootR != None )
		PawnFootR.Destroy();

	if ( PawnFootL != None )
		PawnFootL.Destroy();

	// Remove beam system.
	if ( PawnChestBlast != None )
		PawnChestBlast.Destroy();

	// Remove shrink dot.
	if ( (Owner != None) && Owner.bIsPawn )
		Pawn(Owner).RemoveDOT( DOT_Shrink );
}

simulated function AttachEffect( Actor Other )
{
	if ( Owner == None )
	{
		Log("Error: Tried to attach PawnShrink to a None Owner.");
		Destroy();
		return;
	}

	Super.AttachEffect( Other );

	// Spawn the anchors.
	if ( PawnFingerR == None )
		AttachAnchorToBone( 'Hand_R', Other, PawnFingerR );

	if ( PawnFingerL == None )
		AttachAnchorToBone( 'Hand_L', Other, PawnFingerL );

	if ( PawnHead == None )
		AttachAnchorToBone( 'Head', Other, PawnHead );

	if ( PawnFootR == None )
		AttachAnchorToBone( 'Foot_R', Other, PawnFootR );

	if ( PawnFootL == None )
		AttachAnchorToBone( 'Foot_L', Other, PawnFootL );

	// Mount the chest blast.
	if ( PawnChestBlast == None )
	{
		PawnChestBlast = spawn( PawnChestBlastClass, Self );
		PawnChestBlast.DestinationActor[0] = PawnHead;
		PawnChestBlast.DestinationActor[1] = PawnFootR;
		PawnChestBlast.DestinationActor[2] = PawnFootL;
		PawnChestBlast.DestinationActor[3] = PawnFingerR;
		PawnChestBlast.DestinationActor[4] = PawnFingerL;
		PawnChestBlast.NumberDestinations = 5;
		PawnChestBlast.MountType = MOUNT_MeshBone;
		PawnChestBlast.MountMeshItem = 'Chest';
		PawnChestBlast.SetPhysics( PHYS_MovingBrush );
		PawnChestBlast.AttachActorToParent( Other, true, true );
		PawnChestBlast.RemoteRole = ROLE_None;
	}

	// Add shrink DOT if owner is a pawn.
	if ( Owner.bIsPawn )
		Pawn(Owner).AddDOT( DOT_Shrink, Lifespan, 0.0, 0.0, None );
}
