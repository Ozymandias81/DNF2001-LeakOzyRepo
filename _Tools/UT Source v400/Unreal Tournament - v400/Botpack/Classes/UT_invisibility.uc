//=============================================================================
// UT_Invisibility.
//=============================================================================
class UT_Invisibility extends TournamentPickUp;


#exec MESH IMPORT MESH=invis2M ANIVFILE=MODELS\invis_a.3D DATAFILE=MODELS\invis_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=invis2M STRENGTH=0.5
#exec MESH ORIGIN MESH=invis2M X=0 Y=0 Z=0  YAW=0
#exec MESH SEQUENCE MESH=invis2M SEQ=All    STARTFRAME=0  NUMFRAMES=1
//#exec OBJ LOAD FILE=..\Textures\belt_fx.utx  PACKAGE=botpack.belt_fx
#exec TEXTURE IMPORT NAME=jinvis FILE=MODELS\invis2.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=invis2M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=invis2M NUM=1 TEXTURE=jinvis




state Activated
{
	function endstate()
	{
		local Inventory S;

		bActive = false;		
		PlaySound(DeActivateSound);

		Owner.SetDefaultDisplayProperties();
		S = Pawn(Owner).FindInventoryType(class'UT_ShieldBelt');
		if ( (S != None) && (UT_Shieldbelt(S).MyEffect != None) )
			UT_Shieldbelt(S).MyEffect.bHidden = false;
	}

	function Activate()
	{
		bActive = true;
		SetOwnerDisplay();
	}

	function SetOwnerDisplay()
	{
		if ( !bActive )
			return;
		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
							 FireTexture'unrealshare.Belt_fx.Invis',
							 true,
							 true);
		if( Inventory != None )
			Inventory.SetOwnerDisplay();
	}

	function ChangedWeapon()
	{
		if ( !bActive )
			return;
		if( Inventory != None )
			Inventory.ChangedWeapon();

		// Make new weapon invisible.
		if ( Pawn(Owner).Weapon != None )
			Pawn(Owner).Weapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
									 FireTexture'Unrealshare.Belt_fx.Invis',
									 true,
									 true);
	}

	function Timer()
	{
		Charge -= 1;
		Pawn(Owner).Visibility = 10;
		if (Charge<-0)
			UsedUp();
	}

	function BeginState()
	{
		local Inventory S;

		bActive = true;
		PlaySound(ActivateSound,,4.0);

		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
								   FireTexture'unrealshare.Belt_fx.Invis',
								   false,
								   true);
		SetTimer(0.5,True);
		S = Pawn(Owner).FindInventoryType(class'UT_ShieldBelt');
		if ( (S != None) && (UT_Shieldbelt(S).MyEffect != None) )
			UT_Shieldbelt(S).MyEffect.bHidden = true;
	}
}

state DeActivated
{
Begin:
}

defaultproperties
{
     ExpireMessage="Invisibility has worn off."
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You have Invisibility."
     ItemName="Invisibility"
     RespawnTime=120.000000
     PickupViewMesh=LodMesh'Botpack.invis2M'
     Charge=100
     MaxDesireability=1.200000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealI.Pickups.Invisible'
     RemoteRole=ROLE_DumbProxy
     Texture=FireTexture'UnrealShare.Belt_fx.Invis.Invis'
     Mesh=LodMesh'Botpack.invis2M'
     CollisionRadius=15.000000
     CollisionHeight=20.000000
}
