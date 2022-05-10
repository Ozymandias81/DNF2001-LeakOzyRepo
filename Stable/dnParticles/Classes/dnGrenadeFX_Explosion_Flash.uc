//=============================================================================
// dnGrenadeFX_Explosion_Flash. 						June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Explosion_Flash expands dnGrenadeFX;

// Explosion for the RPG Grenades.
// Does damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     bBurning=True
     UpdateWhenNotVisible=True
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_SmokeCloud')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_Fire')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_Sparks')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_ShockWave')
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnDecal_BlastMark')
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_ShockCloud')
     AdditionalSpawn(6)=(SpawnClass=Class'dnParticles.dnGrenadeFX_Explosion_Glow')
     AdditionalSpawn(7)=(SpawnClass=Class'dnGrenadeFX_Explosion_LightDebris')
     CreationSound=Sound'a_impact.explosions.Expl118'
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.5000
     InitialVelocity=(X=0.000000,Y=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=0.000000)
     Textures(0)=Texture't_generic.particle_efx.pflare1'
     StartDrawScale=32.000000
     EndDrawScale=0.000000
     TriggerType=SPT_None
     PulseSeconds=0.250000
     AlphaEnd=1.000000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     SpriteProjForward=48.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Style=STY_Translucent
     bUnlit=True
     RotationVelocityMaxVariance=2.000000
     bIgnoreBList=True
}
