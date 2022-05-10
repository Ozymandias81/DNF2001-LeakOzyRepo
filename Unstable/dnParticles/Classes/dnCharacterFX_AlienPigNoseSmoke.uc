//=============================================================================
// dnCharacterFX_AlienPigNoseSmoke. 	  March 15th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_AlienPigNoseSmoke expands dnCharacterFX;

// Stream of smoke/snot from the pig's nose

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.010000
     Lifetime=0.250000
     RelativeSpawn=True
     InitialVelocity=(Z=128.000000)
     MaxVelocityVariance=(X=0.000000,Y=48.000000,Z=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.032500
     EndDrawScale=0.075000
     AlphaVariance=0.500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.375000
     TriggerType=SPT_Disable
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
