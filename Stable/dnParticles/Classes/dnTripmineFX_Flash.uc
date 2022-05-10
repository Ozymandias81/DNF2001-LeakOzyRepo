//=============================================================================
// dnTripmineFX_Flash.                    Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_Flash expands dnTripmineFX;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the root explosion flash effect.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnTripmineFX_ShockWave')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnTripmineFX_RootExp')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrapnel',Mount=True)
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnTripmineFX_LineExp_Small',Mount=True,MountOrigin=(X=92.000000),MountAngles=(Pitch=16384))
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnTripmineFX_LineExp_Large',Mount=True,MountOrigin=(X=288.000000),MountAngles=(Pitch=16384))
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnTripmineFX_LineSmoke',Mount=True,MountOrigin=(X=192.000000),MountAngles=(Pitch=16384))
     AdditionalSpawn(6)=(SpawnClass=Class'dnParticles.dnTripmineFX_ShockCloud',Mount=True,MountAngles=(Pitch=16384))
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     LineStartColor=(R=255,G=255,B=128)
     LineEndColor=(R=255,G=255,B=255)
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=24.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.100000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
