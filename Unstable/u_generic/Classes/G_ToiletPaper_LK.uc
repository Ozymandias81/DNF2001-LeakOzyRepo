//=============================================================================
// G_ToiletPaper_LK. 				   December 20th, 2000 - Charlie Wiederhold
//=============================================================================
class G_ToiletPaper_LK expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=5.500000
     LandFrontCollisionHeight=3.500000
     LandSideCollisionRadius=5.500000
     LandSideCollisionHeight=3.500000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.625000,Y=-1.250000,Z=2.000000)
     BobDamping=0.900000
     ItemName="Toilet Paper"
     bFlammable=True
     CollisionRadius=3.500000
     CollisionHeight=4.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.toiletpaper_LK'
}
