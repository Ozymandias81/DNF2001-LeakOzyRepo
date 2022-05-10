/*-----------------------------------------------------------------------------
	Snack_PowerTrip
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_PowerTrip extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     HealingAmount=25
     PickupIcon=Texture'hud_effects.ingame_hud.am_powertrip'
     VendSound=Sound'a_dukevoice.ezvend.ez-powertrip'
     VendTitle(0)=Texture'ezvend.descriptions.pwtrip_desc0'
     VendTitle(1)=Texture'ezvend.descriptions.pwtrip_desc1'
     VendTitle(2)=Texture'ezvend.descriptions.pwtrip_desc2'
     VendTitle(3)=Texture'ezvend.descriptions.pwtrip_desc3'
     VendIcon=SmackerTexture'SMK6.powrtrp_spn'
     VendPrice=BUCKS_25
     PickupViewMesh=DukeMesh'c_dukeitems.AminoAcidJar'
     Mesh=DukeMesh'c_dukeitems.AminoAcidJar'
     ItemName="Amino Acid"
     CollisionRadius=12.000000
     CollisionHeight=10.000000
}
