//=============================================================================
// G_FlashlightOff. 				   November 30th, 2000 - Charlie Wiederhold
//=============================================================================
class G_FlashlightOff expands G_Flashlight;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None)
     MountOnSpawn(1)=(ActorClass=None)
     IdleAnimations(0)=Off
}
