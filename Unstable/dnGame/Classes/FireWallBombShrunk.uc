/*-----------------------------------------------------------------------------
	FireWallBombShrunk
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FireWallBombShrunk extends FireWallBomb;

simulated function SpawnDecals()
{
	local FireWallStarterScorch fwss;
	local vector X, Y, Z;

	GetAxes( Rotation, X, Y, Z );
	fwss = spawn( class'FireWallStarterScorch', Self,,Location-Y*32,rot(16384,0,0) );
	fwss.DrawScale = 0.25;
	fwss.DecalRotation.Pitch = 0;
	fwss.DecalRotation.Yaw = Rotation.Yaw + 40000 - 32768;
	fwss.DecalRotation.Roll = 0;
	fwss.Initialize();

	fwss = spawn( class'FireWallStarterScorch', Self,,Location+Y*32,rot(16384,0,0) );
	fwss.DrawScale = 0.25;
	fwss.DecalRotation.Pitch = 0;
	fwss.DecalRotation.Yaw = Rotation.Yaw + 40000;
	fwss.DecalRotation.Roll = 0;
	fwss.Initialize();
}

defaultproperties
{
	FlameClass=class'dnParticles.dnFlameThrowerFX_Shrunk_BallFire'
	FireWallStarterClass=class'FireWallStarterShrunk'
	FireWallCruiserClass=class'FireWallCruiserShrunk'
	SoundVolume=150
	SoundRadius=28
	SoundPitch=80
}