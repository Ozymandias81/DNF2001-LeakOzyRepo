class NPCRandom extends NPC;

function PostBeginPlay()
{
	SetupRandomNPC();
	Super.PostBeginPlay();
}

	

function SetRandomNPCHead()
{
	local float Decision;

	Decision = Rand( 2 );

	Switch( Decision )
	{
		Case 0:
			MultiSkins[ 0 ] = texture'MaleHead1ARC';
			break;
		Case 1:
			MultiSkins[ 0 ] = texture'MaleHead2ARC';
			break;
		Case 2:
			MultiSkins[ 0 ] = texture'MaleHead4ARC';
	}
}

function SetRandomNPCShirt()
{
	local float Decision;

	Decision = Rand( 3 );

	Switch( Decision )
	{
		Case 0:
			MultiSkins[ 1 ] = texture'MaleShirt1ARC';
			break;
		Case 1:
			MultiSkins[ 1 ] = texture'MaleShirt2ARC';
			break;
		Case 2:
			MultiSkins[ 1 ] = texture'MaleShirt3ARC';
			break;
		Case 3:
			MultiSkins[ 1 ] = texture'MaleShirt4ARC';
			break;
	}
}

function SetRandomNPCPants()
{
	local float Decision;

	Decision = Rand( 3 );

	Switch( Decision )
	{
		Case 0:
			MultiSkins[ 2 ] = texture'MaleShorts1ARC';
			break;
		Case 1:
			MultiSkins[ 2 ] = texture'MaleShorts2ARC';
			break;
		Case 2:
			MultiSkins[ 2 ] = texture'MaleShorts3ARC';
			break;
		Case 3:
			MultiSkins[ 2 ] = texture'MaleShorts4ARC';
			break;
	}
}

function SetupRandomNPC()
{
	local int Decision;

	Decision = Rand( 4 );
	Switch( Decision )
	{
		Case 0:
			Mesh=DukeMesh'c_characters.NPC_M_BellyA';
			SoundSyncScale_Jaw=1.050000;
			SoundSyncScale_MouthCorner=0.070000;
			SoundSyncScale_Lip_U=0.750000;
			SoundSyncScale_Lip_L=0.500000;	
			SetRandomNPCHead();
			SetRandomNPCShirt();
			SetRandomNPCPants();
			break;
		
		Case 1:
			Mesh=DukeMesh'c_characters.NPC_M_ThinA';
			SetRandomNPCHead();
			SetRandomNPCShirt();
			SetRandomNPCPants();
			break;

		Case 2:
			Mesh=DukeMesh'c_characters.NPC_M_OldA';
			SetRandomNPCShirt();
			SetRandomNPCPants();
			break;

		Case 3:
			Mesh=DukeMesh'c_characters.NPC_M_FatA';
			SetRandomNPCHead();
			SetRandomNPCShirt();
			SetRandomNPCPants();
			break;
	}
}

DefaultProperties
{
     Mesh=DukeMesh'c_characters.NPC_M_BellyA'
}
