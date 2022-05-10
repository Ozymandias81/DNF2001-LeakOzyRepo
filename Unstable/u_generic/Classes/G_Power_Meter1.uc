//=============================================================================
// G_Power_Meter1.
//=============================Created Feb 24th, 1999 - Stephen Cole
class G_Power_Meter1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Power Meter"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=13.000000
     CollisionHeight=25.000000
     Mesh=DukeMesh'c_generic.powermeter1'
}
