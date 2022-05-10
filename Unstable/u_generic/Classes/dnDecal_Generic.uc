//=============================================================================
// dnDecal_Generic.
//=============================================================================
class dnDecal_Generic expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\m_dnWeapons.dtx

defaultproperties
{
     Decals(0)=Texture'm_dnweapon.bulletholes.bhole_fabric1cR'
     bHidden=True
     bDirectional=True
     DrawType=DT_Sprite
     Style=STY_Masked
     Texture=Texture'Engine.S_Light'
     DrawScale=1.000000
}
