/*-----------------------------------------------------------------------------
	Rebreather
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Rebreather extends Inventory;

#exec OBJ LOAD FILE=..\Textures\m_dukeitems.dtx
#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Sounds\a_inventory.dfx

var float BreatheTime;
var float WaterAmbientTime;
var sound BreatheSound;
var bool  bCanActivate;

replication
{
	reliable if ( Role == ROLE_Authority )
		BreatheTime;
}

simulated function DrawChargeAmount( Canvas C, HUD HUD, float X, float Y )
{
	local int i, YPos;
	local float BreatheScale;

	YPos = 51;
	BreatheScale = BreatheTime / default.BreatheTime;
	DrawAmmoBar( C, HUD, BreatheScale, X+4*HUD.HUDScaleX*0.8, Y+YPos*HUD.HUDScaleY*0.8 );
}

simulated function Activate()
{
	if ( bCanActivate )
		Super.Activate();
}

state Activated
{
	simulated function AnimEnd()
	{
		PlayAnim( 'IdleA', 1.0, 0.1 );
		bCanActivate = true;
	}

	simulated function BeginState()
	{
		bCanActivate = false;

		if ( (Owner != None) && (Owner.bIsPawn) )
			Pawn(Owner).UsedItem = Self;

		Owner.PlaySound( ActivateSound );
		PlayAnim( 'Activate', 1.0, 0.1 );
		WaterAmbientTime = 5;
		Super.BeginState();

		// Turn on the indicator bar.
		if ( Owner.IsA('PlayerPawn') && (PlayerPawn(Owner).MyHUD != None) )
			DukeHUD(PlayerPawn(Owner).MyHUD).RegisterAirItem(spawn(class'HUDIndexItem_Air'));
	}

	simulated event UpdateTimers(float DeltaSeconds)
	{
		if ( WaterAmbientTime > 0.0 )
		{
			WaterAmbientTime -= DeltaSeconds;
			if ( WaterAmbientTime < 0.0 )
			{
				Owner.PlaySound( BreatheSound, SLOT_Misc, 16 );
				WaterAmbientTime = 10.0;
			}
		}
		
		if ( Role == ROLE_Authority )
		{
			BreatheTime -= DeltaSeconds;
			if ( BreatheTime < 0.0 )
			{
				// We are out of breath!
				BreatheTime = 0.0;
				Activate();
			}

			PlayerPawn(Owner).RemainingAir = PlayerPawn(Owner).UnderWaterTime;
		}
	}

	simulated function Activate()
	{
		if ( bCanActivate )
			Super.Activate();
	}
}

state Deactivated
{
	simulated function AnimEnd()
	{
		bCanActivate = true;
		if ( (Owner != None) && (Owner.bIsPawn) )
			Pawn(Owner).UsedItem = None;
		if ( BreatheTime <= 0.0 )
			Destroy();
	}

	simulated function BeginState()
	{
		bCanActivate = false;
		Owner.PlaySound( DeactivateSound, SLOT_Interact );
		Owner.StopSound( SLOT_Misc );
		PlayAnim( 'Deactivate', 1.0, 0.1 );
		Super.BeginState();

		if ( Owner.bIsPawn )
		{
			if ( Pawn(Owner).HeadRegion.Zone.bWaterZone )
			{
				// We are in water, so start drowning.
				Pawn(Owner).HeadEnteredWater();
			}
			else if ( Owner.IsA('PlayerPawn') && (PlayerPawn(Owner).MyHUD != None) )
			{
				// We aren't in water, but we are a player, remove the air indicator.
				DukeHUD(PlayerPawn(Owner).MyHUD).RemoveAirItem();
			}
		}
	}
}

defaultproperties
{
	dnInventoryCategory=5
	dnCategoryPriority=3
	bActivatable=true

	ItemName="Rebreather"
	PickupIcon=texture'hud_effects.am_rebreath'
    Icon=Texture'hud_effects.mitem_rebreath'

	PlayerViewMesh=Mesh'c_dukeitems.rebreather'
    PickupViewMesh=Mesh'c_dukeitems.w_rebreather'
	Mesh=Mesh'c_dukeitems.w_rebreather'
	PlayerViewScale=0.16
	PlayerViewOffset=(X=135.0,Y=0.0,Z=300.0)

	ActivateSound=sound'a_inventory.OxyMask06'
	DeactivateSound=sound'a_inventory.OxyMaskOff1'
	BreatheSound=sound'a_inventory.UWBreathe03'

	bCanActivate=true
	BreatheTime=100.0

	CollisionRadius=12
	CollisionHeight=5
	LightDetail=LTD_Normal
}