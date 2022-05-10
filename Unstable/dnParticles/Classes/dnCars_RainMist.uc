//=============================================================================
// dnCars_RainMist.
//=============================================================================
class dnCars_RainMist expands dnVehicleFX;

// Rain Mist that is kicked up by fast moving cars

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     Lifetime=2.000000
     LifetimeVariance=2.000000
     RelativeSpawn=True
     RelativeRotation=True
     InitialVelocity=(X=320.000000,Z=64.000000)
     InitialAcceleration=(Z=-48.000000)
     MaxVelocityVariance=(X=64.000000,Y=64.000000,Z=48.000000)
     MaxAccelerationVariance=(Z=-48.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Rain.rain_mist1BC'
     Textures(1)=Texture't_generic.Rain.rain_mist2BC'
     Textures(2)=Texture't_generic.Rain.rain_mist3BC'
     Textures(3)=Texture't_generic.Rain.rain_mist4BC'
     DrawScaleVariance=1.000000
     StartDrawScale=2.000000
     EndDrawScale=4.000000
     UpdateWhenNotVisible=True
     BSPOcclude=False
     AlphaStart=0.100000
     AlphaMid=0.300000
     AlphaEnd=0.100000
     AlphaRampMid=0.300000
     CollisionRadius=64.000000
     CollisionHeight=32.000000
     Physics=PHYS_MovingBrush
     DestroyOnDismount=True
     Style=STY_Translucent
}
