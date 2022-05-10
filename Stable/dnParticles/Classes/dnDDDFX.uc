//=============================================================================
// dnDDDFX. 				   July 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnDDDFX expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\textures\mario.dtx

defaultproperties
{
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     Lifetime=5.000000
     InitialVelocity=(Z=16.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'mario.charlietemp3BC'
     StartDrawScale=0.112500000
     EndDrawScale=0.112500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Prime
     BSPOcclude=False
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.800000
     bUseAlphaRamp=True
     bEdShouldSnap=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     Texture=Texture'mario.charlietemp3BC'
     DrawScale=0.125000
}
