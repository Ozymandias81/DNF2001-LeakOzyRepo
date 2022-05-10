//=============================================================================
// TriggerPlayer
// A trigger that is used to control some aspects of the player
//=============================================================================
class TriggerPlayer extends Triggers;
 
enum ETriggerPlayerType
{
    NoChange,
    On,
    Off,
    Toggle
};

enum EHandAnimateType
{
	NoAnimation,
	BringUpWeapon,
	PressButton,
	DropCoin,
	SlapButton
};

enum ECashModifyType
{
	NoChange,
	GiveCash,
	TakeCash
};

var () ETriggerPlayerType	TakeDamage;
var () ETriggerPlayerType	TakeMomentum;
var () ETriggerPlayerType	InfiniteAmmo;
var () ETriggerPlayerType	WeaponsUseable;
var () EHandAnimateType		HandAnimation;

var () struct SModifyCash
{
	var () int						CashAmount;		// BIG CASH PRIZES!!!!
	var () name					CashFailEvent;	// BIGGISH CASH EVENTS!!!!
	var () name					CashSuccessEvent;	// BIGGER CASH EVENTS!!!!
	var () ECashModifyType		CashModification;	// BIGGEST MCKENNA CASH MODIFICATION! Wait, that doesn't make sense.
} ModifyCash;

var () class<Inventory>		GiveItemClass;

function EnableWeapons( DukePlayer C )
{
	C.WeaponUp( true );
}

function DisableWeapons( DukePlayer C )
{
	C.WeaponDown( true );
}

function Trigger( actor Other, Pawn Instigator )
{
    local DukePlayer C;
	local Inventory InventoryItem;

    Super.Trigger( Other, Instigator );

	foreach AllActors( class'DukePlayer', C )
	{
		switch ( HandAnimation )
		{
		case BringUpWeapon:
			C.Hand_WeaponUp();
			break;
		case PressButton:
			C.Hand_QuickAnim('HitButton_Activate','HitButton_Deactivate',0.3);
			break;
		case DropCoin:
			C.Hand_QuickAnim('DropCoin_Start','DropCoin',0.6);
			break;
		case SlapButton:
			C.Hand_QuickAnim('SlapButton',,0.6);
			break;
		default:
			break;
		}

		switch (ModifyCash.CashModification)
		{
		case GiveCash:
			C.AddCash(ModifyCash.CashAmount);
			GlobalTrigger(ModifyCash.CashSuccessEvent);
			break;
		case TakeCash:
			if (C.Cash < ModifyCash.CashAmount)
			{
				BroadcastMessage("I don't have enough money.");
				GlobalTrigger(ModifyCash.CashFailEvent);
			}
			else
			{
				C.Hand_QuickAnim('Tip_Start','Tip',0.6);
				C.AddCash(-ModifyCash.CashAmount);
				GlobalTrigger(ModifyCash.CashSuccessEvent);
			}
			break;
		default:
			break;
		}

		switch( WeaponsUseable )
		{
		case On:
			EnableWeapons( C );
			break;
		case Off:
			DisableWeapons( C);
			break;
		case Toggle:
			if ( C.bWeaponsActive )
				DisableWeapons( C );
			else
				EnableWeapons( C );
			break;
		default:
			break;
		}

		switch( TakeDamage )
		{
		case On:
			C.bTakeDamage = true;
			break;
		case Off:
			C.bTakeDamage = false;
			break;
		case Toggle:
			C.bTakeDamage = !C.bTakeDamage;
			break;
		default:
			break;
		}
    
		switch( TakeMomentum )
		{
		case On:
			C.bTakeMomentum = true;
			break;
		case Off:
			C.bTakeMomentum = false;
			break;
		case Toggle:
			C.bTakeMomentum = !C.bTakeMomentum;
			break;
		default:
			break;
		}

		switch( InfiniteAmmo )
		{
		case On:
			C.bInfiniteAmmo = true;
			break;
		case Off:
			C.binfiniteAmmo = false;
			break;
		case Toggle:
			C.bInfiniteAmmo = !C.bInfiniteAmmo;
			break;
		default:
			break;
		}

		if ( GiveItemClass != None )
		{
			InventoryItem = C.FindInventoryType( GiveItemClass );
			if ( InventoryItem == None )
			{
				InventoryItem = spawn( GiveItemClass );
				InventoryItem.GiveTo( C );
			}
		}
	}
}

defaultproperties
{
}