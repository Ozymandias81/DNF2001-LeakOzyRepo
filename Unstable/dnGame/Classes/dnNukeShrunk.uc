/*-----------------------------------------------------------------------------
	dnNukeShrunk
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnNukeShrunk extends dnNuke;

simulated function Destroyed()
{
	Super(dnRocket).Destroyed();

	DoDamage( Location );
}

simulated function Explode( vector HitLocation, optional vector HitNormal, optional bool bNoDestroy )
{
	local actor s, HitActor;
	local vector SpawnLoc, TraceHitLoc, TraceHitNorm;
	local float adjustz;

	SpawnLoc = HitLocation + HitNormal*64;
	HitActor = Trace( TraceHitLoc, TraceHitNorm, SpawnLoc + vect(0,0,-32), SpawnLoc, false );
	if ( HitActor == Level )
		adjustz = 32.0 - (Location.Z - TraceHitLoc.Z);
	SpawnLoc.Z += adjustz;
	s = spawn( ExplosionClass, Instigator,, SpawnLoc );

 	s.RemoteRole = ROLE_None;

 	Destroy();
}

defaultproperties
{
	Damage=80.0
	DamageRadius=220.0
	DamageClass=class'CrushingDamage'
	DrawScale=0.35
	ExplosionClass=Class'dnGame.dnWeaponFX_NukeSphere_Shrunk'
}