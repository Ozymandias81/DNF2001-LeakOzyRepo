//=============================================================================
// G_Barricade1.
//=====Created Feb 24th, 1999 - Stephen Cole
class G_Barricade1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragType(4)=Class'dnParticles.dnDebris_Wood1'
     FragType(5)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragSkin=Texture'm_generic.baricade1A'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=1.250000,Z=0.750000)
     Health=20
     ItemName="Barricade"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=27.000000
     Physics=PHYS_Falling
     Mass=1.000000
     Mesh=DukeMesh'c_generic.baricade1'
     DrawScale=1.700000
}
