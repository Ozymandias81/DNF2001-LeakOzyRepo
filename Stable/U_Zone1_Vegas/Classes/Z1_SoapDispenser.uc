//=============================================================================
// Z1_SoapDispenser.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_SoapDispenser expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Soap Dispenser"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=9.500000
     Mesh=DukeMesh'c_zone1_vegas.brothb_soapdisp'
}
