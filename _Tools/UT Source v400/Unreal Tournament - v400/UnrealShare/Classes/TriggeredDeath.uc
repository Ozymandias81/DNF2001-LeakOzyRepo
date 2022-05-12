//=============================================================================
// TriggeredDeath.
// When triggered, kills the player, causing screen flashes and sounds.
//=============================================================================
class TriggeredDeath extends Triggers;

var() Sound  MaleDeathSound;
var() Sound  FemaleDeathSound;
var() float  StartFlashScale;
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var() float  ChangeTime;
var() Name   DeathName;
var() bool   bDestroyItems;	// destroy any items which may touch it as well

var float TimePassed[8];
var PlayerPawn Victim[8];

auto state Enabled
{
	function Touch( Actor Other )
	{
		local inventory Inv;
		local Pawn P;
		local int VNum;

		// Something has contacted the death trigger.
		// If it is a PlayerPawn, have it screen flash and
		// die.
		if( Other.bIsPawn )
		{
			P = Pawn(Other);
			P.Weapon = None;
			P.SelectedItem = None;
			P.DropWhenKilled = None;
			Level.Game.DiscardInventory(P);	
			
			if ( P.Health <= 0 )
				return;
			if ( Other.IsA('PlayerPawn') )
			{
				Enable('Tick');
				While ( (VNum < 7) && (Victim[VNum] != None) )
					VNum++;
				Victim[Vnum] = PlayerPawn(Other);
				TimePassed[VNum] = 0;
			}
			else
				KillVictim(P);

			P.Health = 1;
			if ( P.bIsPlayer )
			{
				if( P.bIsFemale )
					Other.PlaySound( FemaleDeathSound, SLOT_Talk );
				else
					Other.PlaySound( MaleDeathSound, SLOT_Talk );
			}
			else
				P.Playsound(P.Die, SLOT_Talk);
		}
		else if( bDestroyItems )
			Other.Destroy();
	}

	function KillVictim(Pawn Victim)
	{
		Victim.NextState = '';
		Victim.Health = -1;
		if (DeathName == '')
			Victim.Died(None, 'Fell', Victim.Location);
		else
			Victim.Died(None, DeathName, Victim.Location);
		Victim.HidePlayer();
	}

	function Tick( float DeltaTime )
	{
		local Float CurScale;
		local vector CurFog;
		local float  TimeRatio;
		local int i, VNum;
		local bool bFoundVictim;

		for ( i=0; i<8; i++ )
			if( Victim[i] != None )
			{
				if ( Victim[i].Health > 1 )
					Victim[i] = None;
				else
				{
					// Check the timing
					TimePassed[i] += DeltaTime;
					if( TimePassed[i] >= ChangeTime )
					{
						TimeRatio = 1;
						Victim[i].ClientFlash( EndFlashScale, 1000 * EndFlashFog );
						if ( Victim[i].Health > 0 )
							KillVictim(Victim[i]);
						Victim[i] = None;
					}
					else 
					{
						bFoundVictim = true;
						// Continue the screen flashing
						TimeRatio = TimePassed[i]/ChangeTime;
						CurScale = (EndFlashScale-StartFlashScale)*TimeRatio + StartFlashScale;
						CurFog   = (EndFlashFog  -StartFlashFog  )*TimeRatio + StartFlashFog;
						Victim[i].ClientFlash( CurScale, 1000 * CurFog );
					}
				}
			}
		if ( !bFoundVictim )
			Disable('Tick');
	}
}

defaultproperties
{
}


