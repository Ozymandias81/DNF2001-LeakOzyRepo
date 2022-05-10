//=============================================================================
// dnMuzzleRPG.	( AHB3d )
//=============================================================================
class dnMuzzleRPG expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

// Fire explosion
// Calls ShotgunSmoke and ShotgunSmoke2

defaultproperties
{
     GroupID=999
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnMuzzleRPGSmoke',Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnMuzzleRPGSmoke2')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnMuzzleRPGSmoke3',Mount=True,MountOrigin=(X=-32.000000),MountAngles=(Yaw=32768))
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnMuzzleRPGSmoke4',Mount=True,MountOrigin=(X=-32.000000),MountAngles=(Yaw=32768))
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnMuzzleRPGSmoke5',Mount=True,MountOrigin=(X=-32.000000),MountAngles=(Yaw=32768))
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
     StartDrawScale=0.300000
     EndDrawScale=0.150000
     AlphaStart=0.200000
     AlphaEnd=0.000000
     RotationVariance=4000.000000
     PulseSeconds=0.000000
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=0.0
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
