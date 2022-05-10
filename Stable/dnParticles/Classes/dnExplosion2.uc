//=============================================================================
// dnExplosion2.                   Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnExplosion2 expands SoftParticleSystem;

// Explosion effect spawner.
// Does NOT do damage. 
// Uses dnExplosion2_Effect1, dnExplosion2_Effect2.
// Large explosion for fast moving object.
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion2_Effect1')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnExplosion2_Effect2')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.500000
     RelativeSpawn=True
     InitialVelocity=(X=378.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=32.000000
     EndDrawScale=0.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.000000
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
