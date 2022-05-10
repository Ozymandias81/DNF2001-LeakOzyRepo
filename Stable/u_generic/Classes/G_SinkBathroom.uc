//=============================================================================
// G_SinkBathroom. 						January 23rd, 2001 - Charlie Wiederhold
//=============================================================================
class G_SinkBathroom expands Generic;

#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     HealthPrefab=HEALTH_NeverBreak
     Mesh=DukeMesh'c_generic.sink1'
     bNotTargetable=True
     CollisionRadius=11.500000
     CollisionHeight=3.250000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bTakeMomentum=False
}
