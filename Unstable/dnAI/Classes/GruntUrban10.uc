//=============================================================================
// GruntUrban10.
//=============================================================================
class GruntUrban10 expands GruntUrban;

defaultproperties
{
     Mesh=DukeMesh'c_characters.EDF4'
     MultiSkins(0)=Texture'm_characters.EDFsldrface4RC'
	 MultiSkins(1)=Texture'm_characters.EDF1bodyRC'
     MultiSkins(2)=Texture'm_characters.EDF1pantsRC'
     MultiSkins(3)=Texture'm_characters.EDF8partsRC'
	 bRandomFace=true
	 Faces(0)=Texture'm_characters.EDFsldrface5RC'
	 Faces(1)=None
	 Faces(2)=Texture'm_characters.EDFsldrface5RC'
}
