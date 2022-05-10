class EDF_Sapper_Player extends DukePlayer;

var		int		NumMultiBombs;
var		int		NumTripMines;
var		int		NumPistolClips;
var		int		NumHypos;

function AddDefaultInventory()
{	
	local Inventory			Inv;
	local Weapon			Weap;
	local Inventory			InventoryItem;
	local class<Weapon>		WeaponClass;
	local class<Inventory>	InvClass;

	// Pistol
	WeaponClass = class<Weapon>( DynamicLoadObject( "dnGame.Pistol", class'Class' ) );
	Level.Game.GiveWeaponTo( self, class'Pistol' );	
	Weap = Weapon( FindInventoryType( WeaponClass ) );
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0]	= Weap.ReloadCount * NumPistolClips;

	// MultiBomb
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.MultiBomb", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumMultiBombs;

	// TripMine
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.TripMine", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumTripMines;

	// HypoGun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Hypogun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumHypos;

	// Night Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}
}

defaultproperties
{
	Mesh=c_characters.EDF_Sapper
	MultiSkins(0)=None
	MultiSkins(1)=None
	MultiSkins(2)=None
	MultiSkins(3)=None

	NumMultiBombs=30
	NumTripMines=30
	NumPistolClips=6
	NumHypos=2

	GroundSpeed=+00300.000000
	Health=100
	MyClassName="EDF Sapper"
}
