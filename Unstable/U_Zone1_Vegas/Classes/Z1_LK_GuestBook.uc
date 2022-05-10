//=============================================================================
// Z1_LK_GuestBook. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_LK_GuestBook expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandUpright=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.625000,Y=-2.500000,Z=0.250000)
     BobDamping=0.900000
     ItemName="Guest Book"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.LKguestbook'
}
