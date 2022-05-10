//=============================================================================
// Z5_lab_centrifuge.
//=============================================================================
class Z5_lab_centrifuge expands Zone5_Area51;

///=================================  March 18th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     BounceElasticity=0.100000
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragSkin=Texture'm_zone5_area51.centrifugeRC'
     NumberFragPieces=14
     FragBaseScale=0.200000
     TriggerRetriggerDelay=10.000000
     TriggeredSequence=centrion
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     ThrowForce=100.000000
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     LodScale=0.900000
     Health=200
     ItemName="Centrifuge"
     bUseTriggered=True
     bFlammable=True
     CollisionRadius=22.000000
     CollisionHeight=23.000000
     Physics=PHYS_Falling
     Mass=90.000000
     Buoyancy=-10.000000
     Mesh=DukeMesh'c_zone5_area51.lab_centrifuge'
}
