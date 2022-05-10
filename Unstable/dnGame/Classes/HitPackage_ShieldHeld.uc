/*-----------------------------------------------------------------------------
	HitPackage_ShieldHeld
	Author: Brandon Reinhart

	Used when the shot hits a glass shield.
-----------------------------------------------------------------------------*/
class HitPackage_ShieldHeld extends HitPackage;

simulated function Deliver()
{
    local int i;
	local texture tex;
	local MeshDecal a;
	local float size;

	// Call base behavior.
	Super.Deliver();

	// Only perform behavior on the right kind of system.
	if ( Level.NetMode == NM_DedicatedServer)
		return;

	spawn( class'dnBulletFX_GlassSpawner' );
}

defaultproperties
{
	bNoBloodHit=true
}