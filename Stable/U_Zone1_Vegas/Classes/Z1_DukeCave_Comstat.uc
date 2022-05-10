//=============================================================================
// Z1_DukeCave_Comstat.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_DukeCave_Comstat expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=124.000000
     CollisionHeight=39.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.dcavecomstat2'
}
