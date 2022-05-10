//=============================================================================
// dnMuzzleRPGSmoke2.	( AHB3d )
//=============================================================================
class dnMuzzleRPGSmoke2 expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

// Leftover animated Smoke

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     GroupID=999
     SpawnPeriod=0.200000
     PrimeCount=2
     PrimeTimeIncrement=0.100000
     Lifetime=2.600000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=36.000000,Z=0.000000)
     InitialAcceleration=(X=-36.000000,Z=8.000000)
     MaxVelocityVariance=(X=8.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnweapon.weapon_smoke.smokeB0BC'
     DieOnLastFrame=True
     DrawScaleVariance=0.200000
     StartDrawScale=0.260000
     EndDrawScale=0.380000
     AlphaVariance=0.200000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     RotationVariance=3.140000
     TriggerType=SPT_Pulse
     PulseSeconds=0.200000
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=2.000000
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
