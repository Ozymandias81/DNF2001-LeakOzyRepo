//=============================================================================
// CreaturePawnCarcass.
//=============================================================================
class CreaturePawnCarcass extends dnCarcass;

#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

var() bool bRandomName;

function InitFor( RenderActor Other )
{
	local int CurrentMode, i;
	local Pawn NPC;

	if( Other.IsA( 'HumanNPC' ) )
	{
		NPC = Pawn( Other );
		
		if( NPC.Weapon != None )
		{
			CurrentMode = NPC.CurrentAmmoMode;
			AmmoClassAmount = NPC.Weapon.AmmoLoaded;
			AmmoClass = NPC.Weapon.AmmoType.GetClassForMode( CurrentMode );
		}
		if( AmmoClassAmount == 0 || NPC.Weapon == None )
		{
			bSearchable = false;
			bUseTriggered = false;
		}
		for (i=0; i<5; i++)
		{
			if (NPC.SearchableItems[i] != None)
			{
				SearchableItems[i] = NPC.SearchableItems[i];
				bSearchable = true;
				bUseTriggered = true;
			}
		}
	}
	if( Region.Zone.bWaterZone )
	{
		SetPhysics( PHYS_Falling );
	}

	if ( Other.bIsPawn && (Pawn(Other).CharacterName != "") )
		ItemName = Pawn(Other).CharacterName$"'s Corpse";
	else if (bRandomName)
		ItemName = Level.Game.GetRandomName()$"'s Corpse";

	Super.InitFor( Other );
}

function DropQuestItems()
{
	local int i;
	local Inventory Inv;

	for (i=0; i<5; i++)
	{
		if ((SearchableItems[i] != None) && (ClassIsChildOf(SearchableItems[i], class'QuestItem')))
		{
			Inv = spawn( SearchableItems[i] );
			Inv.BecomePickup();
		}
	}
}

function bool HasQuestItem()
{
	local int i;
	local Inventory Inv;

	for (i=0; i<5; i++)
	{
		if ((SearchableItems[i] != None) && (ClassIsChildOf(SearchableItems[i], class'QuestItem')))
			return true;
	}
	return false;
}

function ThrowOthers()
{
	local float dist, shake;
	local pawn Thrown;
	local PlayerPawn aPlayer;
	local vector Momentum;

	Thrown = Level.PawnList;
	While ( Thrown != None )
	{
		aPlayer = PlayerPawn(Thrown);
		if ( aPlayer != None )
		{	
			dist = VSize(Location - aPlayer.Location);
			shake = FMax(500, 1500 - dist);
			aPlayer.ShakeView( FMax(0, 0.35 - dist/20000),shake, 0.015 * shake );
			if ( (aPlayer.Physics == PHYS_Walking) && (dist < 1500) )
			{
				Momentum = -0.5 * aPlayer.Velocity + 100 * VRand();
				Momentum.Z =  7000000.0/((0.4 * dist + 350) * aPlayer.Mass);
				aPlayer.AddVelocity(Momentum);
			}
		}
	Thrown = Thrown.nextPawn;
	}
}

function ImpactGround()
{
	if( !Region.Zone.bWaterZone )
	{
		if( FRand() < 0.5 )
			PlaySound( Sound'a_impact.body.ImpactGround1', SLOT_Misc,,, 512,, false );
		else
			PlaySound( Sound'a_impact.body.ImpactGround2', SLOT_Misc,,,512,, false );
	}
}

function LandThump()
{
	local float impact;

	if ( Physics == PHYS_None)
	{
		bThumped = true;
		if ( Role == ROLE_Authority )
		{
			impact = 0.75 + Velocity.Z * 0.004;
			impact = Mass * impact * impact * 0.015;
			PlaySound(LandedSound,, impact);
			if ( Mass >= 500 )
				ThrowOthers();
		}
	}
}

defaultproperties
{
     bSlidingCarcass=true
     TransientSoundVolume=3.000000
     bBlockActors=false
     bBlockPlayers=false
	 bSearchable=true
	 bNotTargetable=false
	 ItemName="A Dead Guy"
     bUseTriggered=true
	 bBobbing=false
	 BobDamping=0.0400000
     bCanHaveCash=true
	 bRandomName=true
}
