//=============================================================================
// dnCars_Headlights.	ab
//=============================================================================
class dnCars_Headlights expands dnVehicleFX;

// Particle headlights for moving cars on the Strip

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.015000
     Lifetime=0.270000
     RelativeSpawn=True
     SpawnOffset=(X=-608.000000)
     RelativeLocation=True
     InitialVelocity=(X=-2100.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Rain.rain_mist1BC'
     Textures(1)=Texture't_generic.Rain.rain_mist2BC'
     Textures(2)=Texture't_generic.Rain.rain_mist3BC'
     Textures(3)=Texture't_generic.Rain.rain_mist4BC'
     StartDrawScale=1.500000
     EndDrawScale=0.500000
     UpdateWhenNotVisible=True
     AlphaStart=0.000000
     AlphaMid=0.250000
     bUseAlphaRamp=True
     VisibilityRadius=8192.000000
     VisibilityHeight=8192.000000
     bDynamicLight=True
     bDirectional=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
}
