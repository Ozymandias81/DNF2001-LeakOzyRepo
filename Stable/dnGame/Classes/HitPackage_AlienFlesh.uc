/*-----------------------------------------------------------------------------
	HitPackage_Flesh
	Author: Brandon Reinhart

	Used when the shot hits flesh.
-----------------------------------------------------------------------------*/
class HitPackage_AlienFlesh extends HitPackage;

simulated function Deliver()
{
    local int i;
	local texture tex;
	local MeshDecal a;
	local float size;

	// Only perform behavior on the right kind of system.
	if ( Level.NetMode == NM_DedicatedServer)
		return;

	// Call base behavior.
	Super.Deliver();

	// Spawn a blood decal where we hit.
	if ( HitMeshTri != 0 )
		a = spawn(class'MeshDecal');
	if (a != None)
	{
		tex = None;
		i = Rand(10);
		switch(i)
		{
			case 0: tex = Texture't_generic.alienblood1rc';  break;
			case 1: tex = Texture't_generic.alienblood3rc';  break;
			case 2: tex = Texture't_generic.alienblood1rc';  break;
			case 3: tex = Texture't_generic.alienblood8rc';  break;
			case 4: tex = Texture't_generic.alienblood1rc';  break;
			case 5: tex = Texture't_generic.alienblood3rc';  break;
			case 6: tex = Texture't_generic.alienblood1rc';  break;
			case 7: tex = Texture't_generic.alienblood8rc';  break;
			case 8: tex = Texture't_generic.alienblood1rc';  break;
			case 8: tex = Texture't_generic.alienblood3rc';  break;
			default: break;
		}
		size = 5.0+(FRand()*5.0-2.5);
		
		if (i<=6)
			a.BuildDecal(Owner, tex, HitMeshTri, HitMeshBarys, FRand()*2.0*PI, size, size);
		else
			a.BuildDecalGrowable(Owner, tex, HitMeshTri, HitMeshBarys, FRand()*2.0*PI, size, size, 5.0, 0.5);
		a.DecalAttachToActor(Owner);
	}
}

defaultproperties
{
}