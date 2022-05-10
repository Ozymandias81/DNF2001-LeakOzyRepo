//=============================================================================
// dnGenericDropShip.
//=============================================================================
class dnGenericDropShip expands dnMeadDropShip;

// Generic drop ship used for flying in maps (non destructable)

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

// Each thruster is handled by itself and is named <Tag>Thrust#. 
// When you trigger <Tag>Thrust# it toggles the state off the 
// engine.

// The rear door has opening animations, and to go along with that there is
// an effect for smoke spewing out called <Tag>EffectDoorSmoke.

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDropShip_BlueJetsOff')
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnDropShip_BlueJetsOff')
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnDropShip_BlueJetsOff')
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnDropShip_BlueJetsOff')
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnDropShip_DoorSmoke',MountOrigin=(X=-256.000000,Y=64.000000),AppendToTag=EffectDoorSmoke)
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnDropShip_DoorSmoke',MountOrigin=(Y=-64.000000),AppendToTag=EffectDoorSmoke)
}
