//=============================================================================
// Z5_lab_agitator.
//=============================================================================
class Z5_lab_agitator expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//==============================March 18th, Matt Wood

defaultproperties
{
     HealthMarkers(0)=(Threshold=140)
     HealthMarkers(2)=(Threshold=160)
     HealthMarkers(3)=(Threshold=180)
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(3)=Class'dnParticles.dnDebris_Metal1'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1_Small'
     NumberFragPieces=14
     IdleAnimations(0)=Idle
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandBackwards=True
     bLandUpright=True
     LandFrontCollisionRadius=18.000000
     LandFrontCollisionHeight=13.500000
     LandSideCollisionRadius=18.000000
     LandSideCollisionHeight=13.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=-1.500000,Z=1.500000)
     BobDamping=0.900000
     LodScale=0.900000
     Health=200
     ItemName="Agitator"
     bUseTriggered=True
     bFlammable=True
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mass=70.000000
     Buoyancy=-10.000000
     Mesh=DukeMesh'c_zone5_area51.lab_agitator'
}
