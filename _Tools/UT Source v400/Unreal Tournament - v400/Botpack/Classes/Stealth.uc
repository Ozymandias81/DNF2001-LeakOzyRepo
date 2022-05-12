//=============================================================================
// Stealth.
// All players get invisibility
//=============================================================================

class Stealth expands Mutator;

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('UT_Stealth') )
		return true;
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local inventory inv;

	if ( Other.bIsPawn && Pawn(Other).bIsPlayer	)
	{
		inv = Spawn(class'UT_Stealth');
		if( inv != None )
		{
			inv.charge = 9999999999;
			inv.bHeldItem = true;
			inv.RespawnTime = 0.0;
			inv.GiveTo(Pawn(Other));
			inv.Activate();
		}
	}
	if ( Other.IsA('UT_Invisibility') && !Other.IsA('UT_Stealth') )
		return false;

	bSuperRelevant = 0;
	return true;
}

function ModifyPlayer(Pawn Other)
{
	// called by Gameinfo.RestartPlayer()
	local Inventory Inv;

	Inv = Other.FindInventoryType(class'UT_Stealth');
	if ( Inv != None )
		Inv.Charge = 9999999;
	else
	{
		inv = Spawn(class'UT_Stealth');
		if( inv != None )
		{
			inv.charge = 9999999;
			inv.bHeldItem = true;
			inv.RespawnTime = 0.0;
			inv.GiveTo(Other);
			inv.Activate();
		}
	}
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}
