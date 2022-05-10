/*-----------------------------------------------------------------------------
	Inventory
-----------------------------------------------------------------------------*/
class Inventory extends RenderActor
	abstract
	native
	nativereplication;

#exec Texture Import File=Textures\Inventry.pcx Name=S_Inventory Mips=Off Flags=2



/*-----------------------------------------------------------------------------
	Inventory System
-----------------------------------------------------------------------------*/

var() travel byte				AutoSwitchPriority		?("Autoswitch value, 0=never autoswitch.");
var() bool						bActivatable			?("Whether item can be activated.");
var   travel bool				bActive;				// Whether item is currently activated.
var	  bool						bSleepTouch;			// Set when item is touched when leaving sleep state.
var	  bool						bHeldItem;				// Set once an item has left pickup state.
var	  bool						bTossedOut;				// True if weapon was tossed out (so players can't cheat w/ weaponstay)
var   int						SpecialKey;				// Key the item is bound to.
var   Pawn						PickupNotifyPawn;
var() float						RespawnTime				?("Respawn after this time, 0 for instant.");
var   travel int				NumCopies;
var() bool						bCanHaveMultipleCopies	?("If player can possess more than one of this.");
var() bool						bAutoActivate;
var() bool						bDontPickupOnTouch		?("If true, the item can only be picked up by use.");
var() travel int				Charge					?("Amount of charge on item.  Used over time.");
var() int						MaxCharge				?("Maximum charge this item can have.");
var   bool						bInvForceRep;			// Force replication.
var() bool						bCustomPickupSettings	?("Custom pickup settings should be used instead of defaults (collide world, falling, etc).");
var   name						RestSequence;
var   string					SpawnOnHitClassString;
var   bool						bDoRespawnMarker;		// Do a respawn marker when picked up
var   RespawnMarker             MyRespawnMarker;
var	  bool						bCanActivateWhileHandUp;

/*-----------------------------------------------------------------------------
	HUD
-----------------------------------------------------------------------------*/

var() byte						dnInventoryCategory		?("Category that the item is filed under.");
var() byte						dnCategoryPriority		?("Order in the actual category.");
var() texture					Icon					?("Q-menu icon for the object.");
var() texture					PickupIcon				?("Small pickup icon for the object.");
var() class<LocalMessage>		ItemMessageClass;



/*-----------------------------------------------------------------------------
	Vending Machine
-----------------------------------------------------------------------------*/

var(Vending) sound				VendSound;
var          bool				bVendFalling;
var          vector				FallLocation;
var(Vending) texture			VendTitle[4];
var(Vending) smackertexture		VendIcon;
var          sound				ItemLandSound;
enum EPrice
{
	BUCKS_1,
	BUCKS_3,
	BUCKS_4,
	BUCKS_5,
	BUCKS_10,
	BUCKS_15,
	BUCKS_20,
	BUCKS_25,
	BUCKS_30,
	BUCKS_50,
	BUCKS_75,
	BUCKS_100,
	BUCKS_150,
	BUCKS_200
};
var(Vending) EPrice				VendPrice;
var          Actor				VendOwner;



/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

// Player view rendering info.
var() vector					PlayerViewOffset		?("Offset from view center.");
var() mesh						PlayerViewMesh			?("Mesh to render.");
var() float						PlayerViewScale			?("Mesh scale.");
var() float						BobDamping				?("How much to damp view bob.");

// Pickup view rendering info.
var() mesh						PickupViewMesh			?("Mesh to render.");
var() float						PickupViewScale			?("Mesh scale.");

// 3rd person mesh.
var() mesh						ThirdPersonMesh			?("Mesh to render.");
var() float						ThirdPersonScale		?("Mesh scale.  Keep at 1.0 for weapons.");



/*-----------------------------------------------------------------------------
	AI
-----------------------------------------------------------------------------*/

var() float						MaxDesireability		?("Maximum desireability this item will ever have.");
var	  InventorySpot				MyMarker;



/*-----------------------------------------------------------------------------
	Sounds
-----------------------------------------------------------------------------*/

var() sound						PickupSound, ActivateSound, DeactivateSound, RespawnSound;



/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner )
		NumCopies, Charge, bActivatable, bActive, PlayerViewOffset, PlayerViewMesh, PlayerViewScale,
		ThirdPersonMesh, ThirdPersonScale;
}



/*-----------------------------------------------------------------------------
	Object / Core Game Behavior
-----------------------------------------------------------------------------*/

