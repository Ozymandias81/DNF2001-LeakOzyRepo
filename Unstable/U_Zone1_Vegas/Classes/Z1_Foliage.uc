//=============================================================================
// Z1_Foliage. 							October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Foliage expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(1)=Class'dnParticles.dnLeaves'
     FragType(2)=Class'dnParticles.dnLeaves'
     FragType(3)=Class'dnParticles.dnDebris_Dirt1'
     FragType(4)=Class'dnParticles.dnDebris_Dirt1'
     FragType(5)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(6)=Class'dnParticles.dnLeaves'
     FragType(7)=Class'dnParticles.dnLeaves'
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=55.000000
     CollisionHeight=42.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.foilage1'
}
