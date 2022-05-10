//=============================================================================
// dnWallShrinkRay.
//=============================================================================
class dnWallShrinkRay expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     GroupID=999
     SpawnNumber=2
     SpawnPeriod=0.200000
     PrimeCount=1
     PrimeTime=0.100000
     PrimeTimeIncrement=0.100000
     Lifetime=0.750000
     SpawnAtRadius=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     ApexInitialVelocity=-64.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnweapon.weapon_efx.ShrinkHit1'
     DrawScaleVariance=1.000000
     StartDrawScale=0.500000
     AlphaVariance=0.750000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     RotationVariance=32768.000000
     TriggerType=SPT_Pulse
     PulseSeconds=0.100000
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=2.000000
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=48.000000
     CollisionHeight=64.000000
}
