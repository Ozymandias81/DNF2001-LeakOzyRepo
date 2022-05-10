class EDF_Soldier_Player extends DukePlayer;

var		int		NumM16Clips;
var		int		NumGrenades;
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

	// M16
	WeaponClass = class<Weapon>( DynamicLoadObject( "dnGame.M16", class'Class' ) );
	Level.Game.GiveWeaponTo( self, class'M16' );	
	Weap = Weapon( FindInventoryType( WeaponClass ) );
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0]	    = Weap.ReloadCount * NumM16Clips;		
		Weap.AltAmmoType.ModeAmount[0]	= NumGrenades;
	}

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
	Mesh=DukeMesh'c_characters.EDF6'
	MultiSkins(0)=Texture'm_characters.EDFsldrface2RC'
	MultiSkins(1)=Texture'm_characters.EDF2bodyRC'
	MultiSkins(2)=Texture'm_characters.EDF2pantsRC'
	MultiSkins(3)=None

	NumPistolClips=10
	NumM16Clips=10
	NumGrenades=10
	NumHypos=2
	
	Health=100
	GroundSpeed=+00300.000000
	MyClassName="EDF Soldier"
}
