/*-----------------------------------------------------------------------------
	TripMineAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class TripMineAmmo extends Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

function bool UseAmmo(int AmountNeeded)
{
	ModeAmount[0] -= AmountNeeded;
	return true;
}

simulated function int GetModeAmount(int Mode)
{
	return ModeAmount[0];
}

function SetModeAmount(int Mode, int Amount)
{
}

simulated function int GetModeAmmo()
{
	return ModeAmount[0];
}

function SetModeAmmo(int Amount)
{
}

simulated function NextAmmoMode()
{
	AmmoMode++;
	if (AmmoMode >= MaxAmmoMode)
		AmmoMode = 0;
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local Inventory Copy;

		if ( bDontPickupOnTouch )
			return;

		// If touched by a pawn, let him pick this up.
		if ( ValidTouch(Other, true) )
		{
			if ( Pawn(Other).FindInventoryType( class'TripMine' ) == None )
			{
				// They don't have a trip mine weapon yet.
				Level.Game.GiveWeaponTo( Pawn(Other), class'TripMine' );
				DisplayPickupEvent( Self, Other );
				SetRespawn();
			}
			else
			{
				// Create a copy.
				Copy = SpawnCopy( Pawn(Other) );

				// Select this item if nothing else is selected.
				if ( bActivatable && Pawn(Other).SelectedItem == None )
					Pawn(Other).SelectedItem = Copy;

				// Announce pickup.
				AnnouncePickup( Pawn(Other) );

				// Perform special pickup behavior.
				Copy.PickupFunction( Pawn(Other) );
			}
		}
		else if ( bTossedOut && (Other.Class == Class) && Inventory(Other).bTossedOut )
			Destroy();
	}

	// If item is used.
	function Used( Actor Other, Pawn EventInstigator )
	{
		local Inventory Copy;

		if ( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			if ( Pawn(Other).FindInventoryType( class'TripMine' ) == None )
			{
				// They don't have a trip mine weapon yet.
				Level.Game.GiveWeaponTo( Pawn(Other), class'TripMine' );
				DisplayPickupEvent( Self, Other );
				SetRespawn();
			}
			else
			{
				// Create a copy.
				Copy = SpawnCopy( Pawn(Other) );

				// Select this item if nothing else is selected.
				if (bActivatable && Pawn(Other).SelectedItem == None) 
					Pawn(Other).SelectedItem = Copy;

				// Announce pickup.
				AnnouncePickup( Pawn(Other) );

				// Perform special pickup behavior.
				Copy.PickupFunction( Pawn(Other) );
			}
		}
	}
}

defaultproperties
{
	 MaxAmmoMode=3
	 ModeAmount(0)=1
     MaxAmmo(0)=30
     PickupViewMesh=Mesh'c_dnWeapon.p_tripmine'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
	 PickupIcon=texture'hud_effects.am_tripmine'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.p_tripmine'
     bMeshCurvy=false
     CollisionHeight=3.000000
     CollisionRadius=12.0
     bCollideActors=true
	 ItemName="Trip Mine"
	 AnimSequence=close
}