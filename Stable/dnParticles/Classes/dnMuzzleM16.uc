//=============================================================================
// dnMuzzleM16.                                 created by AB (c)April 13, 2000
//=============================================================================
class dnMuzzleM16 expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

defaultproperties
{
     GroupID=999
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=16320,Yaw=8880))
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=5680,Yaw=16016))
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=-6608,Yaw=16136))
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=-16624,Yaw=8880))
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=-6608,Yaw=-15456))
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnMuzzleM16Angle',Mount=True,MountAngles=(Pitch=5680,Yaw=-15456))
     spawnPeriod=0.000000
     PrimeTime=0.400000
     PrimeTimeIncrement=0.060000
     Lifetime=0.800000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=64.000000,Z=0.000000)
     InitialAcceleration=(X=-64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnweapon.muzzleflashes.muzzleflash3RC'
     StartDrawScale=0.160000
     EndDrawScale=0.050000
     AlphaStart=0.400000
     AlphaEnd=0.050000
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
