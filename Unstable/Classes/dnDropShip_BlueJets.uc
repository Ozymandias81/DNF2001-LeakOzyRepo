//=============================================================================
// dnDropShip_BlueJets. 				October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_BlueJets expands dnVehicleFX;

// Blue jets that spawn from the EDF drop ship

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(MountOrigin=(Z=-32.000000),MountAngles=(Roll=32768))
     SpawnNumber=3
     SpawnPeriod=0.050000
     PrimeTimeIncrement=0.000000
     MaximumParticles=45
     Lifetime=1.000000
     SpawnAtRadius=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Apex=(Z=128.000000)
     ApexInitialVelocity=-96.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.LensFlares.blu_glow1'
     StartDrawScale=2.500000
     EndDrawScale=1.500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaEnd=0.250000
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     bBurning=True
     CollisionHeight=0.000000
     DestroyOnDismount=True
     Style=STY_Translucent
     bUnlit=True
     SoundRadius=255
     AmbientSound=Sound'a_transport.Airplanes.DropShipLp'
}