// Called after object is spawned.
event PostBeginPlay()
{
	local class<RespawnMarker>	RespawnMarkerClass;

	// If we have no assigned item name, make one based on our class.
	if ( ItemName == "" )
		ItemName = GetItemName( string(Class) );

	// Do a respawn marker if the gametype calls for it
	if ( Level.Game.RespawnMarkerType != "" && bDoRespawnMarker && RespawnTime > 0 )
	{
		RespawnMarkerClass	= class<RespawnMarker>( DynamicLoadObject( Level.Game.RespawnMarkerType, class'Class' ) );
		MyRespawnMarker		= spawn( RespawnMarkerClass );
		MyRespawnMarker.SetLocation( self.Location );
		MyRespawnMarker.SetRotation( rot(0,0,0) );
		MyRespawnMarker.bHidden=true;
	}

	// Call parent.
	Super.PostBeginPlay();
}

// Called after a travelling inventory item has been accepted into a level.
event TravelPreAccept()
{
	// Call parent.
	Super.TravelPreAccept();

	// Give us to our owner.
	GiveTo( Pawn(Owner) );

	// If we were actived before, stay active.
	if ( bActive )
		Activate();
}

// Called by engine when destroyed.
event Destroyed()
{
	// Remove marker.
	if ( MyMarker != None )
		MyMarker.MarkedItem = None;

	// Remove from owner's inventory.
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory( Self );
}



/*-----------------------------------------------------------------------------
	Base Inventory Behavior
-----------------------------------------------------------------------------*/

// Become a pickup item on the ground.
function BecomePickup()
{
	if ( Physics != PHYS_Falling )
		RemoteRole= ROLE_SimulatedProxy;
	Mesh          = PickupViewMesh;
	DrawScale     = PickupViewScale;
	bOnlyOwnerSee = false;
	bHidden       = false;
	bCarriedItem  = false;
	NetPriority   = 1.4;

	if ( !bCustomPickupSettings )
	{
		bCollideWorld = true;
		SetCollision( true, true, false );
		SetPhysics( PHYS_Falling );
	}
	AnimSequence = RestSequence;
}

// Become an inventory item carried by a player.
function BecomeItem()
{
	RemoteRole    = ROLE_SimulatedProxy;
	Mesh          = PlayerViewMesh;
	DrawScale     = PlayerViewScale;
	bOnlyOwnerSee = true;
	bHidden       = true;
	bCarriedItem  = true;
	NetPriority   = 1.4;
	AmbientGlow   = 0;
	SetCollision( false, false, false );
	SetBase( None );
	SetPhysics( PHYS_None );
	SetTimer( 0.0, false );
}

// Called when we are picked up.
function PickupFunction( Pawn Other )
{
	// Auto activate the item if a bot picks it up.
	if ( bActivatable && bAutoActivate && Other.bAutoActivate )
		Activate();
}

// Give this inventory item to a pawn.
function GiveTo( pawn Other )
{
	Instigator = Other;
	BecomeItem();
	Other.AddInventory( Self );
	GotoState('Waiting');
}

// Return true if Inv can be picked up by Other.
static simulated function bool CanPickup( Pawn Other, class<Inventory> InvClass, Inventory Inv )
{
	return true;
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = spawn( Class, Other,,, rot(0,0,0) );

	ModifyCopy( Copy, Other );
	Copy.GiveTo( Other );
	Copy.VendOwner	= VendOwner;
	Copy.Tag		= Tag;
	Copy.Event		= Event;

	if ( Level.Game.ShouldRespawn(self) )
		GotoState('Sleeping');
	else
		Destroy();

	return Copy;
}

// Give child classes a change to modify the copy before GiveTo.
function ModifyCopy( Inventory Copy, pawn Other );

// For announcing that we were picked up.
function AnnouncePickup( Pawn Receiver )
{
	// Display a pickup message.
	DisplayPickupEvent( Self, Receiver );
	
	// Have the pawn handle the pickup.
	Receiver.HandlePickup( Self );

	// Set respawn state.
	SetRespawn();
}

// Set up respawn waiting if desired.
function SetRespawn()
{
	if( Level.Game.ShouldRespawn(self) )
		GotoState('Sleeping');
	else
		Destroy();
}

// Toggle Activation of selected Item.
simulated function Activate()
{
	if( bActivatable )
		GoToState('Activated');
}

simulated function PlayInventoryActivate( PlayerPawn Other )
{
	Other.PlaySound( Other.QMenuUse, SLOT_Interface );
}

// This is called when a usable inventory item has used up it's charge.
function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		if ( Pawn(Owner).SelectedItem == Self )
			Pawn(Owner).SelectedItem = None;
		if ( ItemMessageClass != None )
			Pawn(Owner).ReceiveLocalizedMessage( ItemMessageClass, 0, None, None, Self.Class );
	}
	Owner.PlaySound( DeactivateSound );
	Destroy();
}

