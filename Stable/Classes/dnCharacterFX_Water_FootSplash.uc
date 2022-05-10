//=============================================================================
// dnCharacterFX_Water_FootSplash. 		  March 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_Water_FootSplash expands dnCharacterFX;

// Splash of water for running in the rain, etc.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnCharacterFX_Water_FootHaze')
     SpawnNumber=0
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.150000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.WaterImpact.waterimpact5RC'
     StartDrawScale=0.100000
     EndDrawScale=0.300000
     AlphaEnd=0.100000
     RotationVariance=65535.000000
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
