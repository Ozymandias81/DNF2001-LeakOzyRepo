//=============================================================================
// Z1_CasinoStool.										   Keith Schuler 7/9/99
//=============================================================================
class Z1_CasinoStool expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     IdleAnimations(0)=On
     TriggerType=TT_PlayerProximity
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     LodScale=0.800000
     LodOffset=75.000000
     ItemName="Casino Stool"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=19.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.slotstool2'
     AnimSequence=Off
}
