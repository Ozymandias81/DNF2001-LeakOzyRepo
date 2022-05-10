/*-----------------------------------------------------------------------------
	MedKit
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class MedKit expands Inventory;

#exec AUDIO IMPORT FILE=Sounds\ahh04.wav NAME=medHeal 
#exec AUDIO IMPORT FILE=Sounds\ahmuch03.wav NAME=medMegaHeal 

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Textures\m_dukeitems.dtx
#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx

var() sound Heal;
var() sound MegaHeal;

simulated function DrawChargeAmount( Canvas C, HUD HUD, float X, float Y )
{
	local int i, YPos;
	local float ChargeScale;

	YPos = 51;
	ChargeScale = float(Charge) / float(MaxCharge);
	DrawAmmoBar( C, HUD, ChargeScale, X+4*HUD.HUDScaleX*0.8, Y+YPos*HUD.HUDScaleY*0.8 );
}

function bool HandlePickupQuery( inventory Item )
{
	// Is this a medkit?
	if ( (Item.class == class) || ClassIsChildOf(Item.class, class) )
	{
		// Don't pick up the other medkit if we have full health.
		if ( Charge == 100 )
			return true;

		// Display a pickup event.
		DisplayPickupEvent( Item, Owner );

		// Refresh our health.
		Charge = 100;

		// Set the respawn state.
		Item.SetRespawn();
		return true;
	}

	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

simulated function Activate()
{
	local int HealAmount;
	
	// Can't use the med kit if you have full health.
	if ( Pawn(Owner).Health >= 100 )
		return;
	
	// Figure out how much to heal.
	HealAmount = 100 - Pawn(Owner).Health;
	if (HealAmount > Charge)
		HealAmount = Charge;
	
	// Apply the results.
	if ( Role == ROLE_Authority )
	{
		Pawn(Owner).Health += HealAmount;
		Charge -= HealAmount;
	}
	
	// Play a sound.
	if ( HealAmount > 33 )
		Pawn(Owner).PlayOwnedSound( MegaHeal, , 1.0, false, 800, , true );
	else
		Pawn(Owner).PlayOwnedSound( Heal, , 1.0, false, 800, , true );

	// Check to see if we are used up.
	if ( (Role == ROLE_Authority) && (Charge <= 0) )
	{
		UsedUp();
		return;
	}
}

simulated function PlayInventoryActivate( PlayerPawn Other )
{
	if ( Other.Health >= 100 )
		return;
	else
		Super.PlayInventoryActivate( Other );
}

defaultproperties
{
	bCanActivateWhileHandUp=true
	ItemName="Med Kit"
	PickupIcon=texture'hud_effects.am_medkit'
    Icon=Texture'hud_effects.mitem_medkit'
	PickupSound=Sound'dnGame.Pickups.AmmoSnd'

     Heal=Sound'dnGame.medHeal'
     MegaHeal=Sound'dnGame.medMegaHeal'
     dnInventoryCategory=5
	 dnCategoryPriority=0
     bActivatable=true
     RespawnTime=40.0
     PickupViewMesh=Mesh'c_dukeitems.MedKit'
     Charge=100
     MaxCharge=100
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'c_dukeitems.MedKit'
     CollisionRadius=12.0
     CollisionHeight=8.0
}
