//=============================================================================
// dnFlamethrowerFX_WallFlame_Debris. 		May 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_WallFlame_Debris expands dnFlamethrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=1.000000
     LifetimeVariance=0.750000
     InitialVelocity=(X=64.0000,Z=64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=16.000000)
     RelativeSpawn=True
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     CollisionRadius=48.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
