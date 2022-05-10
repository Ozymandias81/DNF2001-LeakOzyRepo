//=============================================================================
// HoloDuke.
//=============================================================================
class HoloDuke expands Inventory;

#exec MESH IMPORT MESH=Flashl ANIVFILE=MODELS\flashl_a.3D DATAFILE=MODELS\flashl_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Flashl X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=flashl SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=flashl SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JFlashl1 FILE=MODELS\flashl.PCX GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Flashl X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=flashl NUM=1 TEXTURE=Jflashl1


#exec OBJ LOAD FILE=..\Textures\m_dukeitems.dtx
#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx

var float TimeChange;
var () sound JetpackLoopSound;

state Activated
{
	function endstate()
	{
		bActive = false;		
	}
	
	function Tick( float DeltaTime )
	{
		TimeChange += DeltaTime*10;
		if (TimeChange > 1) 
		{
			Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}
		
		if ( Pawn(Owner) == None )
		{
			UsedUp();
			return;		
		}
		
		if (Charge<-0) 
		{
//			Pawn(Owner).ClientMessage(ExpireMessage);		
			UsedUp();		
		}
		

	}
	function Timer(optional int TimerNum)
	{
		PlaySound(JetpackLoopSound);
	}
	
	function BeginState()
	{
		TimeChange = 0;
		PlayerPawn(Owner).UnderWaterTime = PlayerPawn(Owner).Default.UnderWaterTime;	
		PlaySound(ActivateSound);
		SetTimer(1.0,true);
		bActive=true;
//		PlayerPawn(Owner).GotoState('JetpackFlying');
	}
	
Begin:
}

function UsedUp()
{
	//PlayerPawn(Owner).StartWalk();
	PlayerPawn(Owner).SetControlState(CS_Normal);
	super.UsedUp();
}

state DeActivated
{
Begin:
	//s.Destroy();
	
	//PlayerPawn(Owner).StartWalk();
	PlayerPawn(Owner).SetControlState(CS_Normal);
	PlaySound(DeactivateSound);

}

defaultproperties
{
     JetpackLoopSound=Sound'dnGame.JetpackLoop'
     dnInventoryCategory=5
     bActivatable=True
     RespawnTime=40.000000
     PickupViewMesh=Mesh'c_dukeitems.Jetpack'
     Charge=300
     MaxCharge=300
     Icon=Texture'hud_effects.mitem_chainsaw'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'c_dukeitems.Jetpack'
     AmbientGlow=96
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=4.000000
     LightBrightness=100
     LightHue=33
     LightSaturation=187
     LightRadius=7
}
