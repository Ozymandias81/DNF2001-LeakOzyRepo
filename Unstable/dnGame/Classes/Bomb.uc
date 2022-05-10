/*-----------------------------------------------------------------------------
	Bomb
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class Bomb expands Inventory;

function Destroyed()
{
	if ( Pawn( Owner ).PlayerReplicationInfo != None )
		Pawn( Owner ).PlayerReplicationInfo.bHasBomb = false;

	Super.Destroyed();
}

function GiveTo( pawn Other )
{
	if ( Other.PlayerReplicationInfo != None )
		Other.PlayerReplicationInfo.bHasBomb = true;

	Super.GiveTo( Other );
}

function PickupFunction( Pawn Other )
{
	if ( Other.PlayerReplicationInfo != None )
		Other.PlayerReplicationInfo.bHasBomb = true;

	Super.PickupFunction( Other );
}
 
simulated function Activate()
{
	local PlayerPawn PlayerOwner;
	
	PlayerOwner = PlayerPawn( Owner );

	if ( PlayerOwner != None )
	{
		if ( !PlayerOwner.bCanPlantBomb )
		{
			// Tell the player they can't plant here
			PlayerOwner.ReceiveLocalizedMessage( class'dnBombMessage', 1 );
			return;
		}

		if ( DukeHUD( PlayerOwner.MyHUD ) != None )
		{
			// Turn on the indicator bar.
			DukeHUD( PlayerOwner.MyHUD ).RegisterBombItem( spawn( class'HUDIndexItem_Bomb' ) );
		}

	}

	SetTimer( 0.05, true, 1 );
}

function Timer( optional int TimerNum )
{
	if ( TimerNum == 1 )
		Charge -= 1;

	if ( Charge == 0 )
	{
		if ( DukeHUD( PlayerPawn( Owner ).MyHUD ) != None )
			DukeHUD( PlayerPawn( Owner ).MyHUD ).RemoveBombItem();

		if ( Role == ROLE_Authority )
		{
			PlayerPawn(Owner).PlantBomb();
		}

		SetTimer( 0, false, 1 );
	}
}

defaultproperties
{
	ItemName="Bomb"
	PickupIcon=texture'hud_effects.am_jetpack'
	Icon=Texture'hud_effects.mitem_jetpack'
	PickupSound=Sound'dnGame.Pickups.AmmoSnd'
	dnInventoryCategory=6
	dnCategoryPriority=6
	Mesh=Mesh'c_dukeitems.jetpack2'
	PickupViewMesh=Mesh'c_dukeitems.jetpack2'
	bActivatable=true
	RespawnTime=0.0 
	Charge=100
	MaxCharge=100
	RemoteRole=ROLE_DumbProxy
	CollisionRadius=22.000000
	CollisionHeight=20.000000
	bMeshLowerByCollision=false
}
