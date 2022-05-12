//=============================================================================
// DMMutator.
//=============================================================================

class DMMutator expands Mutator;

var DeathMatchPlus MyGame;

function PostBeginPlay()
{
	MyGame = DeathMatchPlus(Level.Game);
	Super.PostBeginPlay();
}

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;

	if ( Other.IsA('StationaryPawn') )
		return true;

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Inventory Inv;

	// replace Unreal I inventory actors by their Unreal Tournament equivalents
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.

	bSuperRelevant = 1;
	if ( MyGame.bMegaSpeed && Other.bIsPawn && Pawn(Other).bIsPlayer )
	{
		Pawn(Other).GroundSpeed *= 1.4;
		Pawn(Other).WaterSpeed *= 1.4;
		Pawn(Other).AirSpeed *= 1.4;
		Pawn(Other).AccelRate *= 1.4;
	}

	if ( Other.IsA('StationaryPawn') )
		return true;

	Inv = Inventory(Other);
 	if ( Inv == None )
	{
		bSuperRelevant = 0;
		return true;
	}

	if ( MyGame.bNoviceMode && MyGame.bRatedGame && (Level.NetMode == NM_Standalone) )
		Inv.RespawnTime *= (0.5 + 0.1 * MyGame.Difficulty);

	if ( Other.IsA('Weapon') )
	{
		if ( Other.IsA('TournamentWeapon') )
			return true;

		log("Found "$Other$" at "$Other.location);
		//Assert(false);
		if ( Other.IsA('Stinger') )
		{
			ReplaceWith(Other, "Botpack.PulseGun");
			return false; 
		}
		if ( Other.IsA('Rifle') )
		{
			ReplaceWith( Other, "Botpack.SniperRifle" );
			return false;
		}
		if ( Other.IsA('Razorjack') )
		{
			ReplaceWith( Other, "Botpack.Ripper" );
			return false;
		}
		if ( Other.IsA('Minigun') )
		{
			ReplaceWith( Other, "Botpack.Minigun2" );
			return false;
		}
		if ( Other.IsA('AutoMag') )
		{
			ReplaceWith( Other, "Botpack.Enforcer" );
			return false;
		}
		if ( Other.IsA('Eightball') )
		{
			ReplaceWith( Other, "Botpack.UT_Eightball" );
			return false;
		}
		if ( Other.IsA('FlakCannon') )
		{
			ReplaceWith( Other, "Botpack.UT_FlakCannon" );
			return false;
		}
		if ( Other.IsA('ASMD') )
		{
			ReplaceWith( Other, "Botpack.ShockRifle" );
			return false;
		}
		if ( Other.IsA('GesBioRifle') )
		{
			ReplaceWith( Other, "Botpack.UT_BioRifle" );
			return false;
		}
		if ( Other.IsA('DispersionPistol') )
		{
			ReplaceWith( Other, "Botpack.ImpactHammer");
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}
	if ( Other.IsA('Ammo') )
	{
		if ( Other.IsA('TournamentAmmo') )
			return true;

		log("Found "$Other$" at "$Other.location);
		//Assert(false);

		if ( Other.IsA('ASMDAmmo') )
		{
			ReplaceWith( Other, "Botpack.ShockCore" );
			return false;
		}
		if ( Other.IsA('RocketCan') )
		{
			ReplaceWith( Other, "Botpack.RocketPack" );
			return false;
		}
		if ( Other.IsA('StingerAmmo') )
		{
			ReplaceWith(Other, "Botpack.PAmmo");
			return false;
		}
		if ( Other.IsA('RazorAmmo') )
		{
			ReplaceWith( Other, "Botpack.BladeHopper" );
			return false;
		}
		if ( Other.IsA('RifleRound') )
		{
			ReplaceWith( Other, "Botpack.RifleShell" );
			return true;
		}
		if ( Other.IsA('RifleAmmo') )
		{
			ReplaceWith( Other, "Botpack.BulletBox" );
			return false;
		}
		if ( Other.IsA('FlakBox') )
		{
			ReplaceWith( Other, "Botpack.FlakAmmo" );
			return false;
		}
		if ( Other.IsA('Clip') )
		{
			ReplaceWith( Other, "Botpack.EClip" );
			return false;
		}
		if ( Other.IsA('ShellBox') )
		{
			ReplaceWith( Other, "Botpack.MiniAmmo" );
			return false;
		}
		if ( Other.IsA('Sludge') )
		{
			ReplaceWith( Other, "Botpack.BioAmmo" );
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}

	if ( Other.IsA('Pickup') )
	{
		Pickup(Other).bAutoActivate = true;
		if ( Other.IsA('TournamentPickup') )
			return true;
	}
	if ( Other.IsA('TournamentHealth') )
		return true;

	log("Found "$Other$" at "$Other.location);
	//Assert(false);

	if ( Other.IsA('JumpBoots') )
	{
		if ( MyGame.bJumpMatch )
			return false;
		ReplaceWith( Other, "Botpack.UT_JumpBoots" );
		return false;
	}
	if ( Other.IsA('Amplifier') )
	{
		ReplaceWith( Other, "Botpack.UDamage" );
		return false;
	}
	if ( Other.IsA('WeaponPowerUp') )
		return false; 

	if ( Other.IsA('KevlarSuit') )
	{
		ReplaceWith( Other, "Botpack.ThighPads");
		return false;
	}
	if ( Other.IsA('SuperHealth') )
	{
		ReplaceWith( Other, "Botpack.HealthPack" );
		return false;
	}
	if ( Other.IsA('Armor') )
	{
		ReplaceWith( Other, "Botpack.Armor2" );
		return false;
	}
	if ( Other.IsA('Bandages') )
	{
		ReplaceWith( Other, "Botpack.HealthVial" );
		return false;
	}
	if ( Other.IsA('Health') && !Other.IsA('HealthPack') && !Other.IsA('HealthVial')
		 && !Other.IsA('MedBox') && !Other.IsA('NaliFruit') )
	{
		ReplaceWith( Other, "Botpack.MedBox" );
		return false;
	}
	if ( Other.IsA('ShieldBelt') )
	{
		ReplaceWith( Other, "Botpack.UT_ShieldBelt" );
		return false;
	}
	if ( Other.IsA('Invisibility') )
	{
		ReplaceWith( Other, "Botpack.UT_Invisibility" );
		return false;
	}

	bSuperRelevant = 0;
	return true;
}
