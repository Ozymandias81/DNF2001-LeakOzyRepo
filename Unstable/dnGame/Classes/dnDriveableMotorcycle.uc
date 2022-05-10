//=============================================================================
// dnDriveableMotorcycle.
//=============================================================================
// default props AB

class dnDriveableMotorcycle expands dnDriveableDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_vehicles.dmx 
#exec OBJ LOAD FILE=..\Meshes\c_hands.dmx 
#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx
#exec OBJ LOAD FILE=..\Textures\vegas.dtx

defaultproperties
{
     WheelieScale=0.750000
     ShockDampening=2.000000
     WheelieResistance=0.850000
     SkidSensitivity=0.750000
     bDirectional=True
     Texture=Texture'vegas.floors.peoplemover1bRC'
     Mesh=DukeMesh'c_vehicles.cycle_hawg1'
}
