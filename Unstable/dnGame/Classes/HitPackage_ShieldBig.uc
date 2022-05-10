/*-----------------------------------------------------------------------------
	HitPackage_ShieldBig
	Author: Brandon Reinhart

	Used when the shot hits a glass shield and penetrates it.
-----------------------------------------------------------------------------*/
class HitPackage_ShieldBig extends HitPackage;

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

	// Spawn a glass decal where we hit.
	a = spawn(class'MeshDecal');
	if (a != None)
	{
		tex = Texture'm_dnweapon.bulletholes.bhole_glass1aRC';
		if (a != None)
		{
			size = 8.0+(FRand()*5.0-2.5);
			a.BuildDecal(Owner,tex,HitMeshTri,HitMeshBarys,FRand()*2.0*PI,size,size);
			a.DecalAttachToActor(Owner);
			a.LifeSpan=45;
		}
	}
}