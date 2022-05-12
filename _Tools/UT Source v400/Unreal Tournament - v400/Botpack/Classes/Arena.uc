//=============================================================================
// Arena.
// replaces all weapons and ammo with Pulseguns and pulsegun ammo
//=============================================================================

class Arena expands Mutator
	abstract;

var name WeaponName, AmmoName;
var string WeaponString, AmmoString;


function AddMutator(Mutator M)
{
	if ( M.IsA('Arena') )
	{
		log(M$" not allowed (already have an Arena mutator)");
		return; //only allow one arena mutator
	}
	Super.AddMutator(M);
}

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;

	if ( Other.IsA(WeaponName) )
	{
		Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.Default.MaxAmmo;
		return true;
	}
	if ( Other.IsA(AmmoName) )
	{
		Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
		return true;
	}

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('Weapon') )
	{
		if (WeaponString == "")
			return false;
		else if ((WeaponString != "") && !Other.IsA(WeaponName))
		{
			Level.Game.bCoopWeaponMode = false;
			ReplaceWith(Other, WeaponString);
			return false;
		}
	}

	if ( Other.IsA('Ammo') )
	{
		if (AmmoString == "")
			return false;
		else if ((AmmoString != "") && !Other.IsA(AmmoName))
		{
			ReplaceWith(Other, AmmoString);
			return false;
		}
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}