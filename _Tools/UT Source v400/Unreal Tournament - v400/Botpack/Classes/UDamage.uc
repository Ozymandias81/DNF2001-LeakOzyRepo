//=============================================================================
// UDamage.
//=============================================================================
class UDamage extends TournamentPickup;

#exec TEXTURE IMPORT NAME=I_UDamage FILE=TEXTURES\HUD\i_udamage.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=udamage ANIVFILE=MODELS\udamage_a.3d DATAFILE=MODELS\udamage_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=udamage STRENGTH=0.6
#exec MESH SEQUENCE MESH=udamage SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=udamage SEQ=Udamage STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Judamage1 FILE=MODELS\udamage1.PCX GROUP=Skins
#exec MESHMAP NEW   MESHMAP=udamage MESH=udamage
#exec MESHMAP SCALE MESHMAP=udamage X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=udamage NUM=0 TEXTURE=GoldSkin2

#exec AUDIO IMPORT FILE="Sounds\Pickups\MofSFire.WAV" NAME="AmpFire" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\MofSPickup.WAV" NAME="AmpPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\MofSFO1.WAV" NAME="AmpOut" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\MofSRunOut1b.WAV" NAME="AmpFire2b" GROUP="Pickups"

var Weapon UDamageWeapon;
var sound ExtraFireSound;
var sound EndFireSound;
var int FinalCount;

singular function UsedUp()
{
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = None;
	}
	if ( Owner != None )
	{
		if ( Owner.bIsPawn )
		{
			if ( !Pawn(Owner).bIsPlayer || (Pawn(Owner).PlayerReplicationInfo.HasFlag == None) )
			{
				Owner.AmbientGlow = Owner.Default.AmbientGlow;
				Owner.LightType = LT_None;
			}
			Pawn(Owner).DamageScaling = 1.0;
		}
		bActive = false;
		if ( Owner.Inventory != None )
		{
			Owner.Inventory.SetOwnerDisplay();
			Owner.Inventory.ChangedWeapon();
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	Destroy();
}

simulated function FireEffect()
{
	if ( (TimerRate - TimerCounter < 5) && (Level.NetMode != NM_Client) )
		Pawn(Owner).Weapon.PlayOwnedSound(EndFireSound, SLOT_Interact, 8);
	else 
		Pawn(Owner).Weapon.PlayOwnedSound(ExtraFireSound, SLOT_Interact, 8);
}

function SetOwnerLighting()
{
	if ( Owner.bIsPawn && Pawn(Owner).bIsPlayer
		&& (Pawn(Owner).PlayerReplicationInfo.HasFlag != None) ) 
		return;
	Owner.AmbientGlow = 254; 
	Owner.LightEffect=LE_NonIncidence;
	Owner.LightBrightness=255;
	Owner.LightHue=210;
	Owner.LightRadius=10;
	Owner.LightSaturation=0;
	Owner.LightType=LT_Steady;
}

function SetUDamageWeapon()
{
	if ( !bActive )
		return;

	SetOwnerLighting();

	// Make old weapon normal again.
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = None;
	}
		
	UDamageWeapon = Pawn(Owner).Weapon;
	// Make new weapon cool.
	if ( UDamageWeapon != None )
	{
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = self;
		if ( Level.bHighDetailMode )
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
									 FireTexture'UnrealShare.Belt_fx.UDamageFX',
									 true,
									 true);
		else
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Normal, 
							 FireTexture'UnrealShare.Belt_fx.UDamageFX',
							 true,
							 true);
	}
}

//
// Player has activated the item, pump up their damage.
//
state Activated
{
	function Timer()
	{
		if ( FinalCount > 0 )
		{
			SetTimer(1.0, true);
			Owner.PlaySound(DeActivateSound,, 8);
			FinalCount--;
			return;
		}
		UsedUp();
	}

	function SetOwnerDisplay()
	{
		if( Inventory != None )
			Inventory.SetOwnerDisplay();

		SetUDamageWeapon();
	}

	function ChangedWeapon()
	{
		if( Inventory != None )
			Inventory.ChangedWeapon();

		SetUDamageWeapon();
	}

	function EndState()
	{
		UsedUp();
	}

	function BeginState()
	{
		bActive = true;
		FinalCount = Min(FinalCount, 0.1 * Charge - 1);
		SetTimer(0.1 * Charge - FinalCount,false);
		Owner.PlaySound(ActivateSound);	
		SetOwnerLighting();
		Pawn(Owner).DamageScaling = 3.0;
		SetUDamageWeapon();	
	}
}

defaultproperties
{
	 FinalCount=5
	 EndFireSound=AmpFire2b
	 ExtraFireSound=sound'Botpack.Pickups.AmpFire'
	 bMeshEnviroMap=True
	 Texture=Mesh'Beltfx.NewGold'
	 ItemName="Damage Amplifier"
     MaxDesireability=2.500000
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You got the Damage Amplifier!"
     RespawnTime=120.000000
     PickupViewMesh=Mesh'BotPack.UDamage'
     PickupViewScale=1.000000
     Charge=300
     PickupSound=Sound'Botpack.Pickups.AmpPickup'
     DeActivateSound=Sound'Botpack.Pickups.AmpOut'
     Physics=PHYS_Rotating
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'BotPack.UDamage'
     DrawScale=1.000000
     Icon=Texture'BotPack.Icons.I_UDamage'
}
