//=============================================================================
// G_Pole.
//==============================Created Feb 24th, 1999 - Stephen Cole
class G_Pole expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=170.000000
     Mesh=DukeMesh'c_generic.pole'
}
