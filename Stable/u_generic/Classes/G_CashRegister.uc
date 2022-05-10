//=============================================================================
// G_CashRegister. 						 October 9th, 2000 - Charlie Wiederhold
//=============================================================================
class G_CashRegister expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Cash Register"
     bFlammable=True
     CollisionRadius=21.000000
     CollisionHeight=9.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.cash_register'
}
