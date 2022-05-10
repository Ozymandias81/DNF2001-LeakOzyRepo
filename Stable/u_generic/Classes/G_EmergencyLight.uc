//=============================================================================
// G_EmergencyLight.
//==================================Created Feb 24th, 1999 - Stephen Cole
class G_EmergencyLight expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Emergency Light"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=17.000000
     CollisionHeight=12.000000
     Mesh=DukeMesh'c_generic.emergencylight1'
}
