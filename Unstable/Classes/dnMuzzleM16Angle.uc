//=============================================================================
// dnMuzzleM16Angle.                            created by AB (c)April 13, 2000
//=============================================================================
class dnMuzzleM16Angle expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

defaultproperties
{
     GroupID=999
     spawnPeriod=0.000000
     PrimeTime=0.400000
     PrimeTimeIncrement=0.080000
     Lifetime=0.400000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=32.000000,Z=0.000000)
     InitialAcceleration=(X=-32.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnweapon.muzzleflashes.muzzleflash3RC'
     StartDrawScale=0.060000
     EndDrawScale=0.080000
     AlphaStart=0.400000
     AlphaEnd=0.200000
     RotationVariance=4000.000000
     PulseSeconds=0.000000
     bHidden=True
     Physics=PHYS_MovingBrush
	 LifeSpan=0.08
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
