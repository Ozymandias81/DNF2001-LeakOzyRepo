/*-----------------------------------------------------------------------------
	HitPackage_Steel
	Author: Brandon Reinhart

	Used when the shot hits a steel character.
-----------------------------------------------------------------------------*/
class HitPackage_Steel extends HitPackage;

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

	// Spawn a metal decal where we hit.
	a = spawn(class'MeshDecal');
	if (a != None)
	{
		tex = Texture'm_dnweapon.bulletholes.bhole_mtl1bRC';
		size = 2.0+(FRand()*5.0-2.5);
		
		if (i<=6)
			a.BuildDecal(Owner, tex, HitMeshTri, HitMeshBarys, FRand()*2.0*PI, size, size);
		else
			a.BuildDecalGrowable(Owner, tex, HitMeshTri, HitMeshBarys, FRand()*2.0*PI, size, size, 5.0, 0.5);
		a.DecalAttachToActor(Owner);
	}
}