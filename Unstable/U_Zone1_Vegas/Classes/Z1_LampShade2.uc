//=============================================================================
// Z1_LampShade2.							Keith Schuler 5/21/99
//=============================================================================
class Z1_LampShade2 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Fabric1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=22.000000
     LandFrontCollisionHeight=7.500000
     LandSideCollisionRadius=22.000000
     LandSideCollisionHeight=7.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.325000,Y=1.000000,Z=1.000000)
     BobDamping=0.900000
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Table Lamp"
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.lampshade02'
}
