//=============================================================================
// Z1_Buffet_Tray.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Buffet_Tray expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     MassPrefab=MASS_Light
     bLandUpright=True
     bLandUpsideDown=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=-2.000000,Z=0.500000)
     BobDamping=0.900000
     ItemName="Buffet Tray"
     CollisionRadius=13.000000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.buffet_tray'
}
