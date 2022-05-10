//=============================================================================
// Z1_Buffet_Jello.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Buffet_Jello expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(3)=Class'dnParticles.dnDebris_Wood1'
     SpawnOnHit=Class'dnParticles.dnBloodFX'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     LandFrontCollisionRadius=8.000000
     LandFrontCollisionHeight=6.500000
     LandSideCollisionRadius=8.000000
     LandSideCollisionHeight=6.500000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Jello"
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=5.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.buffet_jello'
}