// Function which lets existing items in a pawn's inventory
// prevent the pawn from picking something up. Return true to abort pickup
// or if item handles pickup, otherwise keep going through inventory list.
function bool HandlePickupQuery( inventory Item )
{
	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

// Toss this item out.
function DropFrom( vector StartLocation )
{
	if ( !SetLocation(StartLocation) )
		return; 
	RespawnTime = 0.0; //don't respawn
	SetPhysics( PHYS_Falling );
	RemoteRole = ROLE_DumbProxy;
	bHeldItem = false;
	BecomePickup();
	NetPriority = 2.5;
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory( self );
	Inventory = None;
	GotoState('PickUp', 'Dropped');
}

// Drop behavior.
function DropInventory()
{
}

// Return true if Other touching us is valid for pickup (used in states).
function bool ValidTouch( actor Other, optional bool bCheckWall )
{
}

// Return true if this object has a use hook.
function bool CapturesUse()
{
	return false;
}

// Use input hook functions.
function UseDown();
function UseUp();
function Used( Actor Other, Pawn EventInstigator );

// Special function hook.
// Used to anonymous perform special actions, so I don't have to refer
// directly to objects by cast in DukePlayer.
function SpecialAction( int ActionCode );

// Spawn an effect when hit.
simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, float DecoHealth, float HitDamage, bool bNoCreationSounds )
{
	local class<Actor> HitClass;
	local Actor s;

	if ( SpawnOnHitClassString != "" )
	{
		HitClass = class<Actor>( DynamicLoadObject( SpawnOnHitClassString, class'Class' ) );
		s = spawn( HitClass, Self, , HitLocation, rotator(HitLocation - Location) );
		if ( !bNoCreationSounds && (SoftParticleSystem(s) != None) )
			SoftParticleSystem(s).PlayCreationSounds();
	
	}
}


/*-----------------------------------------------------------------------------
	AI.
-----------------------------------------------------------------------------*/

// AI object capabilities accessors.
function float InventoryCapsFloat( name Property, pawn Other, actor Test );
function string InventoryCapsString( name Property, pawn Other, actor Test );

// Determine whether I should pick this up.
event float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local float desire;
	local bool bChecked;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		bChecked = true;
		AlreadyHas = Bot.FindInventoryType(class); 
		if ( (AlreadyHas != None) 
			&& (AlreadyHas.Charge >= Charge) )
				return -1;
	}
	return desire;
}

// Tell the AI which weapon to use.
simulated function Weapon RecommendWeapon( out float rating, out int bUseAltMode )
{
	if ( inventory != None )
		return inventory.RecommendWeapon(rating, bUseAltMode);
	else
	{
		rating = -1;
		return None;
	}
}



/*-----------------------------------------------------------------------------
	Notifications
-----------------------------------------------------------------------------*/

// Used to inform inventory when owner jumps.
// So that the inventory can alter jump physics, like UT's jump boots.
function OwnerJumped()
{
	if( Inventory != None )
		Inventory.OwnerJumped();
}

// Used to ask inventory if it needs to affect its owners display properties.
function SetOwnerDisplay()
{
	if( Inventory != None )
		Inventory.SetOwnerDisplay();
}



/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

// Draw first person view of inventory and any screen overlays.
simulated event RenderOverlays( canvas Canvas )
{
	if ( Owner == None )
		return;
	if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
		return;
	SetLocation( Owner.Location + CalcDrawOffset() );
	SetRotation( Pawn(Owner).ViewRotation );
	Canvas.SetClampMode( false );
	Canvas.DrawActor( self, false );
	Canvas.SetClampMode( true );
}

// Compute offset for drawing.
simulated final function vector CalcDrawOffset()
{
	local vector DrawOffset, WeaponBob, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	DrawOffset = ((0.9/90 * PlayerViewOffset) >> PawnOwner.ViewRotation);

	if ( (Level.NetMode == NM_DedicatedServer) 
		|| ((Level.NetMode == NM_ListenServer) && (Owner.RemoteRole == ROLE_AutonomousProxy)) )
		DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
	else
	{
		DrawOffset += (PawnOwner.EyeHeight * vect(0,0,1));
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset += WeaponBob;
	}
	if ( Owner.IsA('PlayerPawn') )
	{
		GetAxes( PawnOwner.ViewRotation, X, Y, Z );
		DrawOffset -= X*PlayerPawn(Owner).WeapShakeOffset;
		DrawOffset += PlayerPawn(Owner).VibrationVector;
	}
	return DrawOffset;
}

