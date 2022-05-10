/*-----------------------------------------------------------------------------
	dnLaserBeam
	Author: Brandon Reinhart

	dnGame specific LaserBeam created because of package order issues.
-----------------------------------------------------------------------------*/
class dnLaserBeam extends LaserBeam;

defaultproperties
{
	LaserBeamClass=class'dnParticles.dnLaserRifleFX_Laser'
	BeamSmokeClass=class'dnParticles.dnLaserRifleFX_ResidualSmoke'
	LaserHitClass=class'dnParticles.dnLaserHitFX_WallHitSpawnerA'
	LaserFlashClass=class'dnParticles.dnLaserHitFX_FlashSpawnerA'
}
