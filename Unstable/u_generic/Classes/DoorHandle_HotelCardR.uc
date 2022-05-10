//=============================================================================
// DoorHandle_HotelCardR.	Keith Schuler November 3,2000
//=============================================================================
class DoorHandle_HotelCardR expands DoorHandle;

defaultproperties
{
     HandleOffset=(X=-27.200001,Y=2.400000,Z=18.000000)
     RotationOffset=(Yaw=16384)
     bAnimates=True
     OpenSequence=open_withcard
     LockedSequence=locked_nocard
     Texture=None
     Mesh=DukeMesh'c_generic.Doorhandle_crdR'
     AnimSequence=normal_nocard
}
