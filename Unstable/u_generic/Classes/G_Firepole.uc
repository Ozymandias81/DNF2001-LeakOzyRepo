//=============================================================================
// G_Firepole.							Keith Schuler 5/21/99
//=============================================================================
class G_Firepole expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
#exec OBJ LOAD FILE=..\textures\t_generic.dtx

defaultproperties
{
     FragType(0)=None
     bTakeMomentum=False
     HealthPrefab=HEALTH_NeverBreak
     Mesh=DukeMesh'c_generic.fire_pole'
     bNotTargetable=True
     CollisionRadius=2.000000
     CollisionHeight=271.000000
     Health=0
}
