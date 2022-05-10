//=============================================================================
// dnSparkFX_BrokenLight_Flash. 						June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnSparkFX_BrokenLight_Flash expands dnSparkFX;

// Explosion for the RPG Rockets.
// Does damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     DestroyWhenEmpty=True
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
     StartDrawScale=48.000000
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
