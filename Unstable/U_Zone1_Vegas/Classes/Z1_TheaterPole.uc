//=============================================================================
// Z1_TheaterPole.						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_TheaterPole expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=44.000000
     LandFrontCollisionHeight=7.000000
     LandSideCollisionRadius=44.000000
     LandSideCollisionHeight=7.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.325000,Y=1.250000,Z=2.000000)
     BobDamping=0.900000
     ItemName="Pole"
     CollisionRadius=8.000000
     CollisionHeight=25.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.theatrepole'
}
