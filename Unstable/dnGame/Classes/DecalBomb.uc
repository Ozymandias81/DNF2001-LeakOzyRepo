/*-----------------------------------------------------------------------------
	DecalBomb
	Author: Brandon Reinhart

    Advanced DecalBomb Technology!
-----------------------------------------------------------------------------*/
class DecalBomb extends Info;

#exec TEXTURE IMPORT NAME=S_DecalBomb FILE=Textures\Triggah_Bomb2.PCX Flags=2

var() bool			bNoMeshDecals;
var() bool			bNoLevelDecals;
var() bool			StandardBlood;
var() bool			StandardBulletHole;
var() int			TraceNum;
var() int			TraceNumVariance;
var() rotator		TraceRotationVariance;
var() float			MaxTraceDistance;
var() float			MeshDecalSize;
var() float			MeshDecalSizeVariance;
var() float			LevelDecalSize;
var() float			LevelDecalSizeVariance;
var() texture		Decals[16];
var() float			DecalLifespan;
var() bool			RandomRotation;
var() rotator		DecalRotation;
var() rotator		DecalRotationVariance;
var() bool			bTriggeredSpawn;
var() int			RandomSeed;

var () float BehaviorArgument	?("Argument for level decal behavior mode.");
var () enum EBehavior
{
	DB_Normal,
	DB_Permanant,
	DB_DestroyAfterArgumentSeconds,			
	DB_DestroyNotVisibleForArgumentSeconds,
} Behavior						?("How the level decals behave.");

simulated function PostBeginPlay()
{
	if ( !bTriggeredSpawn )
		DecalBombDeploy();
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	if ( bTriggeredSpawn )
		DecalBombDeploy();
}

simulated function DecalBombDeploy()
{
	local int ActualTraces, i, j, HitMeshTri, NumDecals;
	local Actor HitActor;
	local vector TraceStart, TraceEnd, HitMeshBarys, HitLoc, HitNorm;
	local rotator TraceDir;
	local texture DecalTex;

	if ( RandomSeed > 0 )
		Seed( RandomSeed );

	for (i=0; i<16; i++)
	{
		if (Decals[i] != None)
			NumDecals++;
	}

	ActualTraces = TraceNum + Rand(TraceNumVariance);
	for (i=0; i<ActualTraces; i++)
	{
		// Trace out and hit it!
		TraceStart = Location;
		TraceDir = Rotation;
		if (FRand() > 0.5)
			TraceDir.Pitch += Rand(TraceRotationVariance.Pitch/2);
		else
			TraceDir.Pitch -= Rand(TraceRotationVariance.Pitch/2);
		if (FRand() > 0.5)
			TraceDir.Yaw += Rand(TraceRotationVariance.Yaw/2);
		else
			TraceDir.Yaw -= Rand(TraceRotationVariance.Yaw/2);
		if (FRand() > 0.5)
			TraceDir.Roll += Rand(TraceRotationVariance.Roll/2);
		else
			TraceDir.Roll -= Rand(TraceRotationVariance.Roll/2);
		TraceEnd = Location + normal(vector(TraceDir))*MaxTraceDistance;
		HitActor = Trace( HitLoc, HitNorm, TraceEnd, TraceStart, true, , true, HitMeshTri, HitMeshBarys );

		DecalTex = None;
		if ( StandardBulletHole )
		{
			j = Rand(10);
			switch(j)
			{
				case 0: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood2BC';  break;
				case 1: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood3BC';  break;
				case 2: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood4BC';  break;
				case 3: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood5BC';  break;
				case 4: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood6BC';  break;
				case 5: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood10BC'; break;
				case 6: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood11BC'; break;
				case 7: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood7BC';  break;
				case 8: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood8BC';  break;
				case 9: DecalTex = Texture'm_dnweapon.weapon_efx.char_blood9BC';  break;
				default: break;
			}
		} 
		else if ( StandardBlood )
		{
			j = Rand(5);
			switch(j)
			{
				case 2: DecalTex = Texture't_generic.bloodsplats.bloodsplatter1R';  break;
				case 3: DecalTex = Texture't_generic.bloodsplats.bloodsplatter2R';  break;
				case 4: DecalTex = Texture't_generic.bloodsplats.bloodsplatter3R';  break;
				default: break;
			}
		} else
			DecalTex = Decals[Rand(NumDecals)];

		if (!bNoMeshDecals && (HitActor != None) && (HitActor != Level))
			ApplyMeshDecal( HitActor, HitLoc, HitNorm, HitMeshTri, HitMeshBarys, DecalTex );
		else if (!bNoLevelDecals && (HitActor == Level))
			ApplyLevelDecal( HitActor, HitLoc, HitNorm, DecalTex );
	}
}

