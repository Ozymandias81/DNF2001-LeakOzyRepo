//=============================================================================
// Z1_StratosfearFlag.
//=============================================================================
class Z1_StratosfearFlag expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=70.000000
     CollisionHeight=70.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.stratoflag1'
}
