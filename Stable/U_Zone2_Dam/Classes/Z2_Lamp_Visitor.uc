//=============================================================================
// Z2_Lamp_Visitor.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Lamp_Visitor expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Light"
     bTakeMomentum=False
     CollisionHeight=16.000000
     Mesh=DukeMesh'c_zone2_dam.lamp_visitor'
}
