//=============================================================================
// dnDroneJet_Torpedo. 					October 17th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDroneJet_Torpedo expands dnDroneJet_Unarmed;

// Drone Jet armed with a torpedo.

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     MountOnSpawn(7)=(ActorClass=Class'U_Zone2_Dam.DnProjectileSpawn_MeadTorpedo1',SetMountOrigin=True,MountOrigin=(Z=-32.000000),AppendToTag=Torpedo,TakeParentTag=True)
}
