//=============================================================================
// TournamentFemale.
//=============================================================================
class TournamentFemale extends TournamentPlayer
	abstract;

#exec OBJ LOAD FILE=..\Sounds\FemaleSounds.uax PACKAGE=FemaleSounds

#exec TEXTURE IMPORT NAME=Woman FILE=TEXTURES\HUD\IFem2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=WomanBelt FILE=TEXTURES\HUD\IFemSBelt.PCX GROUP="Icons" MIPS=OFF

function PlayRightHit(float tweentime)
{
	if ( AnimSequence == 'RightHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}	

function PlayDying(name DamageType, vector HitLoc)
{
	local carcass carc;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();
			
	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead3',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
	{
		PlayDecap();
		return;
	}

	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead7',,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( (HitLoc.Z < Location.Z) && !class'GameInfo'.Default.bVeryLowGore && (FRand() < 0.6) )
		{
			PlayAnim('Dead5',,0.05);
			if ( Level.NetMode != NM_Client )
			{
				carc = Spawn(class 'UT_FemaleFoot',,, Location - CollisionHeight * vect(0,0,0.5));
				if (carc != None)
				{
					carc.Initfor(self);
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
			}
		}
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		PlayAnim('Dead9',, 0.1);
		return;
	}
		
	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap();
		else
			PlayAnim('Dead3',, 0.1);
		return;
	}
	
	//then hit in front or back	
	if ( FRand() < 0.5 ) 
		PlayAnim('Dead4',, 0.1);
	else
		PlayAnim('Dead1',, 0.1);
}

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead6',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'UT_HeadFemale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

defaultproperties
{
     drown=mdrown2fem
     breathagain=FemaleSounds.hgasp3
     HitSound3=FemaleSounds.linjur4
     HitSound4=FemaleSounds.hinjur4
	 Die=FemaleSounds.death1d
	 Deaths(0)=FemaleSounds.death1d
	 Deaths(1)=FemaleSounds.death2a
	 Deaths(2)=FemaleSounds.death3c
	 Deaths(3)=FemaleSounds.decap01
	 Deaths(4)=FemaleSounds.death41
	 Deaths(5)=FemaleSounds.death42
	 GaspSound=FemaleSounds.lgasp1
	 JumpSound=FemaleSounds.Fjump1
     CarcassType=TFemale1Carcass
     HitSound1=FemaleSounds.linjur2
     HitSound2=FemaleSounds.linjur3
     LandGrunt=FemaleSounds.lland1
	 UWHit1=FemaleSounds.UWHit01
	 UWHit2=MUWHit2
	 bIsFemale=true
	 StatusDoll=texture'Botpack.Woman'
	 StatusBelt=texture'Botpack.WomanBelt'
	 VoicePackMetaClass="BotPack.VoiceFemale"
}
