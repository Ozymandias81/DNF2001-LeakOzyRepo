class EDF_Captain_Player extends DukePlayer;

var		int		NumM16Clips;
var		int		NumGrenades;
var		int		NumPistolClips;
var		int		NumHypos;
var		int		NumShotgunRounds;

function AddDefaultInventory()
{	
	local Inventory			Inv;
	local Weapon			Weap;
	local Inventory			InventoryItem;
	local class<Weapon>		WeaponClass;
	local class<Inventory>	InvClass;

	// HypoGun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Hypogun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumHypos;

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
		Weap.AmmoType.ModeAmount[0]		= Weap.ReloadCount * NumM16Clips;		
		Weap.AltAmmoType.ModeAmount[0]	= NumGrenades;
	}

	// Shotgun.
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Shotgun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = NumShotgunRounds;
	}

	// Heat Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_HeatVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Night Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Zoom Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_ZoomMode", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Riot Shield
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.RiotShield", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
		InventoryItem.Activate();
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
	NumM16Clips=15
	NumGrenades=10
	NumHypos=4
	NumShotgunRounds=40
	
	Health=150
	MaxHealth=150
	GroundSpeed=+00300.000000
	MyClassName="EDF Captain"
}
