//=============================================================================
// SnatchedGirl.uc
//=============================================================================
class SnatchedGirl extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
     EgoKillValue=8
     GroundSpeed=350
     Health=30
     bIsHuman=True
     SoundSyncScale_Jaw=0.380000
     SoundSyncScale_MouthCorner=0.130000
     SoundSyncScale_Lip_U=0.650000
     SoundSyncScale_Lip_L=0.680000
     GroundSpeed=420.000000
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     bSnatched=True
     Mesh=DukeMesh'c_characters.Stripper_Jenny'
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     WaterSpeed=200.000000
}
