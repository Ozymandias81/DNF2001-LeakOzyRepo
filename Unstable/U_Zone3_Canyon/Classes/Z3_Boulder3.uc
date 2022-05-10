//=============================================================================
// Z3_Boulder3.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Boulder3 expands Z3_Boulder1;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     bLandForward=True
     bLandBackwards=True
     bLandUpright=True
     bLandUpsideDown=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-1.825000,Z=2.250000)
     BobDamping=0.900000
     ItemName="Rock"
     bNotTargetable=False
     CollisionRadius=9.000000
     CollisionHeight=4.000000
     Mesh=DukeMesh'c_zone3_canyon.rock_square1'
}
