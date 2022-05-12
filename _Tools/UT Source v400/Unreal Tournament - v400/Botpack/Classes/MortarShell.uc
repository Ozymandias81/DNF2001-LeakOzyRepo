//=============================================================================
// MortarShell.
//=============================================================================
class MortarShell extends UTFlakShell;

var() int BlastRadius;

function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
	local FlameExplosion F;

	HurtRadius(damage, BlastRadius, 'mortared', MomentumTransfer, HitLocation);	
	start = Location + 10 * HitNormal;
	F = Spawn( class'FlameExplosion',,,Start);
	Spawn(class'Botpack.BlastMark',self,,Location, rotator(HitNormal));
	if ( F != None )
		F.DrawScale *= 2.5;
	Destroy();
}

defaultproperties
{
	 Damage=70.0
     MomentumTransfer=150000
	 BlastRadius=150;
}