//=============================================================================
// dnHRocket3.
//=============================================================================
class dnHRocket3 expands dnHomingRocket;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
     TurnScaler=10.000000
     TrailClass=Class'U_Zone2_Dam.dnHRocket3trail'
     LifeSpan=12.000000
     Mesh=DukeMesh'c_dnWeapon.missile_air'
     bUnlit=False
     DrawScale=4.000000
}
