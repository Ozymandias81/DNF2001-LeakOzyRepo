//=============================================================================
// dnRocketFX_Shrunk_Explosion_Flash. 						August 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_Flash expands dnRocketFX_Shrunk;

// Explosion for the RPG Rockets.
// Does damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_SmokeCloud')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_Fire')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_Sparks')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_ShockWave')
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnDecal_BlastMark')
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_ShockCloud')
     AdditionalSpawn(6)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_Glow')
     AdditionalSpawn(7)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_LightDebris')
     CreationSound=Sound'a_impact.explosions.Expl118'
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.5000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare1'
     StartDrawScale=12.000000
     EndDrawScale=0.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     SpriteProjForward=32.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
