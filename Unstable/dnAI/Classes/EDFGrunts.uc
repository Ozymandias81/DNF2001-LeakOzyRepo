class EDFGrunts expands Grunt
	abstract;

#exec OBJ LOAD FILE=..\Textures\m_characters.dtx 

var int DrawScaleMod;
var() bool bRandomFace;

var() Texture Faces[ 3 ];
var int GruntFaceNum;
var() Texture SnatchedFaces[ 4 ];
var() Texture SnatchedParts[ 4 ];

var( NPCFace ) Enum ENPCFace
{
	FACE_Random,
	FACE_1,
	FACE_2,
	FACE_3,
} NPCFace;

function SetSnatchedFace( int SkinNum )
{
	log( " Old face was: "$MultiSkins[ 0 ] );
	MultiSkins[ 0 ] = SnatchedFaces[ SkinNum ];
	log(" New face is : "$SnatchedFaces[ SkinNum ] );
}

function SetSnatchedParts( int SkinNum )
{
	if( SnatchedParts[ SkinNum ] != None || self.IsA( 'GruntDesert2' ) )
	{
		MultiSkins[ 3 ] = SnatchedParts[ SkinNum ];
	}
}

function SetPartsSequences()
{
	if( MultiSkins[ 3 ] == texture'm_characters.EDF1PartsRC' )
	{
		SnatchedParts[ 3 ] = texture'm_characters.EDF1Snch1DPartRC';
	}
	else if( MultiSkins[ 3 ] == texture'm_characters.EDF2PartsRC' )
	{
		SnatchedParts[ 3 ] = texture'm_characters.EDF2Snch2DPartRC';
	}
	else if( MultiSkins[ 3 ] == texture'm_characters.EDF3PartsRC' || self.IsA( 'GruntDesert1' ) )
	{
		SnatchedParts[ 3 ] = texture'm_characters.EDF3Snch3DPartRC';
	}
	else if( MultiSkins[ 3 ] == texture'm_characters.EDF8PartsRC' )
	{
		SnatchedParts[ 3 ] = texture'm_characters.EDF8Snch8DPartRC';
	}
	else if( MultiSkins[ 3 ] == texture'm_characters.EDF9PartsRC' )
	{
		SnatchedParts[ 3 ] = texture'm_characters.EDF9Snch9DPartRC';
	}
}

