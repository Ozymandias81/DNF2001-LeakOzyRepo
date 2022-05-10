//=============================================================================
// RandomSWAT.
//=============================================================================
class RandomSWAT expands GruntSWAT;

function PostBeginPlay()
{
	GenerateRandomNPC();
	Super.PostBeginPlay();
	if( Mesh == dukemesh'EDF3' || Mesh == dukemesh'EDF3Desert' || Mesh == dukemesh'EDF6' || Mesh == dukemesh'EDF6Desert' )
		Texture = texture'EDF1Reflect1RC';
}

function GenerateRandomNPC()
{
	local int Decision;

	Decision = Rand( 11 );

//	log( "* DECISION: "$Decision );
	Switch( Decision )
	{
		Case 0:
			Mesh=DukeMesh'c_characters.EDF6';
			MultiSkins[0]=Texture'm_characters.EDFsldrface2RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;

		Case 1:
			Mesh=DukeMesh'c_characters.EDF5';
			MultiSkins[0]=Texture'm_characters.EDFsldrface3RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;

		Case 2:
			Mesh=DukeMesh'c_characters.EDF4';
			MultiSkins[0]=Texture'm_characters.EDFsldrface2RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF2partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;

		Case 3:
			Mesh=DukeMesh'c_characters.EDF3';
			MultiSkins[0]=Texture'm_characters.EDFsldrface3RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;
	
		Case 4:
			Mesh=DukeMesh'c_characters.EDF2';
			MultiSkins[0]=Texture'm_characters.EDFsldrface3RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;
		
		Case 5:
			Mesh=DukeMesh'c_characters.EDF1';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF2partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=Texture'm_characters.EDFsldrface1RC';
			break;

		Case 6:
			Mesh=DukeMesh'c_characters.EDF2';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5RC';
			Faces[1]=Texture'm_characters.EDFsldrface4RC';
			Faces[2]=Texture'm_characters.EDFsldrface5RC';
			break;

		Case 7:
			Mesh=DukeMesh'c_characters.EDF3';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5RC';
			Faces[1]=Texture'm_characters.EDFsldrface4RC';
			Faces[2]=Texture'm_characters.EDFsldrface5RC';
			break;

		Case 8:
			Mesh=DukeMesh'c_characters.EDF4';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF9partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5RC';
			Faces[1]=Texture'm_characters.EDFsldrface4RC';
			Faces[2]=Texture'm_characters.EDFsldrface5RC';
			break;

		Case 9:
			Mesh=DukeMesh'c_characters.EDF5';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5RC';
			Faces[1]=Texture'm_characters.EDFsldrface4RC';
			Faces[2]=Texture'm_characters.EDFsldrface5RC';
			break;

		Case 10:
			Mesh=DukeMesh'c_characters.EDF6';
			MultiSkins[0]=Texture'm_characters.EDFsldrface4RC';
			MultiSkins[3]=Texture'm_characters.EDF6partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface5RC';
			Faces[1]=Texture'm_characters.EDFsldrface4RC';
			Faces[2]=Texture'm_characters.EDFsldrface5RC';
			break;

		Default:
			Mesh=DukeMesh'c_characters.EDF6';
			MultiSkins[0]=Texture'm_characters.EDFsldrface2RC';
			MultiSkins[1]=Texture'm_characters.EDF2bodyRC';
			MultiSkins[2]=Texture'm_characters.EDF2pantsRC';
			MultiSkins[3]=Texture'm_characters.EDF2partsRC';
			bRandomFace=true;
			Faces[0]=Texture'm_characters.EDFsldrface2RC';
			Faces[1]=Texture'm_characters.EDFsldrface3RC';
			Faces[2]=None;
			break;
	}
	Default.MultiSkins[ 3 ] = MultiSkins[ 3 ];
	Default.MultiSkins[ 0 ] = MultiSkins[ 0 ];
}

defaultproperties
{
	Mesh=DukeMesh'c_characters.EDF6'
	MultiSkins(0)=Texture'm_characters.EDFsldrface2RC'
	MultiSkins(1)=Texture'm_characters.EDF2bodyRC'
	MultiSkins(2)=Texture'm_characters.EDF2pantsRC'
}
