/*-----------------------------------------------------------------------------
	dnNuke
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnNuke extends dnRocket;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

simulated function Destroyed()
{
	Super.Destroyed();

	spawn( class'ShockWave' );
}

simulated function Explode( vector HitLocation, optional vector HitNormal, optional bool bNoDestroy )
{
	local actor s, HitActor;
	local vector SpawnLoc, TraceHitLoc, TraceHitNorm;
	local float adjustz;

//	SpawnLoc = HitLocation + HitNormal*128;
//	HitActor = Trace( TraceHitLoc, TraceHitNorm, SpawnLoc + vect(0,0,-128), SpawnLoc, false );
//	if ( HitActor == Level )
//		adjustz = 128.0 - (Location.Z - TraceHitLoc.Z);
//	SpawnLoc.Z += adjustz;
	s = spawn( ExplosionClass, Instigator,, /*SpawnLoc*/HitLocation );
 	s.RemoteRole = ROLE_None;

 	Destroy();
}

defaultproperties
{
     TrailClass=Class'dnParticles.dnRocketFX_BlueBurn'
     TrailMountOrigin=(X=-18.000000,Y=6.000000)
     AdditionalMountedActors(0)=(ActorClass=Class'dnGame.dnWeaponFX_NukeFire',MountOrigin=(X=-18.000000,Y=6.000000,Z=-8.000000))
     ExplosionClass=Class'dnGame.dnWeaponFX_NukeSphere'
     speed=700.000000
     MaxSpeed=1200.000000
     bFixedRotationDir=True
     RotationRate=(Roll=131070)
     Mesh=DukeMesh'c_dnWeapon.rpg_rocketNUKE'
}
