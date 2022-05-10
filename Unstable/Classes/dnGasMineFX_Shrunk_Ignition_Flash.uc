//=============================================================================
// dnGasMineFX_Shrunk_Ignition_Flash.				June 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnGasMineFX_Shrunk_Ignition_Flash expands dnGasMineFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\dnmodulation.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'dnModulation.firebites2tw'
     StartDrawScale=12.000000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
