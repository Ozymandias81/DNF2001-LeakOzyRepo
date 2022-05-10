//=============================================================================
// TriggerDnProjectileSpawn.
//=============================================================================
class TriggerDnProjectileSpawn expands TriggerSpawn;

var () vector TargetVariance;
function actor DoSpawn()
{
	local actor a;
	local dnProjectile p;
	a=super.DoSpawn();
	if(a==none) return none;
	p=dnProjectile(a);

	p.TargetOffset.X=Rand(TargetVariance.X)-TargetVariance.X/2;
	p.TargetOffset.Y=Rand(TargetVariance.Y)-TargetVariance.Y/2;
	p.TargetOffset.Z=Rand(TargetVariance.Z)-TargetVariance.Z/2;
	// Specific TriggerDnProjectileSpawn.

	return a;
}