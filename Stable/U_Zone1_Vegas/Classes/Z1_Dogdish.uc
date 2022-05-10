//=============================================================================
// Z1_Dogdish.							October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Dogdish expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MassPrefab=MASS_Light
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.325000,Y=-1.250000,Z=1.250000)
     BobDamping=0.900000
     ItemName="Dog Dish"
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=3.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.dogdish'
}
