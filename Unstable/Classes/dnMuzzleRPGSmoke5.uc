//=============================================================================
// dnMuzzleRPGSmoke5.	( AHB3d )
//=============================================================================
class dnMuzzleRPGSmoke5 expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

// Exhaust Fire explosion

defaultproperties
{
     GroupID=999
     SpawnPeriod=0.050000
     PrimeTime=0.800000
     PrimeTimeIncrement=0.060000
     Lifetime=0.800000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=48.000000,Z=0.000000)
     InitialAcceleration=(X=-48.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionfx.explosion64.R301_090'
     StartDrawScale=0.200000
     EndDrawScale=0.100000
     AlphaStart=0.200000
     AlphaEnd=0.000000
     RotationVariance=4000.000000
     PulseSeconds=0.000000
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=0.150000
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
