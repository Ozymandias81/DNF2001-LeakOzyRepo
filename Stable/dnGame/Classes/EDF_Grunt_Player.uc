class EDF_Grunt_Player extends DukePlayer;

var		int		NumM16Clips;
var		int		NumPistolClips;
var		int		NumHypos;

function AddDefaultInventory()
{	
	local class<Weapon> WeaponClass;
	local Weapon		Weap;

	// HypoGun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Hypogun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = NumHypos;

	// M16
	WeaponClass = class<Weapon>( DynamicLoadObject( "dnGame.M16", class'Class' ) );
	Level.Game.GiveWeaponTo( self, class'M16' );	
	Weap = Weapon( FindInventoryType( WeaponClass ) );	
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0]	= Weap.ReloadCount * NumM16Clips;		

	// Pistol
	WeaponClass = class<Weapon>( DynamicLoadObject( "dnGame.Pistol", class'Class' ) );
	Level.Game.GiveWeaponTo( self, class'Pistol' );	
	Weap = Weapon( FindInventoryType( WeaponClass ) );	
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0]	= Weap.ReloadCount * NumPistolClips;
}

defaultproperties
{
	Mesh=DukeMesh'c_characters.EDF1'
	MultiSkins(0)=Texture'm_characters.EDFsldrface3RC'
	MultiSkins(1)=Texture'm_characters.EDF1bodyRC'
	MultiSkins(2)=Texture'm_characters.EDF1pantsRC'
	MultiSkins(3)=Texture'm_characters.EDF1partsRC'	

	NumM16Clips=3
	NumPistolClips=10
	NumHypos=1

	GroundSpeed=+00300.000000
	Health=80
	MaxHealth=80
	MyClassName="EDF Grunt"
}
