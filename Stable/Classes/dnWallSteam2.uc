//=============================================================================
// dnWallSteam2.                                                  created by AB
//=============================================================================
class dnWallSteam2 expands dnWallSteam;

// Steam Smoke

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None,Mount=False,MountOrigin=(X=0.000000))
     AdditionalSpawn(1)=(SpawnClass=None)
     SpawnNumber=1
     Lifetime=0.600000
     LifetimeVariance=1.000000
     RelativeSpawn=False
     RelativeLocation=True
     RelativeRotation=True
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=0.000000)
     UseLines=False
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.Smoke.gensmoke1aRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1bRC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.010000
     EndDrawScale=0.100000
     AlphaVariance=0.500000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     RotationVariance=32768.000000
     SystemAlphaScaleVelocity=-0.250000
     DamageAmount=2.000000
     DamageRadius=48.000000
     MomentumTransfer=500.000000
     DamagePeriod=0.750000
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
