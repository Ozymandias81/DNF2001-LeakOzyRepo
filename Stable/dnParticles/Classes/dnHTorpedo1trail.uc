//=============================================================================
// dnHTorpedo1trail.
//=============================================================================
class dnHTorpedo1trail expands dnMissileTrail;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=1.500000
     RelativeSpawn=True
     InitialVelocity=(X=-64.000000,Z=128.000000)
     MaxVelocityVariance=(X=-64.000000,Y=0.000000,Z=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.250000
     EndDrawScale=0.750000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=8.000000
     CollisionHeight=8.000000
}
