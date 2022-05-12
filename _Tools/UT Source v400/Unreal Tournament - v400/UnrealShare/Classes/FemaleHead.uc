//=============================================================================
// FemaleHead.
//=============================================================================
class FemaleHead extends PlayerChunks;

simulated function Initfor(actor Other)
{
	Super.InitFor(Other);
	RotationRate = RotationRate/3;
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local BloodSpurt b;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		b = Spawn(class 'Bloodspurt',,,,rot(16384,0,0));
		if ( bGreenBlood )
			b.GreenBlood();		
		b.RemoteRole = ROLE_None;
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

#exec MESH IMPORT MESH=FemHead1 ANIVFILE=MODELS\g_f2h_a.3D DATAFILE=MODELS\g_f2h_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FemHead1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=FemHead1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FemHead1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jf2h1  FILE=MODELS\g_f2h.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=FemHead1 X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=FemHead1 NUM=1 TEXTURE=Jf2h1

defaultproperties
{
     Mesh=UnrealShare.FemHead1
     Class=UnrealShare.FemaleHead
}
