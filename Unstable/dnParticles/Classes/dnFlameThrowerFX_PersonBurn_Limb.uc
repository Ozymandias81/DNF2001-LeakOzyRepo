//=============================================================================
// dnFlameThrowerFX_PersonBurn_Limb. 	   June 11th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlameThrowerFX_PersonBurn_Limb expands dnFlameThrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.050000
     Lifetime=0.500000
     LifetimeVariance=0.125000
     InitialVelocity=(Z=48.000000)
     MaxVelocityVariance=(X=24.000000,Y=24.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     StartDrawScale=0.225000
     EndDrawScale=0.225000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=3.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
     bUnlit=True
}
