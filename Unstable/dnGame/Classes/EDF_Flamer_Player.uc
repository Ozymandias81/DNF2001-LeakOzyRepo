class EDF_Flamer_Player extends DukePlayer;

var int NumPistolClips;
var int NumHypos;
var int	NumFlamerAmmo;

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

	// Flamer
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Flamethrower", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumFlamerAmmo;

	// HypoGun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Hypogun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumHypos;

	// Heat Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_HeatVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}
}

defaultproperties
{
	GroundSpeed=+00300.000000
	Mesh=c_characters.EDF_Pyro
	MultiSkins(0)=None
	MultiSkins(1)=None
	MultiSkins(2)=None
	MultiSkins(3)=None

	NumPistolClips=6
	NumHypos=2
	NumFlamerAmmo=40
	MyClassName="EDF Flamer"
}
