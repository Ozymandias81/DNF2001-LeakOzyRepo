//=============================================================================
// SlotMachineBank.
//=============================================================================
class SlotMachineBank expands InfoActor;
//#exec OBJ LOAD FILE=..\Sounds\a_zone1_vegas.dfx  PACKAGE=a_zone1_vegas
//#exec OBJ LOAD FILE=..\Textures\Vegas.dtx		 PACKAGE=Vegas

struct Rotor
{
	var () name SurfaceTag;
	var    int  SurfaceIndex;
	var    int  Velocity;
};

struct SlotMachine
{
	var bool Active;		// Internal active flag.
	var () Rotor Rotors[3];
	var float TimeSpinning;
};

struct SlotMachine2
{
	var  int DollarsBet;
	var  Pawn Instigator;
};
				
struct SlotMachine3
{
	var int FinalRotorPositions[3];
};

struct SlotMachine4
{
	var int DamageLeft;
};

struct SlotMachine5
{
	var () name PayoutSurfaceTag;
};

struct SlotMachine6
{
	var int PayoutSurfaceIndex;
};

struct SlotMachine7
{
	var texture PreviousTexture;
	var int   BlinksRemaining;
	var float BlinkTimeRemaining;
};

var () SlotMachine  SlotMachines [32];
var () SlotMachine2 SlotMachines2[32];
var () SlotMachine3 SlotMachines3[32];
var () SlotMachine4 SlotMachines4[32];
var () SlotMachine5 SlotMachines5[32];
var () SlotMachine6 SlotMachines6[32];
var () SlotMachine7 SlotMachines7[32];

var () int RotorSymbols;				// Number of symbols on each rotor.
var () int RotorTopVelocity;			// Fastest a rotor can spin
var int    RotorTextureV;
var () float InitialSpinTime;
var () float AdditionalRotorSpinTime;
var () int RotorSymbolOffset;
var () int RotorPixelOffset;

var () sound SoundInsertCoin[3];
var () sound SoundPullLever;
var () sound SoundWheelStop;
var () sound SoundWin[3];
var () sound SoundSpin;
var () int MaxDamage;

var () texture PayoutTextures[30];
var () texture PayoutTextureNone;
var () texture PayoutTextureBlank;

var bool	bPlayInsertCoinSound;
var float	PlayInsertCoinSoundTime;
var int		PlayInsertCoinSoundIndex;
var Pawn	SoundInstigator;

function PostBeginPlay()
{
	local int i, j, k;
	local texture t;
	
	for(i=0;i<ArrayCount(SlotMachines);i++)
	{
		SlotMachines[i].Active=false;
		SlotMachines[i].TimeSpinning=0;
		SlotMachines4[i].DamageLeft=MaxDamage;
		SlotMachines7[i].BlinksRemaining=-1;

		if(SlotMachines5[i].PayoutSurfaceTag!='')
		{
			SlotMachines6[i].PayoutSurfaceIndex=FindSurfaceByName(SlotMachines5[i].PayoutSurfaceTag);
			if(SlotMachines6[i].PayoutSurfaceIndex>=0)
				SetSurfaceTexture(SlotMachines6[i].PayoutSurfaceIndex,PayoutTextureNone);
		}
		
		for(j=0;j<ArrayCount(SlotMachines[i].Rotors);j++)
		{
			if(SlotMachines[i].Rotors[j].SurfaceTag=='')	
			{
				SlotMachines[i].Rotors[j].SurfaceIndex=-1;
			} else
			{
				
				SlotMachines[i].Rotors[j].SurfaceIndex=FindSurfaceByName(SlotMachines[i].Rotors[j].SurfaceTag);
				if(SlotMachines[i].Rotors[j].SurfaceIndex!=-1)
				{
					t=GetSurfaceTexture(SlotMachines[i].Rotors[j].SurfaceIndex);
					RotorTextureV=t.VSize;
					// Randomize this rotor:
					SetSurfacePan(SlotMachines[i].Rotors[j].SurfaceIndex,GetSurfaceUPan(SlotMachines[i].Rotors[j].SurfaceIndex),(Rand(RotorSymbols)*(RotorTextureV/RotorSymbols))+RotorPixelOffset);
				}
			}
		}
	}	
}

