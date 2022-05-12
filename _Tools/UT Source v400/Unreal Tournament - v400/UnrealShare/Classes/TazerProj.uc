//=============================================================================
// TazerProj.
//=============================================================================
class TazerProj extends Projectile;

#exec MESH IMPORT MESH=TazerProja ANIVFILE=MODELS\Cross_a.3D DATAFILE=MODELS\Cross_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TazerProja X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=TazerProja SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=TazerProja SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=TazerProja X=0.04 Y=0.04 Z=0.08
#exec OBJ LOAD FILE=Textures\FireEffect2.utx PACKAGE=UnrealShare.Effect2
#exec MESHMAP SETTEXTURE MESHMAP=TazerProja NUM=1 TEXTURE=UnrealShare.Effect2.FireEffect2

#exec AUDIO IMPORT FILE="Sounds\General\Expla02.wav" NAME="Expla02" GROUP="General"

function SuperExplosion()
{
	local RingExplosion2 r;

	HurtRadius(Damage*3.9, 240, 'jolted', MomentumTransfer*2, Location );
	
	r = Spawn(Class'RingExplosion2',,'',Location, Instigator.ViewRotation);
	r.PlaySound(r.ExploSound,,20.0,,1000,0.6);
	Destroy(); 
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{

		If (Other!=Instigator  && TazerProj(Other)==None)
		{
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function BeginState()
	{
		Velocity = vector(Rotation) * speed;	
	}
}


function Explode(vector HitLocation,vector HitNormal)
{
	local RingExplosion r;

	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	HurtRadius(Damage, 70, 'jolted', MomentumTransfer, Location );
	if (Damage > 60)
		r = Spawn(class'RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
	else
		r = Spawn(class'RingExplosion',,, HitLocation+HitNormal*8,rotator(HitNormal));

	r.PlaySound(r.ExploSound,,6);
	Destroy();
}

defaultproperties
{
     speed=1000.000000
     Damage=55.000000
     MomentumTransfer=70000
     ImpactSound=Sound'UnrealShare.General.Expla02'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     Mesh=Mesh'UnrealShare.TazerProja'
     bUnlit=True
     bMeshCurvy=False
     CollisionRadius=12.000000
     CollisionHeight=12.000000
     bProjTarget=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=101
     LightHue=165
     LightSaturation=72
     LightRadius=6
     bFixedRotationDir=True
	 bNetTemporary=false
     RotationRate=(Pitch=45345,Yaw=33453,Roll=63466)
     DesiredRotation=(Pitch=23442,Yaw=34234,Roll=34234)
}
