//=============================================================================
// G_Chair.
//=======================================Created Feb 24th, 1999 - Stephen Cole
class G_Chair expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

var rotator DesiredWheelRotation, WheelRotation;
var float WheelRotationIncrement;

simulated function Bump( actor Other )
{
	local MeshInstance minst;
	local int bone;

	if ((Physics == PHYS_Falling) && (!IsWaterLogged()))
		return;
	Enable( 'Tick' );
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
		Disable('Tick');
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
     FragType(0)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Fabric1'
     FragType(2)=Class'dnParticles.dnDebris_Fabric1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(7)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=12.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=2.250000,Z=0.000000)
     ItemName="Rolling Chair"
     bFlammable=True
     CollisionRadius=18.000000
     CollisionHeight=25.000000
     GroundFriction=-7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.officechair1'
}
