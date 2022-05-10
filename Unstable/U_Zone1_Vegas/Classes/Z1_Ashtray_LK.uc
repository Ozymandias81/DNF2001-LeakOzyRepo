//=============================================================================
// Z1_Ashtray_LK.					   	October 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Ashtray_LK expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=26.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=26.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Lady Killer Ashtray"
     CollisionRadius=11.000000
     CollisionHeight=17.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.ashtray_LK'
}
