//=============================================================================
// CannonBolt.
//=============================================================================
class CannonBolt extends KraalBolt;



#exec MESH IMPORT MESH=bolt1 ANIVFILE=MODELS\bolt1_a.3D DATAFILE=MODELS\bolt1_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bolt1 X=0 Y=0 Z=-0 YAW=64
#exec MESH SEQUENCE MESH=bolt1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bolt1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmisc1 FILE=..\unrealshare\MODELS\misc.PCX
#exec MESHMAP SCALE MESHMAP=bolt1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=bolt1 NUM=1 TEXTURE=Jmisc1

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage,200.0, 'exploded', MomentumTransfer, HitLocation );
	PlaySound(ImpactSound);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local SpriteSmokePuff s;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		s = spawn(class'SpriteSmokePuff',,,HitLocation);
		s.RemoteRole = ROLE_None;
	}
	BlowUp(HitLocation);
	destroy();
}

defaultproperties
{
     speed=+02000.000000
     MaxSpeed=+02000.000000
     Damage=+00060.000000
     Mesh=UnrealI.bolt1
     Class=UnrealI.CannonBolt
}
