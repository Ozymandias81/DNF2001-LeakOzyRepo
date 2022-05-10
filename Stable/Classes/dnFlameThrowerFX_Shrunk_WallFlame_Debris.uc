//=============================================================================
// dnFlamethrowerFX_Shrunk_WallFlame_Debris. 		May 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_Shrunk_WallFlame_Debris expands dnFlamethrowerFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=1.000000
     LifetimeVariance=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=16.00000,Z=16.000000)
     MaxVelocityVariance=(X=0.0000000,Y=0.000000,Z=4.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     EndDrawScale=0.250000
     StartDrawScale=0.250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     CollisionRadius=12.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
