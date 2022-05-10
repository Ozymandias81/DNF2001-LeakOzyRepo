//=============================================================================
// Z1_NewspaperStand. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_NewspaperStand expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=36.000000
     LandFrontCollisionHeight=12.000000
     LandSideCollisionRadius=36.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Newspaper Stand"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=26.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.stand1RC'
}
