//=============================================================================
// Z1_LK_DeskBell. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_LK_DeskBell expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     bLandUpright=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-1.250000,Z=1.500000)
     BobDamping=0.900000
     ItemName="Call Bell"
     CollisionRadius=4.000000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.LKdeskbell'
}