function bool ActivateMachine(int MachineIndex, optional Pawn Instigator)
{
	local int i, j;
	local float f;
	local bool doOver;
	
	if(MachineIndex>=ArrayCount(SlotMachines)) 
		return false;
	
	if(SlotMachines4[MachineIndex].DamageLeft<=0)
	{
//		Instigator.ClientMessage("That machine is too damaged to use.");
		return false;
	}

	if(SlotMachines[MachineIndex].Active)
	{
//		Instigator.ClientMessage("That machine is already active.");
		return false;
	}

	if(SlotMachines2[MachineIndex].DollarsBet<=0)
	{
//		Instigator.ClientMessage("You must place a bet first.");
		return false;
	}
	
	if (Instigator.IsA('DukePlayer'))
	{
		if (DukePlayer(Instigator).DukesHand.IsBusy())
			return false;
	
		DukePlayer(Instigator).Hand_QuickAnim('SlapButton',,0.6);
	}
	
	SetSurfaceTexture(SlotMachines6[MachineIndex].PayoutSurfaceIndex,PayoutTextureBlank);

	SlotMachines[MachineIndex].Active=true;
	SlotMachines2[MachineIndex].Instigator=Instigator;
	for(i=0;i<ArrayCount(SlotMachines[i].Rotors);i++)	
		SlotMachines[MachineIndex].Rotors[i].Velocity=(RotorTopVelocity/4)*3+Rand(RotorTopVelocity/4);

	Instigator.PlaySound(SoundPullLever);
	Instigator.AmbientSound=SoundSpin;
	
	SlotMachines3[MachineIndex].FinalRotorPositions[0]=0;
	SlotMachines3[MachineIndex].FinalRotorPositions[1]=0;
	SlotMachines3[MachineIndex].FinalRotorPositions[2]=0;
	
	f=frand();
	//if(Instigator.Cash<10) f/=4;

	//Instigator.ClientMessage("Probability: "$f);
	if(f<=0.000046*3) 
	{
		//Instigator.ClientMessage("3 Nukes");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=5;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=5;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=5;
	} else if(f<=0.000153*24)
	{
		//Instigator.ClientMessage("3 Sevens");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=4;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=4;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=4;
	} else if(f<=0.000275*16)
	{
		//Instigator.ClientMessage("3 ThreeBars");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=2;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=2;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=2;
	} else if(f<=0.000458*40)
	{
		//Instigator.ClientMessage("3 TwoBars");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=1;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=1;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=1;
	} else if(f<=0.000801*30)
	{
		//Instigator.ClientMessage("3 OneBars");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=0;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=0;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=0;
	} else if(f<=0.001099*20)
	{
		//Instigator.ClientMessage("3 AnyBars");
		SlotMachines3[MachineIndex].FinalRotorPositions[0]=Rand(2);
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=Rand(2);
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=Rand(2);

		while(SlotMachines3[MachineIndex].FinalRotorPositions[0]==SlotMachines3[MachineIndex].FinalRotorPositions[1])
			SlotMachines3[MachineIndex].FinalRotorPositions[0]=Rand(2);
	} else if(f<0.00820*6)
	{
		//Instigator.ClientMessage("2 Cherries");

		SlotMachines3[MachineIndex].FinalRotorPositions[0]=3;
		SlotMachines3[MachineIndex].FinalRotorPositions[1]=3;
		SlotMachines3[MachineIndex].FinalRotorPositions[2]=3;
		
		j=Rand(3);
		do SlotMachines3[MachineIndex].FinalRotorPositions[j]=Rand(6);
		until(SlotMachines3[MachineIndex].FinalRotorPositions[j]!=3);
	} else if(f<(0.153778))
	{

		for(j=0;j<3;j++)
			do SlotMachines3[MachineIndex].FinalRotorPositions[j]=Rand(6);
			until(SlotMachines3[MachineIndex].FinalRotorPositions[j]!=3);

		j=Rand(3);
		SlotMachines3[MachineIndex].FinalRotorPositions[j]=3;
	} else
	{
		//Instigator.ClientMessage("You Lose.");

		/* Pick non cherries to start with: */
		for(j=0;j<3;j++)
		{
			SlotMachines3[MachineIndex].FinalRotorPositions[j]=Rand(6);
		
			while(SlotMachines3[MachineIndex].FinalRotorPositions[j]==3)
				SlotMachines3[MachineIndex].FinalRotorPositions[j]=Rand(6);			
		}
		do
		{
			doOver=false;
		
			/* Make sure the first and second are not equal to prevent 3 of a kind: */
			while((SlotMachines3[MachineIndex].FinalRotorPositions[0]==SlotMachines3[MachineIndex].FinalRotorPositions[Rand(2)+1])||(SlotMachines3[MachineIndex].FinalRotorPositions[0]==3))
			{
				SlotMachines3[MachineIndex].FinalRotorPositions[0]=Rand(6);
				doOver=true;
			}
			/* Make sure we don't have 3 bars: */
			j=Rand(3);
			while(SlotMachines3[MachineIndex].FinalRotorPositions[j]<4)	/* No cherries or bars */
			{
				SlotMachines3[MachineIndex].FinalRotorPositions[j]=Rand(6);
				doOver=true;
			}
		} until(!doOver);		
	}

	return true;
}

