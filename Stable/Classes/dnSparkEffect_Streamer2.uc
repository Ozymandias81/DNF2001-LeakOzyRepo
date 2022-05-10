//=============================================================================
// dnSparkEffect_Streamer2.
//=============================================================================
class dnSparkEffect_Streamer2 expands dnSparkEffect_Streamer;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect5')
     AdditionalSpawn(1)=(SpawnClass=None,Mount=False)
     Lifetime=1.000000
     Bounce=True
     ParticlesCollideWithWorld=True
     ParticlesCollideWithActors=True
}
