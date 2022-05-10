//=============================================================================
// dnWallDust.                                                    created by AB 
//=============================================================================
class dnWallDust expands dnWallFX;

// General smoke effect class.
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=2
     SpawnPeriod=0.200000
     PrimeCount=1
     PrimeTimeIncrement=0.100000
     Lifetime=1.000000
     LifetimeVariance=0.500000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=32.000000,Z=0.000000)
     InitialAcceleration=(X=-32.000000,Z=16.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000,Z=16.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.dirtcloud.dirtcloud1aRC'
     Textures(1)=Texture't_generic.dirtcloud.dirtcloud1bRC'
     Textures(2)=Texture't_generic.dirtcloud.dirtcloud1cRC'
     Textures(3)=Texture't_generic.dirtcloud.dirtcloud1dRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.050000
     EndDrawScale=0.200000
     AlphaEnd=0.000000
     RotationVariance=32768.000000
     TriggerType=SPT_Pulse
     PulseSeconds=0.100000
     bHidden=True
     Style=STY_Modulated
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
	 UpdateWhenNotVisible=true
}