function bool AddBet(int MachineIndex, optional Pawn Instigator)
{
	if(SlotMachines4[MachineIndex].DamageLeft<=0)
	{
//		Instigator.ClientMessage("That machine is too damaged to use.");
		return false;
	}

	if(SlotMachines[MachineIndex].Active)
	{
//		Instigator.ClientMessage("That machine is already active.");
		return false;
	}
	
	if(Instigator.Cash<=0)
	{
//		Instigator.ClientMessage("You don't have any money!");
		return false;
	}
	
	if(SlotMachines2[MachineIndex].DollarsBet>=3)
	{
//		Instigator.ClientMessage("You have already bet the maximum.");
		return false;
	}
	
	if (Instigator.IsA('DukePlayer'))
	{
		if (DukePlayer(Instigator).DukesHand.IsBusy())
			return false;
		
		DukePlayer(Instigator).Hand_QuickAnim('DropCoin_Start','DropCoin',0.6);
	}

	bPlayInsertCoinSound = true;
	PlayInsertCoinSoundTime = 0.0f;
	PlayInsertCoinSoundIndex = SlotMachines2[MachineIndex].DollarsBet;
	SoundInstigator = Instigator;

	Instigator.AddCash(-1);
	SlotMachines2[MachineIndex].DollarsBet++;

	return true;
}

function DamageMachine(int MachineIndex, int amount)
{
	SlotMachines4[MachineIndex].DamageLeft-=amount;
}

function Timer(optional int TimerNum)
{
	Instigator.AmbientSound=none;
}

