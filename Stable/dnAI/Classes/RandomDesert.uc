//=============================================================================
// RandomDesert.
//=============================================================================
class RandomDesert expands GruntDesert;

function PostBeginPlay()
{
	GenerateRandomNPC();
	Super.PostBeginPlay();
	if( Mesh == dukemesh'EDF3' || Mesh == dukemesh'EDF2Desert' || Mesh == dukemesh'EDF3Desert' || Mesh == dukemesh'EDF6' || Mesh == dukemesh'EDF6Desert' )
		Texture = texture'EDF1Reflect1RC';
}

function GenerateRandomNPC()
{
	local int Decision;

	Decision = Rand( 11 );
	Switch( Decision )
	{
		Case 0:
			Mesh=DukeMesh'c_characters.EDF1desert';
		    MultiSkins[0]=Texture'm_characters.EDFsldrface3DRC';
			MultiSkins[3]=Texture'm_characters.EDF3PartsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;

		Case 1:
			Mesh=DukeMesh'c_characters.EDF2desert';
			bRandomFace=true;
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			// Does this guy need 1DRC or is it a mismatch?
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;

		Case 2:
			Mesh=DukeMesh'c_characters.EDF3desert';
			MultiSkins[0]=Texture'm_characters.EDFsldrface3DRC';
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;

		// Short sleeves, parts defined
		Case 3:
		    Mesh=DukeMesh'c_characters.EDF4desert';
			MultiSkins[3]=Texture'm_characters.EDF3partsRC';
		    MultiSkins[0]=Texture'm_characters.EDFsldrface2DRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;
		// Long sleeves, parts defined.
		Case 4:
		    Mesh=DukeMesh'c_characters.EDF5desert';
			MultiSkins[0]=Texture'm_characters.EDFsldrface3DRC';
		    MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;
		// Long sleeves, parts defined
		Case 5:
			Mesh=DukeMesh'c_characters.EDF6desert';
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;
		// Black guy short sleeves
		Case 6:
			Mesh=DukeMesh'c_characters.EDF1desert';
			MultiSkins[0]=Texture'EDFsldrface4DRC';
			MultiSkins[3]=Texture'm_characters.EDF10partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5DRC';
			Faces[1]=Texture'm_characters.EDFsldrface4DRC';
			Faces[2]=Texture'm_characters.EDFsldrface5DRC';
			break;
		// Black guy long sleeves
		Case 7:
			Mesh=DukeMesh'c_characters.EDF2desert';
			MultiSkins[0]=Texture'EDFsldrface4DRC';
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5DRC';
			Faces[1]=Texture'm_characters.EDFsldrface4DRC';
			Faces[2]=Texture'm_characters.EDFsldrface5DRC';
			break;
		// Black guy long sleeves
		Case 8:
			Mesh=DukeMesh'c_characters.EDF3desert';
			MultiSkins[0]=Texture'EDFsldrface4DRC';
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5DRC';
			Faces[1]=Texture'm_characters.EDFsldrface4DRC';
			Faces[2]=Texture'm_characters.EDFsldrface5DRC';
			break;
		// Black guy short sleeves
 		Case 9:
			Mesh=DukeMesh'c_characters.EDF4desert';
			MultiSkins[0]=Texture'EDFsldrface4DRC';
			MultiSkins[3]=Texture'm_characters.EDF10partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5DRC';
			Faces[1]=Texture'm_characters.EDFsldrface4DRC';
			Faces[2]=Texture'm_characters.EDFsldrface5DRC';
			break;
		// Black guy long sleeves
		Case 10:
			Mesh=DukeMesh'c_characters.EDF5desert';
			MultiSkins[0]=Texture'EDFsldrface4DRC';
			MultiSkins[3]=Texture'm_characters.EDF7partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5DRC';
			Faces[1]=Texture'm_characters.EDFsldrface4DRC';
			Faces[2]=Texture'm_characters.EDFsldrface5DRC';
			break;

		Default:
			Mesh=DukeMesh'c_characters.EDF1desert';
		    MultiSkins[0]=Texture'm_characters.EDFsldrface3DRC';
			MultiSkins[3]=Texture'm_characters.EDF3PartsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface3DRC';
			Faces[1]=Texture'm_characters.EDFsldrface2DRC';
			Faces[2]=Texture'm_characters.EDFsldrface1DRC';
			break;
	}
	Default.MultiSkins[ 3 ] = MultiSkins[ 3 ];
	Default.MultiSkins[ 0 ] = MultiSkins[ 0 ];
}

defaultproperties
{
}