function SetFaceSequences()
{
	local int i;
	if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface1RC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch1dface1RC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface1DRC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch1dface1DRC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface2RC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch2dface2RC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface2DRC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch2dface2DRC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface3RC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch3dface3RC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface3DRC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch3dface3DRC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface4RC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch4dface4RC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface4DRC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch4dface4DRC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface5RC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch5dface5RC';
	}
	else if( MultiSkins[ 0 ] == texture'm_characters.EDFsldrface5DRC' )
	{
		SnatchedFaces[ 3 ] = texture'm_characters.EDFsnch5dface5DRC';
	}
}


	
/*
function SetFaceSnatchedEffects( int SkinNum )
{
	local texture FaceTexture;

	FaceTexture = Default.MultiSkins[ 0 ];

	if( FaceTexture == texture'EDFSldrface5rc' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5aface5RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5bface5RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5cface5RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5dface5RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface4rc' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4aface4RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4bface4RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4cface4RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4dface4RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface1RC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1aface1RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1bface1RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1cface1RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1dface1RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface1DRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1aface1DRC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1bface1DRC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1cface1DRC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch1dface1DRC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface2RC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2aface2RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2bface2RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2cface2RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2dface2RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface2DRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2aface2DRC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2bface2DRC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2cface2DRC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch2dface2DRC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface3RC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3aface3RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3bface3RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3cface3RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3dface3RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface3DRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3aface3DRC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3bface3DRC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3cface3DRC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch3dface3DRC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface4RC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4aface4RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4bface4RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4cface4RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4dface4RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface4DRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4aface4DRC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4bface4DRC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4cface4DRC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch4dface4DRC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface5RC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5aface5RC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5bface5RC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5cface5RC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5dface5RC'; break;
		}
	}
	else if( FaceTexture == texture'EDFSldrface5DRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5aface5DRC'; break;
			Case 1:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5bface5DRC'; break;
			Case 2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5cface5DRC'; break;
			Case 3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsnch5dface5DRC'; break;
		}
	}
}

function SetSnatchedFace()
{
	if( GruntFaceNum == 0 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1RC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1RC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1RC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1RC';
				break;
		}
	}
	else if( GruntFaceNum == 1 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1DRC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1DRC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1DRC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1DRC';
				break;
		}
	}
	else if( GruntFaceNum == 1 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1DRC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1DRC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1DRC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1DRC';
				break;
		}
	}
	else if( GruntFaceNum == 1 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1DRC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1DRC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1DRC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1DRC';
				break;
		}
	}
	else if( GruntFaceNum == 1 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1DRC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1DRC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1DRC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1DRC';
				break;
		}
	}
	else if( GruntFaceNum == 1 )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1aface1DRC';
				break;
			Case 1:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1bface1DRC';
				break;
			Case 2:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1cface1DRC';
				break;
			Case 3:
				MultiSkins[ 0 ] == texture'm_characters.EDFsnch1dface1DRC';
				break;
		}
	}


function SetPartsSnatchedEffects( int SkinNum )
{
	local texture PartsTexture;

	PartsTexture = Default.MultiSkins[ 3 ];
//	log( self$" MESH : "$Mesh );
//	log( self$" MultiSkins[ 0 ] "$MultiSkins[ 0 ] );
//	log( self$" MultiSkins[ 2 ] "$MultiSkins[ 2 ] );
//
//	log( "PARTS TEXTURE2: "$PartsTexture );

	if( PartsTexture == texture'EDF1PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF1snch1apartRC';
				break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF1snch1bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF1snch1cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF1snch1dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF2PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF2PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF2snch2dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF3PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF3snch3apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF3snch3bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF3snch3cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF3snch3dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF8PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF8snch8apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF8snch8bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF8snch8cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF8snch8dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF9PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF9snch9apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF9snch9bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF9snch9cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF9snch9dpartRC'; break;
		}
	}
	if( PartsTexture == texture'EDF10PartsRC' )
	{
		Switch( SkinNum )
		{
			Case 0:
				MultiSkins[ 3 ] = texture'm_characters.EDF10snch10apartRC'; break;
			Case 1:
				MultiSkins[ 3 ] = texture'm_characters.EDF10snch10bpartRC'; break;
			Case 2:
				MultiSkins[ 3 ] = texture'm_characters.EDF10snch10cpartRC'; break;
			Case 3:
				MultiSkins[ 3 ] = texture'm_characters.EDF10snch10dpartRC'; break;
		}
	}

	//log( "Final Parts Texture: "$MultiSkins[ 3 ] );
}
*/
function PostBeginPlay()
{
	//DrawScaleMod = Rand( 14 );

	if( Mesh == dukemesh'EDF3' || Mesh == dukemesh'EDF2Desert' || Mesh == dukemesh'EDF3Desert' || Mesh == dukemesh'EDF6' || Mesh == dukemesh'EDF6Desert' )
		Texture = texture'EDF1Reflect1RC';

	if( Level.Game.IsA( 'dnSinglePlayer' ) && dnSinglePlayer( Level.Game ).SpeechCoordinator != None && !bSteelSkin )
	{
		SpeechCoordinator = EDFSpeechCoordinator( dnSinglePlayer( Level.Game ).SpeechCoordinator );
		SpeechCoordinator.AddGrunt( self );
	}

	//DrawScale += ( DrawScaleMod * 0.01 );

	SetupFace();
	Super.PostBeginPlay();
}
/*
state idling
{
	function BeginState()
	{
		PlayBottomAnim( 'B_KneelIdle', 0.2 , 0.1, true );
	}

begin:
	PlayBottomAnim( 'B_KneelIdle', 0.2 , 0.1, true );
	Sleep( 5.0 );
	PlayBottomAnim( 'None' );
	log( "Playing kneel up" );
DoIt:
	PlayBottomAnim( 'B_KneelUp',, 0.1, true );
	fINISHaNIM( 2 );
//	pLAYtOwAITING();
//	Sleep( 2.5 );
	Goto( 'DoIt' );
}
*/

