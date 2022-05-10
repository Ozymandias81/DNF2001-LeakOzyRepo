/*-----------------------------------------------------------------------------
	HypoVial_Health
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoVial_Health expands Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx
#exec OBJ LOAD FILE=..\Textures\SMK5.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

simulated function class<Ammo> GetClassForMode( int Mode )
{
	switch ( Mode )
	{
		case 0:
			return class'HypoVial_Health';
		case 1:
			return class'HypoVial_Steroids';
		case 2:
			return class'HypoVial_Antidote';
	}
}

simulated function texture GetSkinForMode()
{
	switch ( AmmoMode )
	{
		case 0:
			return texture'm_dnWeapon.vial_efx_blue';
		case 1:
			return texture'm_dnWeapon.vial_efx_red';
		case 2:
			return texture'm_dnWeapon.vial_efx_green';
	}
}

simulated function bool CanAffect( Pawn Target )
{
	local Inventory i;

	switch (AmmoMode)
	{
		case 0:
			return true;
			break;
		case 1:
			if ( !Target.IsA('PlayerPawn') )
				return false;

			i = Target.FindInventoryType( class'Steroids' );
			if ( i==None )
				return true;
			else
				return false;
			break;
		case 2:
			return true;
			break;
	}
}

function HypoEffect( Pawn Target )
{
	local Steroids s;
	local Inventory i;

	switch (AmmoMode)
	{
		case 0:
			Target.AddEgo( 30, false );
			break;
		case 1:
			s = spawn( class'Steroids' );
			s.GiveTo( Target );
			s.Activate();
			break;
		case 2:
			// First, cancel any steroids effect.
			i = Target.FindInventoryType( class'Steroids' );
			if ( i != None )
				i.UsedUp();

			// Next, cure poison, biochemical, and burnout effects.
			Target.RemoveDOT( DOT_Poison );
			Target.RemoveDOT( DOT_Biochemical );
			Target.RemoveDOT( DOT_Burnout );
			if ( Target.Shrunken() && !Target.bRestoringShrink )
				Target.RestoreShrink();
			break;
	}
}

defaultproperties
{
	MaxAmmoMode=3
	ModeAmount(0)=1
	ModeAmount(1)=0
	ModeAmount(2)=0
    MaxAmmo(0)=10
    MaxAmmo(1)=10
    MaxAmmo(2)=10

	AnimSequence=bottle_up
    PickupViewMesh=Mesh'c_dnWeapon.w_hypobottle'
    PickupSound=Sound'dnGame.Pickups.AmmoSnd'
    Physics=PHYS_Falling
    Mesh=Mesh'c_dnWeapon.w_hypobottle'
    bMeshCurvy=false
    CollisionRadius=12.0
    CollisionHeight=5.0
    bCollideActors=true
	MultiSkins(2)=texture'm_dnWeapon.vial_efx_blue'
	LodMode=LOD_Disabled
	PickupIcon=texture'hud_effects.am_healing'
	ItemName="Health HypoVial"

	VendTitle(0)=texture'ezvend.descriptions.helth_desc0'
	VendTitle(1)=texture'ezvend.descriptions.helth_desc1'
	VendTitle(2)=texture'ezvend.descriptions.helth_desc2'
	VendTitle(3)=texture'ezvend.descriptions.helth_desc3'
	VendIcon=texture'smk5.healthb_spn'
	VendSound=sound'a_dukevoice.ezvend.ez-sportsdrink'
	VendPrice=BUCKS_25
	ItemLandSound=sound'dnsMaterials.LthrMtlDamp18'
}