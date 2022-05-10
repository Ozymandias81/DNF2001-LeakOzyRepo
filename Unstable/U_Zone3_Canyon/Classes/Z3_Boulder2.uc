//=============================================================================
// Z3_Boulder2.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Boulder2 expands Z3_Boulder1;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     MassPrefab=MASS_Heavy
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     Grabbable=True
     PlayerViewOffset=(X=-0.325000,Y=0.000000,Z=0.000000)
     ItemName="Boulder"
     bNotTargetable=False
     CollisionRadius=22.000000
     CollisionHeight=20.000000
     Mesh=DukeMesh'c_zone3_canyon.Boulder2'
}
