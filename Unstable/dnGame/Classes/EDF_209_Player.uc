class EDF_209_Player extends DukePlayer;

var		int		NumRockets;
var		int		NumNukes;

function AddDefaultInventory()
{	
	local Inventory			Inv;
	local Weapon			Weap;
	local Inventory			InventoryItem;
	local class<Weapon>		WeaponClass;
	local class<Inventory>	InvClass;

	// RPG
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.RPG", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = NumRockets;
		Weap.AmmoType.ModeAmount[1] = NumNukes;
	}

	// Night Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Zoom 
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_ZoomMode", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

}

defaultproperties
{
	Mesh=c_characters.EDF_HeavyWeps
	MultiSkins(0)=None
	MultiSkins(1)=None
	MultiSkins(2)=None
	MultiSkins(3)=None

	NumRockets=15
	NumNukes=1
	
	Health=350
	MaxHealth=350
	GroundSpeed=+00250.000000
	MyClassName="EDF 209"
}
