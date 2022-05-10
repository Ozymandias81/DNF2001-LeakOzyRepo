//=============================================================================
// Z1_Buffet_Ladel.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Buffet_Ladel expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=13.000000
     LandFrontCollisionHeight=2.500000
     LandSideCollisionRadius=13.000000
     LandSideCollisionHeight=2.500000
     Grabbable=True
     PlayerViewOffset=(X=0.750000,Y=-0.325000,Z=2.000000)
     BobDamping=0.900000
     ItemName="Ladel"
     CollisionRadius=5.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.buffet_ladel'
}
