/*-----------------------------------------------------------------------------
	MultiBombAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class MultiBombAmmo extends Ammo;

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
			if ( Pawn(Other).FindInventoryType( class'MultiBomb' ) == None )
			{
				// They don't have a trip mine weapon yet.
				Level.Game.GiveWeaponTo( Pawn(Other), class'MultiBomb' );
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
		// Don't allow inventory to pile up (frame rate hit).
		else if ( (Inventory != None) && Other.IsA('Inventory') && (Inventory(Other).Inventory != None) )
			Destroy();
	}

	// If item is used.
	function Used( Actor Other, Pawn EventInstigator )
	{
		local Inventory Copy;

		if (Level.Game.PickupQuery(Pawn(Other), self))
		{
			if ( Pawn(Other).FindInventoryType( class'MultiBomb' ) == None )
			{
				// They don't have a trip mine weapon yet.
				Level.Game.GiveWeaponTo( Pawn(Other), class'MultiBomb' );
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
	 MaxAmmoMode=2
	 ModeAmount(0)=1
     MaxAmmo(0)=30
     PickupViewMesh=Mesh'c_dnWeapon.w_multipipe'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
	 PickupIcon=texture'hud_effects.am_multibomb'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.w_multipipe'
     bMeshCurvy=false
     CollisionHeight=3.0
	 CollisionRadius=12.0
     bCollideActors=true
	 ItemName="Multi Bomb"
	 bMeshLowerByCollision=false
}