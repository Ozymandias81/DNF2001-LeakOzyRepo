//=============================================================================
// Z5_c_monitor.
//=============================================================================
//==========MW
class Z5_c_monitor expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Glass1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=16.000000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=16.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     Health=200
     ItemName="Monitor"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.comp_monitor'
}
