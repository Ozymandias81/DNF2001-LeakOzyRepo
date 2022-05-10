//=============================================================================
// dnCannonBall_Projectile.
//=============================================================================
class dnCannonBall_Projectile expands dnRocket;

//ab

defaultproperties
{
     TrailClass=None
     DestroyOnWaterTouch=True
     SpawnOnWaterTouch(0)=Class'dnParticles.dnWater1_Splash'
     SpawnOnWaterTouch(1)=Class'dnParticles.dnWater1_Spray'
     speed=600.000000
     MaxSpeed=1000.000000
     MomentumTransfer=50000
     Velocity=(X=700.000000,Y=700.000000,Z=1000.000000)
     Physics=PHYS_Falling
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
     Mesh=DukeMesh'c_zone1_vegas.ps_cannonball'
     AmbientGlow=64
}
