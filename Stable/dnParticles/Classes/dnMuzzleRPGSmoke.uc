//=============================================================================
// dnMuzzleRPGSmoke.	( AHB3d )
//=============================================================================
class dnMuzzleRPGSmoke expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

// Large flash of Smoke

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     GroupID=999
     SpawnPeriod=0.000000
     PrimeTime=0.400000
     PrimeTimeIncrement=0.200000
     Lifetime=0.400000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=64.000000,Z=0.000000)
     InitialAcceleration=(X=-96.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1aRC'
     StartDrawScale=0.040000
     EndDrawScale=0.400000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     RotationVariance=4000.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.000001
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=0.200000
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
