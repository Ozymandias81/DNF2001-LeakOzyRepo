//=============================================================================
// MRECase.	Keith Schuler	August 16, 2001
// An ammo case with 2 MREs
//=============================================================================
class MRECase expands AmmoCase;

defaultproperties
{
     Treats(0)=Class'U_Generic.Snack_MRE'
     Treats(1)=Class'U_Generic.Snack_MRE'
     TreatsOffset(0)=(Y=9.000000,Z=-6.000000)
     TreatsOffset(1)=(Y=-9.000000,Z=-6.000000)
     TreatsRotation(0)=(Pitch=0,Yaw=32768,Roll=0)
     TreatsRotation(1)=(Pitch=0,Yaw=32768,Roll=0)
}
