/*-----------------------------------------------------------------------------
	Snack_Sportsdrink
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_Sportsdrink extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     HealingAmount=15
     PickupIcon=Texture'hud_effects.ingame_hud.am_sportsdrink'
     VendSound=Sound'a_dukevoice.ezvend.ez-sportsdrink'
     VendTitle(0)=Texture'ezvend.descriptions.sportd_desc0'
     VendTitle(1)=Texture'ezvend.descriptions.sportd_desc1'
     VendTitle(2)=Texture'ezvend.descriptions.sportd_desc2'
     VendTitle(3)=Texture'ezvend.descriptions.sportd_desc3'
     VendIcon=SmackerTexture'SMK6.spdrink_spn'
     VendPrice=BUCKS_15
     PickupViewMesh=DukeMesh'c_dukeitems.Sportdrink'
     Mesh=DukeMesh'c_dukeitems.Sportdrink'
     ItemName="Sports Drink"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
	 bDrink=true
}
