/*-----------------------------------------------------------------------------
	Ammo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Ammo extends Inventory
	abstract;

#exec Texture Import File=Textures\Ammo.pcx Name=S_Ammo Mips=Off Flags=2

// Multimode support.
var          int MaxAmmoMode;
var          int AmmoType;
var   travel int AmmoMode;
var() travel int ModeAmount[4];
var() travel int MaxAmmo[4];
var() class<ammo> ParentAmmo;			// Class of ammo to be represented as in inventory.

// Special damage behavior.
var float ModeDamageMultiplier[4];
var float ModeAccuracyModifier[4];
var int CanPierceArmor[4];

// Network replication
replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner )
		AmmoType, ModeAmount;
}

/*
simulated event PostNetInitial()
{
	Super.PostNetInitial();

	GotoState('Waiting');
}
*/

// Return a float that indicates whether the bot wants this item.
event float BotDesireability(Pawn Bot)
{
	local Ammo AlreadyHas;
	local int i, need;

	if ( ParentAmmo != None )
		AlreadyHas = Ammo(Bot.FindInventoryType(ParentAmmo));
	else
		AlreadyHas = Ammo(Bot.FindInventoryType(Class));
	if ( AlreadyHas == None )
		return (0.35 * MaxDesireability);
	if ( AlreadyHas.OutOfAmmo() )
		return MaxDesireability;
	need = -1;
	for (i=0; i<AlreadyHas.MaxAmmoMode; i++)
	{
		if (AlreadyHas.ModeAmount[i] < AlreadyHas.MaxAmmo[i])
			need = i;
	}
	if (need == -1)
		return need;

	return ( MaxDesireability * FMin(1, 0.15 * MaxAmmo[need]/AlreadyHas.ModeAmount[need]) );
}

// We are being asked if Other can pick us up.
// If one of the weapons can't pick up an ammo, we don't pick it up.
static simulated function bool CanPickup( Pawn Other, class<Inventory> InvClass, Inventory Inv )
{
	for ( Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if ( Inv.IsA('Weapon') && Weapon(Inv).CanPickupAmmo(class<Ammo>(InvClass)) )
			return true;
	}
	return false;
}

// We are being asked to pick up this ammo item.
function bool HandlePickupQuery( inventory Item )
{
	// Is this an ammo item like use?
	if ( (Item.class == class) || ClassIsChildOf(Item.class, class) )
	{
		// We can't pick it up if we are already at max.
		if (ModeAmount[Ammo(Item).AmmoType] == MaxAmmo[Ammo(Item).AmmoType])
			return true;

		// Display a pickup message.
		DisplayPickupEvent( Item, Owner );

		// Add the item's distinctiveness to our own.
		AddAmmo(Ammo(Item).ModeAmount[Ammo(Item).AmmoType], Ammo(Item).AmmoType);

		// Set respawn.
		Item.SetRespawn();
		return true;
	}

	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

// This function is called by an actor that wants to use ammo.  
// Return true if ammo exists.  Remove the amount of ammo from our count.
function bool UseAmmo(int AmountNeeded)
{
	if( PlayerPawn( Owner ) != None )
	{
		if (PlayerPawn(Owner).bInfiniteAmmo)
			return true;

		if (GetModeAmmo() < AmountNeeded)
			return false;
	}	
	ModeAmount[AmmoMode] -= AmountNeeded;

	return true;
}

// If we can, add ammo and return true.  
// We we are at max ammo, return false
function bool AddAmmo( int AmmoToAdd, int ModeToAdd )
{
	if ( ModeAmount[ModeToAdd] >= MaxAmmo[ModeToAdd] )
		return false;

	ModeAmount[ModeToAdd] += AmmoToAdd;

	if ( ModeAmount[ModeToAdd] > MaxAmmo[ModeToAdd] )
		ModeAmount[ModeToAdd] = MaxAmmo[ModeToAdd];

	return true;
}

// Return the current mode's damage multiplier.
simulated function float GetModeDamageMultiplier()
{
	return ModeDamageMultiplier[AmmoMode];
}

// Return the current mode's accuracy modifier.
simulated function float GetModeAccuracyModifier()
{
	return ModeAccuracyModifier[AmmoMode];
}

// Return the appropriate class for a certain mode.
function class<Ammo> GetClassForMode( int Mode )
{
	return Class;
}

// Return if the current mode can pierce armor.
function bool ArmorPiercing()
{
	if (CanPierceArmor[AmmoMode] == 1)
		return true;
	return false;
}

// Return the current mode's ammo amount.
simulated function int GetModeAmmo()
{
	return ModeAmount[AmmoMode];
}

// Set the current mode's ammo amount.
function SetModeAmmo(int Amount)
{
	ModeAmount[AmmoMode] = Amount;
}

// Get the a given mode's ammo amount.
simulated function int GetModeAmount(int Mode)
{
	return ModeAmount[Mode];
}

// Set a given mode's ammo amount.
function SetModeAmount(int Mode, int Amount)
{
	ModeAmount[Mode] = Amount;
}

// Toggle this ammo item to its next ammo mode.
simulated function NextAmmoMode()
{
	local int StartMode;

	StartMode = AmmoMode;

	AmmoMode++;
	while (AmmoMode > 0)
	{
		if (AmmoMode >= MaxAmmoMode)
			AmmoMode = 0;
		if (AmmoMode == StartMode)
			return;
		if (GetModeAmmo() > 0)
			return;
		AmmoMode++;
	}
}

// Is this ammo object out of ammo?
simulated function bool OutOfAmmo()
{
	local int i, j;

	for (i=0; i<MaxAmmoMode; i++)
	{
		if (ModeAmount[i] > 0)
			j++;
	}
	if (j==0)
		return true;
	return false;
}

// Duplicate this ammo object.
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;
	local int i;

	if ( ParentAmmo != None )
	{
		Copy = Spawn( ParentAmmo,Other, , , rot(0,0,0) );

		Copy.Tag           = Tag;
		Copy.Event         = Event;
		Copy.Instigator    = Other;
		Copy.VendOwner	   = VendOwner;

		for (i=0; i<4; i++)
			Ammo(Copy).ModeAmount[i] = ModeAmount[i];

		Copy.BecomeItem();
		Other.AddInventory( Copy );

		Copy.GotoState('');

		if ( Level.Game.ShouldRespawn(self) )
			GotoState('Sleeping');
		else
			Destroy();

		return Copy;
	}

	Copy = Super.SpawnCopy(Other);
	for (i=0; i<4; i++)
		Ammo(Copy).ModeAmount[i] = ModeAmount[i];

	return Copy;
}


defaultproperties
{
    RespawnTime=+00030.000000
    MaxDesireability=+00000.200000
    Texture=Engine.S_Ammo
    bCollideActors=False

	AmmoType=0
	MaxAmmoMode=1
	CanPierceArmor(0)=0
	CanPierceArmor(1)=0
	CanPierceArmor(2)=0
	CanPierceArmor(3)=0
}
