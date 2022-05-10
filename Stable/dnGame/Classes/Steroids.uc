//=============================================================================
// Steroids.
//=============================================================================
class Steroids expands Inventory;

#exec AUDIO IMPORT FILE=Sounds\hartbeat.wav NAME=LoopSteroids

#exec OBJ LOAD FILE=..\Textures\m_dukeitems.dtx
#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx

var float TimeChange;
var() sound SteroidsLoop;
var() float LoopTime;

state Activated
{
	function EndState()
	{
		bActive = false;		
	}
	
	function Tick( float DeltaTime )
	{
		// Count down steroids time remaining.
		TimeChange += DeltaTime*10;
		if ( TimeChange > 1 )
		{
			Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}
		
		if ( Pawn(Owner) == None )
		{
			UsedUp();
			return;		
		}
		
		if ( Charge < -0 )
			UsedUp();

	}
	
	function Activate()
	{
		// Cannot deactivate steroids.
	}
	
	simulated function Timer( optional int TimerNum )
	{
		local vector v;

		PlaySound( SteroidsLoop );
		v.x = 255;
		PlayerPawn(Owner).ClientFlash( 100.0, v );
	}
	
	simulated function BeginState()
	{
		TimeChange = 0;
		PlaySound( ActivateSound );
		PlayerPawn(Owner).SetPlayerSpeed( 1.2 );
		PlayerPawn(Owner).AddEgo( 50 );
		PlayerPawn(Owner).MeleeDamageMultiplier = 2.0;
		PlayerPawn(Owner).SetTimer( 0.6, true, 3 );
		SetTimer( LoopTime, true );
		bActive = true;
	}
	
Begin:
}

function UsedUp()
{
	PlayerPawn(Owner).SetPlayerSpeed( 1.0 );
	PlayerPawn(Owner).MeleeDamageMultiplier = 1.0;
	PlayerPawn(Owner).SetTimer( 3.0, true, 3 );
	PlayerPawn(Owner).AddDOT( DOT_Burnout, 20.0, 1.0, 1.0, None );

	Super.UsedUp();	
}

defaultproperties
{
     LoopTime=0.600000
     SteroidsLoop=Sound'dnGame.LoopSteroids'
     bActivatable=true
     RespawnTime=0.0
     Charge=300
     MaxCharge=300
     Icon=Texture'hud_effects.mitem_steroids'
     RemoteRole=ROLE_DumbProxy
     AmbientGlow=96
     CollisionRadius=22.000000
     CollisionHeight=4.000000
}
