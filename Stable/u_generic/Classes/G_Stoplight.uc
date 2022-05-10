//=============================================================================
// G_Stoplight.
//=============================================================================
class G_Stoplight expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 11th, 1998 - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1c'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(5)=Class'dnParticles.dnDebris_Metal1'
     FragBaseScale=0.300000
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SmallElectronic')
     ItemName="Stoplight"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=11.000000
     CollisionHeight=22.000000
     Mesh=DukeMesh'c_generic.stoplight'
}
