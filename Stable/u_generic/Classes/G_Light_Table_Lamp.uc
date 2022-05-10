//=============================================================================
// G_Light_Table_Lamp.
//=========================================Created Feb 24th, 1999 - Stephen Cole
class G_Light_Table_Lamp expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=12.000000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=12.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=0.250000,Z=0.500000)
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Table Lamp"
     bFlammable=True
     CollisionRadius=13.000000
     CollisionHeight=16.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.light_tablelamp'
}
