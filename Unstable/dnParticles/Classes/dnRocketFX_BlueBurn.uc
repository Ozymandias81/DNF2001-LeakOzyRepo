//=============================================================================
// dnRocketFX_BlueBurn. 			   November 29th, 2000 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_BlueBurn expands dnRocketFX_Burn;

// Nuke Trail effect
// Does NOT do damage. 
// Spawns the hot part of the residual smoke effect 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnRocketFX_NukeTrail')
     Textures(0)=Texture't_generic.particle_efx.pflare5ABC'
     StartDrawScale=5.000000
     EndDrawScale=10.000000
}
