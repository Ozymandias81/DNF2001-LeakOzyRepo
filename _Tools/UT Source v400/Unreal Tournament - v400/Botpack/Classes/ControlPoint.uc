//=============================================================================
// ControlPoint.
//=============================================================================
class ControlPoint extends NavigationPoint;

#exec TEXTURE IMPORT NAME=GoldSkin2 FILE=..\unrealshare\models\gold.PCX GROUP="None"
#exec TEXTURE IMPORT NAME=RedSkin2 FILE=..\unrealshare\MODELS\ChromR.PCX GROUP=Skins 
#exec TEXTURE IMPORT NAME=BlueSkin2 FILE=..\unrealshare\MODELS\ChromB.PCX GROUP=Skins 

// Red Team
#exec MESH IMPORT MESH=DomR ANIVFILE=MODELS\DomR_a.3d DATAFILE=MODELS\DomR_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DomR X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=DomR SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=DomR SEQ=DomR STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=DomR MESH=DomR
#exec MESHMAP SCALE MESHMAP=DomR X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=DomR NUM=0 TEXTURE=RedSkin2

// Blue Team
#exec MESH IMPORT MESH=DomB ANIVFILE=MODELS\DomB_a.3d DATAFILE=MODELS\DomB_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DomB X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=DomB SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=DomB SEQ=DomB STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=DomB MESH=DomB
#exec MESHMAP SCALE MESHMAP=DomB X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=DomB NUM=0 TEXTURE=BlueSkin2

// Gold Team
#exec MESH IMPORT MESH=MercSymbol ANIVFILE=MODELS\MercSymbol_a.3d DATAFILE=MODELS\MercSymbol_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MercSymbol X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=MercSymbol SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MercSymbol SEQ=DomY                     STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=MercSymbol MESH=MercSymbol
#exec MESHMAP SCALE MESHMAP=MercSymbol X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=MercSymbol NUM=0 TEXTURE=GoldSkin2

// Neutral
#exec MESH IMPORT MESH=DomN ANIVFILE=MODELS\DomN_a.3d DATAFILE=MODELS\DomN_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DomN X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=DomN SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=DomN SEQ=DomN STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JDomN0 FILE=MODELS\ChromX.PCX GROUP=Skins
#exec MESHMAP NEW   MESHMAP=DomN MESH=DomN
#exec MESHMAP SCALE MESHMAP=DomN X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=DomN NUM=0 TEXTURE=JDomN0

#exec AUDIO IMPORT FILE="Sounds\Domination\takeDP2.WAV" NAME="ControlSound" GROUP="Domination"

var TeamInfo ControllingTeam;
var Pawn Controller;
var() Name RedEvent;
var() Name BlueEvent;
var() Name GreenEvent;
var() Name GoldEvent;
var() bool bSelfDisplayed;
var() localized String PointName;
var() Sound ControlSound;	
var   int ScoreTime;
var   bool bScoreReady;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		ControllingTeam, PointName;
}

function PostBeginPlay()
{
	if ( !Level.Game.IsA('Domination') )
		return;
	else
	{
		Super.PostBeginPlay();
		bHidden = !bSelfDisplayed;
	}

	// Log the event.
	if (Level.Game.LocalLog != None)
	{
		Level.Game.LocalLog.LogSpecialEvent("controlpoint_created", PointName);
	}
	if (Level.Game.WorldLog != None)
	{
		Level.Game.WorldLog.LogSpecialEvent("controlpoint_created", PointName);
	}
}

function string GetHumanName()
{
	return PointName;
}

function Touch(Actor Other)
{
	if ( !Other.bIsPawn || !Pawn(Other).bIsPlayer || !Level.Game.IsA('Domination') )
		return;

	Controller = Pawn(Other);
	if ( Controller.IsA('Bot') && (Controller.MoveTarget == self) )
		Controller.MoveTimer = -1.0; // stop moving toward this
	UpdateStatus();
}

