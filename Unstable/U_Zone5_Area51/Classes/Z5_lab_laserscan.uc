//=============================================================================
// Z5_lab_laserscan.
//=============================================================================
class Z5_lab_laserscan expands Zone5_Area51;

///=======================================  March 18th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandUpright=True
     LandFrontCollisionRadius=18.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=18.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=-1.250000,Z=1.000000)
     ItemName="Laser Scan"
     bFlammable=True
     CollisionRadius=18.000000
     CollisionHeight=9.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_laserscan'
}
