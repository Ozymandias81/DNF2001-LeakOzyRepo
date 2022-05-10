//=============================================================================
// G_Cardboard_Box. 				   November 14th, 2000 - Charlie Wiederhold
//=============================================================================
class G_Cardboard_Box expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Paper1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=16.000000
     LandFrontCollisionHeight=10.000000
     LandSideCollisionRadius=16.000000
     LandSideCollisionHeight=13.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=-2.000000,Z=1.000000)
     ItemName="Cardboard Box"
     bFlammable=True
     CollisionRadius=16.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.CardboardBoxA'
}
