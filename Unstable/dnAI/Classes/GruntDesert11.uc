//=============================================================================
// GruntDesert11.
//=============================================================================
class GruntDesert11 expands GruntDesert;

defaultproperties
{
     Mesh=DukeMesh'c_characters.EDF5Desert'
     MultiSkins(0)=Texture'm_characters.EDFsldrface4DRC'
	 MultiSkins(3)=Texture'm_characters.EDF7partsRC'
	 bRandomFace=true
	 Faces(0)=Texture'm_characters.EDFsldrface5DRC'
	 Faces(1)=Texture'm_characters.EDFsldrface4DRC'
	 Faces(2)=Texture'm_characters.EDFsldrface5DRC'
}
