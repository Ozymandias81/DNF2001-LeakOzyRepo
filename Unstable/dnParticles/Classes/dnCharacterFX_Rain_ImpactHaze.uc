//=============================================================================
// dnCharacterFX_Rain_ImpactHaze. 		  March 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_Rain_ImpactHaze expands dnCharacterFX;

// Couple of hazy rain impacts

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     MaximumParticles=5
     Lifetime=0.400000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=-1.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=2.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.rain.genrain7RC'
     Textures(1)=Texture't_generic.rain.genrain9RC'
     Textures(2)=Texture't_generic.rain.genrain8RC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.200000
     EndDrawScale=0.300000
     AlphaVariance=0.150000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     TriggerType=SPT_Disable
     Style=STY_Translucent
     CollisionRadius=4.000000
     CollisionHeight=1.000000
}
