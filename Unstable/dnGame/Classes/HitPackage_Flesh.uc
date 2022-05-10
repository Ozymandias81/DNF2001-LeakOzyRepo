/*-----------------------------------------------------------------------------
	HitPackage_Flesh
	Author: Brandon Reinhart

	Used when the shot hits flesh.
-----------------------------------------------------------------------------*/
class HitPackage_Flesh extends HitPackage;

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
			case 0: tex = Texture'm_dnweapon.weapon_efx.char_blood2BC';  break;
			case 1: tex = Texture'm_dnweapon.weapon_efx.char_blood3BC';  break;
			case 2: tex = Texture'm_dnweapon.weapon_efx.char_blood4BC';  break;
			case 3: tex = Texture'm_dnweapon.weapon_efx.char_blood5BC';  break;
			case 4: tex = Texture'm_dnweapon.weapon_efx.char_blood6BC';  break;
			case 5: tex = Texture'm_dnweapon.weapon_efx.char_blood10BC'; break;
			case 6: tex = Texture'm_dnweapon.weapon_efx.char_blood11BC'; break;
			case 7: tex = Texture'm_dnweapon.weapon_efx.char_blood7BC';  break;
			case 8: tex = Texture'm_dnweapon.weapon_efx.char_blood8BC';  break;
			case 9: tex = Texture'm_dnweapon.weapon_efx.char_blood9BC';  break;
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