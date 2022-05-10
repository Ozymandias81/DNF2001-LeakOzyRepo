//=============================================================================
// dnLensFlares.                                   Charlie Wiederhold 4/17/2000
//=============================================================================
class dnLensFlares expands SoftParticleSystem;

// Default Lens Flare Class
// Does NOT do damage. 
// This particular one is used for the lights on the jets.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.000000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.lensflares.bluelensflare1B'
     StartDrawScale=0.500000
     EndDrawScale=0.500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