function Win(pawn TheInstigator, int Amount, int MachineIndex)
{
	local texture t;

	Instigator=TheInstigator;
//	Instigator.ClientMessage("You Win!");
	TheInstigator.AmbientSound=SoundWin[Rand(3)];
	SetTimer(1+float(Amount/100)+frand()*0.25,false);
	Instigator.AddCash(Amount);

	switch(Amount)
	{
		case 1:  t=PayoutTextures[0]; break;
		case 2:  t=PayoutTextures[1]; break;
		case 3:  t=PayoutTextures[2]; break;
		case 5:  t=PayoutTextures[3]; break;
		case 10: t=PayoutTextures[4]; break;
		case 15: t=PayoutTextures[5]; break;
		case 20: t=PayoutTextures[6]; break;
		case 25: t=PayoutTextures[7]; break;
		case 30: t=PayoutTextures[8]; break;
		case 40: t=PayoutTextures[9]; break;
		case 50: t=PayoutTextures[10]; break;
		case 75: t=PayoutTextures[11]; break;
		case 80: t=PayoutTextures[12]; break;
		case 120: t=PayoutTextures[13]; break;
		case 160: t=PayoutTextures[14]; break;
		case 240: t=PayoutTextures[15]; break;
		case 800: t=PayoutTextures[16]; break;
		case 1600: t=PayoutTextures[17]; break;
		case 2400: t=PayoutTextures[18]; break;
		default: t=PayoutTextureNone; break;
	}
	
	SetSurfaceTexture(SlotMachines6[MachineIndex].PayoutSurfaceIndex,t);
	SlotMachines7[MachineIndex].BlinksRemaining=6;
	SlotMachines7[Machineindex].BlinkTimeRemaining=0.4;
	SlotMachines7[Machineindex].PreviousTexture=PayoutTextureBlank;
}
function Tick(float DeltaSeconds)
{
	local int i,j, temp;
	local int uPan, vPan, vPanThisFrame;
	local int stoppingRotor;
	local int r1, r2, r3;
	local bool payout;
	local int basePayout;
	local texture tt;
	
	if (bPlayInsertCoinSound)
	{
		PlayInsertCoinSoundTime += DeltaSeconds;

		if (PlayInsertCoinSoundTime >= 0.4)		// Hard coded hack
		{
			SoundInstigator.PlaySound(SoundInsertCoin[PlayInsertCoinSoundIndex]);
			bPlayInsertCoinSound = false;
		}
	}

	for(i=0;i<ArrayCount(SlotMachines);i++)
	{
	
		if(SlotMachines7[i].BlinksRemaining>0)
		{
			SlotMachines7[i].BlinkTimeRemaining-=DeltaSeconds;
			if(SlotMachines7[i].BlinkTimeRemaining<=0)
			{
				SlotMachines7[i].BlinksRemaining--;
				SlotMachines7[i].BlinkTimeRemaining+=0.25;
				tt=GetSurfaceTexture(SlotMachines6[i].PayoutSurfaceIndex);				
				SetSurfaceTexture(SlotMachines6[i].PayoutSurfaceIndex,SlotMachines7[i].PreviousTexture);
				SlotMachines7[i].PreviousTexture=tt;
			}
		}
		
		if(!SlotMachines[i].Active) continue;

		if(SlotMachines4[i].DamageLeft<=0)
		{
			SlotMachines[i].Active=false;
			Instigator.AmbientSound=none;
			SlotMachines2[i].Instigator.AmbientSound=none;
			continue;
		}
		

		SlotMachines[i].TimeSpinning+=DeltaSeconds;
		
		// No stopping rotors for the time being
		stoppingRotor=-1;
		if((SlotMachines[i].TimeSpinning>=InitialSpinTime)
		 &&(SlotMachines[i].Rotors[0].Velocity!=0))
		{
			stoppingRotor=0;
		} 
		else if((SlotMachines[i].TimeSpinning>=InitialSpinTime+AdditionalRotorSpinTime)
		     &&(SlotMachines[i].Rotors[1].Velocity!=0))
		{
			stoppingRotor=1;
		}
		else if((SlotMachines[i].TimeSpinning>=InitialSpinTime+(AdditionalRotorSpinTime*2))
		     &&(SlotMachines[i].Rotors[2].Velocity!=0))
		{
			stoppingRotor=2;
		}
		
		payout=false;
		for(j=0;j<ArrayCount(SlotMachines[i].Rotors);j++)
		{
			uPan=GetSurfaceUPan(SlotMachines[i].Rotors[j].SurfaceIndex);
			vPan=GetSurfaceVPan(SlotMachines[i].Rotors[j].SurfaceIndex)-RotorPixelOffset;
			
			vPanThisFrame=int(SlotMachines[i].Rotors[j].Velocity*DeltaSeconds);
			if(stoppingRotor==j)
			{
				// Compute Distance to next rotor symbol:
				temp=(RotorTextureV/RotorSymbols)-vPan%(RotorTextureV/RotorSymbols);

				
				if(temp<vPanThisFrame)
				{

					r1=(vPan+temp)/(RotorTextureV/RotorSymbols);
					r1=(r1+RotorSymbolOffset)%8;
				
					switch(j)
					{
						case 0:
							switch(r1)
							{
								case 0: r1=0; break;
								case 1: r1=1; break;
								case 2: r1=3; break;
								case 3: r1=4; break;
								case 4: r1=5; break;
								case 5: r1=2; break;
								case 6: r1=3; break;
								case 7: r1=1; break;
							} 
							break;
			
						case 1:
							switch(r1)
							{
								case 0: r1=1; break;
								case 1: r1=5; break;
								case 2: r1=4; break;
								case 3: r1=0; break;
								case 4: r1=3; break;
								case 5: r1=2; break;
								case 6: r1=0; break;
								case 7: r1=3; break;
							}
							break;

						case 2:
							switch(r1)
							{
								case 0: r1=3; break;
								case 1: r1=0; break;
								case 2: r1=4; break;
								case 3: r1=1; break;
								case 4: r1=2; break;
								case 5: r1=5; break;
								case 6: r1=3; break;
								case 7: r1=2; break;
							};
							break;
					};	
					
					if(SlotMachines3[i].FinalRotorPositions[j]==r1)
					{		
						vPan+=temp;
						vPanThisFrame=0;
						SlotMachines[i].Rotors[j].Velocity=0;
						SlotMachines2[i].Instigator.PlaySound(SoundWheelStop);
						if(j==2)
						{
							SlotMachines[i].Active=false;
							SlotMachines[i].TimeSpinning=0;
							/* Check for payouts. */
							payout=true;
							Instigator.AmbientSound=none;
							SlotMachines2[i].Instigator.AmbientSound=none;
						}
					}
				} 
			}
			
			vPan+=vPanThisFrame;
			
			vPan=vPan%RotorTextureV;
			SetSurfacePan(SlotMachines[i].Rotors[j].SurfaceIndex,UPan,VPan+RotorPixelOffset);
		}

		/* Payout if needed: */
		if(payout)
		{
			Instigator.AmbientSound=none;
			r1=(GetSurfaceVPan(SlotMachines[i].Rotors[0].SurfaceIndex)-RotorPixelOffset)/(RotorTextureV/RotorSymbols);
			r2=(GetSurfaceVPan(SlotMachines[i].Rotors[1].SurfaceIndex)-RotorPixelOffset)/(RotorTextureV/RotorSymbols);
			r3=(GetSurfaceVPan(SlotMachines[i].Rotors[2].SurfaceIndex)-RotorPixelOffset)/(RotorTextureV/RotorSymbols);
			r1=(r1+RotorSymbolOffset)%8;
			r2=(r2+RotorSymbolOffset)%8;
			r3=(r3+RotorSymbolOffset)%8;
			
			switch(r1)
			{
				case 0: r1=0; break;
				case 1: r1=1; break;
				case 2: r1=3; break;
				case 3: r1=4; break;
				case 4: r1=5; break;
				case 5: r1=2; break;
				case 6: r1=3; break;
				case 7: r1=1; break;
			}
			
			switch(r2)
			{
				case 0: r2=1; break;
				case 1: r2=5; break;
				case 2: r2=4; break;
				case 3: r2=0; break;
				case 4: r2=3; break;
				case 5: r2=2; break;
				case 6: r2=0; break;
				case 7: r2=3; break;
			}

			switch(r3)
			{
				case 0: r3=3; break;
				case 1: r3=0; break;
				case 2: r3=4; break;
				case 3: r3=1; break;
				case 4: r3=2; break;
				case 5: r3=5; break;
				case 6: r3=3; break;
				case 7: r3=2; break;
			}
			
			/* Check for any 3 bars: */
			if((r1==r2)&&(r2==r3))
			{
				basePayout=0;
				switch(r1)
				{
					case 0: basePayout=10;   break;	// Single Bar
					case 1: basePayout=25;   break;	// Double Bar
					case 2: basePayout=40;   break;	// Triple Bar
					case 3: basePayout=10;   break;	// Cherries
					case 4: basePayout=80;  break;	// 7
					case 5: basePayout=800; break;	// Nuke
				}
				basePayout*=SlotMachines2[i].DollarsBet;
//				SlotMachines2[i].Instigator.ClientMessage("You Win.");
				Win(SlotMachines2[i].Instigator,basePayout,i);
			} else if(r1==3||r2==3||r3==3)
			{
				/* Single or double cherry: */
				j=0;
				if(r1==3) j++;
				if(r2==3) j++;
				if(r3==3) j++;
				     if(j==1) { basePayout=1;  }
				else if(j==2) { basePayout=5;  }
				else          basePayout=0;
				
				basePayout*=SlotMachines2[i].DollarsBet;
				if(basePayout>0)
				{
					Win(SlotMachines2[i].Instigator,basePayout,i);
				}
			} else if((r1==0||r1==1||r1==2)&&(r2==0||r2==1||r2==2)&&(r3==0||r3==1||r3==2))
			{
				basePayout=5*SlotMachines2[i].DollarsBet;
				Win(SlotMachines2[i].Instigator,basePayout,i);
			} else
			{
				SetSurfaceTexture(SlotMachines6[i].PayoutSurfaceIndex,PayoutTextureNone);
				SlotMachines7[i].BlinksRemaining=6;
				SlotMachines7[i].BlinkTimeRemaining=0.4;
				SlotMachines7[i].PreviousTexture=PayoutTextureBlank;

//				SlotMachines2[i].Instigator.ClientMessage("You lose.");
			}
			SlotMachines2[i].DollarsBet=0;
			SlotMachines2[i].Instigator=none;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
}

defaultproperties
{
     SlotMachines5(0)=(PayoutSurfaceTag=S1)
     RotorSymbolOffset=2
     RotorPixelOffset=16
     SoundInsertCoin(0)=Sound'a_zone1_vegas.Casino.SlotCoin22'
     SoundInsertCoin(1)=Sound'a_zone1_vegas.Casino.SlotCoin22'
     SoundInsertCoin(2)=Sound'a_zone1_vegas.Casino.SlotCoin33'
     SoundPullLever=Sound'a_zone1_vegas.Casino.SlotPull09'
     SoundWheelStop=Sound'a_zone1_vegas.Casino.SlotStop16'
     SoundWin(0)=Sound'a_zone1_vegas.Casino.SlotPayLoop02'
     SoundWin(1)=Sound'a_zone1_vegas.Casino.SlotPayLoop04'
     SoundWin(2)=Sound'a_zone1_vegas.Casino.SlotPayLoop09'
     SoundSpin=Sound'a_zone1_vegas.Casino.SlotSpinLp13'
     MaxDamage=20
     PayoutTextures(0)=Texture'vegas.LedScores.slotled_1'
     PayoutTextures(1)=Texture'vegas.LedScores.slotled_2'
     PayoutTextures(2)=Texture'vegas.LedScores.slotled_3'
     PayoutTextures(3)=Texture'vegas.LedScores.slotled_5'
     PayoutTextures(4)=Texture'vegas.LedScores.slotled_10'
     PayoutTextures(5)=Texture'vegas.LedScores.slotled_15'
     PayoutTextures(6)=Texture'vegas.LedScores.slotled_20'
     PayoutTextures(7)=Texture'vegas.LedScores.slotled_25'
     PayoutTextures(8)=Texture'vegas.LedScores.slotled_30'
     PayoutTextures(9)=Texture'vegas.LedScores.slotled_40'
     PayoutTextures(10)=Texture'vegas.LedScores.slotled_50'
     PayoutTextures(11)=Texture'vegas.LedScores.slotled_75'
     PayoutTextures(12)=Texture'vegas.LedScores.slotled_80'
     PayoutTextures(13)=Texture'vegas.LedScores.slotled_120'
     PayoutTextures(14)=Texture'vegas.LedScores.slotled_160'
     PayoutTextures(15)=Texture'vegas.LedScores.slotled_240'
     PayoutTextures(16)=Texture'vegas.LedScores.slotled_800'
     PayoutTextures(17)=Texture'vegas.LedScores.slotled_1600'
     PayoutTextures(18)=Texture'vegas.LedScores.slotled_2400'
     PayoutTextureNone=Texture'vegas.LedScores.slotled_dashes'
     PayoutTextureBlank=Texture'vegas.LedScores.slotled_blank'
}
