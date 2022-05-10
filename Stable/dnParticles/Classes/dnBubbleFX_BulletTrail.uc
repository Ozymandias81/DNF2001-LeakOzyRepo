//=============================================================================
// dnBubbleFX_BulletTrail. 				October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnBubbleFX_BulletTrail expands dnBubbleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.007500
     Lifetime=2.500000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(Z=8.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.bubbles.bubble2RC'
     StartDrawScale=0.062500
     EndDrawScale=0.062500
     AlphaStart=0.750000
     AlphaEnd=0.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     PulseSeconds=0.100000
     Physics=PHYS_MovingBrush
     Velocity=(X=256.000000)
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
