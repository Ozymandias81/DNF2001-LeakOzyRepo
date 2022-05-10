//=============================================================================
// Z1_HotelRack.							Keith Schuler 5/21/99
//=============================================================================
class Z1_HotelRack expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

var rotator DesiredWheelRotation, WheelRotation;
var float WheelRotationIncrement;

simulated function Bump( actor Other )
{
	local MeshInstance minst;
	local int bone;

	if ((Physics == PHYS_Falling) && (!IsWaterLogged()))
		return;
	Enable('Tick');
	if( bPushable && (Pawn(Other) != None) && (Other.Mass > 40) )
	{
		// Velocity...
		bBobbing = false;
		Velocity = Other.Velocity * 150.0/VSize(Other.Velocity);
		SetPhysics(PHYS_Rolling);
		SetTimer(0.5,true);
		Instigator = Pawn(Other);

		// Wheels...
		minst = GetMeshInstance();
		bone = minst.BoneFindNamed('WheelF');
		DesiredWheelRotation = minst.BoneGetRotate(bone, false, true);
		DesiredWheelRotation.Yaw = rotator(Velocity).Yaw - Rotation.Yaw;

		if (DesiredWheelRotation.Yaw < WheelRotation.Yaw)
			WheelRotationIncrement = -32768*2;
		else
			WheelRotationIncrement = 32768*2;
	}
}

simulated function Tick(float Delta)
{
	local MeshInstance minst;
	local int bone;

	Super.Tick(Delta);

	if (WheelRotation == DesiredWheelRotation)
	{
		Disable( 'Tick' );
		return;
	}

	minst = GetMeshInstance();

	WheelRotation.Pitch = DesiredWheelRotation.Pitch;
	WheelRotation.Yaw += Delta * WheelRotationIncrement;
	if ((WheelRotationIncrement > 0) && (WheelRotation.Yaw > DesiredWheelRotation.Yaw))
		WheelRotation.Yaw = DesiredWheelRotation.Yaw;
	if ((WheelRotationIncrement < 0) && (WheelRotation.Yaw < DesiredWheelRotation.Yaw))
		WheelRotation.Yaw = DesiredWheelRotation.Yaw;
	WheelRotation.Roll = DesiredWheelRotation.Roll;

	bone = minst.BoneFindNamed('WheelF');
	if (bone != 0)
		minst.BoneSetRotate(bone, WheelRotation, true, false);

	bone = minst.BoneFindNamed('WheelL');
	if (bone != 0)
		minst.BoneSetRotate(bone, WheelRotation, true, false);

	bone = minst.BoneFindNamed('WheelR');
	if (bone != 0)
		minst.BoneSetRotate(bone, WheelRotation, true, false);
}

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Fabric1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=36.000000
     LandFrontCollisionHeight=20.000000
     LandSideCollisionRadius=36.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.500000,Y=3.000000,Z=-1.000000)
     ItemName="Luggage Rack"
     bTakeMomentum=False
     CollisionHeight=38.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.hotel_rack'
}
