/*-----------------------------------------------------------------------------
	Jetpack
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Jetpack expands Inventory;

var bool				bDrain;
var int					TimerTick;
var float				LastJetpackTime, ChargeFraction;
var JetpackAccessory	JADeco;

function SpecialAction( int ActionCode )
{
	switch (ActionCode)
	{
	case 0:
		JetpackDown();
		break;
	case 1:
		JetpackUp();
		break;
	case 2:
		JetpackOff();
		break;
	case 3:
		JetpackOn();
		break;
	}
}

function JetpackDown()
{
	if ( JADeco != None )
		JADeco.JetpackDown();
	
	bDrain = true;
}

function JetpackUp()
{
	if ( JADeco != None )
		JADeco.JetpackUp();
}

function JetpackOff()
{		
	JADeco.JetpackOff();	
	bDrain = false;	
	GotoState( 'Deactivated' );
}

function JetpackOn()
{
}

function Timer( optional int TimerNum )
{
	local vector TestAccel;

	if ( PlayerPawn(Owner) == None )
		return;

	if ( TimerNum == 1 )
	{
		if ( ( PlayerPawn(Owner).Physics != PHYS_Jetpack ) || !bDrain )
			Charge += 1;					
	}
	else if ( TimerNum == 2 )
	{
		TestAccel = PlayerPawn(Owner).Acceleration;
		TestAccel.Z = 0;

		TimerTick++;
		
		if ( TimerTick > 5 )
			TimerTick = 0;
		
		if ( Owner.Physics == PHYS_Jetpack )
		{
			if ( PlayerPawn(Owner).bPressedJump ) // Pressing jump eats more jetpack
				Charge -= 1;
			else if ( (VSize(TestAccel) > 0) && (TimerTick%2==0) ) // moving eats a little bit of fuel
				Charge -= 1;
			else if ( TimerTick < 1 ) // eat a bit for time
				Charge -= 1;
		}
		
		// If we reached zero, then turn off the jetpack
		if ( Charge == 0 )
		{
			PlayerPawn(Owner).JetpackOff();
			GoToState('DeActivated');
			Destroy();
		}
	}

	Charge = Clamp( Charge, 0, 100 );

	if ( JADeco != None )
		JADeco.DrawScale = FMax( 1.0 - (PlayerPawn(Owner).ShrinkCounter/PlayerPawn(Owner).ShrinkTime), 0.25 );

}

state Activated
{
	simulated function Activate()
	{
		GoToState('DeActivated');	
	}

	simulated function BeginState()
	{		
		if ( Charge <= 0 )
			return;

		PlayerPawn(Owner).bActiveJetpack = true;
		PlayerPawn(Owner).JetpackOn();

		if ( Owner.IsA('PlayerPawn') ) 
		{
			if ( DukeHUD( PlayerPawn(Owner).MyHUD ) != None )
			{
				// Turn on the indicator bar.
				DukeHUD(PlayerPawn(Owner).MyHUD).RegisterJetpackItem(spawn(class'HUDIndexItem_Jetpack'));
			}

			if ( Role == ROLE_Authority )
			{
				// Mount the decoration.
				JADeco = spawn( class'JetpackAccessory', Owner,, Owner.Location, Owner.Rotation );
				Pawn(Owner).AddMountable( JADeco, false, false );
				JADeco.JetpackOn();
			}
		}
		// Start a burn timer
		SetTimer( 0.1, true, 2 );
	}

	simulated function EndState()
	{
		local int i;

		PlayerPawn(Owner).JetpackOff();
		PlayerPawn(Owner).bActiveJetpack = false;

		if ( Owner.IsA('PlayerPawn') )
		{
			if ( DukeHUD( PlayerPawn(Owner).MyHUD ) != None )
			{
				// Turn off the indicator bar.
				DukeHUD(PlayerPawn(Owner).MyHUD).RemoveJetpackItem();
			}

			// Remove the decoration.
			if ( Role == ROLE_Authority )
			{
				if ( JADeco != None )
				{
					Pawn(Owner).RemoveMountable( JADeco );
					JADeco.Destroy();
				}
			}
		}

		LastJetpackTime = 0;
		SetTimer( 0.0, false, 2 );			
	}
}

defaultproperties
{
	ItemName="Jetpack"
	PickupIcon=texture'hud_effects.am_jetpack'
	Icon=Texture'hud_effects.mitem_jetpack'
	PickupSound=Sound'dnGame.Pickups.AmmoSnd'

	dnInventoryCategory=5
	dnCategoryPriority=6

	Mesh=Mesh'c_dukeitems.jetpack2'
	PickupViewMesh=Mesh'c_dukeitems.jetpack2'

	bActivatable=true
	RespawnTime=40.0
	Charge=100
	MaxCharge=100
	RemoteRole=ROLE_DumbProxy
	CollisionRadius=22.000000
	CollisionHeight=20.000000
	bMeshLowerByCollision=false
}