simulated function ApplyMeshDecal( Actor HitActor, vector HitLoc, vector HitNorm, int HitMeshTri, vector HitMeshBarys, texture DecalTex )
{
	local MeshDecal a;
	local float size;

	a = spawn(class'MeshDecal');
	a.Style = Style;
	if (a != None)
	{
		if ( StandardBulletHole )
			size = 5.0+(FRand()*5.0-2.5);
		else if ( StandardBlood )
			size = 10.0+(FRand()*5.0-2.5);
		else
			size = MeshDecalSize+(FRand()*MeshDecalSizeVariance-(MeshDecalSizeVariance/2));
		
		a.LifeSpan = DecalLifeSpan;
		a.BuildDecal(HitActor, DecalTex, HitMeshTri, HitMeshBarys, FRand()*2.0*PI, size, size);
		a.DecalAttachToActor( HitActor );
	}
}

simulated function ApplyLevelDecal( Actor HitActor, vector HitLoc, vector HitNorm, texture DecalTex )
{
	local dnDecal_Delayed a;

	a = spawn(class'dnDecal_Delayed',,, HitLoc, rotator(HitNorm));
	a.Style = Style;
	if (a != None)
	{
		a.RandomRotation = RandomRotation;
		if (!RandomRotation)
		{
			a.DecalRotation = DecalRotation;
			if (FRand() > 0.5)
				a.DecalRotation.Pitch += Rand(DecalRotationVariance.Pitch/2);
			else
				a.DecalRotation.Pitch -= Rand(DecalRotationVariance.Pitch/2);
			if (FRand() > 0.5)
				a.DecalRotation.Yaw += Rand(DecalRotationVariance.Yaw/2);
			else
				a.DecalRotation.Yaw -= Rand(DecalRotationVariance.Yaw/2);
			if (FRand() > 0.5)
				a.DecalRotation.Roll += Rand(DecalRotationVariance.Roll/2);
			else
				a.DecalRotation.Roll -= Rand(DecalRotationVariance.Roll/2);
		}
		switch (Behavior)
		{
		case DB_Normal:
			a.Behavior = DB_Normal;
			break;
		case DB_Permanant:
			a.Behavior = DB_Permanant;
			break;
		case DB_DestroyAfterArgumentSeconds:
			a.Behavior = DB_DestroyAfterArgumentSeconds;
			break;
		case DB_DestroyNotVisibleForArgumentSeconds:
			a.Behavior = DB_DestroyNotVisibleForArgumentSeconds;
			break;
		}
		a.BehaviorArgument = BehaviorArgument;
		a.DrawScale = LevelDecalSize + LevelDecalSizeVariance*FRand();
		a.Decals[0] = DecalTex;
		a.LifeSpan = 0.0;
		a.bImportant = true;
		a.Initialize();
	}
}

defaultproperties
{
	bHidden=true
	bDirectional=true
	MeshDecalSize=5.0
	MeshDecalSizeVariance=5.0
	LevelDecalSize=1.0
	LevelDecalSizeVariance=0.0
	RandomRotation=true
	MaxTraceDistance=1000
	Behavior=DB_Permanant
	Texture=S_DecalBomb
	Style=STY_Modulated
	RemoteRole=ROLE_SimulatedProxy
}