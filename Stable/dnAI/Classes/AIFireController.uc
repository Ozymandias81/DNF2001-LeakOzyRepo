/*=============================================================================
	AIFireController
	Author: Jess Crable

	Automatically spawned actor that controls Grunt weapon firing when they
	are performing latent actions such as movement.
=============================================================================*/

class AIFireController extends AIController;

var Grunt Target;
var int Attempt;
/*
auto state Startup
{
	function BeginState()
	{
		SetTimer( 0.1, true );
	}

	function Timer( optional int TimerNum )
	{
		if( Target != None )
		{
			GotoState( 'CountDown' );
			return;
		}
		else
			Attempt++;
	
		if( Attempt > 10 )
			Destroy();
	}
}

state CountDown
{
	function BeginState()
	{
		Disable( 'Tick' );

		if( Target.Weapon.IsA( 'Pistol' ) )
			SetTimer( 0.35, true );
		else if( Target.Weapon.IsA( 'M16' ) )
			SetTimer( 0.15, true );
		else if( Target.Weapon.IsA( 'Shotgun' ) )
			SetTimer( 1.7, true );
	}

	function Timer( optional int TimerNum )
	{
		if( Target.Weapon.GottaReload() )
		{
			dnWeapon( Target.Weapon ).AmmoType.AddAmmo( 9999, 0 );
			Target.Weapon.AmmoLoaded = 50;
			broadcastmessage( "RELOADING" );
			//return;
		}
		//else
		//{
			//if( FRand() < 0.5 )//&& Target.GetSequence( 1 ) == 'T_M16Idle' )
			//{
				Target.bFire = 1;
				dnWeapon( Target.Weapon ).FireAnim.AnimTween = 0.1;
				Target.PlayWeaponFire();
				Target.Weapon.Fire();
			//}
		//}
	}
}

*/
DefaultProperties
{
     bIgnoreBList=false
     bHidden=true
}

    
