/*-----------------------------------------------------------------------------
	Snack_Sandwich
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_Sandwich extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupIcon=Texture'hud_effects.ingame_hud.am_sandwich'
     VendSound=Sound'a_dukevoice.ezvend.ez-sandwich'
     VendTitle(0)=Texture'ezvend.descriptions.ham_desc_0'
     VendTitle(1)=Texture'ezvend.descriptions.ham_desc_1'
     VendTitle(2)=Texture'ezvend.descriptions.ham_desc_2'
     VendTitle(3)=Texture'ezvend.descriptions.ham_desc_3'
     VendIcon=SmackerTexture'SMK6.sandwch_spn'
     PickupViewMesh=DukeMesh'c_dukeitems.Sandwich'
     Mesh=DukeMesh'c_dukeitems.Sandwich'
     ItemName="Sandwich"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