// Draw pickup icon.
function DisplayPickupEvent( Inventory Inv, Actor ByOwner )
{
	if ( (ByOwner != None) && ByOwner.IsA('PlayerPawn') )
	{
		PlayerPawn(ByOwner).RecentPickups[PlayerPawn(ByOwner).RecentPickupsIndex++] = Inv.Class;
		if (PlayerPawn(ByOwner).RecentPickupsIndex == 6)
			PlayerPawn(ByOwner).RecentPickupsIndex = 0;
	}

	if ( (Inv.VendOwner != None) && (Inv.VendOwner.IsA('Decoration')) )
		Decoration(Inv.VendOwner).NotifyPickup(Self);

	if ( Inv.PickupNotifyPawn != None )
		PickupNotifyPawn.NotifyPickup( ByOwner, Pawn(ByOwner) );

	// Play the pickup sound.
	ByOwner.PlaySound( Inv.PickupSound, , 1.0, false, 800 );
}

// Update per-frame timers.
event UpdateTimers( float DeltaSeconds )
{
}

// Draw charge bar on Q-menu.
simulated function DrawChargeAmount( Canvas C, HUD HUD, float X, float Y );

// Draw ammo bar on Q-menu.
simulated function DrawAmmoBar( Canvas C, HUD HUD, float AmmoScale, float X, float Y )
{
	if ( AmmoScale > 1.0 )
		AmmoScale = 1.0;
	if ( AmmoScale > 0.5 )
		C.DrawColor = HUD.GreenColor;
	else if ( AmmoScale > 0.15 )
		C.DrawColor = HUD.GoldColor;
	else
		C.DrawColor = HUD.RedColor;
	C.SetPos( X, Y );
	C.DrawTile( texture'WhiteTexture', AmmoScale * 30 * HUD.HUDScaleX, 2 * HUD.HUDScaleY * 0.8, 1, 1, 1, 1 );
}



/*-----------------------------------------------------------------------------
	Vending
-----------------------------------------------------------------------------*/

// Init this item to be generated by a vending machine.
function SetupVendItem( vector inFallLocation )
{
	SetPhysics( PHYS_Falling );
	SetCollision( false, false, false );

	FallLocation = inFallLocation;
	bVendFalling = true;
}

// Falling update from the vending machine.
// We do manual physics here so we can emulate the collision with the vending machine.
function VendUpdate( float Delta )
{
	if ( bVendFalling )
	{
		if ( Location.Z < FallLocation.Z )
		{
			bVendFalling = false;
			SetPhysics( PHYS_None );
			SetLocation( FallLocation );
			SetCollision( true, true, true );
			PlaySound( ItemLandSound );
		}
	}
}

