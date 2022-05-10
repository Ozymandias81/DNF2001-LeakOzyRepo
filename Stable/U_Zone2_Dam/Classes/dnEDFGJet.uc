//=============================================================================
// dnEDFGJet.
//=============================================================================
class dnEDFGJet expands dnVehicles;

defaultproperties
{
     DelayedDamageTime=0.250000
     DelayedDamageAmount=1000
     FragType(0)=None
     FragBaseScale=0.125000
     DamageOnHitWall=1000
     DamageOnHitWater=1000
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Zone2_Dam.dnDroneJet_BaseGib2',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(1)=(SpawnClass=Class'U_Zone2_Dam.dnDroneJet_LodgeGib2',RotationVariance=(Pitch=16384,Yaw=180,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(2)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect2',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_lrtor',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(3)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect2',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_rrtor',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(4)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect2',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_rwing',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(5)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect2',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_wingw',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=180.000000,Y=180.000000))
     SpawnOnDestroyed(6)=(SpawnClass=Class'dnParticles.dnEDFGameExplosion')
     CollisionRadius=32.000000
     CollisionHeight=7.000000
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_vehicles.drone_jet'
     DrawScale=0.125000
}
