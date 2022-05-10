//=============================================================================
// EDFSoldier.uc
//=============================================================================
class EDFSoldier extends GruntSWAT;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\Textures\m_characters.dtx

var( NPCFace ) Enum ENPCFace
{
	FACE_Random,
	FACE_1,
	FACE_2,
	FACE_3,
} NPCFace;

function PostBeginPlay()
{
	local int Decision;

	local int Annoyer;

	for( Annoyer = 0; Annoyer <= 1; Annoyer++ );
	log( "****************************" );
	log( "Please remove reference to EDFSoldier: " );
	log( "I am at Location: " );
	log( "****************************" );

	if( NPCFace != FACE_Random )
	{
		Switch ( NPCFace )
		{
			Case FACE_2:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsldrface2RC';
				break;
			Case FACE_3:
				MultiSkins[ 0 ] = Texture'm_characters.EDFsldrface3RC';
				break;
			Default:
				MultiSkins[ 0 ] = Default.MultiSkins[ 0 ];
				break;
		}
	}
	else
	{
		Decision = Rand( 3 );
		if( Decision == 0 )
			MultiSkins[ 0 ] = Texture'm_characters.EDFsldrface3RC';
		else if( Decision == 1 )
			MultiSkins[ 0 ] = Texture'm_characters.EDFsldrface2RC';
		else if( Decision == 2 )
			MultiSkins[ 0 ] = None;
	}
	
	Super.PostBeginPlay();
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



defaultproperties
{
 
}