// Return true if the other guy can't buy something.
static function bool CantBuyItem( Pawn Other )
{
	return false;
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// State for when the object is on the ground, ready to be picked up.
auto state Pickup
{
	// For generating effects on changes to special zones.
	singular function ZoneChange( ZoneInfo NewZone )
	{
		// BR FIXME: Add real splash code here.
		/*
		local float splashsize;
		local actor splash;

		if ( NewZone.bWaterZone && !Region.Zone.bWaterZone ) 
		{
			splashSize = 0.000025 * Mass * (250 - 0.5 * Velocity.Z);
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = 2 * splashSize;
			}
		}
		*/
	}

	// Returns true if Other is valid to pick up the item.
	function bool ValidTouch( actor Other, optional bool bCheckWall )
	{
		local Actor A;

		// Make sure it is a live player.
		if ( !Other.bIsPawn || (Pawn(Other).Health <= 0) || Other.bHidden )
			return false;

		// Make sure not touching through wall.
		if ( bCheckWall && !FastTrace(Other.Location, Location) )
			return false;

		// Make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			GlobalTrigger( Event, Pawn(Other) );
			return true;
		}

		return false;
	}

	// Checks to see if the other person can pick up the item and performs pickup logic.
	function Touch( actor Other )
	{
		local Inventory Copy;

		if ( bDontPickupOnTouch )
			return;

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other, true) )
		{
			// Create a copy.
			Copy = SpawnCopy( Pawn(Other) );

			// Select this item if nothing else is selected.
			if (bActivatable && Pawn(Other).SelectedItem == None) 
				Pawn(Other).SelectedItem = Copy;

			// Announce pickup.
			AnnouncePickup( Pawn(Other) );

			// Perform special pickup behavior.
			Copy.PickupFunction( Pawn(Other) );
		}
		// Don't allow inventory to pile up (frame rate hit).
		else if ( (Inventory != None) && Other.IsA('Inventory') && (Inventory(Other).Inventory != None) )
			Destroy();
	}

	// If item is used, do something like Touch.
	function Used( Actor Other, Pawn EventInstigator )
	{
		local Inventory Copy;

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			// Create a copy.
			Copy = SpawnCopy( Pawn(Other) );

			// Select this item if nothing else is selected.
			if (bActivatable && Pawn(Other).SelectedItem == None) 
				Pawn(Other).SelectedItem = Copy;

			// Announce pickup.
			AnnouncePickup( Pawn(Other) );

			// Perform special pickup behavior.
			Copy.PickupFunction( Pawn(Other) );
		}
	}

	// WHen the object lands, adjust us to be upright.
	function Landed( vector HitNormal )
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation( newRot );
		SetTimer( 2.0, false );
	}

	// Check to see if we are touching anything.
	function CheckTouching()
	{
		local Pawn P;

		// Make sure no pawn already touching (while touch was disabled in sleep).
		bSleepTouch = false;
		foreach TouchingActors( class'Pawn', P )
		{
			Touch( P );
		}
	}

	// Periodic timer.
	function Timer( optional int TimerNum )
	{
		if ( RemoteRole != ROLE_SimulatedProxy )
		{
			NetPriority = 1.4;
			RemoteRole = ROLE_SimulatedProxy;
			if ( bHeldItem )
			{
				if ( bTossedOut )
					SetTimer( 15.0, false );
				else
					SetTimer( 40.0, false );
			}
			return;
		}

		if ( bHeldItem )
		{
			if (  (FRand() < 0.1) || !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer( 3.0, true );
		}
	}

	// Called when we enter the pickup state.
	function BeginState()
	{
		BecomePickup();
		NumCopies = 0;
		if ( bHeldItem )
			SetTimer(30, false);
		else if ( Level.bStartup )
			bAlwaysRelevant = true;
	}

	// Called when we exit the pickup state.
	function EndState()
	{        
		bCollideWorld = false;
		bSleepTouch = false;
	}

	// Called when we land on something.
	function BaseChange()
	{
		if ( bVendFalling )
			return;

		if ( Base == None )
			SetPhysics( PHYS_Falling );
		else
			SetPhysics( PHYS_None );
	}

Dropped:
	if( bSleepTouch )
		CheckTouching();
}

// State entered when the item is activated.
state Activated
{
	simulated function BeginState()
	{
		bActive = true;
	}

	simulated function EndState()
	{
		bActive = false;
	}

	simulated function Activate()
	{
		if ( (Pawn(Owner) != None) && Pawn(Owner).bAutoActivate 
			&& bAutoActivate && (Charge>0) )
				return;

		GoToState('DeActivated');	
	}
}

// State entered when the item is deactivated.
state Deactivated
{
}

// State entered when the item is sleeping and needs to be respawned.
state Sleeping
{
	ignores Touch;

	function BeginState()
	{
		BecomePickup();
        SetPhysics( PHYS_None );
		SetCollisionSize( 0, 0 );
		bHidden = true;

		// Unhide a respawn marker
		if ( MyRespawnMarker != None )
		{
			MyRespawnMarker.Show( RespawnTime );			
		}
	}

	function EndState()
	{
		local Pawn P;

		// Hide the respawn marker
		if ( MyRespawnMarker != None )
			MyRespawnMarker.Hide();

		SetCollisionSize( default.CollisionRadius, default.CollisionHeight );
		bSleepTouch = false;
		
		foreach TouchingActors( class'Pawn', P )
		{
			bSleepTouch = true;
		}
	}
	
Begin:
	Sleep( ReSpawnTime );
	PlaySound( RespawnSound );	
	Sleep( Level.Game.PlaySpawnEffect(self) );
	GoToState( 'Pickup' );
}

// Null state for items in someone's inventory.
state Waiting
{
}

defaultproperties
{
     PlayerViewScale=1.000000
     BobDamping=0.960000
     PickupViewScale=1.000000
     ThirdPersonScale=1.000000
     MaxDesireability=0.005000
     bTravel=True
     DrawType=DT_Mesh
     Texture=Texture'Engine.S_Inventory'
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bCollideActors=True
     RemoteRole=ROLE_SimulatedProxy
	 NetPriority=1.4
	 SpecialKey=-1
	 bNotTargetable=false
	 ItemName="Inventory Item"
	 bProjTarget=true
	 bUseTriggered=true
	 AnimSequence=centered
	 RestSequence=centered
	 HitPackageClass=class'HitPackage_Inventory'
	 SpawnOnHitClassString="dnParticles.dnBulletFX_MetalSpawners"
	 bDoRespawnMarker=true
}
