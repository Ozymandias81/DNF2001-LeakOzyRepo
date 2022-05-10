//=============================================================================
// Z5_RollerCart. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_RollerCart expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=26.000000
     LandFrontCollisionHeight=14.000000
     LandSideCollisionRadius=26.000000
     LandSideCollisionHeight=14.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=-1.000000,Z=0.000000)
     BobDamping=0.900000
     ItemName="Roller Cart"
     CollisionHeight=18.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.roller_cart'
}
