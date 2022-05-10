//=============================================================================
// dnHRocketStreetMap. 						 Created by Keith Schuler 4/10/2000
//=============================================================================
class dnHRocketStreetMap expands dnHomingRocket;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
     TurnScaler=10.000000
     TrailClass=Class'dnParticles.dnHRocket2trail'
     Mesh=DukeMesh'c_dnWeapon.missile_air'
     DrawScale=0.750000
}
