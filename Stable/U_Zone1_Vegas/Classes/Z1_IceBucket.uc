//=============================================================================
// Z1_IceBucket. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_IceBucket expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Ice1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=40.000000
     LandFrontCollisionHeight=10.000000
     LandSideCollisionRadius=40.000000
     LandSideCollisionHeight=10.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=2.250000,Z=1.000000)
     BobDamping=0.900000
     ItemName="Ice Bucket"
     CollisionRadius=12.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.icebucket'
}
