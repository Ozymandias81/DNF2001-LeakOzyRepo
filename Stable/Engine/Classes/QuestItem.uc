/*-----------------------------------------------------------------------------
	QuestItem
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class QuestItem extends Inventory
	abstract;

var bool bRaising, bFastActivate;
var() name PickupEvent;

function Activate()
{
	if ( Owner.IsA('PlayerPawn') )
	{
		PlayerPawn(Owner).WeaponDown();
		Super.Activate();
	}
}

state Activated
{
	function BeginState()
	{
		bRaising = true;
		PlayerViewOffset.Z = default.PlayerViewOffset.Z - 100;
		PlayerPawn(Owner).UsedItem = Self;
		Enable( 'Tick' );
	}

	function EndState()
	{
		Disable( 'Tick' );
	}

	function Tick(float Delta)
	{
		if ( bRaising )
		{
			PlayerViewOffset.Z += 600*Delta;
			if ( PlayerViewOffset.Z > default.PlayerViewOffset.Z )
			{
				bRaising = false;
				PlayerViewOffset.Z = default.PlayerViewOffset.Z;
				Disable( 'Tick' );
			}
		}
	}
}

state Deactivated
{
	function BeginState()
	{
		if ( bFastActivate )
		{
			bFastActivate = false;
			PlayerPawn(Owner).UsedItem = None;
		}
		else 
		{
			Enable( 'Tick' );
			bRaising = true;
		}
	}

	function EndState()
	{
		Disable( 'Tick' );
	}

	function Tick( float Delta )
	{
		if ( bRaising )
		{
			PlayerViewOffset.Z -= 600*Delta;
			if ( PlayerViewOffset.Z < default.PlayerViewOffset.Z - 100 )
			{
				Disable('Tick');
				bRaising = false;
				PlayerPawn(Owner).UsedItem = None;
				PlayerPawn(Owner).WeaponUp();
			}
		}
	}
}

function bool HandlePickupQuery( inventory Item )
{
	// You can't carry two QuestItems of the same priority.
	if ( Item.IsA('QuestItem') && (Item.dnCategoryPriority == dnCategoryPriority) )
		return true;
	else
		return Super.HandlePickupQuery( Item );
}

simulated function DisplayPickupEvent( Inventory Inv, Actor ByOwner )
{
	local Actor A;

	if ( PickupEvent != '' )
	{
		foreach AllActors( class 'Actor', A, PickupEvent )
			A.Trigger( Self, None );
	}

	Super.DisplayPickupEvent( Inv, ByOwner );
}

static simulated function bool CanPickup( Pawn Other, class<Inventory> InvClass, Inventory Inv )
{
	for ( Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if ( Inv.IsA('QuestItem') && (Inv.dnCategoryPriority == InvClass.default.dnCategoryPriority) )
			return false;
	}

	return true;
}

defaultproperties
{
	dnInventoryCategory=6
	dnCategoryPriority=0
}