function SetupFace()
{
	local int Decision;

	if( !bRandomFace )
		return;

	if( NPCFace != FACE_Random )
	{
		Switch ( NPCFace )
		{
			Case FACE_2:
				MultiSkins[ 0 ] = Faces[ 0 ];
				break;
			Case FACE_3:
				MultiSkins[ 0 ] = Faces[ 1 ];
				break;
			Default:
				MultiSkins[ 0 ] = Faces[ 2 ];
				break;
		}
	}
	else
	{
		Decision = Rand( 3 );
		if( Decision == 0 )
			MultiSkins[ 0 ] = Faces[ 0 ];
		else if( Decision == 1 )
			MultiSkins[ 0 ] = Faces[ 1 ];
		else if( Decision == 2 )
			MultiSkins[ 0 ] = Faces[ 2 ];

		if( MultiSkins[ 0 ] == None )
			MultiSkins[ 0 ] = Default.MultiSkins[ 0 ];
	}
	
	switch( MultiSkins[ 0 ] )
	{
		Case Texture'EDFsldrface1RC':
			GruntFaceNum = 0;
			break;
		Case Texture'EDFsldrface1DRC':
			GruntFaceNum = 1;
			break;
		Case Texture'EDFsldrface2RC':
			GruntFaceNum = 2;
			break;
		Case Texture'EDFsldrface2DRC':
			GruntFaceNum = 3;
			break;
		Case Texture'EDFsldrface3RC':
			GruntFaceNum = 4;
			break;
		Case Texture'EDFsldrface3DRC':
			GruntFaceNum = 5;
			break;
		Case Texture'EDFsldrface4RC':
			GruntFaceNum = 6;
			break;
		Case Texture'EDFsldrface4DRC':
			GruntFaceNum = 7;
			break;
		Case Texture'EDFsldrface5RC':
			GruntFaceNum = 8;
			break;
		Case Texture'EDFsldrface5DRC':
			GruntFaceNum = 9;
			break;
	}

	Default.MultiSkins[ 0 ] = MultiSkins[ 0 ];
	SetFaceSequences();
}	

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;

	if( bEyesShut )
	{
		CloseEyes();
		return false;
	}
    if( bVisiblySnatched )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Pupil_L');
		if (bone!=0)
		{			
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		}
		bone = minst.BoneFindNamed('Pupil_R');
		if (bone!=0)
		{
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		}
		return false;
	}
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if (BlinkDurationBase <= 0.0)
		return(false);

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if (BlinkTimer <= 0.0)
	{
		if (!bBlinked)
		{
			bBlinked = true;
			BlinkTimer = BlinkDurationBase + FRand()*BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = BlinkRateBase + FRand()*BlinkRateRandom;
		}
	}

	if (BlinkChangeTime <= 0.0)
	{
		if (bBlinked)
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
	}
	else
	{
		if (bBlinked)
		{
			CurrentBlinkAlpha += deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha > 1.0)
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha < 0.0)
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	
	if( BrowExpression == BROW_Lowered )
	{
		bone = minst.BoneFindNamed('Brow');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			t -= BlinkEyelidPosition*0.62; // angry brow
			minst.BoneSetTranslate(bone, t, false);
		}
	}	
	
	if( GetStateName() != 'TentacleThrust' )
	{
	if( MouthExpression == MOUTH_Frown )
	{
		bone = minst.BoneFindNamed('MouthCorner');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			t -= BlinkEyelidPosition*0.45; // frowny
			minst.BoneSetTranslate( bone, t, false );
		}
	}
	if( MouthExpression == MOUTH_Smile )
	{
		bone = minst.BoneFindNamed('MouthCorner');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			t += BlinkEyelidPosition*0.35; 
			minst.BoneSetTranslate( bone, t, false );
		}
	}
	}
	if( BrowExpression == BROW_Raised )
	{
		bone = minst.BoneFindNamed('Brow');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			t += BlinkEyelidPosition*0.42; // angry brow
			minst.BoneSetTranslate(bone, t, false);
		}
	}

	if( GetStateName() != 'TentacleThrust' ) 
	{
		// TEST... move brow
		bone = minst.BoneFindNamed('Brow');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			if (Health < Default.Health )
			{
				if (Health < int(Default.Health * 0.3))
					t += BlinkEyelidPosition*0.12; // surprise and alarm brow
				else
					t -= BlinkEyelidPosition*0.42; // angry brow
			}
			minst.BoneSetTranslate(bone, t, false);
		}

		// TEST... mouth corner brow
		bone = minst.BoneFindNamed('MouthCorner');
		if (bone!=0)
		{
			t = minst.BoneGetTranslate(bone, false, true);
			if (Health < Default.Health)
			{
				if (Health < int(Default.Health * 0.3))
					t -= BlinkEyelidPosition*0.25; // frowny
				else
					t += BlinkEyelidPosition*0.15; // smiley
			}
		}
		minst.BoneSetTranslate(bone, t, false);
	}
	return(true);
}

function TickTracking(float inDeltaTime)
{
	Super.TickTracking( inDeltaTime );
	EyeTracking.DesiredWeight = 0.2;
	EyeTracking.DesiredRotation = Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) + rot(0, int(FRand()*20384.0 - 8192.0), 0);
	EyeTracking.DesiredRotation.Roll = 0;
}

defaultproperties
{
	 //DrawScale=0.95
	 // Note: Old default was 50.
	 Health=35	
	 EgoKillValue=8
	 bAggressivetoplayer=true
     WeaponInfo(0)=(WeaponClass="dnGame.m16",PrimaryAmmoCount=999,altAmmoCount=25)
     //Health=50
     bIsHuman=True
     SoundSyncScale_Jaw=0.900000
     SoundSyncScale_MouthCorner=0.100000
     SoundSyncScale_Lip_L=0.700000
     GroundSpeed=420.000000
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     bSnatched=True
     Mesh=DukeMesh'c_characters.EDF1'
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     NPCFace=FACE_Random
     bRandomFace=true
	 Faces(0)=Texture'm_characters.EDFsldrface2RC'
	 Faces(1)=Texture'm_characters.EDFsldrface3RC'
	 Faces(2)=None
}

