//=============================================================================
// G_BoomBarrelMines.
//=============================================================================
class G_BoomBarrelMines expands G_BoomBarrel2;

#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None)
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnDebrisMesh_BoomBarrel')
     MultiSkins(0)=None
     MultiSkins(1)=None
     Mesh=DukeMesh'c_zone3_canyon.barrel_wood1'
}
