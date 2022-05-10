//=============================================================================
// dnNukeFX_Flash. 							June 5th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Flash expands dnNukeFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnNukeFX_Residual_GasCloud')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnNukeFX_Residual_GasCloudRing')
	 AdditionalSpawnTakesOwner=true
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=2
     MaximumParticles=2
     Lifetime=0.325000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.Flamestill1cRC'
     StartDrawScale=28.000000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
