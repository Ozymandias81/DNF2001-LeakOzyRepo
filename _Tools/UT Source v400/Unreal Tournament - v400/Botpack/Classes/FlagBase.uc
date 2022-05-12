//=============================================================================
// FlagBase.
//=============================================================================
class FlagBase extends NavigationPoint;

#exec AUDIO IMPORT FILE="Sounds\CTF\flagtaken.WAV" NAME="flagtaken" GROUP="CTF"

#exec MESH IMPORT MESH=newflag ANIVFILE=MODELS\newflag_a.3d DATAFILE=MODELS\newflag_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=newflag X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=newflag SEQ=All     STARTFRAME=0 NUMFRAMES=144
#exec MESH SEQUENCE MESH=newflag SEQ=newflag STARTFRAME=0 NUMFRAMES=144

#exec TEXTURE IMPORT NAME=JpflagB FILE=MODELS\N-Flag-B.PCX GROUP=Skins FLAGS=2 // twosided
#exec TEXTURE IMPORT NAME=JpflagR FILE=MODELS\N-Flag-R.PCX GROUP=Skins FLAGS=2 // twosided

#exec MESHMAP NEW   MESHMAP=newflag MESH=newflag
#exec MESHMAP SCALE MESHMAP=newflag X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=newflag NUM=0 TEXTURE=JpflagB

var() byte Team;
var() Sound TakenSound;

function PostBeginPlay()
{
	local CTFFlag myFlag;

	Super.PostBeginPlay();
	LoopAnim('newflag');
	if ( !Level.Game.IsA('CTFGame') )
		return;

	bHidden = false;
	if ( Team == 0 )
	{
		Skin=texture'JpflagR';	
		myFlag = Spawn(class'RedFlag');
	}
	else if ( Team == 1 )
		myFlag = Spawn(class'CTFFlag');

	myFlag.HomeBase = self;
	myFlag.Team = Team;
	CTFReplicationInfo(Level.Game.GameReplicationInfo).FlagList[Team] = myFlag;
}

function PlayAlarm()
{
	SetTimer(5.0, false);
	AmbientSound = TakenSound;
}

function Timer()
{
	AmbientSound = None;
}

defaultproperties
{
	Skin=texture'JpflagB'	
	bNoDelete=true
	bStatic=false
	bStasis=false
	bAlwaysRelevant=true
	SoundRadius=255
	SoundVolume=255
	TakenSound=Sound'flagtaken'
     DrawType=DT_Mesh
     Mesh=Mesh'Botpack.newflag'
     DrawScale=1.300000
     CollisionRadius=60.000000
     CollisionHeight=60.000000
     bCollideActors=True
     bBlockActors=False
     bBlockPlayers=False
}