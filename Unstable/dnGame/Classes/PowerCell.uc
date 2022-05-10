/*-----------------------------------------------------------------------------
	PowerCell
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PowerCell expands Inventory;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Textures\ezvend.dtx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

var() int EnergyCharge;

simulated function DrawChargeAmount( Canvas C, HUD HUD, float X, float Y )
{
	local int i, YPos;
	local float BreatheScale;

	C.Font = font'hudfont';
	C.DrawColor = DukeHUD(HUD).TextColor;
	C.SetPos( X+10*HUD.HUDScaleX*0.8, Y+40*HUD.HUDScaleY*0.8 );
	C.DrawText( NumCopies+1 );
}

function Activate()
{
	if ( PlayerPawn(Owner).Energy < 100 )
	{
		NumCopies--;
		PlayerPawn(Owner).AddEnergy( EnergyCharge );
	}
	if ( NumCopies < 0 )
		Destroy();
}

defaultproperties
{
	bActivatable=true
	dnInventoryCategory=5
	dnCategoryPriority=5
	PickupViewMesh=mesh'c_dukeitems.sos_powercell'
	Mesh=mesh'c_dukeitems.sos_powercell'
	EnergyCharge=25
	PickupIcon=texture'hud_effects.am_sospcell'
    Icon=Texture'hud_effects.mitem_sospcell'
	ItemName="SOS Power Cell"
	LodMode=LOD_Disabled
	VendTitle(0)=texture'ezvend.descriptions.powercell_00'
	VendTitle(1)=texture'ezvend.descriptions.powercell_01'
	VendTitle(2)=texture'ezvend.descriptions.powercell_02'
	VendTitle(3)=texture'ezvend.descriptions.powercell_03'
	VendIcon=texture'smk6.sospowercell_spn'
	VendSound=sound'a_dukevoice.ezvend.ez-sportsdrink'
	VendPrice=BUCKS_15
	ItemLandSound=sound'dnsMaterials.LthrMtlDamp18'
    CollisionRadius=4.0
    CollisionHeight=5.0
	bCanHaveMultipleCopies=true
}