//=============================================================================
// dnFlamethrowerFX_Shrunk_PersonBurn_Footstep. 	   June 11th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_Shrunk_PersonBurn_Footstep expands dnFlamethrowerFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     SpawnOnDestruction(0)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_Shrunk_PersonBurn_Footstep_Smoke',bTakeParentMountInfo=True)
     SpawnPeriod=0.075000
     Lifetime=0.500000
     LifetimeVariance=0.125000
     InitialVelocity=(Z=8.000000)
     MaxVelocityVariance=(X=3.000000,Y=3.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=3.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Disable
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
