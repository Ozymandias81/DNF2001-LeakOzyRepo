//=============================================================================
// NPCFemale1.
//=============================================================================
class NPCFemale1 expands NPC;

// divide frame you want by # of frames
#exec OBJ LOAD FILE=..\meshes\c_characters.dmx

function PostBeginPlay()
{
	if( bVisiblySnatched )
	{
		MultiSkins[ 0 ] = texture'm_characters.FemaleHeadSnAh1dRC';
		MultiSkins[ 3 ] = texture'm_characters.FemalePartSnAh1ADRC';
		MultiSkins[ 4 ] = texture'm_characters.FemalePartSnAh1bdRC';
	}
	Super.PostBeginPlay();
}

defaultproperties
{
     Mesh=DukeMesh'c_characters.NPC_F_Civilian1'
     //SoundSyncScale_Jaw=1.050000
     //SoundSyncScale_MouthCorner=0.070000
     //SoundSyncScale_Lip_U=0.750000
     //SoundSyncScale_Lip_L=0.500000r
     SoundSyncScale_Jaw=0.450000
     SoundSyncScale_MouthCorner=0.095000
     SoundSyncScale_Lip_U=0.700000
     SoundSyncScale_Lip_L=0.450000
	 bVisiblySnatched=false
     Accessories(0)=class'dnMountables.M_HairLong'
}
