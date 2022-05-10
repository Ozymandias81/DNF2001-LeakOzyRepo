/*-----------------------------------------------------------------------------
	Snack_Powerbar
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_Powerbar extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupIcon=Texture'hud_effects.ingame_hud.am_sportsbar'
     VendSound=Sound'a_dukevoice.ezvend.ez-powerbar'
     VendTitle(0)=Texture'ezvend.descriptions.fatbust_desc0'
     VendTitle(1)=Texture'ezvend.descriptions.fatbust_desc1'
     VendTitle(2)=Texture'ezvend.descriptions.fatbust_desc2'
     VendTitle(3)=Texture'ezvend.descriptions.fatbust_desc3'
     VendIcon=SmackerTexture'SMK6.sprtbar_spn'
     PickupViewMesh=DukeMesh'c_dukeitems.Powerbar'
     Mesh=DukeMesh'c_dukeitems.Powerbar'
     ItemName="Power Bar"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
