class Health extends PickUp;

#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH2.WAV"  NAME="Health2"     GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_Health FILE=TEXTURES\HUD\i_Health.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=HealthM ANIVFILE=MODELS\aniv38.3D DATAFILE=MODELS\data38.3D LODSTYLE=8
#exec MESH LODPARAMS MESH=HealthM STRENGTH=0.3
#exec  MESH ORIGIN MESH=HealthM X=0 Y=0 Z=0 YAW=0
#exec  MESH SEQUENCE MESH=HealthM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec  TEXTURE IMPORT NAME=Jhealth1 FILE=MODELS\health.PCX GROUP="Skins" FLAGS=2
#exec  MESHMAP SCALE MESHMAP=HealthM X=0.02 Y=0.02 Z=0.04
#exec  MESHMAP SETTEXTURE MESHMAP=HealthM NUM=0 TEXTURE=Jhealth1 TLOD=5

var() int HealingAmount;
var() bool bSuperHeal;

event float BotDesireability(Pawn Bot)
{
	local float desire;
	local int HealMax;

	HealMax = Bot.Default.Health;
	if (bSuperHeal) HealMax = HealMax * 2.0;
	desire = Min(HealingAmount, HealMax - Bot.Health);

	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( Bot.Health < 40 )
		return ( FMin(0.03 * desire, 2.2) );
	else
		return ( FMin(0.015 * desire, 2.0) ); 
}

function PlayPickupMessage(Pawn Other)
{
	Other.ClientMessage(PickupMessage$HealingAmount, 'Pickup');
}

auto state Pickup
{	
	function Touch( actor Other )
	{
		local int HealMax;
		local Pawn P;
			
		if ( ValidTouch(Other) ) 
		{	
			P = Pawn(Other);	
			HealMax = P.default.health;
			if (bSuperHeal) HealMax = HealMax * 2.0;
			if (P.Health < HealMax) 
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, P);
				P.Health += HealingAmount;
				if (P.Health > HealMax) P.Health = HealMax;
				PlayPickupMessage(P);
				PlaySound (PickupSound,,2.5);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);		
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
     HealingAmount=20
     PickupMessage="You picked up a Health Pack +"
     RespawnTime=20.000000
     PickupViewMesh=Mesh'UnrealShare.HealthM'
     MaxDesireability=0.500000
     PickupSound=Sound'UnrealShare.Pickups.Health2'
     Icon=Texture'UnrealShare.Icons.I_Health'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'UnrealShare.HealthM'
     AmbientGlow=64
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=8.000000
     Mass=10.000000
}
