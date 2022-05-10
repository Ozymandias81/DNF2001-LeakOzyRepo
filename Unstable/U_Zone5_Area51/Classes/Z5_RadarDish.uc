//=============================================================================
// Z5_RadarDish. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_RadarDish expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=155.000000
     CollisionHeight=210.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone5_area51.radar_dish_big1'
}
