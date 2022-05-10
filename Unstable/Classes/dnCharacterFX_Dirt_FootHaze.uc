//=============================================================================
// dnCharacterFX_Dirt_FootHaze. 		  March 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_Dirt_FootHaze expands dnCharacterFX;

// Haze left behind after a step in dirt

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=1
     MaximumParticles=1
     Lifetime=1.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.dirtcloud.dirtcloud1cRC'
     StartDrawScale=0.250000
     EndDrawScale=0.750000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
