class TurretMounts expands InfoActor
	abstract;

var() int	MinShotDamage;
var() float TimeBetweenShots;
var() float TraceDistance;

simulated function int GetHitDamage(actor Victim, name BoneName)
{
	return MinShotDamage;
}

defaultproperties
{
	HitPackageLevelClass=class'HitPackage_DukeLevel'
}
