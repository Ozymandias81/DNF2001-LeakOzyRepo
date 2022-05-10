//=============================================================================
// dnExplosion1. 						Created by Keith Schuler April 12, 2000
//=============================================================================
class dnExplosion1 expands SoftParticleSystem;

// Explosion effect class.
// Does damage. 
// Uses dnExplosion1_Effect1, dnExplosion1_Effect2, dnExplosion1_Effect3.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect1')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect2')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnDebris_Sparks1')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnExplosion1_PostSmoke')
	 AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnDecal_BlastMark')
     CreationSound=Sound'a_impact.explosions.Expl118'
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=10.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
	 SpriteProjForward=32.0
}
