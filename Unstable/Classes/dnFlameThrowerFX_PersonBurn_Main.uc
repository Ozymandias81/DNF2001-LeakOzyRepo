//=============================================================================
// dnFlameThrowerFX_PersonBurn_Main. 	   June 11th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlameThrowerFX_PersonBurn_Main expands dnFlameThrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(Mount=True)
     SpawnOnDestruction(0)=(SpawnClass=Class'dnParticles.dnFlameThrowerFX_PersonBurn_Main_Smoke',bTakeParentMountInfo=True)
     SpawnPeriod=0.025000
     Lifetime=0.500000
     LifetimeVariance=0.125000
     SpawnAtRadius=True
     InitialVelocity=(Z=64.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     StartDrawScale=0.300000
     EndDrawScale=0.300000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=3.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     CollisionRadius=12.000000
     CollisionHeight=12.000000
     Style=STY_Translucent
     bUnlit=True
     LightType=LT_Steady
     LightBrightness=255
     LightHue=16
     LightSaturation=16
     LightRadius=4
}
