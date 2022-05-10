class BUG_Octabrain_Player extends DukePlayer;

var int	NumBlasts;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetPlayerSpeed( 0.5 );
}

function AddDefaultInventory()
{	
	local Inventory			Inv;
	local Weapon			Weap;
	local Inventory			InventoryItem;
	local class<Weapon>		WeaponClass;
	local class<Inventory>	InvClass;

	// Octablaster
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.OctaBlaster", class'Class' ) );
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon( FindInventoryType( WeaponClass ) );
	if ( Weap != None )
	{
		Weap.AmmoType.ModeAmount[0] = NumBlasts;
	}

	// Night Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ) );
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}
}

function StartWalk()
{
	Super.StartWalk();	
	SetPhysics( PHYS_Flying );	
}

function ClientRestart()
{
	Super.ClientRestart();

	// OctaPlayer is flying!
	SetControlState( CS_Flying );
}

function PlayTurning( float Yaw )
{
	// No turning anim needed
}

function PlayUpdateRotation( int Yaw )
{
	// No turning anim needed
}

function PlayFlying()
{
	PlayAllAnim( 'RUN_F',,0.1,true );
}

function PlayWaiting()
{
	if ( FRand() > 0.5 )
		PlayAllAnim( 'IDLEA',,0.1,true );
	else
		PlayAllAnim( 'IDLEB',,0.1,true );
}

function PlayToWaiting( float TweenTime )
{
	if ( FRand() > 0.5 )
		PlayAllAnim( 'IDLEA',,TweenTime,true );
	else
		PlayAllAnim( 'IDLEB',,TweenTime,true );
}

function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	PlayAllAnim( 'DeathA',,0.1, false );
}

function WpnPlayActivate()
{
}

defaultproperties
{
	Mesh=c_characters.Octobrain
	MultiSkins(0)=None
	MultiSkins(1)=None
	MultiSkins(2)=None
	MultiSkins(3)=None

	ImmolationClass="dnGame.dnPawnImmolation_Octabrain"
	bCanFly=true
    CollisionHeight=51.000000
	CollisionRadius=32.000000
	PelvisRotationScale=-0.5
	AbdomenRotationScale=-0.2
	ChestRotationScale=-0.5

	NumBlasts=30
	Health=350
	MaxHealth=350
	GroundSpeed=+00175.000000
	MyClassName="BUG Octabrain"
}