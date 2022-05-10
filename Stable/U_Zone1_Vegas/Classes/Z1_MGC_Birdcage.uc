//=============================================================================
// Z1_MGC_Birdcage.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MGC_Birdcage expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(5)=Class'dnParticles.dnDebris_Metal1_Small'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=16.000000
     LandFrontCollisionHeight=10.000000
     LandSideCollisionRadius=16.000000
     LandSideCollisionHeight=10.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=0.750000,Z=1.000000)
     BobDamping=0.900000
     ItemName="Birdcage"
     CollisionRadius=10.000000
     CollisionHeight=14.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.mgc_birdcage'
}