function UpdateStatus()
{
	local Actor A;
	local Name E;
	local TeamInfo NewTeam;
	local TeamGamePlus T;
	local Bot B, B2;
	local Pawn P;
	local bool bNeedDefense, bTempDefense;

	T = TeamGamePlus(Level.Game);
	if ( Controller == None )
		NewTeam = None;
	else
        NewTeam = T.GetTeam(Controller.PlayerReplicationInfo.Team);

	if ( NewTeam == ControllingTeam )
		return;

	ControllingTeam = NewTeam;
	if ( ControllingTeam != None )
	{
		// Log the event.
		if (Level.Game.LocalLog != None)
		{
			Level.Game.LocalLog.LogSpecialEvent("controlpoint_capture", PointName, Controller.PlayerReplicationInfo.PlayerID);
		}
		if (Level.Game.WorldLog != None)
		{
			Level.Game.WorldLog.LogSpecialEvent("controlpoint_capture", PointName, Controller.PlayerReplicationInfo.PlayerID);
		}
		PlaySound(ControlSound, SLOT_None, 12.0);
		BroadcastLocalizedMessage( class'ControlPointMessage', Controller.PlayerReplicationInfo.Team, None, None, Self );
		B = Bot(Controller);
		if ( B != None )
		{
			bNeedDefense = false;
			bTempDefense = false;
			B.SendTeamMessage(None, 'OTHER', 11, 15);
			if ( (B.Orders != 'Follow') && (B.Orders != 'Hold') )
			{
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == ControllingTeam.TeamIndex) )
					{
						bNeedDefense = true; // only defend if at least one other player on team
						B2 = Bot(P);
						if ( B2 == None ) 
							bTempDefense = true;
						else if ( ((B2.OrderObject == self) && (B2.Orders == 'Defend'))
								|| ((B2.OrderObject == B) && (B2.Orders == 'Follow')) )
						{
							bNeedDefense = false;
							break;
						}
					}
				if ( bNeedDefense )
				{
					if ( bTempDefense || (FRand() < 0.35) )
					{
						B.SetOrders('Freelance', None);
						B.Orders = 'Defend';
					}
					else
					{
						B.SetOrders('Defend', None);
						BotReplicationInfo(B.PlayerReplicationInfo).OrderObject = self;
					}
					B.OrderObject = self;
				}
			}
		}
		else if ( Controller.IsA('TournamentPlayer') )
		{
			if ( TournamentPlayer(Controller).bAutoTaunt )
				Controller.SendTeamMessage(None, 'OTHER', 11, 15);
			if ( DeathMatchPlus(Level.Game).bRatedGame
					&& (Controller == DeathMatchPlus(Level.Game).RatedPlayer) )
				DeathMatchPlus(Level.Game).bFulfilledSpecial = true;
		}
	}
	if ( bSelfDisplayed )
		bHidden = false;

	if ( ControllingTeam == None )
	{
		bScoreReady = false;
		E = '';
		if ( bSelfDisplayed ) 
		{
			DrawScale=0.4;
			Mesh = mesh'DomN';
			Texture=texture'JDomN0';
			LightHue=0;
		    LightSaturation=255;
		}
	}	
	else
	{
		ScoreTime = 2;
		SetTimer(1.0, true);
		if ( bSelfDisplayed )
		{
			LightBrightness=255;
			LightSaturation=0;
		}
		if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Red )
		{
			E = RedEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.4;
				Mesh = mesh'DomR';
				Texture = texture'RedSkin2';
				LightHue=0;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Blue )
		{
			E = BlueEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.4;
				Mesh = mesh'DomB';
				Texture = texture'BlueSkin2'; 
				LightHue=170;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Green )
		{
			E = GreenEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=1.0;
				Mesh=mesh'UDamage';
				Texture=Texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen'; //FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'; 
				LightHue=85;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Gold )
		{
			E = GoldEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.7;
				Mesh=mesh'MercSymbol';
				Texture=texture'GoldSkin2';
				LightHue=35;
			}
		}
	}
	if ( E != '' )
		foreach AllActors(class'Actor', A, E )
		 Trigger(self, Controller);
}

function Timer()
{
	ScoreTime--;
	if (ScoreTime > 0)
		bScoreReady = false;
	else 
	{
		ScoreTime = 0;
		bScoreReady = true;
		SetTimer(0.0, false);
	}
}

defaultproperties
{
	ControlSound=sound'Botpack.Domination.ControlSound'
	RemoteRole=ROLE_SimulatedProxy
	PointName="Position"
	bStatic=false
	bNoDelete=true
	bCollideActors=true
	bSelfDisplayed=true
	Mesh=mesh'DomN'
    Texture=texture'JDomN0'
    DrawScale=0.4
	bUnlit=true
	AmbientGlow=255
    SoundRadius=64
    SoundVolume=255
    bFixedRotationDir=True
    RotationRate=(Yaw=5000)
    DesiredRotation=(Yaw=30000)
	bAlwaysRelevant=true
	LightType=LT_SubtlePulse
	LightEffect=LE_NonIncidence
	Physics=PHYS_Rotating
	DrawType=DT_Mesh
	Style=STY_Normal
	bMeshEnviroMap=true
	LightBrightness=255;
	LightRadius=7;
    LightHue=170
    LightSaturation=255
}
