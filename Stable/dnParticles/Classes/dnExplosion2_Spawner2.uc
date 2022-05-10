//=============================================================================
// dnExplosion2_Spawner2.          Created by Charlie Wiederhold April 15, 2000
//=============================================================================
class dnExplosion2_Spawner2 expands dnExplosion2;

// Explosion effect spawner.
// Does NOT do damage. 
// Uses dnExplosion2_Effect3, dnExplosion2_Effect4.
// Medium/Large explosion for non moving object.
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion2_Effect3')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnExplosion2_Effect4')
     CreationSound=Sound'a_impact.explosions.Expl118'
     CreationSoundRadius=16384.000000
     RelativeSpawn=False
     InitialVelocity=(X=0.000000)
     bBurning=True
}
