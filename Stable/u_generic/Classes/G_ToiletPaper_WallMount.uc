//=============================================================================
// G_ToiletPaper_WallMount.			   December 20th, 2000 - Charlie Wiederhold
//=============================================================================
class G_ToiletPaper_WallMount expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Toilet Paper"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=5.000000
     CollisionHeight=3.500000
     Mesh=DukeMesh'c_generic.toiletpaperrack'
}
