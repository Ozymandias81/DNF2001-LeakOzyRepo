//=============================================================================
// dnMuzzleRPGSmoke4.	( AHB3d )
//=============================================================================
class dnMuzzleRPGSmoke4 expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

// Exhaust Leftover animated Smoke

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     GroupID=999
     SpawnPeriod=0.050000
     PrimeTime=0.200000
     PrimeTimeIncrement=0.060000
     Lifetime=1.500000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=96.000000,Z=0.000000)
     InitialAcceleration=(X=-80.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     MaxAccelerationVariance=(X=-16.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnweapon.weapon_smoke.smokeB0BC'
     DieOnLastFrame=True
     StartDrawScale=0.200000
     EndDrawScale=1.500000
     AlphaStart=0.200000
     AlphaEnd=0.000000
     RotationVariance=4000.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.400000
     bHidden=True
     Physics=PHYS_MovingBrush
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
